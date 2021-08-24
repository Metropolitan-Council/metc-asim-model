##########################################################################################################################
#
# Script to format CMAP raw HTS as inputs for Python based tour/trip processing tool (SPA)
#
#
# Leah Flake, March 2021
##########################################################################################################################


if (!"data.table" %in% installed.packages()) install.packages("data.table")
if (!"readxl" %in% installed.packages()) install.packages("readxl")
if (!"magrittr" %in% installed.packages()) install.packages("magrittr")
if (!"sf" %in% installed.packages()) install.packages("sf")
if (!"dplyr" %in% installed.packages()) install.packages("dplyr")
if (!"lubridate" %in% installed.packages()) install.packages("lubridate")
if (!"yaml" %in% installed.packages()) install.packages("yaml")
if (!"stringr" %in% installed.packages()) install.packages("stringr")
if (!"geosphere" %in% installed.packages()) install.packages("geosphere")

library(dplyr)
library(data.table)
library(lubridate)
library(readxl)
library(magrittr)
library(sf)
library(geosphere)
library(yaml)
library(stringr)

# Function for getting distance btw two points

get_distance_meters =
  function(location_1, location_2) {
    distance_meters =
      distHaversine(
        matrix(location_1, ncol = 2),
        matrix(location_2, ncol = 2))
    return(distance_meters)
  }


# load settings

args = commandArgs(trailingOnly = TRUE)

if(length(args) > 0){
  settings_file = args[1]
} else {
  settings_file = 'E:/Projects/Clients/MetCouncilASIM/tasks/survey_data_processing/metc_inputs.yml'
}

settings = yaml.load_file(settings_file)


data_dir = settings$data_dir
output_dir = file.path(settings$proj_dir, 'SPA_Inputs')

dir.create(output_dir, showWarnings = FALSE)
dir.create( file.path(settings$proj_dir, 'SPA_Processed'), showWarnings = FALSE) # also create processed folder if doesn't exist

hh_raw = fread(file.path(data_dir, 'household.csv'))
per_raw = fread(file.path(data_dir,'person.csv'))
trip_raw = fread(file.path(data_dir, 'trip.csv'))
day_raw = fread(file.path(data_dir, 'day.csv'))

# get TAZs from labeled data files
hh_labeled = fread(file.path(settings$labeled_data_dir, 'TravelBehaviorInventory2019Household.csv'))
per_labeled = fread(file.path(settings$labeled_data_dir, 'TravelBehaviorInventory2019Person.csv'))
trip_labeled = fread(file.path(settings$labeled_data_dir, 'TravelBehaviorInventory2019Trip.csv'))

# read updated weights
wt_dir = settings$updated_weights_dir
hh_weights = readRDS(file.path(wt_dir, 'hh_weights.rds'))
person_weights = readRDS(file.path(wt_dir, 'person_weights.rds'))
day_weights = readRDS(file.path(wt_dir, 'day_weights.rds'))
trip_weights = readRDS(file.path(wt_dir, 'trip_weights.rds'))


# Checking Value Counts
#----------------------------
print("Household size value counts: ")
hh_raw[, .N, num_people][order(num_people)]

print("Age value counts:")
per_raw[, .N, age][order(age)]

print("Trip Purpose value counts:")
trip_labeled[, .N, D_PURPOSE_IMPUTED][order(-N)]
trip_labeled[, .N, D_PURPOSE_CATEGORY_IMPUTED][order(-N)]


# Update weights
#---------------------------

hh_raw[, old_weight := hh_weight]
per_raw[, old_weight := person_weight]
day_raw[, old_weight := day_weight]
trip_raw[, old_weight := trip_weight]

hh_weights[, hh_id := as.integer(hh_id)]

hh_raw[hh_weights, hh_weight := i.hh_weight, on = .(hh_id)]
per_raw[person_weights, person_weight := i.person_weight, on = .(person_id)]
day_raw[day_weights, day_weight := i.day_weight, on = .(person_id, day_num)]

# for kids, use the new day weight; for adults use the new trip weight
trip_raw[per_raw, is_adult := ifelse(i.age >= 4, 1, 0), on = .(person_id)]
trip_raw[trip_weights, trip_weight := ifelse(is_adult == 1, i.trip_weight, NA), on = .(person_id, trip_num)]
trip_raw[day_weights, trip_weight := ifelse(is_adult == 0, i.day_weight, trip_weight), on = .(person_id, day_num)]



# Processing HH
#---------------------------

# codebook[NAME == 'hhinc']

hh_raw[, HH_INC_CAT := income_broad] 


# Add num workers
hh_raw[, HH_WORKERS := 0]
hh_raw[per_raw[employment_status %in% c(1:3), .N, .(hh_id)],  HH_WORKERS := i.N, on = .(hh_id)]

# add num drivers
hh_raw[, HH_DRIVERS := 0]
hh_raw[per_raw[license == 1, .N, .(hh_id)],  HH_DRIVERS := i.N, on = .(hh_id)]

hh_raw[hh_labeled, HH_ZONE_ID := i.HOME_TAZ, on = .(hh_id = HH_ID)]

HH = hh_raw[, .(SAMPN = hh_id,
                # HH_DOW = travday,
                HH_SIZE = num_people,
                HH_SIZE_CAT = fifelse(num_people >= 5, 5, num_people),
                HH_INC_CAT,
                HH_WORKERS,
                HH_WORKERS_CAT = fifelse(HH_WORKERS >= 3, 3, HH_WORKERS),
                HH_DRIVERS,
                HH_DRIVERS_CAT = fifelse(HH_DRIVERS >= 3, 3, HH_DRIVERS),
                HH_VEH_CAT = fifelse(num_vehicles >= 4, 4, num_vehicles),
                HHEXPFAC = hh_weight, 
                HH_UNO = 1,  
                HH_ZONE_ID,
                bg_geoid = home_bg,
                AREA = 0)]
  


# Processing PER
#---------------------------

# Person Variables
#------------------


per_raw[, AGE_CAT := age]
                       

per_raw[, SCHOL := fcase(school_type %in% c(1, 2), 1, # nanny/babysitter, 
                         school_type  == 3, 2, # nursery/preschool
                         school_type == 3, 3, # k-8
                         school_type %in% c(5, 6), 3, # k-8 if missing schol but age 6-12
                         school_type == 4 & age < 3, 3, # k-8 if homeschool < 15 (approximation)
                         school_type == 4 & age %in% c(4, 5), 4, # 9-12 homeschool < 15 (approximation)
                         school_type == 7, 4, # 9-12
                         school_type == 8, 5, #vocational/technical
                         school_type == 9, 6, #  2 yr
                         school_type == 10, 7, #  4 yr
                         school_type == 11, 8, #  grad
                         school_type == 997, 97, #  other
                         default = -9 # None/NA
                         )]

per_raw[, PER_EMPLY_LOC_TYPE := fcase(job_type == 1, 1, # one work location
                                      job_type == 3, 2, # wfh
                                      job_type %in%  c(2, 4), 3, # wplace varies
                                      default = 0)]

per_raw[, EMPLY := fcase(employment_status %in% c(1, 3), 1, # full time
                         employment_status == 2, 2, # part time
                         default = 3 # unemployed
                         )]

per_raw[, STUDE := fcase(student_status == 1, 1, # yes (ft)
                         student_status == 2, 1, # yes (pt)
                         student_status == 0, 0, # no
                         stude < 0 & age < 4, 1, # student if <18 and no answer
                         default = -9 # not answered
)]

per_raw[per_labeled, `:=` (PER_SCHL_ZONE_ID = SCHOOL_TAZ,
                          PER_WK_ZONE_ID = WORK_TAZ), on = .(hh_id = HH_ID, person_id = PERSON_ID)]


PER = per_raw[, .(PERNO = person_num,
                  SAMPN = hh_id,
                  PER_WEIGHT = person_weight,
                  AGE_CAT,
                  PER_GENDER = gender,  # 1 is male, 2 is female; does SPA care?
                  PER_EMPLY_LOC_TYPE,
                  EMPLY,
                  STUDE,
                  SCHOL,
                  PER_WFH = fifelse(PER_EMPLY_LOC_TYPE == 2, 1, 0),
                  PER_SCHL_ZONE_ID,
                  PER_WK_ZONE_ID,
                  WXCORD = work_lon,
                  PEREXPFAC = person_weight 
                  )]


# print(str(PER))

PER = PER[order(SAMPN, PERNO)]



PER[is.na(PER)] = 0



# Processing PLACE
#---------------------------


# add taz
trip_raw = trip_raw[trip_labeled[, .(TRIP_D_TAZ, TRIP_O_TAZ, TRIP_ID)], on = .(trip_id = TRIP_ID)]

# add times from labeled file
trip_raw[trip_labeled, `:=` (depart_time_hhmm = DEPART_TIME, depart_time_imputed_hhmm = DEPART_TIME_IMPUTED, 
                              arrive_time_hhmm = ARRIVE_TIME), on = .(trip_id = TRIP_ID)]

# fix times
trip_raw[, .(depart_time, depart_time_hhmm)]

trip_raw[hh_raw, participation_group := i.participation_group, on = .(hh_id)]
trip_raw[, DEP_HR := as.numeric(str_sub(depart_time_imputed_hhmm, 0, 2))]
trip_raw[, ARR_HR := as.numeric(str_sub(arrive_time_hhmm, 0, 2))]

# Patch incorrect time zone conversion
trip_raw[, DEP_HR := ifelse(participation_group == 2, DEP_HR, DEP_HR + 1)]
trip_raw[, ARR_HR := ifelse(participation_group == 2, ARR_HR, ARR_HR + 1)]

trip_raw[, DEP_MIN := as.numeric(str_sub(depart_time_imputed_hhmm, 4, 5))]
trip_raw[, ARR_MIN := as.numeric(str_sub(arrive_time_hhmm, 4, 5))]

trip_raw[DEP_HR == 24, DEP_HR := 0]
trip_raw[ARR_HR == 24, ARR_HR := 0]
trip_raw = trip_raw[order(hh_id, person_id, DEP_HR, DEP_MIN, ARR_HR, ARR_MIN)]


# add at-home record to create place file

# Order trip data and identify last trip

trip_raw[, trip_num_day := seq_len(.N), by = .(hh_id, person_num, day_num)]

trip_raw = trip_raw %>%
  group_by(hh_id, person_num, day_num, trip_num_day) %>%
  mutate(tripnum_max = max(trip_num_day)) %>%
  mutate(lasttrip = ifelse(trip_num_day==tripnum_max, 1, 0)) %>%
  ungroup() %>% setDT()

# Copy the first trips
trip_raw[, tripno_orig := trip_num]
trip_raw[, trip_num := seq_len(.N), .(hh_id, person_num)]

firsttrip = trip_raw[trip_num_day == 1]


# Add one place record for people who did not travel
# add for each day


per_without_trips = data.table()

for(day_num_i in 1:7){
  dt = per_raw[!trip_raw[day_num == day_num_i], on = .(person_num, hh_id)][, .(person_num, hh_id, 
                                                                              trip_num_day = 1,
                                                                              day_num = day_num_i,
                                                                        trip_weight = person_weight, 
                                                                        participation_group)]
  
  if(day_num_i != 1) {
    dt = dt[participation_group != 2]
 } 
  
  dt[hh_raw, travel_date := (day_num - 1) + i.first_travel_date, on = .(hh_id)]
  dt[, travel_dow := wday(travel_date, week_start = 1)]
  per_without_trips = rbindlist(list(per_without_trips, dt), use.names = TRUE, fill = TRUE)
}

per_without_trips[hh_raw, TRIP_D_TAZ := HH_ZONE_ID, on = .(hh_id)]
per_without_trips[hh_raw, TRIP_O_TAZ := HH_ZONE_ID, on = .(hh_id)]
per_without_trips[hh_raw, `:=` (o_lat = home_lat,
                                o_lon = home_lon,
                                d_lat = home_lat,
                                d_lon = home_lon), on = .(hh_id)]


firsttrip = rbindlist(list(firsttrip, per_without_trips), use.names = TRUE, fill = TRUE)



# Create initial PLACE file as a copy of TRIP data

place_raw = trip_raw %>%
  mutate(trip_num_day = trip_num_day + 1) %>%
  bind_rows(firsttrip) %>%
  arrange(hh_id, person_num,day_num, trip_num_day) %>%
  rename(PLACENO = trip_num_day) %>%
  
  # identify last trip for each person
  group_by(hh_id, person_num, day_num) %>%
  mutate(place_id_max = max(PLACENO)) %>%
  mutate(lasttrip = ifelse(PLACENO==place_id_max, 1, 0)) %>%
  ungroup() %>%
  
  # code all PLACE variables
  # Place variable = Trip destination variable
  # Place variable = Trip origin variable for duplicated first trip record
  
  # LAT/LON
  mutate(YCORD = ifelse(PLACENO==1, o_lat, d_lat)) %>%
  mutate(XCORD = ifelse(PLACENO==1, o_lon, d_lon)) %>%
  
  # TAZ
  mutate(TAZ = ifelse(PLACENO==1, TRIP_O_TAZ, TRIP_D_TAZ)) %>%
  
  # PURPOSE
  mutate(PURPOSE = ifelse(PLACENO==1, o_purpose_category_imputed, d_purpose_category_imputed)) %>%

  # MODE
  mutate(MODE = ifelse(PLACENO==1, -9, mode_type_predicted)) %>%
  mutate(MODE_survey = ifelse(PLACENO==1, -9, mode_type)) %>%

  # Arrival and Departure time at PLACE
  
  mutate(ARR_HR = ifelse(PLACENO==1, 3, ARR_HR)) %>%
  mutate(ARR_MIN = ifelse(PLACENO==1, 00, ARR_MIN)) %>%
  mutate(DEP_HR = lead(DEP_HR)) %>%
  mutate(DEP_HR = ifelse(lasttrip==1, 2, DEP_HR)) %>%
  mutate(DEP_MIN = lead(DEP_MIN)) %>%
  mutate(DEP_MIN = ifelse(lasttrip==1, 59, DEP_MIN)) %>%
  
  # Set all variables to zero that are not applicable to 1st PLACE
  mutate(TRAVELERS_TOTAL = ifelse(PLACENO==1, -1, num_travelers)) %>%
  mutate(TRAVELERS_HH = ifelse(PLACENO==1, -1, num_hh_travelers)) %>%
  mutate(HH_MEMBER1 = ifelse(PLACENO==1, 0, hh_member_1)) %>%
  mutate(HH_MEMBER2 = ifelse(PLACENO==1, 0, hh_member_2)) %>%
  mutate(HH_MEMBER3 = ifelse(PLACENO==1, 0, hh_member_3)) %>%
  mutate(HH_MEMBER4 = ifelse(PLACENO==1, 0, hh_member_4)) %>%
  mutate(HH_MEMBER5 = ifelse(PLACENO==1, 0, hh_member_5)) %>%
  mutate(HH_MEMBER6 = ifelse(PLACENO==1, 0, hh_member_6)) %>%
  mutate(HH_MEMBER7 = ifelse(PLACENO==1, 0, hh_member_7)) %>%
  mutate(HH_MEMBER8 = ifelse(PLACENO==1, 0, hh_member_8)) %>%
  mutate(HH_MEMBER9 = ifelse(PLACENO==1, 0, hh_member_9)) %>%
  mutate(HH_MEMBER10 = ifelse(PLACENO==1, 0, hh_member_10)) %>%
  mutate(HH_MEMBER11 = ifelse(PLACENO==1, 0, hh_member_11)) %>%
  mutate(DISTANCE = ifelse(PLACENO==1, 0, distance)) %>%
  
  
  # Select final set of variables
  select(hh_id, person_num, day_num, PLACENO, trip_num, travel_dow, YCORD, XCORD, TAZ, DISTANCE,
         PURPOSE, d_purpose_imputed, MODE, MODE_survey, mode_type_detailed, is_access, is_egress, vehicle_driver,
         ARR_HR, ARR_MIN, DEP_HR, DEP_MIN, TRAVELERS_TOTAL, 
         TRAVELERS_HH, HH_MEMBER1, HH_MEMBER2, HH_MEMBER3, HH_MEMBER4, HH_MEMBER5, HH_MEMBER6, HH_MEMBER7, 
         HH_MEMBER8, HH_MEMBER9, HH_MEMBER10, HH_MEMBER11, DISTANCE, trip_weight) %>%
  setDT()


place_raw[PLACENO == 1 & is.na(DEP_HR), `:=` (DEP_HR = 2, DEP_MIN = 59)]

place_raw[per_raw, SCHOL := i.SCHOL, on = .(hh_id, person_num)]
place_raw[per_raw, age := i.age, on = .(hh_id, person_num)]
place_raw[per_raw, license := i.license, on = .(hh_id, person_num)]
place_raw[, PURPOSE_original := PURPOSE]
place_raw[, PURPOSE := fcase(PURPOSE_original == 1, 0, # home 
                                      PURPOSE_original == 2 , 1, # work (fixed)
                                      PURPOSE_original == 4 & SCHOL %in% c(6:8), 2, # university
                                      PURPOSE_original == 4 & SCHOL == -9 & age == 4, 2, # university
                                      PURPOSE_original == 4 & SCHOL %in% c(1:5, 97), 3, # school if k=12 student
                                      PURPOSE_original == 4 & SCHOL == -9 & age <4, 3, # school if young age
                                      PURPOSE_original == 4 & SCHOL == -9 & age >4, 6, # other maint if adult not student
                                      PURPOSE_original == 5, 4, # escort
                                      PURPOSE_original  == 6, 5, # shop
                                      d_purpose_imputed %in% c(52, 56), 8, # social/visit
                                      PURPOSE_original == 7, 7, # eat out
                                      d_purpose_imputed %in% c(51, 53:55, 62), 9, # other disc
                                      PURPOSE_original == 3, 6, # work related --> other maint
                                      PURPOSE_original == 9, 6, # errand/other --> other maint
                                      PURPOSE_original == 10, 12, # change mode
                                     PURPOSE_original %in% c(12, 14), 6, # other maint
                             
                             
                             default = -9 
                                     )]

place_raw[PURPOSE == -1, PURPOSE := -9]
place_raw[PLACENO > 1, .N, PURPOSE][order(PURPOSE)]

# get trip weight from day weight for 0-trip days
place_raw[day_raw, trip_weight := ifelse(PLACENO == 1, i.day_weight, trip_weight), on = .(hh_id, person_num, day_num)]
place_raw[PLACENO == 1 & PURPOSE <0 & trip_weight >0,  PURPOSE := 0] # at home for 0-trip days with no prev purpose

# Assign SPA mode value to each column

# model modes:
SOV = 1L
HOV2	= 2L
HOV3	= 3L
WALK =	4L
BIKE	= 5L
TRANSIT_LOC	= 6L
TRANSIT_PREMIUM	= 7L
TAXI	= 8L
TNC_SINGLE	= 9L
TNC_POOL = 10L
SCHOOLBUS =	11L
OTHER = 12L

## check change mode/lack thereof

place_raw[, MODE := fcase( MODE_survey %in% c(8, 9) & (TRAVELERS_TOTAL == 1 | TRAVELERS_TOTAL < 0), SOV, # sov if party is 1 or unknown
                           MODE_survey %in% c(8, 9) & (TRAVELERS_TOTAL == 2), HOV2,
                           MODE_survey %in% c(8, 9) & TRAVELERS_TOTAL >= 3, HOV3, # hov3
                           MODE_survey %in% c(8, 9) & license %in% c(0, 995) & TRAVELERS_TOTAL == 1, HOV2, # hov2 if one-party passenger not licensed
                           MODE_survey == 12, WALK, 
                           MODE_survey == 10, BIKE,
                           MODE_survey == 7, TAXI,
                           MODE_survey == 6 & (mode_type_detailed == 19), TNC_SINGLE,
                           MODE_survey == 6 & (mode_type_detailed == 18), TNC_POOL,
                           MODE_survey == 2, SCHOOLBUS,
                           MODE_survey == 3, TRANSIT_LOC,
                           MODE_survey == 1, TRANSIT_PREMIUM,
                           MODE_survey == 4, TRANSIT_PREMIUM,
                           MODE_survey < 0, -9L, # missing/drop from dataset
                           default = OTHER)] # other
  

place_raw[, .N, MODE][order(MODE)]

place_raw[hh_raw, HOME_DIST := get_distance_meters(c(XCORD, YCORD), c(home_lon, home_lat)) * 0.000621371, on = .(hh_id) ]


# tottr - next 

place_raw[, TOTTR_NEXT := shift(TRAVELERS_TOTAL, n = 1L, type = 'lead'), by = .(hh_id, person_num)]

place_raw[is.na(TOTTR_NEXT), TOTTR_NEXT := 0]



PLACE = place_raw[(MODE != -9 | PLACENO == 1) & trip_weight > 0 & travel_dow %in% c(1:4), .(SAMPN = hh_id,
                      PLANO = PLACENO,
                      PERNO = person_num,
                      DOW = travel_dow,
                      TAZ,
                      DEP_HR,
                      DEP_MIN,
                      ARR_HR,
                      ARR_MIN,
                      TPURP = PURPOSE,
                      SURVEY_PURPOSE = PURPOSE_original,
                      PNAME = PURPOSE,
                      DRIVER = vehicle_driver%%995,
                      TOTTR = TRAVELERS_TOTAL,
                      TOTTR_NEXT,
                      MODE, 
                      SURVEY_MODE = MODE_survey,
                      PER1 = HH_MEMBER1%%995 ,
                      PER2 = HH_MEMBER2%%995 ,
                      PER3 = HH_MEMBER3%%995 ,
                      PER4 = HH_MEMBER4%%995 ,
                      PER5 = HH_MEMBER5%%995 ,
                      PER6 = HH_MEMBER6%%995 ,
                      PER7 = HH_MEMBER7%%995 ,
                      PER8 = HH_MEMBER8%%995 ,
                      PER9 = HH_MEMBER9%%995 ,
                      PER10 =HH_MEMBER10%%995, 
                      PER11 =HH_MEMBER11%%995,
                      HHMEM = TRAVELERS_HH,
                      XCORD,
                      YCORD,
                      HOME_DIST,
                      DISTANCE,
                      IS_TRIP = fifelse(PLACENO == 1, 0, 1),
                      TRIP_WEIGHT = trip_weight
)]

# Process per1 to perN like SEMCOG to see if that helps joint tours


PLACE_backup = copy(PLACE)
# 
# for(i in 1:11) {
#   colname = paste0('PER', i)
# 
#   PLACE[, paste0(colname, '_orig') := get(colname)]
#   PLACE[, paste0(colname, '') := 0]
# }
# 
# for(i in 1:9) {
#   colname = paste0('PER', i)
#   prev_colname = paste0('PER', i-1)
#   if(prev_colname == 'PER0') {prev_colname = 'PER1'}
#   
# 
#   PLACE[, paste0(colname, '') := fcase(HHMEM <= i, 0,
#                       PER1_orig == 1 & get(prev_colname)!= 1 & PERNO != 1, 1,
#                       PER2_orig == 1 & get(prev_colname) != 2 & PERNO != 2 , 2,
#                       PER3_orig == 1 & get(prev_colname) != 3 & PERNO != 3 , 3,
#                       PER4_orig == 1 & get(prev_colname) != 2 & PERNO != 2, 4,
#                       PER5_orig == 1 & get(prev_colname) != 5 & PERNO != 5, 5,
#                       PER6_orig == 1 & get(prev_colname) != 6 & PERNO != 6, 6,
#                       PER7_orig == 1 & get(prev_colname) != 7 & PERNO != 7, 7,
#                       PER8_orig == 1 & get(prev_colname) != 8 & PERNO != 8, 8,
#                       PER9_orig == 1 & get(prev_colname) != 9 & PERNO != 9, 9,
#                       PER10_orig == 1 & get(prev_colname) != 10 & PERNO != 10, 10,
#                       PER11_orig == 1 & get(prev_colname) != 11 & PERNO != 11, 11,
#                       default = 0
#                     )]
# }

PLACE[HHMEM == 995, HHMEM := -1]


#=========================================================================================================================
# CREATE INPUTS FOR Python SPA
#=========================================================================================================================



HH[is.na(HH)] = -9
PER[is.na(PER)] = -9
PLACE[is.na(PLACE)] = -9

str(HH)
str(PER)
str(PLACE)



# Checking to see if every person in PER file is in PLACE file:
# -----------------
num_persons_in_per = nrow(unique(PER[, .(SAMPN, PERNO)]))
paste0("Distinct people in PER file: ", num_persons_in_per)
num_persons_in_PLACE = nrow(unique(PLACE[, .(SAMPN, PERNO)]))
paste0("Distict people in PLACE file: ", num_persons_in_PLACE)


# Writing Output
# -----------------

HH_TEST = HH[1:400]
PER_TEST = PER[SAMPN %in% HH_TEST[, SAMPN]]

write.csv(HH_TEST, file.path(output_dir, "HH_SPA_INPUT.csv"), row.names = F)
write.csv(PER_TEST, file.path(output_dir, "PER_SPA_INPUT.csv"), row.names = F)

for (i in 1:4) {
  write.csv(PLACE[DOW==i & SAMPN %in% HH_TEST[, SAMPN],], file.path(settings$SPA_input_dir, paste0('place_', as.character(i), ".csv")), row.names = F)
}

# # #
write.csv(HH, file.path(output_dir, "HH_SPA_INPUT.csv"), row.names = F)
write.csv(PER, file.path(output_dir, "PER_SPA_INPUT.csv"), row.names = F)

for (i in 1:4) {
  write.csv(PLACE[DOW==i,], file.path(output_dir, paste0('place_', as.character(i), ".csv")), row.names = F)
}

