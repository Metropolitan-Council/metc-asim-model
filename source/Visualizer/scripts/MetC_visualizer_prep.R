#######################################################
### Script for summarizing CMAP HTS
### Author: Binny M Paul, binny.paul@rsginc.com; Leah Flake
### March 2021
### Copied from previous processing scripts
#######################################################
start_time = Sys.time()
R_LIBRARY = Sys.getenv("R_LIBRARY")
.libPaths(c(R_LIBRARY, .libPaths()))
#-------------------------------------------------------------------------------
# person trips to be used for tour/trip mode choice
# unique joint tours to be used for all joint tour level summaries
# unique joint tours to be used for all summaries created for joint purposes (e.g., jMain & jDisc)
# person trips/tours to be used for all totals
#-------------------------------------------------------------------------------

# Following standard purpose/market segmentation coding to be used for tours/trips
#-------------------------------------------------------------------------------

# Recode tour purpose into unique market segmentations
# Work   - [No Subtours ], [All            ], [TOURPURP - (1,10)    ] 
# Univ   - [No Subtours ], [All            ], [TOURPURP - (2)       ] 
# Schl   - [No Subtours ], [All            ], [TOURPURP - (3)       ]
# iEsc   - [No Subtours ], [All            ], [TOURPURP - (4)       ]
# iShop  - [No Subtours ], [Non-Fully_Joint], [TOURPURP - (5)       ]
# iMain  - [No Subtours ], [Non-Fully_Joint], [TOURPURP - (6)       ]
# iEati  - [No Subtours ], [Non-Fully_Joint], [TOURPURP - (7)       ]
# iVisi  - [No Subtours ], [Non-Fully_Joint], [TOURPURP - (8)       ]
# iDisc  - [No Subtours ], [Non-Fully_Joint], [TOURPURP - (9)       ]   
# jShop  - [No Subtours ], [Fully_Joint    ], [TOURPURP - (5)       ]
# jMain  - [No Subtours ], [Fully_Joint    ], [TOURPURP - (6)       ]
# jEati  - [No Subtours ], [Fully_Joint    ], [TOURPURP - (7)       ]
# jVisi  - [No Subtours ], [Fully_Joint    ], [TOURPURP - (8)       ]
# jDisc  - [No Subtours ], [Fully_Joint    ], [TOURPURP - (9)       ]   
# AtWork - [All Subtours], [All            ], [TOURPURP - (All)     ]    
# Other  - [No Subtours ], [All            ], [TOURPURP - (11,12,13)] 

# NOTES FROM THE MODEL DEVELOPMENT DEPARTMENT
# In this script, "dow" is used incorrectly. It should be assumed to be the day id, NOT the
# day of week. There is no filtering based on this (apparently it was designed to never
# import weekends in the first place).
#
# Note that the processing was revised to use day id and use the day weights to ensure
# that weekend days were not used, as such dow_num CAN hit 7.
#
# SCHOOL CHILD CDAP
#
# Due to significant data collection during summer months, the school ()

## Libraries
############
if (!"devtools" %in% installed.packages()) install.packages("devtools", repos='http://cran.us.r-project.org')
library(devtools)
if(!"lattice" %in% installed.packages()) devtools::install_version("latticeExtra", version="0.6-28", repos='http://cran.us.r-project.org')
if (!"omxr" %in% installed.packages())  {devtools::install_github("gregmacfarlane/omxr")}
library(omxr)
if (!"plyr" %in% installed.packages()) install.packages("plyr", repos='http://cran.us.r-project.org')
library(plyr)
if (!"weights" %in% installed.packages()) install.packages("weights", repos='http://cran.us.r-project.org')
library(weights)
if (!"reshape2" %in% installed.packages()) install.packages("reshape2", repos='http://cran.us.r-project.org')
library(reshape2)
if (!"data.table" %in% installed.packages()) install.packages("data.table", repos='http://cran.us.r-project.org')
library(data.table)
if (!"rgeos" %in% installed.packages()) install.packages("rgeos", repos='http://cran.us.r-project.org')
library(rgeos)
if (!"sp" %in% installed.packages()) install.packages("sp", repos='http://cran.us.r-project.org')
library(sp)
if (!"rgdal" %in% installed.packages()) install.packages("rgdal", repos='http://cran.us.r-project.org')
library(rgdal)
if (!"stringr" %in% installed.packages()) install.packages("stringr", repos='http://cran.us.r-project.org')
library(stringr)
if (!"yaml" %in% installed.packages()) install.packages("yaml", repos='http://cran.us.r-project.org')
library(yaml)
if (!"sf" %in% installed.packages()) install.packages("sf", repos='http://cran.us.r-project.org')
library(sf)
if (!"tidycensus" %in% installed.packages()) install.packages("sf", repos='http://cran.us.r-project.org')
library(tidycensus)


#if (!"Hmisc" %in% installed.packages()) install.packages("Hmisc", repos='http://cran.us.r-project.org')


## User Inputs
#######################################################################################

include_delivery_trips = F

# Directories
args = commandArgs(trailingOnly = TRUE)

if(length(args) > 0){
  settings_file = args[1]
} else {
  settings_file = 'E:\\Met_Council\\metc-asim-model\\source\\survey_data_processing\\metc_inputs_phase2.yml'
}

settings = yaml.load_file(settings_file)

WD                   = settings$visualizer_summaries
gis_dir              = settings$zone_dir
HTS_raw_Dir          = settings$data_dir
Survey_Dir           = file.path(settings$proj_dir, 'SPA_Inputs')
Survey_Processed_Dir = file.path(settings$proj_dir, 'SPA_Processed')
# SkimDir              = "E:/Projects/Clients/MWCOG/Models/CGV2_3_75_Visualize2045_CLRP_Xmittal/2019_Final/"
# geogXWalkDir         = "E:/projects/clients/mtc/data/Trip End Geocodes"
zone_dir = settings$zone_dir
print('Reading input files...')



## Read Data
hh                   = fread(file.path(Survey_Dir, "HH_SPA_INPUT.csv"))
per                  = fread(file.path(Survey_Dir, "PER_SPA_INPUT.csv"))
if(file.exists(file.path(HTS_raw_Dir, "person.csv"))){
	per_raw = fread(file.path(HTS_raw_Dir, "person.csv"))
}else{
	per_raw = fread(file.path(HTS_raw_Dir, "TBI21_PERSON_RAW_202308281334.csv"))
}


# tours                = fread(file.path(Survey_Processed_Dir, "tours.csv"))[!HH_ID %in% weekend_ids]
# trips                = fread(file.path(Survey_Processed_Dir, "trips.csv"))[!HH_ID %in% weekend_ids]
# jutrips              = fread(file.path(Survey_Processed_Dir, "unique_joint_ultrips.csv"))[!HH_ID %in% weekend_ids]
# jtours               = fread(file.path(Survey_Processed_Dir, "unique_joint_tours.csv"))[!HH_ID %in% weekend_ids]
# proc_hh              = fread(file.path(Survey_Processed_Dir, "day1/households.csv"))

processedPerson      = data.table(HH_ID = numeric(),PER_ID  = numeric())
proc_hh              = data.table(HH_ID = numeric())
perDays = data.table(HH_ID = numeric(),PER_ID  = numeric(), dow = numeric())
hhDays = data.table(HH_ID = numeric(), dow = numeric())

trips = data.table()
tours = data.table()
jutrips = data.table()
jtours = data.table()
place = data.table()

for(dow in c(1:7)){
# for(dow in c(1:4)){
  cat(dow)
  
  per_data = fread(file.path(Survey_Processed_Dir, paste0('day', as.character(dow)), "persons.csv"))
  perDays = rbindlist(list(perDays, data.frame(HH_ID = per_data$HH_ID, PER_ID = per_data$PER_ID, dow = dow)))
  
  #per_data = per_data[!processedPerson, on = .(HH_ID, PER_ID)]
  processedPerson = rbindlist(list(processedPerson, per_data), use.names = TRUE, fill = TRUE)
  
  hh_data   = fread(file.path(Survey_Processed_Dir, paste0('day', as.character(dow)), "households.csv"))
  hhDays = rbindlist(list(hhDays, data.frame(HH_ID = hh_data$HH_ID, dow = dow)))
  hh_data = hh_data[!proc_hh, on = .(HH_ID)]
  
  proc_hh = rbindlist(list(processedPerson, per_data), use.names = TRUE, fill = TRUE)
  place_data = fread(file.path(Survey_Dir, paste0('place_', as.character(dow), ".csv")))
  place_data[, dow_num := dow]
  place = rbindlist(list(place, place_data), use.names = TRUE, fill = TRUE)
  
  trip_data = fread(file.path(Survey_Processed_Dir,  paste0('day', as.character(dow)), "trips.csv"))
  trip_data[, dow_num := dow]
  
  trips = rbindlist(list(trips, trip_data), use.names = TRUE, fill = TRUE)
  
  tour_data = fread(file.path(Survey_Processed_Dir,  paste0('day', as.character(dow)), "tours.csv"))
  tour_data[, dow_num := dow]
  
  tours = rbindlist(list(tours, tour_data), use.names = TRUE, fill = TRUE)
  
  jtour_data = fread(file.path(Survey_Processed_Dir,  paste0('day', as.character(dow)), "unique_joint_tours.csv"))
  jtour_data[, dow_num := dow]
  
  jtours = rbindlist(list(jtours, jtour_data), use.names = TRUE, fill = TRUE)
  
  jutrip_data = fread(file.path(Survey_Processed_Dir,  paste0('day', as.character(dow)), "unique_joint_ultrips.csv"))
  jutrip_data[, dow_num := dow]
  
  jutrips = rbindlist(list(jutrips, jutrip_data), use.names = TRUE, fill = TRUE)

}


zones = st_read(file.path(zone_dir, "TAZ2010.shp"))
zones_dt = setDT(zones)
xwalk <- zones
xwalk$COUNTY_NAME <- as.character(xwalk$CO_NAME)

# read updated weights #### 
# wt_dir = settings$updated_weights_dir
# hh_weights = readRDS(file.path(wt_dir, 'hh_weights.rds'))
# person_weights = readRDS(file.path(wt_dir, 'person_weights.rds'))
# day_weights = readRDS(file.path(wt_dir, 'day_weights.rds'))
# trip_weights = readRDS(file.path(wt_dir, 'trip_weights.rds'))

#NOTE: these are not being used, but the weights already in the HH file are the same

#CHECK: do we have too many persons?
#per = per[(per$SAMPN*10+per$PERNO) %in% (processedPerson$HH_ID*10+processedPerson$PER_ID),]


## Prepare Data Files
#######################################################################################
setwd(WD)

print(paste("Saving files to", WD))

library(omxr)
skim_file = file.path(settings$skims_dir, settings$skims_filename)
print(paste('Processing Distance Skim Matrix...', skim_file))
skimMat <- read_omx(skim_file, settings$skims_name)
DST_SKM <- reshape2::melt(skimMat)
colnames(DST_SKM) <- c("o", "d", "dist")

hh$hhtaz = hh$HH_ZONE_ID
per$pwtaz = per$PER_WK_ZONE_ID
per$pstaz = per$PER_SCHL_ZONE_ID

hh$hhtaz[is.na(hh$hhtaz)] = 0
per$pwtaz[is.na(per$pwtaz)] = 0
per$pstaz[is.na(per$pstaz)] = 0

# Define other variables

pertypeCodes = data.frame(code = c(1,2,3,4,5,6,7,8,"All"), 
                           name = c("FT Worker", "PT Worker", "Univ Stud", "Non Worker", "Retiree", "Driv Stud", "NonDriv Stud", "Pre-School", "All"))


processedPerson[per, PER_WEIGHT := i.PEREXPFAC, on = .(HH_ID = SAMPN, PER_ID = PERNO)]
trips[per, PER_WEIGHT := i.PEREXPFAC, on = .(HH_ID = SAMPN, PER_ID = PERNO)]
tours[per, PER_WEIGHT := i.PEREXPFAC, on = .(HH_ID = SAMPN, PER_ID = PERNO)]
jtours[hh, HH_WEIGHT := i.HHEXPFAC, on = .(HH_ID = SAMPN)]


trips[place, trip_weight := i.TRIP_WEIGHT, on = .(HH_ID = SAMPN, PER_ID = PERNO, DEST_PLACENO = PLANO, dow_num = dow_num)]

trips[, avg_tour_weight := mean(trip_weight), by = .(HH_ID, PER_ID, TOUR_ID)]
tours[trips, trip_weight := i.avg_tour_weight, on = .(HH_ID, PER_ID, TOUR_ID)]

# Join county name
county_fips_lookup = fread(file.path(settings$proj_dir, 'county_lookup.csv'))



place[, O_TAZ := data.table::shift(TAZ, type = 'lag'), by = .(SAMPN, PERNO)]
place[zones_dt, OCOUNTY := i.CO_NAME, on = .(O_TAZ = TAZ)]
place[zones_dt, DCOUNTY := i.CO_NAME, on = .(TAZ = TAZ)]

trips[place, OCOUNTY := i.OCOUNTY, on = .(HH_ID = SAMPN, PER_ID = PERNO, DEST_PLACENO = PLANO)]
trips[place, DCOUNTY := i.DCOUNTY, on = .(HH_ID = SAMPN, PER_ID = PERNO, DEST_PLACENO = PLANO)]

hh[zones_dt, HDISTRICT := i.CO_NAME, on = .(HH_ZONE_ID = TAZ)]
per[hh, HDISTRICT := i.HDISTRICT, on = .(SAMPN)]
per[zones_dt, WDISTRICT := i.CO_NAME, on = .(PER_WK_ZONE_ID = TAZ)]
per[zones_dt, SCHOOL_COUNTY := i.CO_NAME, on = .(PER_SCHL_ZONE_ID = TAZ)]

# Join weight

hh$finalweight = hh$HHEXPFAC
# hh$tourDays = hhDays$dow[match(hh$SAMPN, hhDays$HH_ID)]
# hh$tourDays[is.na(hh$tourDays)] = 0
# hh = hh[!is.na(hh$tourDays)]
hh$adjFinalWeight = hh$HHEXPFAC #/ hh$tourDays
hh$adjFinalWeight[is.na(hh$adjFinalWeight)] = 0

per$finalweight = per$PEREXPFAC
processedPerson$finalweight = processedPerson$PER_WEIGHT

trips$finalweight = trips$trip_weight
tours$finalweight = tours$trip_weight
jtours$finalweight = jtours$HH_WEIGHT 

names(processedPerson)[names(processedPerson)=="HH_ID"] = "HHID"
names(processedPerson)[names(processedPerson)=="PER_ID"] = "PERID"

hh$HHVEH = hh$HH_VEH
hh$HHVEH[hh$HH_VEH >= 4] = 4

hh$HHSIZE = hh$HH_SIZE
hh$HHSIZE[hh$HH_SIZE >= 5] = 5

#Adults in the HH
adults = plyr::count(per[per$AGE>=4 ,], c("SAMPN"))
hh$ADULTS = adults$freq[match(hh$SAMPN, adults$SAMPN)]
hh$ADULTS[is.na(hh$ADULTS)] = 0


per[processedPerson, PERTYPE := i.PERSONTYPE, on = .(SAMPN = HHID, PERNO = PERID)]
per$hhtaz = hh$HH_ZONE_ID[match(per$SAMPN, hh$SAMPN)]


# Compute tour days to adjust rates (many days -> one day)
tourDays = as.data.frame(table(tours$HH_ID*1000+tours$PER_ID*10+tours$dow_num), stringsAsFactors = F)
per$tourDays = tourDays$Freq[match(per$SAMPN*100+per$PERNO, as.integer(as.numeric(tourDays$Var1)/10))]
per[is.na(per$tourDays),]$tourDays = 0

##-------Compute Summary Statistics-------#### 

print("Computing summary statistics...")

# Auto ownership
autoOwnership = plyr::count(hh[!is.na(hh$HHVEH),], c("HHVEH"), "finalweight")
write.csv(autoOwnership, "autoOwnership_region.csv", row.names = TRUE)

hh$COUNTY <- xwalk$COUNTY_NAME[match(hh$home_zone_id, xwalk$TAZ)]
autoOwnershipCY <- rbind(count(hh, c("COUNTY", "HHVEH"), "finalweight"), 
                         cbind(COUNTY= "Total", count(hh, "HHVEH", "finalweight")))
#autoOwnershipCY <- cast(autoOwnershipCY, COUNTY~HHVEH, value = "freq", sum)
write.csv(autoOwnershipCY, file.path(WD, "autoOwnership.csv"), row.names = F)

# Persons by person type
pertypeDistbn = plyr::count(per[!is.na(per$PERTYPE),], c("PERTYPE"), "finalweight")
write.csv(pertypeDistbn, "pertypeDistbn.csv", row.names = TRUE)

# Mandatory DC
# emp_loc_type - 1:fixed, 2:WFH, 3: varies
# per$empl_loc_type = per_raw$empl_loc_type[match(paste(per$SAMPN, per$PERNO, sep = "-"), paste(per_raw$sampno, per_raw$perno, sep = "-"))]
per$empl_loc_type = per$PER_EMPLY_LOC_TYPE
per$empl_loc_type[is.na(per$empl_loc_type)] = 0
workers = per[PER_WK_ZONE_ID > 0 & (PERTYPE<=3 | PERTYPE==6) & empl_loc_type!=2, c("SAMPN", "PERNO", "hhtaz", "PER_WK_ZONE_ID", "empl_loc_type","PERTYPE", "HDISTRICT", "WDISTRICT", "finalweight")]

# Work from home [for each district and total]
per$worker[per$PERTYPE<=2 | (per$PERTYPE==3 & !is.na(per$pwtaz)) | (per$PERTYPE==6 & !is.na(per$pwtaz))] = 1
per$worker[is.na(per$worker)] = 0
per$wfh[per$empl_loc_type==2] = 1
per$wfh[is.na(per$wfh)] = 0
# Telecommute Frequency?
per$person_id = as.integer(100* per$SAMPN + per$PERNO)

per_raw[per, finalweight := i.finalweight, on = .(person_id)]
per_raw[per, worker := i.worker, on = .(person_id)]
per_raw[per, wfh := i.wfh, on = .(person_id)]

per_raw$telecommute_frequency = "No_Telecommute"
per_raw[per_raw$telework_freq == 5,]$telecommute_frequency = "1_day_week"
per_raw[per_raw$telework_freq == 4,]$telecommute_frequency = "2_3_days_week"
per_raw[per_raw$telework_freq < 4,]$telecommute_frequency = "4_days_week"
per_raw[per_raw$telework_freq < 0,]$telecommute_frequency = "No_Telecommute"

workers$WDIST = DST_SKM$dist[match(paste(workers$hhtaz, workers$PER_WK_ZONE_ID, sep = "-"), paste(DST_SKM$o, DST_SKM$d, sep = "-"))]
workers = na.omit(workers)
print(workers)


students = per[per$pstaz>0, c("SAMPN", "PERNO", "hhtaz", "pstaz", "PERTYPE", "HDISTRICT", "finalweight")]
students$SDIST = DST_SKM$dist[match(paste(students$hhtaz, students$pstaz, sep = "-"), paste(DST_SKM$o, DST_SKM$d, sep = "-"))]

students = na.omit(students)

# code distance bins
workers$distbin = cut(workers$WDIST, breaks = c(seq(0,50, by=1), 9999), labels = F, right = F)
students$distbin = cut(students$SDIST, breaks = c(seq(0,50, by=1), 9999), labels = F, right = F)

# alternate distbin profile for workers
#workers$distbin = cut(workers$WDIST, breaks = c(0, 3, 5, 10, 15, 20, 30, 40, 50, 60, 9999), labels = F, right = F)


distBinCat = data.frame(distbin = seq(1,51, by=1))
#distBinCat = data.frame(distbin = seq(1,10, by=1))


# compute TLFDs by district and total
# question: use something else instead of "district"?

# tlfd_work = ddply(workers[,c("HDISTRICT", "distbin", "finalweight")], c("HDISTRICT", "distbin"), summarise, work = sum((HDISTRICT>0)*finalweight))
tlfd_work = ddply(workers[,c("HDISTRICT", "distbin", "finalweight")], c("HDISTRICT", "distbin"), summarise, work = sum(finalweight))
tlfd_work = reshape::cast(tlfd_work, distbin ~ HDISTRICT, value = "work", sum)
tlfd_work$Total = rowSums(tlfd_work[,!colnames(tlfd_work) %in% c("distbin")])
tlfd_work_df = merge(x = distBinCat, y = tlfd_work, by = "distbin", all.x = TRUE)
tlfd_work_df[is.na(tlfd_work_df)] = 0

# tlfd_univ = ddply(students[students$PERTYPE==3,c("HDISTRICT", "distbin", "finalweight")], c("HDISTRICT", "distbin"), summarise, univ = sum((HDISTRICT>0)*finalweight))
tlfd_univ = ddply(students[students$PERTYPE==3,c("HDISTRICT", "distbin", "finalweight")], c("HDISTRICT", "distbin"), summarise, univ = sum(finalweight))
tlfd_univ = reshape::cast(tlfd_univ, distbin~HDISTRICT, value = "univ", sum)
tlfd_univ$Total = rowSums(tlfd_univ[,!colnames(tlfd_univ) %in% c("distbin")])
tlfd_univ_df = merge(x = distBinCat, y = tlfd_univ, by = "distbin", all.x = TRUE)
tlfd_univ_df[is.na(tlfd_univ_df)] = 0

# tlfd_schl = ddply(students[students$PERTYPE>=6,c("HDISTRICT", "distbin", "finalweight")], c("HDISTRICT", "distbin"), summarise, schl = sum((HDISTRICT>0)*finalweight))
tlfd_schl = ddply(students[students$PERTYPE>=6,c("HDISTRICT", "distbin", "finalweight")], c("HDISTRICT", "distbin"), summarise, schl = sum(finalweight))
tlfd_schl = reshape::cast(tlfd_schl, distbin~HDISTRICT, value = "schl", sum)
tlfd_schl$Total = rowSums(tlfd_schl[,!colnames(tlfd_schl) %in% c("distbin")])
tlfd_schl_df = merge(x = distBinCat, y = tlfd_schl, by = "distbin", all.x = TRUE)
tlfd_schl_df[is.na(tlfd_schl_df)] = 0

write.csv(tlfd_work_df, "workTLFD.csv", row.names = F)
write.csv(tlfd_univ_df, "univTLFD.csv", row.names = F)
write.csv(tlfd_schl_df, "schlTLFD.csv", row.names = F)

cat("\n Average distance to workplace (Total): ", weighted.mean(workers$WDIST, workers$finalweight, na.rm = TRUE))
cat("\n Average distance to university (Total): ", weighted.mean(students$SDIST[students$PERTYPE == 3], students$finalweight[students$PERTYPE == 3], na.rm = TRUE))
cat("\n Average distance to school (Total): ", weighted.mean(students$SDIST[students$PERTYPE >= 6 & students$PERTYPE <= 7], students$finalweight[students$PERTYPE >= 6 & students$PERTYPE <= 7], na.rm = TRUE), "\n")

## Output avg trip lengths for visualizer
# district_df = data.frame(HDISTRICT = c(districtList, "Total"))
districtList = unique(hh$HDISTRICT)
district_df = data.frame(HDISTRICT = c(districtList, "Total"))
workTripLengths = ddply(workers[,c("HDISTRICT", "WDIST", "finalweight")], c("HDISTRICT"), summarise, work = weighted.mean(WDIST,finalweight))
totalLength     = data.frame("Total", weighted.mean(workers$WDIST,workers$finalweight))
colnames(totalLength) = colnames(workTripLengths)
workTripLengths = rbind(workTripLengths, totalLength)
workTripLengths_df = merge(x = district_df, y = workTripLengths, by = "HDISTRICT", all.x = TRUE)
workTripLengths_df[is.na(workTripLengths_df)] = 0

univTripLengths = ddply(students[students$PERTYPE==3,c("HDISTRICT", "SDIST", "finalweight")], c("HDISTRICT"), summarise, univ = weighted.mean(SDIST,finalweight))
totalLength     = data.frame("Total", weighted.mean(students$SDIST[students$PERTYPE==3], students$finalweight[students$PERTYPE==3]))
colnames(totalLength) = colnames(univTripLengths)
univTripLengths = rbind(univTripLengths, totalLength)
univTripLengths_df = merge(x = district_df, y = univTripLengths, by = "HDISTRICT", all.x = TRUE)
univTripLengths_df[is.na(univTripLengths_df)] = 0

schlTripLengths = ddply(students[students$PERTYPE>=6,c("HDISTRICT", "SDIST", "finalweight")], c("HDISTRICT"), summarise, schl = weighted.mean(SDIST,finalweight))
totalLength     = data.frame("Total", weighted.mean(students$SDIST[students$PERTYPE>=6], students$finalweight[students$PERTYPE>=6]))
colnames(totalLength) = colnames(schlTripLengths)
schlTripLengths = rbind(schlTripLengths, totalLength)
schlTripLengths_df = merge(x = district_df, y = schlTripLengths, by = "HDISTRICT", all.x = TRUE)
schlTripLengths_df[is.na(schlTripLengths_df)] = 0

mandTripLengths = cbind(workTripLengths_df, univTripLengths_df$univ, schlTripLengths_df$schl)
colnames(mandTripLengths) = c("District", "Work", "Univ", "Schl")
# rearranging such that the "Total" comes at the end
mandTripLengths = rbind(mandTripLengths[!(mandTripLengths$District == "Total"),], mandTripLengths[(mandTripLengths$District == "Total"),])
write.csv(mandTripLengths, "mandTourLengths.csv", row.names = F)



districtWorkers = ddply(per[per$worker==1,c("HDISTRICT", "finalweight")], c("HDISTRICT"), summarise, workers = sum(finalweight))
districtWorkers_df = merge(x = data.frame(HDISTRICT = districtList), y = districtWorkers, by = "HDISTRICT", all.x = TRUE)
districtWorkers_df[is.na(districtWorkers_df)] = 0

districtWfh     = ddply(per[per$worker==1 & per$wfh==1,c("HDISTRICT", "finalweight")], c("HDISTRICT"), summarise, wfh = sum(finalweight))
districtWfh_df = merge(x = data.frame(HDISTRICT = districtList), y = districtWfh, by = "HDISTRICT", all.x = TRUE)
districtWfh_df[is.na(districtWfh_df)] = 0

wfh_summary     = cbind(districtWorkers_df, districtWfh_df$wfh)
colnames(wfh_summary) = c("District", "Workers", "WFH")
totalwfh        = data.frame("Total", sum((per$worker==1)*per$finalweight), sum((per$worker==1 & per$wfh==1)*per$finalweight))
colnames(totalwfh) = colnames(wfh_summary)
wfh_summary = rbind(wfh_summary, totalwfh)
# Let the Census script do this
write.csv(wfh_summary, "wfh_summary.csv", row.names = F)

tc_summary = ddply(per_raw[per_raw$worker == 1 & per_raw$wfh == 0, c("telecommute_frequency", "finalweight")], c("telecommute_frequency"), summarise, freq = sum(finalweight))
write.csv(tc_summary, "telecommuteFrequency.csv", row.names = T)


# County-County Flows
countyFlowWorkers = per[per$PER_WK_ZONE_ID > 0 & per$PER_WK_ZONE_ID < 9999 & per$EMPLY<3,] 
countyFlowWorkers = countyFlowWorkers[WDISTRICT %in% countyFlowWorkers$HDISTRICT]
countyFlows = xtabs(finalweight~HDISTRICT+WDISTRICT, data = countyFlowWorkers)
countyFlows[is.na(countyFlows)] = 0
countyFlows = addmargins(as.table(countyFlows))

countyFlows = as.data.frame.matrix(countyFlows)
colnames(countyFlows)[colnames(countyFlows)=="Sum"] = "Total"
rownames(countyFlows)[rownames(countyFlows)=="Sum"] = "Total"

countyFlowCircle = setDT(countyFlowWorkers)[, .(value = sum(finalweight)), by = .(from = HDISTRICT, to = WDISTRICT)]

# setnames(countyFlows, "rn", "X")

write.csv(countyFlows, "countyFlows.csv", row.names = F)
write.csv(countyFlowCircle, "countyFlowCircle.csv", row.names = F)

# wplace_employed = count(countyFlowWorkers, vars='WPLACE', wt_var='finalweight')  # what is WPLACE?

#Workers in the HH
workersHH = plyr::count(per[!is.na(per$pwtaz) & !is.na(per$PERTYPE) & !is.na(per$empl_loc_type),], c("SAMPN"), "(per$PERTYPE<=2) | (per$PERTYPE==3 & per$pwtaz>0)")
hh$WORKERS = workersHH$freq[match(hh$SAMPN, workersHH$SAMPN)]
hh$WORKERS[is.na(hh$WORKERS)] = 0


# Process Tour file
#------------------
print("Processing tour file...")
#tours$finalweight = hh$finalweight[match(tours$HH_ID, hh$SAMPN)] #NOTE: do not uncomment - it skyrockets tours
tours = tours[!is.na(tours$finalweight),]
tours = tours[tours$TOURPURP > 0,]
tours$PERTYPE = per$PERTYPE[match(tours$HH_ID*100+tours$PER_ID, per$SAMPN*100+per$PERNO)]
#tours$DISTMILE = tours$dist/5280
tours$HHVEH = hh$HHVEH[match(tours$HH_ID, hh$SAMPN)]
tours$ADULTS = hh$ADULTS[match(tours$HH_ID, hh$SAMPN)]
#tours$AUTOSUFF[tours$HHVEH == 0] = 0
#tours$AUTOSUFF[tours$HHVEH < tours$ADULTS & tours$HHVEH > 0] = 1
#tours$AUTOSUFF[tours$HHVEH >= tours$ADULTS & tours$HHVEH > 0] = 2
tours$WORKERS = hh$WORKERS[match(tours$HH_ID, hh$SAMPN)]
tours$AUTOSUFF[tours$HHVEH == 0] = 0
tours$AUTOSUFF[tours$HHVEH < tours$WORKERS & tours$HHVEH > 0] = 1
tours$AUTOSUFF[tours$HHVEH >= tours$WORKERS & tours$HHVEH > 0] = 2

tours$TOTAL_STOPS = tours$OUTBOUND_STOPS + tours$INBOUND_STOPS

tours$SKIMDIST = DST_SKM$dist[match(paste(tours$ORIG_TAZ, tours$DEST_TAZ, sep = "-"), paste(DST_SKM$o, DST_SKM$d, sep = "-"))]
tours$dist = tours$SKIMDIST

## Recode tour mode

tours$TOURMODE_RECODE[tours$TOURMODE==1]  = '1_SOV'
tours$TOURMODE_RECODE[tours$TOURMODE==2]  = '2_HOV2'
tours$TOURMODE_RECODE[tours$TOURMODE==3]  = '3_HOV3'
tours$TOURMODE_RECODE[tours$TOURMODE==4]  = '4_WALK'
tours$TOURMODE_RECODE[tours$TOURMODE==5]  = '5_BIKE'
tours$TOURMODE_RECODE[tours$TOURMODE==6]  = '6_WALK_LOCAL'
tours$TOURMODE_RECODE[tours$TOURMODE==7]  = '7_WALK_PREMIUM'
tours$TOURMODE_RECODE[tours$TOURMODE==8]  = '8_WALK_MIXED'
tours$TOURMODE_RECODE[tours$TOURMODE==9]  = '9_PNR_LOCAL'
tours$TOURMODE_RECODE[tours$TOURMODE==10]  = '10_PNR_PREMIUM'
tours$TOURMODE_RECODE[tours$TOURMODE==11]  = '11_PNR_MIXED'
tours$TOURMODE_RECODE[tours$TOURMODE==12]  = '12_KNR_LOCAL'
tours$TOURMODE_RECODE[tours$TOURMODE==13]  = '13_KNR_PREMIUM'
tours$TOURMODE_RECODE[tours$TOURMODE==14]  = '14_KNR_MIXED'
tours$TOURMODE_RECODE[tours$TOURMODE==15]  ='15_TNC_SINGLE'
tours$TOURMODE_RECODE[tours$TOURMODE==16]  ='11_TNC_SHARED'
tours$TOURMODE_RECODE[tours$TOURMODE==17]  ='17_TAXI'
tours$TOURMODE_RECODE[tours$TOURMODE==18]  ='18_SCHOOLBUS'
tours$TOURMODE_RECODE[tours$TOURMODE==19]  ='19_OTHER'

tours$TOURMODE_RECODE[is.na(tours$TOURMODE_RECODE)] = "Missing"


# Recode trip mode
tours$TOURMODE_ORIG = tours$TOURMODE
tours$TOURMODE[tours$TOURMODE_ORIG == 1] = 1  #SOV
tours$TOURMODE[tours$TOURMODE_ORIG == 2] = 2  #HOV2
tours$TOURMODE[tours$TOURMODE_ORIG == 3] = 3  #HOV3
tours$TOURMODE[tours$TOURMODE_ORIG == 4] = 4  #Walk
tours$TOURMODE[tours$TOURMODE_ORIG == 5] = 5  #Bike
tours$TOURMODE[tours$TOURMODE_ORIG == 6]  = 6  #WT
tours$TOURMODE[tours$TOURMODE_ORIG == 7]  = 6  #WT
tours$TOURMODE[tours$TOURMODE_ORIG == 8]  = 6  #WT
tours$TOURMODE[tours$TOURMODE_ORIG == 9] = 7  #PNR
tours$TOURMODE[tours$TOURMODE_ORIG == 10] = 7  #PNR
tours$TOURMODE[tours$TOURMODE_ORIG == 11] = 7  #PNR
tours$TOURMODE[tours$TOURMODE_ORIG == 12] = 7  #KNR
tours$TOURMODE[tours$TOURMODE_ORIG == 13] = 7  #KNR
tours$TOURMODE[tours$TOURMODE_ORIG == 14] = 7  #KNR
tours$TOURMODE[tours$TOURMODE_ORIG %in% c(15:17)] =8 # RIDEHAIL

tours$TOURMODE[tours$TOURMODE_ORIG == 18] = 9  #SchoolBus
tours$TOURMODE[tours$TOURMODE_ORIG > 18] = 11 #Other

# Removing Other modes
# todo: taxi/tnc?
#tours = subset(tours, TOURMODE <= 9)

# Recode Duration Bins

tours$TOUR_DUR_BIN[tours$TOUR_DUR_BIN<=1] = 1


# Recode time bin windows

# bin_xwalk = data.frame(bin48 = seq(1:48), 
#                        bin23 = c(seq(1,24, each = 2)))



# cap tour duration at 20 hours
tours$TOUR_DUR_BIN[tours$TOUR_DUR_BIN>=40] = 40

# tours = merge(tours, bin_xwalk, by.x = 'ANCHOR_DEPART_BIN', by.y = 'bin48', all.x = T)
# names(tours)[names(tours)=="bin48"]   = 'ANCHOR_DEPART_BIN_RECODE'
# 
# tours = merge(tours, bin_xwalk, by.x = 'ANCHOR_ARRIVE_BIN', by.y = 'bin48', all.x = T)
# names(tours)[names(tours)=="bin48"]   = 'ANCHOR_ARRIVE_BIN_RECODE'

tours$TOUR_DUR_BIN_RECODE = tours$ANCHOR_ARRIVE_BIN - tours$ANCHOR_DEPART_BIN + 1


# Recode tour purpose into unique market segmentations
# Work   - [No Subtours ], [All            ], [TOURPURP - (1,10)    ] 
# Univ   - [No Subtours ], [All            ], [TOURPURP - (2)       ] 
# Schl   - [No Subtours ], [All            ], [TOURPURP - (3)       ]  
# iMain  - [No Subtours ], [Non-Fully_Joint], [TOURPURP - (4,5,6)   ]   
# iDisc  - [No Subtours ], [Non-Fully_Joint], [TOURPURP - (7,8,9)   ]   
# jMain  - [No Subtours ], [Fully_Joint    ], [TOURPURP - (4,5,6)   ]       
# jDisc  - [No Subtours ], [Fully_Joint    ], [TOURPURP - (7,8,9)   ]   
# AtWork - [All Subtours], [All            ], [TOURPURP - (All)     ]    
# Other  - [No Subtours ], [All            ], [TOURPURP - (11,12,13)] 

tours$TOURPURP_RECODE = "Other"
tours$TOURPURP_RECODE[tours$IS_SUBTOUR==0 & tours$TOURPURP %in% c(1,10)] = "Work"
tours$TOURPURP_RECODE[tours$IS_SUBTOUR==0 & tours$TOURPURP %in% c(2)] = "University"
tours$TOURPURP_RECODE[tours$IS_SUBTOUR==0 & tours$TOURPURP %in% c(3)] = "School"
tours$TOURPURP_RECODE[tours$IS_SUBTOUR==0 & tours$FULLY_JOINT==0 & tours$TOURPURP %in% c(4,5,6)] = "Indi-Main"
tours$TOURPURP_RECODE[tours$IS_SUBTOUR==0 & tours$FULLY_JOINT==0 & tours$TOURPURP %in% c(7,8,9)] = "Indi-Disc"
tours$TOURPURP_RECODE[tours$IS_SUBTOUR==0 & tours$FULLY_JOINT==1 & tours$TOURPURP %in% c(4,5,6)] = "Joint-Main"
tours$TOURPURP_RECODE[tours$IS_SUBTOUR==0 & tours$FULLY_JOINT==1 & tours$TOURPURP %in% c(7,8,9)] = "Joint-Disc"
tours$TOURPURP_RECODE[tours$IS_SUBTOUR==1] = "At-Work"


#ASR: PII Warning, if this is needed, do not write it to the visualizer inputs.
# Export data for mode choice targets spreadsheet
# write.csv(tours[,c("HH_ID", "PER_ID", "TOUR_ID","TOURMODE_RECODE", "TOURPURP_RECODE", "AUTOSUFF", "finalweight")], 
#           "tourModeChoice.csv", row.names = F)

# Recode workrelated tours which are not at work subtour as work tour
# tours$TOURPURP[tours$TOURPURP == 10] = 1

# Copy TOURPURP to trip file
trips$TOURPURP = tours$TOURPURP[match(trips$HH_ID*10000+trips$PER_ID*1000+trips$TOUR_ID*10+trips$dow_num, tours$HH_ID*10000+tours$PER_ID*1000+tours$TOUR_ID*10+tours$dow_num)]
trips$TOURPURP_RECODE = tours$TOURPURP_RECODE[match(trips$HH_ID*10000+trips$PER_ID*1000+trips$TOUR_ID*10+trips$dow_num, tours$HH_ID*10000+tours$PER_ID*1000+tours$TOUR_ID*10+tours$dow_num)]
trips$TOURMODE_RECODE = tours$TOURMODE_RECODE[match(trips$HH_ID*10000+trips$PER_ID*1000+trips$TOUR_ID*10+trips$dow_num, tours$HH_ID*10000+tours$PER_ID*1000+tours$TOUR_ID*10+tours$dow_num)]
trips$TOURMODE = tours$TOURMODE[match(trips$HH_ID*10000+trips$PER_ID*1000+trips$TOUR_ID*10+trips$dow_num, tours$HH_ID*10000+tours$PER_ID*1000+tours$TOUR_ID*10+tours$dow_num)]
trips$AUTOSUFF = tours$AUTOSUFF[match(trips$HH_ID*10000+trips$PER_ID*1000+trips$TOUR_ID*10+trips$dow_num, tours$HH_ID*10000+tours$PER_ID*1000+tours$TOUR_ID*10+tours$dow_num)]
trips$IS_SUBTOUR = tours$IS_SUBTOUR[match(trips$HH_ID*10000+trips$PER_ID*1000+trips$TOUR_ID*10+trips$dow_num, tours$HH_ID*10000+tours$PER_ID*1000+tours$TOUR_ID*10+tours$dow_num)]

tours$TOTAL_STOPS = tours$OUTBOUND_STOPS + tours$INBOUND_STOPS

#----------------
jtours = jtours[!is.na(jtours$finalweight),]

#copy tour mode & other attributes
jtours$TOURMODE = tours$TOURMODE[match(jtours$HH_ID*1000+jtours$JTOUR_ID*10+jtours$dow_num,
                                                    tours$HH_ID*1000+tours$JTOUR_ID*10+tours$dow_num)]
jtours$AUTOSUFF = tours$AUTOSUFF[match(jtours$HH_ID*1000+jtours$JTOUR_ID*10+jtours$dow_num,
                                                    tours$HH_ID*1000+tours$JTOUR_ID*10+tours$dow_num)]
jtours$ANCHOR_DEPART_BIN = tours$ANCHOR_DEPART_BIN[match(jtours$HH_ID*1000+jtours$JTOUR_ID*10+jtours$dow_num,
                                                                      tours$HH_ID*1000+tours$JTOUR_ID*10+tours$dow_num)]
jtours$ANCHOR_ARRIVE_BIN = tours$ANCHOR_ARRIVE_BIN[match(jtours$HH_ID*1000+jtours$JTOUR_ID*10+jtours$dow_num,
                                                                      tours$HH_ID*1000+tours$JTOUR_ID*10+tours$dow_num)]
jtours$TOUR_DUR_BIN_RECODE = tours$TOUR_DUR_BIN_RECODE[match(jtours$HH_ID*1000+jtours$JTOUR_ID*10+jtours$dow_num,
                                                            tours$HH_ID*1000+tours$JTOUR_ID*10+tours$dow_num)]
jtours$dist = tours$dist[match(jtours$HH_ID*1000+jtours$JTOUR_ID*10+jtours$dow_num,
                                            tours$HH_ID*1000+tours$JTOUR_ID*10+tours$dow_num)]
#jtours$DISTMILE = jtours$dist/5280

jtours$OUTBOUND_STOPS = tours$OUTBOUND_STOPS[match(jtours$HH_ID*1000+jtours$JTOUR_ID*10+jtours$dow_num,
                                                                tours$HH_ID*1000+tours$JTOUR_ID*10+tours$dow_num)]
jtours$INBOUND_STOPS = tours$INBOUND_STOPS[match(jtours$HH_ID*1000+jtours$JTOUR_ID*10+jtours$dow_num,
                                                              tours$HH_ID*1000+tours$JTOUR_ID*10+tours$dow_num)]
jtours$TOTAL_STOPS = tours$TOTAL_STOPS[match(jtours$HH_ID*1000+jtours$JTOUR_ID*10+jtours$dow_num,
                                                          tours$HH_ID*1000+tours$JTOUR_ID*10+tours$dow_num)]
jtours$SKIMDIST = tours$SKIMDIST[match(jtours$HH_ID*1000+jtours$JTOUR_ID*10+jtours$dow_num,
                                                    tours$HH_ID*1000+tours$JTOUR_ID*10+tours$dow_num)]


# stop freq model calibration summary
temp_tour = tours
temp_tour$TOURPURP[temp_tour$IS_SUBTOUR==1] = 20
temp_tour1 = temp_tour[(temp_tour$TOURPURP==20 | temp_tour$TOURPURP<=9) & temp_tour$FULLY_JOINT==0,c("TOURPURP","OUTBOUND_STOPS","INBOUND_STOPS", "finalweight")]
temp_tour2 = jtours[jtours$JOINT_PURP>=5 & jtours$JOINT_PURP<=9,c("JOINT_PURP","OUTBOUND_STOPS","INBOUND_STOPS", "finalweight")]
colnames(temp_tour2) = colnames(temp_tour1)
temp_tour = rbind(temp_tour1,temp_tour2)

# code stop frequency model alternatives
temp_tour$STOP_FREQ_ALT[temp_tour$OUTBOUND_STOPS==0 & temp_tour$INBOUND_STOPS==0] = 1
temp_tour$STOP_FREQ_ALT[temp_tour$OUTBOUND_STOPS==0 & temp_tour$INBOUND_STOPS==1] = 2
temp_tour$STOP_FREQ_ALT[temp_tour$OUTBOUND_STOPS==0 & temp_tour$INBOUND_STOPS==2] = 3
temp_tour$STOP_FREQ_ALT[temp_tour$OUTBOUND_STOPS==0 & temp_tour$INBOUND_STOPS>=3] = 4
temp_tour$STOP_FREQ_ALT[temp_tour$OUTBOUND_STOPS==1 & temp_tour$INBOUND_STOPS==0] = 5
temp_tour$STOP_FREQ_ALT[temp_tour$OUTBOUND_STOPS==1 & temp_tour$INBOUND_STOPS==2] = 7
temp_tour$STOP_FREQ_ALT[temp_tour$OUTBOUND_STOPS==1 & temp_tour$INBOUND_STOPS>=3] = 8
temp_tour$STOP_FREQ_ALT[temp_tour$OUTBOUND_STOPS==2 & temp_tour$INBOUND_STOPS==0] = 9
temp_tour$STOP_FREQ_ALT[temp_tour$OUTBOUND_STOPS==2 & temp_tour$INBOUND_STOPS==1] = 10
temp_tour$STOP_FREQ_ALT[temp_tour$OUTBOUND_STOPS==2 & temp_tour$INBOUND_STOPS==2] = 11
temp_tour$STOP_FREQ_ALT[temp_tour$OUTBOUND_STOPS==2 & temp_tour$INBOUND_STOPS>=3] = 12
temp_tour$STOP_FREQ_ALT[temp_tour$OUTBOUND_STOPS>=3 & temp_tour$INBOUND_STOPS==0] = 13
temp_tour$STOP_FREQ_ALT[temp_tour$OUTBOUND_STOPS>=3 & temp_tour$INBOUND_STOPS==1] = 14
temp_tour$STOP_FREQ_ALT[temp_tour$OUTBOUND_STOPS>=3 & temp_tour$INBOUND_STOPS==2] = 15
temp_tour$STOP_FREQ_ALT[temp_tour$OUTBOUND_STOPS>=3 & temp_tour$INBOUND_STOPS>=3] = 16
temp_tour$STOP_FREQ_ALT[is.na(temp_tour$STOP_FREQ_ALT)] = 0

stopFreqModel_summary = xtabs(finalweight~STOP_FREQ_ALT+TOURPURP, data = temp_tour[temp_tour$TOURPURP<=9 | temp_tour$TOURPURP==20,])
write.csv(stopFreqModel_summary, "stopFreqModel_summary.csv", row.names = T)




# Process Trip file
#------------------
print("Processing Trip file...")
#trips$finalweight = hh$finalweight[match(trips$HH_ID, hh$SAMPN)]
trips = trips[!is.na(trips$finalweight),]

#trips$JTRIP_ID = lapply(trips$JTRIP_ID, as.character)
#trips$JTRIP_ID = lapply(trips$JTRIP_ID, as.integer)

trips$JTRIP_ID = as.character(trips$JTRIP_ID)
trips$JTRIP_ID = as.integer(trips$JTRIP_ID)
trips$JTRIP_ID[is.na(trips$JTRIP_ID)] = 0

# recode trip mode for mode choice targets

trips$TRIPMODE_RECODE[trips$TRIPMODE==1]  = '1_SOV'
trips$TRIPMODE_RECODE[trips$TRIPMODE==2]  = '2_HOV2'
trips$TRIPMODE_RECODE[trips$TRIPMODE==3]  = '3_HOV3'
trips$TRIPMODE_RECODE[trips$TRIPMODE==4]  = '4_WALK'
trips$TRIPMODE_RECODE[trips$TRIPMODE==5]  = '5_BIKE'
trips$TRIPMODE_RECODE[trips$TRIPMODE==6]  = '6_WALK_LOCAL'
trips$TRIPMODE_RECODE[trips$TRIPMODE==7]  = '7_WALK_PREMIUM'
trips$TRIPMODE_RECODE[trips$TRIPMODE==8]  = '8_WALK_MIXED'
trips$TRIPMODE_RECODE[trips$TRIPMODE==9]  = '9_PNR_LOCAL'
trips$TRIPMODE_RECODE[trips$TRIPMODE==10]  = '10_PNR_PREMIUM'
trips$TRIPMODE_RECODE[trips$TRIPMODE==11]  = '11_PNR_MIXED'
trips$TRIPMODE_RECODE[trips$TRIPMODE==12]  = '12_KNR_LOCAL'
trips$TRIPMODE_RECODE[trips$TRIPMODE==13]  = '13_KNR_PREMIUM'
trips$TRIPMODE_RECODE[trips$TRIPMODE==14]  = '14_KNR_MIXED'
trips$TRIPMODE_RECODE[trips$TRIPMODE==15]  ='15_TNC_SINGLE'
trips$TRIPMODE_RECODE[trips$TRIPMODE==16]  ='11_TNC_SHARED'
trips$TRIPMODE_RECODE[trips$TRIPMODE==17]  ='17_TAXI'
trips$TRIPMODE_RECODE[trips$TRIPMODE==18]  ='18_SCHOOLBUS'
trips$TRIPMODE_RECODE[trips$TRIPMODE==19]  ='19_OTHER'

tours$TRIPMODE_RECODE[is.na(tours$TRIPMODE_RECODE)] = "Missing"


# Recode trip mode
trips$TRIPMODE_ORIG = trips$TRIPMODE
trips$TRIPMODE[trips$TRIPMODE_ORIG == 1] = 1  #SOV
trips$TRIPMODE[trips$TRIPMODE_ORIG == 2] = 2  #HOV2
trips$TRIPMODE[trips$TRIPMODE_ORIG == 3] = 3  #HOV3
trips$TRIPMODE[trips$TRIPMODE_ORIG == 4] = 4  #Walk
trips$TRIPMODE[trips$TRIPMODE_ORIG == 5] = 5  #Bike
trips$TRIPMODE[trips$TRIPMODE_ORIG == 6]  = 6  #WT
trips$TRIPMODE[trips$TRIPMODE_ORIG == 7]  = 6  #WT
trips$TRIPMODE[trips$TRIPMODE_ORIG == 8]  = 6  #WT
trips$TRIPMODE[trips$TRIPMODE_ORIG == 9] = 7  #PNR
trips$TRIPMODE[trips$TRIPMODE_ORIG == 10] = 7  #PNR
trips$TRIPMODE[trips$TRIPMODE_ORIG == 11] = 7  #PNR
trips$TRIPMODE[trips$TRIPMODE_ORIG == 12] = 7  #KNR
trips$TRIPMODE[trips$TRIPMODE_ORIG == 13] = 7  #KNR
trips$TRIPMODE[trips$TRIPMODE_ORIG == 14] = 7  #KNR
trips$TRIPMODE[trips$TRIPMODE_ORIG == 18] = 9  #SchoolBus
trips$TRIPMODE[trips$TRIPMODE_ORIG %in% c(15:17)] = 8 # RIDEHAIL
trips$TRIPMODE[trips$TRIPMODE_ORIG %in% c(19)] = 11 #Other
# REMOVING OTHER MODES
#trips = subset(trips, TRIPMODE <= 9)

# Recode time bin windows

# trips = merge(trips, bin_xwalk, by.x = 'ORIG_DEP_BIN', by.y = 'bin48', all.x = T)
# names(trips)[names(trips)=="bin48"]   = 'ORIG_DEP_BIN_RECODE'
# trips = merge(trips, bin_xwalk, by.x = 'ORIG_ARR_BIN', by.y = 'bin48', all.x = T)
# names(trips)[names(trips)=="bin48"]   = 'ORIG_ARR_BIN_RECODE'
# trips = merge(trips, bin_xwalk, by.x = 'DEST_DEP_BIN', by.y = 'bin48', all.x = T)
# names(trips)[names(trips)=="bin48"]   = 'DEST_DEP_BIN_RECODE'
# trips = merge(trips, bin_xwalk, by.x = 'DEST_ARR_BIN', by.y = 'bin48', all.x = T)
# names(trips)[names(trips)=="bin48"]   = 'DEST_ARR_BIN_RECODE'

#trips$ORIG_DEP_BIN[trips$ORIG_DEP_HOUR<=4] = 1
#trips$ORIG_DEP_BIN[!is.na(trips$ORIG_DEP_HOUR) & trips$ORIG_DEP_HOUR>=5 & trips$ORIG_DEP_HOUR<=22] = trips$ORIG_DEP_HOUR[!is.na(trips$ORIG_DEP_HOUR) & trips$ORIG_DEP_HOUR>=5 & trips$ORIG_DEP_HOUR<=22]
#trips$ORIG_DEP_BIN[trips$ORIG_DEP_HOUR>=23] = 23
#
#trips$ORIG_ARR_BIN[trips$ORIG_ARR_BIN<=4] = 1
#trips$ORIG_ARR_BIN[!is.na(trips$ORIG_ARR_BIN) & trips$ORIG_ARR_BIN>=5 & trips$ORIG_ARR_BIN<=22] = trips$ORIG_ARR_BIN[!is.na(trips$ORIG_ARR_BIN) & trips$ORIG_ARR_BIN>=5 & trips$ORIG_ARR_BIN<=42]
#trips$ORIG_ARR_BIN[trips$ORIG_ARR_BIN>=23] = 23
#
#trips$DEST_DEP_BIN[trips$DEST_DEP_BIN<=4] = 1
#trips$DEST_DEP_BIN[!is.na(trips$DEST_DEP_BIN) & trips$DEST_DEP_BIN>=5 & trips$DEST_DEP_BIN<=22] = trips$DEST_DEP_BIN[!is.na(trips$DEST_DEP_BIN) & trips$DEST_DEP_BIN>=5 & trips$DEST_DEP_BIN<=42]
#trips$DEST_DEP_BIN[trips$DEST_DEP_BIN>=23] = 23
#
#trips$DEST_ARR_BIN[trips$DEST_ARR_BIN<=4] = 1
#trips$DEST_ARR_BIN[!is.na(trips$DEST_ARR_BIN) & trips$DEST_ARR_BIN>=5 & trips$DEST_ARR_BIN<=22] = trips$DEST_ARR_BIN[!is.na(trips$DEST_ARR_BIN) & trips$DEST_ARR_BIN>=5 & trips$DEST_ARR_BIN<=22]
#trips$DEST_ARR_BIN[trips$DEST_ARR_BIN>=23] = 23

#ASR Correct for School Bus Trips/Tours on Non-School Tours -->> Trn Walk
trips[trips$HHPERTOUR_ID %in% tours[tours$TOURMODE == 9 & tours$TOURPURP != 3,]$HHPERTOUR_ID,]$TOURMODE = 6
trips[trips$TRIPMODE == 9 & trips$TOURPURP != 3,]$TRIPMODE = 6
tours[tours$TOURMODE == 9 & tours$TOURPURP != 3,]$TOURMODE = 6

#Mark trips which are stops on the tour [not to primary destination and not going back to tour anchor/origin]
trips$stops[trips$DEST_PURP>0 & trips$DEST_PURP<=10 & trips$DEST_IS_TOUR_DEST==0 & trips$DEST_IS_TOUR_ORIG==0] = 1
trips$stops[is.na(trips$stops)] = 0

trips$TOUROTAZ = tours$ORIG_TAZ[match(trips$HH_ID*1000+trips$PER_ID*100+10*trips$TOUR_ID+trips$dow_num, 
                                   tours$HH_ID*1000+tours$PER_ID*100+10*tours$TOUR_ID+tours$dow_num)]
trips$TOURDTAZ = tours$DEST_TAZ[match(trips$HH_ID*1000+trips$PER_ID*100+10*trips$TOUR_ID+trips$dow_num, 
                                   tours$HH_ID*1000+tours$PER_ID*100+10*tours$TOUR_ID+tours$dow_num)]	

# copy tour dep hour and minute
trips$ANCHOR_DEPART_HOUR = tours$ANCHOR_DEPART_HOUR[match(trips$HH_ID*1000+trips$PER_ID*100+10*trips$TOUR_ID+trips$dow_num, 
                                                           tours$HH_ID*1000+tours$PER_ID*100+10*tours$TOUR_ID+tours$dow_num)]
trips$ANCHOR_DEPART_MIN = tours$ANCHOR_DEPART_MIN[match(trips$HH_ID*1000+trips$PER_ID*100+10*trips$TOUR_ID+trips$dow_num, 
                                                         tours$HH_ID*1000+tours$PER_ID*100+10*tours$TOUR_ID+tours$dow_num)]

trips$od_dist = DST_SKM$dist[match(paste(trips$ORIG_TAZ, trips$DEST_TAZ, sep = "-"), paste(DST_SKM$o, DST_SKM$d, sep = "-"))]
trips$od_dist[is.na(trips$od_dist)] = 0

#ASR PII WARNING. If this is needed, save it somewhere else, not in the visualizer inputs folder.
# export trip file for tour mode choice targets spreadsheet
# write.csv(trips[, c("HH_ID", "PER_ID", "TOUR_ID", "TRIP_ID", "TRIPMODE_RECODE","TOURMODE_RECODE", "TOURPURP_RECODE", "AUTOSUFF", "finalweight")], 
#           "tripModeChoice.csv", row.names = F)

#create stops table
stops = trips[trips$stops==1,]

stops$finaldestTAZ[stops$IS_INBOUND==0] = stops$TOURDTAZ[stops$IS_INBOUND==0]
stops$finaldestTAZ[stops$IS_INBOUND==1] = stops$TOUROTAZ[stops$IS_INBOUND==1]
stops$od_dist = DST_SKM$dist[match(paste(stops$ORIG_TAZ, stops$finaldestTAZ, sep = "-"), paste(DST_SKM$o, DST_SKM$d, sep = "-"))]
stops$os_dist = DST_SKM$dist[match(paste(stops$ORIG_TAZ, stops$DEST_TAZ, sep = "-"), paste(DST_SKM$o, DST_SKM$d, sep = "-"))]
stops$sd_dist = DST_SKM$dist[match(paste(stops$DEST_TAZ, stops$finaldestTAZ, sep = "-"), paste(DST_SKM$o, DST_SKM$d, sep = "-"))]
stops$out_dir_dist = stops$os_dist + stops$sd_dist - stops$od_dist				

#Joint trips		
#---------------------------------------------------------------------------------------------
print("Processing joint trips file...")
# create joint trips file from trip file [trips belonging to fully joint tours]
trips$JTOUR_ID = tours$JTOUR_ID[match(trips$HH_ID*10000+trips$PER_ID*1000+trips$TOUR_ID*10+trips$dow_num, 
                                       tours$HH_ID*10000+tours$PER_ID*1000+tours$TOUR_ID*10+tours$dow_num)]
trips$JTOUR_ID[is.na(trips$JTOUR_ID)] = 0

jtrips = trips[trips$JTOUR_ID>0 & trips$JTRIP_ID>0,]   #this contains a joint trip for each person

# joint trips should be a household level file, therefore, remove person dimension
jtrips$PER_ID = NULL
jtrips = unique(jtrips[,c("HH_ID", "JTRIP_ID", "dow_num")])
jtrips$uid = paste(jtrips$HH_ID, jtrips$JTRIP_ID, jtrips$dow_num, sep = "-")

jutrips$uid = paste(jutrips$HH_ID, jutrips$JTRIP_ID, jutrips$dow_num, sep = "-")

jtrips$NUMBER_HH = jutrips$NUMBER_HH[match(jtrips$uid, jutrips$uid)]
jtrips$PERSON_1 = jutrips$PERSON_1[match(jtrips$uid, jutrips$uid)]
jtrips$PERSON_2 = jutrips$PERSON_2[match(jtrips$uid, jutrips$uid)]
jtrips$PERSON_3 = jutrips$PERSON_3[match(jtrips$uid, jutrips$uid)]
jtrips$PERSON_4 = jutrips$PERSON_4[match(jtrips$uid, jutrips$uid)]
jtrips$PERSON_5 = jutrips$PERSON_5[match(jtrips$uid, jutrips$uid)]
jtrips$PERSON_6 = jutrips$PERSON_6[match(jtrips$uid, jutrips$uid)]
jtrips$PERSON_7 = jutrips$PERSON_7[match(jtrips$uid, jutrips$uid)]
jtrips$PERSON_8 = jutrips$PERSON_8[match(jtrips$uid, jutrips$uid)]
jtrips$PERSON_9 = jutrips$PERSON_9[match(jtrips$uid, jutrips$uid)]
jtrips$COMPOSITION = jutrips$COMPOSITION[match(jtrips$uid, jutrips$uid)]

jtrips$TOUR_ID = trips$TOUR_ID[match(jtrips$HH_ID*10000+jtrips$JTRIP_ID*100+jtrips$dow_num,trips$HH_ID*10000+trips$JTRIP_ID*100+trips$dow_num)]	
jtrips$JTOUR_ID = trips$JTOUR_ID[match(jtrips$HH_ID*10000+jtrips$JTRIP_ID*100+jtrips$dow_num,trips$HH_ID*10000+trips$JTRIP_ID*100+trips$dow_num)]	
jtrips$finalweight = trips$finalweight[match(jtrips$HH_ID*10000+jtrips$JTRIP_ID*100+jtrips$dow_num,trips$HH_ID*10000+trips$JTRIP_ID*100+trips$dow_num)]	

#remove joint tours from joint_tours with no joint trips in jtrips 
jtours_jtrips = unique(jtrips[,c("HH_ID", "JTOUR_ID", "dow_num")])
jtours_jtrips$uid = paste(jtours_jtrips$HH_ID, jtours_jtrips$JTOUR_ID, jtours_jtrips$dow_num, sep = "-")

jtours$uid = paste(jtours$HH_ID, jtours$JTOUR_ID, jtours$dow_num,sep = "-")
jtours = jtours[jtours$uid %in% jtours_jtrips$uid,]
#---------------------------------------------------------------------------------------------

jtrips = jtrips[!is.na(jtrips$finalweight),]

jtrips$stops = trips$stops[match(jtrips$HH_ID*10000+jtrips$JTRIP_ID*100+jtrips$dow_num,trips$HH_ID*10000+trips$JTRIP_ID*100+trips$dow_num)]	
jtrips$TOURPURP = trips$TOURPURP[match(jtrips$HH_ID*10000+jtrips$JTRIP_ID*100+jtrips$dow_num,trips$HH_ID*10000+trips$JTRIP_ID*100+trips$dow_num)]	
jtrips$DEST_PURP = trips$DEST_PURP[match(jtrips$HH_ID*10000+jtrips$JTRIP_ID*100+jtrips$dow_num,trips$HH_ID*10000+trips$JTRIP_ID*100+trips$dow_num)]	
jtrips$TRIPMODE = trips$TRIPMODE[match(jtrips$HH_ID*10000+jtrips$JTRIP_ID*100+jtrips$dow_num,trips$HH_ID*10000+trips$JTRIP_ID*100+trips$dow_num)]
jtrips$TOURMODE = trips$TOURMODE[match(jtrips$HH_ID*10000+jtrips$JTRIP_ID*100+jtrips$dow_num,trips$HH_ID*10000+trips$JTRIP_ID*100+trips$dow_num)]	
jtrips$ORIG_TAZ = trips$ORIG_TAZ[match(jtrips$HH_ID*10000+jtrips$JTRIP_ID*100+jtrips$dow_num,trips$HH_ID*10000+trips$JTRIP_ID*100+trips$dow_num)]	
jtrips$DEST_TAZ = trips$DEST_TAZ[match(jtrips$HH_ID*10000+jtrips$JTRIP_ID*100+jtrips$dow_num,trips$HH_ID*10000+trips$JTRIP_ID*100+trips$dow_num)]	
jtrips$TOUROTAZ = trips$TOUROTAZ[match(jtrips$HH_ID*10000+jtrips$JTRIP_ID*100+jtrips$dow_num,trips$HH_ID*10000+trips$JTRIP_ID*100+trips$dow_num)]	
jtrips$TOURDTAZ = trips$TOURDTAZ[match(jtrips$HH_ID*10000+jtrips$JTRIP_ID*100+jtrips$dow_num,trips$HH_ID*10000+trips$JTRIP_ID*100+trips$dow_num)]
jtrips$DEST_DEP_BIN = trips$DEST_DEP_BIN[match(jtrips$HH_ID*10000+jtrips$JTRIP_ID*100+jtrips$dow_num,trips$HH_ID*10000+trips$JTRIP_ID*100+trips$dow_num)]
jtrips$ORIG_DEP_BIN = trips$ORIG_DEP_BIN[match(jtrips$HH_ID*10000+jtrips$JTRIP_ID*100+jtrips$dow_num,trips$HH_ID*10000+trips$JTRIP_ID*100+trips$dow_num)]
jtrips$IS_INBOUND = trips$IS_INBOUND[match(jtrips$HH_ID*10000+jtrips$JTRIP_ID*100+jtrips$dow_num,trips$HH_ID*10000+trips$JTRIP_ID*100+trips$dow_num)]	
jtrips$ANCHOR_DEPART_HOUR = trips$ANCHOR_DEPART_HOUR[match(jtrips$HH_ID*10000+jtrips$JTRIP_ID*100+jtrips$dow_num,trips$HH_ID*10000+trips$JTRIP_ID*100+trips$dow_num)]															  
jtrips$ANCHOR_DEPART_MIN = trips$ANCHOR_DEPART_MIN[match(jtrips$HH_ID*10000+jtrips$JTRIP_ID*100+jtrips$dow_num,trips$HH_ID*10000+trips$JTRIP_ID*100+trips$dow_num)]															  

#DEBUG



#ASR In theory not necessary since changed at trip/tour level
#ASR Correct for School Bus Trips/Tours on Non-School Tours -->> Trn Walk
#jtrips$HHPERTOUR_ID = 10000 + jtrips$JTOUR_ID
#jtours$HHPERTOUR_ID = 10000 + jtours$JTOUR_ID
#jtrips[jtrips$HHPERTOUR_ID %in% jtours[jtours$TOURMODE == 9 & jtours$TOURPURP != 3,]$HHPERTOUR_ID,]$TOURMODE = 6
#jtours[jtours$TOURMODE == 9 & jtours$TOURPURP != 3,]$TOURMODE = 6
#jtrips[jtrips$TRIPMODE == 9 & jtrips$TOURPURP != 3,]$TRIPMODE = 6


#some joint trips missing in trip file, so couldnt copy their attributes
jtrips = jtrips[!is.na(jtrips$IS_INBOUND),]

# get person type and age of all memebrs on joint tours
jtrips$PERTYPE_1 = processedPerson$PERSONTYPE[match(jtrips$HH_ID*100+jtrips$PERSON_1, 
                                                     processedPerson$HHID*100+processedPerson$PERID)]
jtrips$PERTYPE_2 = processedPerson$PERSONTYPE[match(jtrips$HH_ID*100+jtrips$PERSON_2, 
                                                     processedPerson$HHID*100+processedPerson$PERID)]
jtrips$PERTYPE_3 = processedPerson$PERSONTYPE[match(jtrips$HH_ID*100+jtrips$PERSON_3, 
                                                     processedPerson$HHID*100+processedPerson$PERID)]
jtrips$PERTYPE_4 = processedPerson$PERSONTYPE[match(jtrips$HH_ID*100+jtrips$PERSON_4, 
                                                     processedPerson$HHID*100+processedPerson$PERID)]
jtrips$PERTYPE_5 = processedPerson$PERSONTYPE[match(jtrips$HH_ID*100+jtrips$PERSON_5, 
                                                     processedPerson$HHID*100+processedPerson$PERID)]
jtrips$PERTYPE_6 = processedPerson$PERSONTYPE[match(jtrips$HH_ID*100+jtrips$PERSON_6, 
                                                     processedPerson$HHID*100+processedPerson$PERID)]
jtrips$PERTYPE_7 = processedPerson$PERSONTYPE[match(jtrips$HH_ID*100+jtrips$PERSON_7, 
                                                     processedPerson$HHID*100+processedPerson$PERID)]
jtrips$PERTYPE_8 = processedPerson$PERSONTYPE[match(jtrips$HH_ID*100+jtrips$PERSON_8, 
                                                     processedPerson$HHID*100+processedPerson$PERID)]
jtrips$PERTYPE_9 = processedPerson$PERSONTYPE[match(jtrips$HH_ID*100+jtrips$PERSON_9, 
                                                     processedPerson$HHID*100+processedPerson$PERID)]

jtrips$PERTYPE_1 = ifelse(is.na(jtrips$PERTYPE_1), 0, jtrips$PERTYPE_1)
jtrips$PERTYPE_2 = ifelse(is.na(jtrips$PERTYPE_2), 0, jtrips$PERTYPE_2)
jtrips$PERTYPE_3 = ifelse(is.na(jtrips$PERTYPE_3), 0, jtrips$PERTYPE_3)
jtrips$PERTYPE_4 = ifelse(is.na(jtrips$PERTYPE_4), 0, jtrips$PERTYPE_4)
jtrips$PERTYPE_5 = ifelse(is.na(jtrips$PERTYPE_5), 0, jtrips$PERTYPE_5)
jtrips$PERTYPE_6 = ifelse(is.na(jtrips$PERTYPE_6), 0, jtrips$PERTYPE_6)
jtrips$PERTYPE_7 = ifelse(is.na(jtrips$PERTYPE_7), 0, jtrips$PERTYPE_7)
jtrips$PERTYPE_8 = ifelse(is.na(jtrips$PERTYPE_8), 0, jtrips$PERTYPE_8)
jtrips$PERTYPE_9 = ifelse(is.na(jtrips$PERTYPE_9), 0, jtrips$PERTYPE_9)


jtrips$AGE_1 = processedPerson$AGE[match(jtrips$HH_ID*100+jtrips$PERSON_1, 
                                          processedPerson$HHID*100+processedPerson$PERID)]
jtrips$AGE_2 = processedPerson$AGE[match(jtrips$HH_ID*100+jtrips$PERSON_2, 
                                          processedPerson$HHID*100+processedPerson$PERID)]
jtrips$AGE_3 = processedPerson$AGE[match(jtrips$HH_ID*100+jtrips$PERSON_3, 
                                          processedPerson$HHID*100+processedPerson$PERID)]
jtrips$AGE_4 = processedPerson$AGE[match(jtrips$HH_ID*100+jtrips$PERSON_4, 
                                          processedPerson$HHID*100+processedPerson$PERID)]
jtrips$AGE_5 = processedPerson$AGE[match(jtrips$HH_ID*100+jtrips$PERSON_5, 
                                          processedPerson$HHID*100+processedPerson$PERID)]
jtrips$AGE_6 = processedPerson$AGE[match(jtrips$HH_ID*100+jtrips$PERSON_6, 
                                          processedPerson$HHID*100+processedPerson$PERID)]
jtrips$AGE_7 = processedPerson$AGE[match(jtrips$HH_ID*100+jtrips$PERSON_7, 
                                          processedPerson$HHID*100+processedPerson$PERID)]
jtrips$AGE_8 = processedPerson$AGE[match(jtrips$HH_ID*100+jtrips$PERSON_8, 
                                          processedPerson$HHID*100+processedPerson$PERID)]
jtrips$AGE_9 = processedPerson$AGE[match(jtrips$HH_ID*100+jtrips$PERSON_9, 
                                          processedPerson$HHID*100+processedPerson$PERID)]

jtrips$AGE_1 = ifelse(is.na(jtrips$AGE_1), 0, jtrips$AGE_1)
jtrips$AGE_2 = ifelse(is.na(jtrips$AGE_2), 0, jtrips$AGE_2)
jtrips$AGE_3 = ifelse(is.na(jtrips$AGE_3), 0, jtrips$AGE_3)
jtrips$AGE_4 = ifelse(is.na(jtrips$AGE_4), 0, jtrips$AGE_4)
jtrips$AGE_5 = ifelse(is.na(jtrips$AGE_5), 0, jtrips$AGE_5)
jtrips$AGE_6 = ifelse(is.na(jtrips$AGE_6), 0, jtrips$AGE_6)
jtrips$AGE_7 = ifelse(is.na(jtrips$AGE_7), 0, jtrips$AGE_7)
jtrips$AGE_8 = ifelse(is.na(jtrips$AGE_8), 0, jtrips$AGE_8)
jtrips$AGE_9 = ifelse(is.na(jtrips$AGE_9), 0, jtrips$AGE_9)

jtrips$MAX_AGE = pmax(jtrips$AGE_1, jtrips$AGE_2, jtrips$AGE_3, 
                       jtrips$AGE_4, jtrips$AGE_5, jtrips$AGE_6, 
                       jtrips$AGE_7, jtrips$AGE_8, jtrips$AGE_9)

#create stops table
jstops = jtrips[jtrips$stops==1,]

jstops$finaldestTAZ[jstops$IS_INBOUND==0] = jstops$TOURDTAZ[jstops$IS_INBOUND==0]
jstops$finaldestTAZ[jstops$IS_INBOUND==1] = jstops$TOUROTAZ[jstops$IS_INBOUND==1]

jstops$od_dist = DST_SKM$dist[match(paste(jstops$ORIG_TAZ, jstops$finaldestTAZ, sep = "-"), paste(DST_SKM$o, DST_SKM$d, sep = "-"))]
jstops$os_dist = DST_SKM$dist[match(paste(jstops$ORIG_TAZ, jstops$DEST_TAZ, sep = "-"), paste(DST_SKM$o, DST_SKM$d, sep = "-"))]
jstops$sd_dist = DST_SKM$dist[match(paste(jstops$DEST_TAZ, jstops$finaldestTAZ, sep = "-"), paste(DST_SKM$o, DST_SKM$d, sep = "-"))]

jstops$out_dir_dist = jstops$os_dist + jstops$sd_dist - jstops$od_dist	


#---------------------------------------------------------------------------------														  
# create summary for Indi NonMand Tour Frequency Calibration
#---------------------------------------------------------------------------------
print("Computing stop frequencies...")

workCounts = plyr::count(tours[tours$TOURPURP<=10,], c( "HH_ID", "PER_ID", "dow_num"), "(TOURPURP %in% c(1,10)) & IS_SUBTOUR == 0") #[excluding at work subtours]. joint work tours should be considered individual mandatory tours
atWorkCounts = plyr::count(tours[tours$TOURPURP<=10,], c("HH_ID", "PER_ID", "dow_num"), "(IS_SUBTOUR == 1)") #include joint work-subtours as individual subtours
schlCounts = plyr::count(tours[tours$TOURPURP<=10,], c("HH_ID", "PER_ID", "dow_num"), "(TOURPURP %in% c(2,3)) & IS_SUBTOUR == 0") #joint school/university tours should be considered individual mandatory tours
inmCounts = plyr::count(tours[tours$TOURPURP<=10,], c("HH_ID", "PER_ID", "dow_num"), "(TOURPURP>=4 & TOURPURP<=9 & FULLY_JOINT==0 & IS_SUBTOUR == 0) | (TOURPURP==4 & FULLY_JOINT==1 & IS_SUBTOUR == 0)") #joint escort tours should be considered individual non-mandatory tours
itourCounts = plyr::count(tours[tours$TOURPURP<=10,], c("HH_ID", "PER_ID", "dow_num"), "(TOURPURP <= 10 & IS_SUBTOUR == 0 & FULLY_JOINT==0) | (TOURPURP <= 4 & FULLY_JOINT==1 & IS_SUBTOUR == 0)")  #number of individual tours per person [excluding at work subtours]
jtourCounts = plyr::count(tours[tours$TOURPURP<=10,], c("HH_ID", "PER_ID", "dow_num"), "TOURPURP >= 5 & TOURPURP <= 9 & IS_SUBTOUR == 0 & FULLY_JOINT==1")  #number of joint tours per person [excluding at work subtours, also excluding joint escort tours]


workCounts_temp = workCounts
schlCounts_temp = schlCounts
inmCounts_temp = inmCounts
jtourCounts_temp = jtourCounts
atWorkCounts_temp = atWorkCounts

colnames(workCounts_temp)[4] = "freq_work"
colnames(schlCounts_temp)[4] = "freq_schl"
colnames(inmCounts_temp)[4] = "freq_inm"
colnames(jtourCounts_temp)[4] = "freq_joint"
colnames(atWorkCounts_temp)[4] = "freq_atwork"

# colnames(workCounts_temp)[3] = "freq_work"
# colnames(schlCounts_temp)[3] = "freq_schl"
# colnames(inmCounts_temp)[3] = "freq_inm"
# colnames(jtourCounts_temp)[3] = "freq_joint"
# colnames(atWorkCounts_temp)[3] = "freq_atwork"

temp = merge(workCounts_temp, schlCounts_temp, by = c( "HH_ID", "PER_ID", "dow_num"))
temp1 = merge(temp, inmCounts_temp, by = c( "HH_ID", "PER_ID", "dow_num"))

# temp = merge(workCounts_temp, schlCounts_temp, by = c( "HH_ID", "PER_ID"))
# temp1 = merge(temp, inmCounts_temp, by = c( "HH_ID", "PER_ID"))

temp1$freq_m = temp1$freq_work + temp1$freq_schl
temp1 = temp1[temp1$freq_m>0 | temp1$freq_inm>0,]

#joint tours
jtourCounts_temp[is.na(jtourCounts_temp)] = 0
temp_joint = jtourCounts_temp[jtourCounts_temp$freq_joint>0,]

# temp2 = merge(temp1, temp_joint, by = c("HH_ID", "PER_ID", "dow_num"), all = T)
# temp2 = merge(temp2, atWorkCounts_temp, by = c("HH_ID", "PER_ID", "dow_num"), all = T)

temp2 = merge(temp1, temp_joint, by = c("HH_ID", "PER_ID"), all = T)
temp2 = merge(temp2, atWorkCounts_temp, by = c("HH_ID", "PER_ID"), all = T)

temp2[is.na(temp2)] = 0

#add number of joint tours to non-mandatory
temp2$freq_nm = temp2$freq_inm + temp2$freq_joint

#total tours
temp2$total_tours = temp2$freq_nm+temp2$freq_m+temp2$freq_atwork

temp2$PERTYPE = per$PERTYPE[match(temp2$HH_ID*1000+temp2$PER_ID*10,per$SAMPN*1000+per$PERNO*10)]
temp2$finalweight = per$finalweight[match(temp2$HH_ID*1000+temp2$PER_ID*10,per$SAMPN*1000+per$PERNO*10)] / per$tourDays[match(temp2$HH_ID*1000+temp2$PER_ID*10,per$SAMPN*1000+per$PERNO*10)]
temp2 = temp2[!is.na(temp2$PERTYPE),]

persons_mand = temp2[temp2$freq_m>0,]  #persons with atleast 1 mandatory tours
persons_nomand = temp2[temp2$freq_m==0,] #active persons with 0 mandatory tours

# joint tours counted as iNM for calibration purpose [model does not allow 0 iNM and >0 JT]

freq_nmtours_mand = plyr::count(persons_mand, c("PERTYPE","freq_nm"), "finalweight")
freq_nmtours_nomand = plyr::count(persons_nomand, c("PERTYPE","freq_nm"), "finalweight")

# write.table("Non-Mandatory Tours for Persons with at-least 1 Mandatory Tour", "indivNMTourFreq.csv", sep = ",", row.names = F, append = F)
# write.table(freq_nmtours_mand, "indivNMTourFreq.csv", sep = ",", row.names = F, append = T)
# write.table("Non-Mandatory Tours for Active Persons with 0 Mandatory Tour", "indivNMTourFreq.csv", sep = ",", row.names = F, append = T)
# write.table(freq_nmtours_nomand, "indivNMTourFreq.csv", sep = ",", row.names = F, append = TRUE)

#---------------------------------------------------------------------------------														  
# End of Indi Non Mand Tour Frequency Calibration Summary
#---------------------------------------------------------------------------------														  



#---------------------------------------------------------------------------------														  

#workCounts = count(tours, c( "HH_ID", "PER_ID"), "TOURPURP == 1 & IS_SUBTOUR == 0") #[excluding at work subtours]
#atWorkCounts = count(tours, c("HH_ID", "PER_ID"), "TOURPURP == 10 & FULLY_JOINT==0 & IS_SUBTOUR == 1")
#schlCounts = count(tours, c("HH_ID", "PER_ID"), "TOURPURP == 2 | TOURPURP == 3")
#inmCounts = count(tours, c("HH_ID", "PER_ID"), "TOURPURP>=4 & TOURPURP<=9 & FULLY_JOINT==0 & IS_SUBTOUR == 0")
#itourCounts = count(tours, c("HH_ID", "PER_ID"), "TOURPURP <= 10 & IS_SUBTOUR == 0 & FULLY_JOINT==0")  #number of individual tours per person [excluding at work subtours]
#jtourCounts = count(tours, c("HH_ID", "PER_ID"), "TOURPURP >= 5 & TOURPURP <= 9 & IS_SUBTOUR == 0 & FULLY_JOINT==1")  #number of joint tours per person [excluding at work subtours]
joint5 = plyr::count(jtours, c("HH_ID"), "JOINT_PURP==5")
joint6 = plyr::count(jtours, c("HH_ID"), "JOINT_PURP==6")
joint7 = plyr::count(jtours, c("HH_ID"), "JOINT_PURP==7")
joint8 = plyr::count(jtours, c("HH_ID"), "JOINT_PURP==8")
joint9 = plyr::count(jtours, c("HH_ID"), "JOINT_PURP==9")

hh$joint5 = joint5$freq[match(hh$SAMPN, joint5$HH_ID)]
hh$joint6 = joint6$freq[match(hh$SAMPN, joint6$HH_ID)]
hh$joint7 = joint7$freq[match(hh$SAMPN, joint7$HH_ID)]
hh$joint8 = joint8$freq[match(hh$SAMPN, joint8$HH_ID)]
hh$joint9 = joint9$freq[match(hh$SAMPN, joint9$HH_ID)]
hh$jtours = hh$joint5+hh$joint6+hh$joint7+hh$joint8+hh$joint9

hh$joint5[is.na(hh$joint5)] = 0
hh$joint6[is.na(hh$joint6)] = 0
hh$joint7[is.na(hh$joint7)] = 0
hh$joint8[is.na(hh$joint8)] = 0
hh$joint9[is.na(hh$joint9)] = 0
hh$jtours[is.na(hh$jtours)] = 0
hh$JOINT = 0
hh$JOINT[hh$jtours>0] = 1

# code JTF category
hh$jtf[hh$jtours==0] = 1 
hh$jtf[hh$joint5==1] = 2
hh$jtf[hh$joint6==1] = 3
hh$jtf[hh$joint7==1] = 4
hh$jtf[hh$joint8==1] = 5
hh$jtf[hh$joint9==1] = 6

hh$jtf[hh$joint5>=2] = 7
hh$jtf[hh$joint6>=2] = 8
hh$jtf[hh$joint7>=2] = 9
hh$jtf[hh$joint8>=2] = 10
hh$jtf[hh$joint9>=2] = 11

hh$jtf[hh$joint5>=1 & hh$joint6>=1] = 12
hh$jtf[hh$joint5>=1 & hh$joint7>=1] = 13
hh$jtf[hh$joint5>=1 & hh$joint8>=1] = 14
hh$jtf[hh$joint5>=1 & hh$joint9>=1] = 15

hh$jtf[hh$joint6>=1 & hh$joint7>=1] = 16
hh$jtf[hh$joint6>=1 & hh$joint8>=1] = 17
hh$jtf[hh$joint6>=1 & hh$joint9>=1] = 18

hh$jtf[hh$joint7>=1 & hh$joint8>=1] = 19
hh$jtf[hh$joint7>=1 & hh$joint9>=1] = 20

hh$jtf[hh$joint8>=1 & hh$joint9>=1] = 21

toursPerDay = data.frame(x = unique(tours$HH_ID*1000+tours$PER_ID*10+tours$dow_num))
toursPerDay$HH_ID = as.integer(toursPerDay$x / 10)

tourDays = as.data.frame(table(toursPerDay$HH_ID), stringsAsFactors = FALSE)
tourDays$Var1 = as.integer(tourDays$Var1) * 10

per$tourDays = tourDays$Freq[match(per$SAMPN*1000+per$PERNO*10, tourDays$Var1)]
per$tourDays[is.na(per$tourDays)] = 1

#NOTE: commented because these will be incorrect at the person level (they must be at the per-day level)
# per$workTours   = workCounts$freq[match(per$SAMPN*1000+per$PERNO*10, workCounts$HH_ID*1000+workCounts$PER_ID*10)]
# per$atWorkTours = atWorkCounts$freq[match(per$SAMPN*1000+per$PERNO*10, atWorkCounts$HH_ID*1000+atWorkCounts$PER_ID*10)]
# per$schlTours   = schlCounts$freq[match(per$SAMPN*1000+per$PERNO*10, schlCounts$HH_ID*1000+schlCounts$PER_ID*10)]
# per$inmTours    = inmCounts$freq[match(per$SAMPN*1000+per$PERNO*10, inmCounts$HH_ID*1000+inmCounts$PER_ID*10)]
# per$inmTours[is.na(per$inmTours)] = 0
# per$inumTours = itourCounts$freq[match(per$SAMPN*1000+per$PERNO*10, itourCounts$HH_ID*1000+itourCounts$PER_ID*10)]
# per$inumTours[is.na(per$inumTours)] = 0
# per$jnumTours = jtourCounts$freq[match(per$SAMPN*1000+per$PERNO*10, jtourCounts$HH_ID*1000+jtourCounts$PER_ID*10)]
# per$jnumTours[is.na(per$jnumTours)] = 0
# per$numTours = per$inumTours + per$jnumTours


# per$workTours   = workCounts$freq[match(per$SAMPN*1000+per$PERNO*10, workCounts$HH_ID*1000+workCounts$PER_ID*10)] / per$tourDays
# per$atWorkTours = atWorkCounts$freq[match(per$SAMPN*1000+per$PERNO*10, atWorkCounts$HH_ID*1000+atWorkCounts$PER_ID*10)] / per$tourDays
# per$schlTours   = schlCounts$freq[match(per$SAMPN*1000+per$PERNO*10, schlCounts$HH_ID*1000+schlCounts$PER_ID*10)] / per$tourDays
# per$inmTours    = inmCounts$freq[match(per$SAMPN*1000+per$PERNO*10, inmCounts$HH_ID*1000+inmCounts$PER_ID*10)] / per$tourDays
# per$inmTours[is.na(per$inmTours)] = 0
# per$inumTours = itourCounts$freq[match(per$SAMPN*1000+per$PERNO*10, itourCounts$HH_ID*1000+itourCounts$PER_ID*10)] / per$tourDays
# per$inumTours[is.na(per$inumTours)] = 0
# per$jnumTours = jtourCounts$freq[match(per$SAMPN*1000+per$PERNO*10, jtourCounts$HH_ID*1000+jtourCounts$PER_ID*10)] / per$tourDays
# per$jnumTours[is.na(per$jnumTours)] = 0
# per$numTours = per$inmTours + per$jnumTours

per$workTours[is.na(per$workTours)] = 0
per$schlTours[is.na(per$schlTours)] = 0
per$atWorkTours[is.na(per$atWorkTours)] = 0

# Individual tours by person type
per$numTours[is.na(per$numTours)] = 0
toursPertypeDistbn = plyr::count(tours[!is.na(tours$TOURPURP) & tours$TOURPURP<=10 & tours$FULLY_JOINT==0 & tours$IS_SUBTOUR==0,], c("PERTYPE"), "finalweight")
write.csv(toursPertypeDistbn, "toursPertypeDistbn.csv", row.names = TRUE)

# Total tours by person type for visualizer
totaltoursPertypeDistbn = plyr::count(tours[!is.na(tours$PERTYPE) & !is.na(tours$TOURPURP) & tours$TOURPURP<=10 & tours$IS_SUBTOUR==0,], c("PERTYPE"), "finalweight")
write.csv(totaltoursPertypeDistbn, "total_tours_by_pertype_vis.csv", row.names = F)


# Total indi NM tours by person type and purpose
tours_pertype_purpose = plyr::count(tours[(tours$TOURPURP>=4 & tours$TOURPURP<=9 & tours$FULLY_JOINT==0 & tours$IS_SUBTOUR==0) | (tours$TOURPURP==4 & tours$FULLY_JOINT==0),], c("PERTYPE", "TOURPURP", "dow_num"), "finalweight")
write.csv(tours_pertype_purpose, "tours_pertype_purpose.csv", row.names = TRUE)

tours_pertype_purpose = xtabs(freq~PERTYPE+TOURPURP+dow_num, tours_pertype_purpose)
tours_pertype_purpose = xtabs(Freq~PERTYPE+TOURPURP, tours_pertype_purpose)
tours_pertype_purpose[is.na(tours_pertype_purpose)] = 0
tours_pertype_purpose = addmargins(as.table(tours_pertype_purpose))
tours_pertype_purpose = as.data.frame.matrix(tours_pertype_purpose)

totalPersons = sum(pertypeDistbn$freq)
totalPersons_DF = data.frame("Total", totalPersons)
colnames(totalPersons_DF) = colnames(pertypeDistbn)
pertypeDF = rbind(pertypeDistbn, totalPersons_DF)
nm_tour_rates = tours_pertype_purpose/pertypeDF$freq
nm_tour_rates$pertype = row.names(nm_tour_rates)
nm_tour_rates = reshape2::melt(nm_tour_rates, id = c("pertype"))
colnames(nm_tour_rates) = c("pertype", "tour_purp", "tour_rate")
nm_tour_rates$pertype = as.character(nm_tour_rates$pertype)
nm_tour_rates$tour_purp = as.character(nm_tour_rates$tour_purp)
nm_tour_rates$pertype[nm_tour_rates$pertype=="Sum"] = "All"
nm_tour_rates$tour_purp[nm_tour_rates$tour_purp=="Sum"] = "All"
nm_tour_rates$pertype = pertypeCodes$name[match(nm_tour_rates$pertype, pertypeCodes$code)]

nm_tour_rates$tour_purp[nm_tour_rates$tour_purp==4] = "Escorting"
nm_tour_rates$tour_purp[nm_tour_rates$tour_purp==5] = "Shopping"
nm_tour_rates$tour_purp[nm_tour_rates$tour_purp==6] = "Maintenance"
nm_tour_rates$tour_purp[nm_tour_rates$tour_purp==7] = "EatingOut"
nm_tour_rates$tour_purp[nm_tour_rates$tour_purp==8] = "Visiting"
nm_tour_rates$tour_purp[nm_tour_rates$tour_purp==9] = "Discretionary"
write.csv(nm_tour_rates, "nm_tour_rates.csv", row.names = F)
# Total tours by purpose X tourtype
par(mar=c(1,1,1,1))
t1 = wtd.hist(tours$TOURPURP[!is.na(tours$TOURPURP) & tours$TOURPURP<=10 & tours$TOURPURP>0 & tours$FULLY_JOINT==0 & tours$IS_SUBTOUR==0], 
               breaks = seq(1,10, by=1), 
               freq = NULL, right=FALSE, 
               weight=tours$finalweight[!is.na(tours$TOURPURP) & tours$TOURPURP<=10 & tours$TOURPURP>0 & tours$FULLY_JOINT==0 & tours$IS_SUBTOUR==0])

t3 = wtd.hist(jtours$JOINT_PURP[jtours$JOINT_PURP > 0 & jtours$JOINT_PURP<10], breaks = seq(1,10, by=1), freq = NULL, right=FALSE, weight=jtours$finalweight[jtours$JOINT_PURP > 0 & jtours$JOINT_PURP<10])
tours_purpose_type = data.frame(t1$counts, t3$counts)
colnames(tours_purpose_type) = c("indi", "joint")
write.csv(tours_purpose_type, "tours_purpose_type.csv", row.names = TRUE)
print("marker 6.4")
# DAP by pertype+day ####
#perday_valid = melt(per, id.vars = c("SAMPN", "PERNO"), variable.name = "day_num", measure.vars = c("Complete_2", "Complete_3", "Complete_4"))
#perday_valid$dow = as.integer(substr(perday_valid$day_num, str_length(perday_valid$day_num) , str_length(perday_valid$day_num)))

#perDays$validDay = perday_valid$value[match(perDays$HH_ID*1000+perDays$PER_ID*10+perDays$dow, perday_valid$SAMPN*1000+perday_valid$PERNO*10+perday_valid$dow)]

# perDays$validDay = 0
# #print(match(perDays[perDays$dow == 1,]$HH_ID*1000+perDays[perDays$dow == 1,]$PER_ID*10+perDays[perDays$dow == 1,]$dow, per[!is.na(per$person_id),]$person_id * 10 + 1))
# print(perDays[perDays$dow == 1,]$HH_ID*1000+perDays[perDays$dow == 1,]$PER_ID*10+perDays[perDays$dow == 1,]$dow)

# perDays[perDays$dow == 1,]$validDay = per$Complete_1[match(perDays[perDays$dow == 1,]$HH_ID*1000+perDays[perDays$dow == 1,]$PER_ID*10+perDays[perDays$dow == 1,]$dow, per[!is.na(per$person_id),]$person_id * 10 + 1)]
# print("marker 6.5")
# perDays[perDays$dow == 2,]$validDay = per$Complete_2[match(perDays[perDays$dow == 2,]$HH_ID*1000+perDays[perDays$dow == 2,]$PER_ID*10+perDays[perDays$dow == 2,]$dow, per$person_id * 10 + 2)]
# perDays[perDays$dow == 3,]$validDay = per$Complete_3[match(perDays[perDays$dow == 3,]$HH_ID*1000+perDays[perDays$dow == 3,]$PER_ID*10+perDays[perDays$dow == 3,]$dow, per$person_id * 10 + 3)]
# perDays[perDays$dow == 4,]$validDay = per$Complete_4[match(perDays[perDays$dow == 4,]$HH_ID*1000+perDays[perDays$dow == 4,]$PER_ID*10+perDays[perDays$dow == 4,]$dow, per$person_id * 10 + 4)]
# perDays = perDays[perDays$validDay == 1,]
# print("marker 7")

perDays$workTours   = workCounts$freq[match(perDays$HH_ID*1000+perDays$PER_ID*10+perDays$dow, workCounts$HH_ID*1000+workCounts$PER_ID*10+workCounts$dow_num)]
perDays$workTours[is.na(perDays$workTours)] = 0
perDays$atWorkTours = atWorkCounts$freq[match(perDays$HH_ID*1000+perDays$PER_ID*10+perDays$dow, atWorkCounts$HH_ID*1000+atWorkCounts$PER_ID*10+atWorkCounts$dow_num)]
perDays$atWorkTours[is.na(perDays$atWorkTours)] = 0
perDays$schlTours   = schlCounts$freq[match(perDays$HH_ID*1000+perDays$PER_ID*10+perDays$dow, schlCounts$HH_ID*1000+schlCounts$PER_ID*10+schlCounts$dow_num)]
perDays$schlTours[is.na(perDays$schlTours)] = 0
perDays$inmTours    = inmCounts$freq[match(perDays$HH_ID*1000+perDays$PER_ID*10+perDays$dow, inmCounts$HH_ID*1000+inmCounts$PER_ID*10+inmCounts$dow_num)]
perDays$inmTours[is.na(perDays$inmTours)] = 0
perDays$inumTours = 0 #not sure why the below is a warning, but none of the lines above are
perDays$inumTours = itourCounts$freq[match(perDays$HH_ID*1000+perDays$PER_ID*10+perDays$dow, itourCounts$HH_ID*1000+itourCounts$PER_ID*10+itourCounts$dow_num)]
perDays$inumTours[is.na(perDays$inumTours)] = 0
perDays$jnumTours = jtourCounts$freq[match(perDays$HH_ID*1000+perDays$PER_ID*10+perDays$dow, jtourCounts$HH_ID*1000+jtourCounts$PER_ID*10+jtourCounts$dow_num)]
perDays$jnumTours[is.na(perDays$jnumTours)] = 0
perDays$numTours = perDays$inumTours + perDays$jnumTours

#
print("marker 8")
perDays$DAP = "H"
perDays$DAP[perDays$workTours > 0 | perDays$schlTours > 0] = "M"
perDays$DAP[perDays$numTours > 0 & perDays$DAP == "H"] = "N"

perDays$PERTYPE = per$PERTYPE[match(perDays$HH_ID*1000+perDays$PER_ID*10, per$SAMPN*1000+per$PERNO*10)]
perDays$finalweight = per$finalweight[match(perDays$HH_ID*1000+perDays$PER_ID*10, per$SAMPN*1000+per$PERNO*10)]
#perDays$daywt = day_weights$day_weight[match(perDays$HH_ID*1000+perDays$PER_ID*10+perDays$dow, day_weights$person_id*10+day_weights$day_num)]
perDays$daywt = 1.0

perN = perDays[, .(.N), by = .(HH_ID*1000+PER_ID)]

perDays$NDays = perN$N[match(perDays$HH_ID*1000+perDays$PER_ID, perN$HH_ID)]

perDays$adjFinalWeight = perDays$finalweight / perDays$NDays

dapSummary = plyr::count(perDays, c("PERTYPE", "DAP"), "adjFinalWeight")
print(paste("dap weight", sum(dapSummary$adjFinalWeight)))
print(paste("perDays weight", sum(perDays$finalweight)))
print(paste("per weight", sum(per$finalweight)))

### Hard-coding DAP pattern based on Fall/Winter data
### School Driving Student
dapSummary$freq[(dapSummary$PERTYPE==6)&(dapSummary$DAP=='M')] = 78
dapSummary$freq[(dapSummary$PERTYPE==6)&(dapSummary$DAP=='N')] = 5.9
dapSummary$freq[(dapSummary$PERTYPE==6)&(dapSummary$DAP=='H')] = 16.1

### School Non-Driving Student
dapSummary$freq[(dapSummary$PERTYPE==7)&(dapSummary$DAP=='M')] = 81.4
dapSummary$freq[(dapSummary$PERTYPE==7)&(dapSummary$DAP=='N')] = 8
dapSummary$freq[(dapSummary$PERTYPE==7)&(dapSummary$DAP=='H')] = 10.6

write.csv(dapSummary, "dapSummary.csv", row.names = TRUE)

# Prepare DAP summary for visualizer
dapSummary_vis = xtabs(freq~PERTYPE+DAP, dapSummary)
dapSummary_vis = addmargins(as.table(dapSummary_vis))
dapSummary_vis = as.data.frame.matrix(dapSummary_vis)

dapSummary_vis$id = row.names(dapSummary_vis)
dapSummary_vis = reshape2::melt(dapSummary_vis, id = c("id"))
colnames(dapSummary_vis) = c("PERTYPE", "DAP", "freq")
dapSummary_vis$DAP = as.character(dapSummary_vis$DAP)
dapSummary_vis$PERTYPE = as.character(dapSummary_vis$PERTYPE)
dapSummary_vis = dapSummary_vis[dapSummary_vis$DAP!="Sum",]
dapSummary_vis$PERTYPE[dapSummary_vis$PERTYPE=="Sum"] = "Total"
write.csv(dapSummary_vis, "dapSummary_vis.csv", row.names = TRUE)

# HHSize X Joint
hhsizeJoint = plyr::count(hh[hh$HHSIZE>=2,], c("HHSIZE", "JOINT"), "finalweight")
write.csv(hhsizeJoint, "hhsizeJoint.csv", row.names = TRUE)

#mandatory tour frequency ####
#NOTE: changed to per-day and adj weights to account for multiple days
perDays$mtf = 0
perDays$mtf[perDays$workTours == 1] = 1
perDays$mtf[perDays$workTours >= 2] = 2
perDays$mtf[perDays$schlTours == 1] = 3
perDays$mtf[perDays$schlTours >= 2] = 4
perDays$mtf[perDays$workTours >= 1 & perDays$schlTours >= 1] = 5

mtfSummary = plyr::count(perDays[perDays$mtf > 0,], c("PERTYPE", "mtf"), "adjFinalWeight")
write.csv(mtfSummary, "mtfSummary.csv")
#ASR: PII WARNING. DO NOT WRITE THIS.
# write.csv(tours, "tours_test.csv")

# Prepare MTF summary for visualizer
mtfSummary_vis = xtabs(freq~PERTYPE+mtf, mtfSummary)
mtfSummary_vis = addmargins(as.table(mtfSummary_vis))
mtfSummary_vis = as.data.frame.matrix(mtfSummary_vis)

mtfSummary_vis$id = row.names(mtfSummary_vis)
mtfSummary_vis = reshape2::melt(mtfSummary_vis, id = c("id"))
colnames(mtfSummary_vis) = c("PERTYPE", "MTF", "freq")
mtfSummary_vis$PERTYPE = as.character(mtfSummary_vis$PERTYPE)
mtfSummary_vis$MTF = as.character(mtfSummary_vis$MTF)
mtfSummary_vis = mtfSummary_vis[mtfSummary_vis$MTF!="Sum",]
mtfSummary_vis$PERTYPE[mtfSummary_vis$PERTYPE=="Sum"] = "Total"
write.csv(mtfSummary_vis, "mtfSummary_vis.csv")

# indi NM summary ####
inm0Summary = plyr::count(perDays[perDays$inmTours==0,], c("PERTYPE"), "adjFinalWeight")
inm1Summary = plyr::count(perDays[perDays$inmTours==1,], c("PERTYPE"), "adjFinalWeight")
inm2Summary = plyr::count(perDays[perDays$inmTours==2,], c("PERTYPE"), "adjFinalWeight")
inm3Summary = plyr::count(perDays[perDays$inmTours>=3,], c("PERTYPE"), "adjFinalWeight")

inmSummary = data.frame(PERTYPE = c(1,2,3,4,5,6,7,8))
inmSummary$tour0 = inm0Summary$freq[match(inmSummary$PERTYPE, inm0Summary$PERTYPE)]
inmSummary$tour1 = inm1Summary$freq[match(inmSummary$PERTYPE, inm1Summary$PERTYPE)]
inmSummary$tour2 = inm2Summary$freq[match(inmSummary$PERTYPE, inm2Summary$PERTYPE)]
inmSummary$tour3pl = inm3Summary$freq[match(inmSummary$PERTYPE, inm3Summary$PERTYPE)]

write.table(inmSummary, "innmSummary.csv", col.names=TRUE, sep=",")

# prepare INM summary for visualizer
inmSummary_vis = reshape2::melt(inmSummary, id=c("PERTYPE"))
inmSummary_vis$variable = as.character(inmSummary_vis$variable)
inmSummary_vis$variable[inmSummary_vis$variable=="tour0"] = "0"
inmSummary_vis$variable[inmSummary_vis$variable=="tour1"] = "1"
inmSummary_vis$variable[inmSummary_vis$variable=="tour2"] = "2"
inmSummary_vis$variable[inmSummary_vis$variable=="tour3pl"] = "3pl"
inmSummary_vis = xtabs(value~PERTYPE+variable, inmSummary_vis)
inmSummary_vis = addmargins(as.table(inmSummary_vis))
inmSummary_vis = as.data.frame.matrix(inmSummary_vis)

inmSummary_vis$id = row.names(inmSummary_vis)
inmSummary_vis = reshape2::melt(inmSummary_vis, id = c("id"))
colnames(inmSummary_vis) = c("PERTYPE", "nmtours", "freq")
inmSummary_vis$PERTYPE = as.character(inmSummary_vis$PERTYPE)
inmSummary_vis$nmtours = as.character(inmSummary_vis$nmtours)
inmSummary_vis = inmSummary_vis[inmSummary_vis$nmtours!="Sum",]
inmSummary_vis$PERTYPE[inmSummary_vis$PERTYPE=="Sum"] = "Total"
write.csv(inmSummary_vis, "inmSummary_vis.csv")

# Joint Tour Frequency and composition ####

jtfSummary = plyr::count(hh[!is.na(hh$jtf),], c("jtf"), "finalweight")
jointComp = plyr::count(jtours[jtours$JOINT_PURP>=5 & jtours$JOINT_PURP<=9,], c("COMPOSITION"), "finalweight")
jointPartySize = plyr::count(jtours[jtours$JOINT_PURP>=5 & jtours$JOINT_PURP<=9,], c("NUMBER_HH"), "finalweight")
jointCompPartySize = plyr::count(jtours[jtours$JOINT_PURP>=5 & jtours$JOINT_PURP<=9,], c("COMPOSITION","NUMBER_HH"), "finalweight")

hh$jointCat[hh$jtours==0] = 0
hh$jointCat[hh$jtours==1] = 1
hh$jointCat[hh$jtours>=2] = 2

jointToursHHSize = plyr::count(hh[!is.na(hh$HHSIZE) & !is.na(hh$jointCat),], c("HHSIZE", "jointCat"), "finalweight")

# write.table(jtfSummary, "jtfSummary.csv", col.names=TRUE, sep=",")
# write.table(jointComp, "jtfSummary.csv", col.names=TRUE, sep=",", append=TRUE)
# write.table(jointPartySize, "jtfSummary.csv", col.names=TRUE, sep=",", append=TRUE)
# write.table(jointCompPartySize, "jtfSummary.csv", col.names=TRUE, sep=",", append=TRUE)
# write.table(jointToursHHSize, "jtfSummary.csv", col.names=TRUE, sep=",", append=TRUE)

#cap joint party size to 5+
jointPartySize$freq[jointPartySize$NUMBER_HH==5] = sum(jointPartySize$freq[jointPartySize$NUMBER_HH>=5])
jointPartySize = jointPartySize[jointPartySize$NUMBER_HH<=5, ]

jtf = data.frame(jtf_code = seq(from = 1, to = 21), 
                  alt_name = c("No Joint Tours", "1 Shopping", "1 Maintenance", "1 Eating Out", "1 Visiting", "1 Other Discretionary", 
                               "2 Shopping", "1 Shopping / 1 Maintenance", "1 Shopping / 1 Eating Out", "1 Shopping / 1 Visiting", 
                               "1 Shopping / 1 Other Discretionary", "2 Maintenance", "1 Maintenance / 1 Eating Out", 
                               "1 Maintenance / 1 Visiting", "1 Maintenance / 1 Other Discretionary", "2 Eating Out", "1 Eating Out / 1 Visiting", 
                               "1 Eating Out / 1 Other Discretionary", "2 Visiting", "1 Visiting / 1 Other Discretionary", "2 Other Discretionary"))
jtf$freq = jtfSummary$freq[match(jtf$jtf_code, jtfSummary$jtf)]
jtf[is.na(jtf)] = 0

jointComp$COMPOSITION[jointComp$COMPOSITION==1] = "All Adult"
jointComp$COMPOSITION[jointComp$COMPOSITION==2] = "All Children"
jointComp$COMPOSITION[jointComp$COMPOSITION==3] = "Mixed"

jointToursHHSizeProp = xtabs(freq~jointCat+HHSIZE, jointToursHHSize[jointToursHHSize$HHSIZE>1,])
jointToursHHSizeProp = addmargins(as.table(jointToursHHSizeProp))
jointToursHHSizeProp = jointToursHHSizeProp[-4,]  #remove last row 
jointToursHHSizeProp = prop.table(jointToursHHSizeProp, margin = 2)
jointToursHHSizeProp = as.data.frame.matrix(jointToursHHSizeProp)
jointToursHHSizeProp = jointToursHHSizeProp*100
jointToursHHSizeProp$jointTours = row.names(jointToursHHSizeProp)
jointToursHHSizeProp = reshape2::melt(jointToursHHSizeProp, id = c("jointTours"))
colnames(jointToursHHSizeProp) = c("jointTours", "hhsize", "freq")
jointToursHHSizeProp$hhsize = as.character(jointToursHHSizeProp$hhsize)
jointToursHHSizeProp$hhsize[jointToursHHSizeProp$hhsize=="Sum"] = "Total"

jointCompPartySize$COMPOSITION[jointCompPartySize$COMPOSITION==1] = "All Adult"
jointCompPartySize$COMPOSITION[jointCompPartySize$COMPOSITION==2] = "All Children"
jointCompPartySize$COMPOSITION[jointCompPartySize$COMPOSITION==3] = "Mixed"

jointCompPartySizeProp = xtabs(freq~COMPOSITION+NUMBER_HH, jointCompPartySize)
jointCompPartySizeProp = addmargins(as.table(jointCompPartySizeProp))
jointCompPartySizeProp = jointCompPartySizeProp[,-6]  #remove last row 
jointCompPartySizeProp = prop.table(jointCompPartySizeProp, margin = 1)
jointCompPartySizeProp = as.data.frame.matrix(jointCompPartySizeProp)
jointCompPartySizeProp = jointCompPartySizeProp*100
jointCompPartySizeProp$comp = row.names(jointCompPartySizeProp)
jointCompPartySizeProp = reshape2::melt(jointCompPartySizeProp, id = c("comp"))
colnames(jointCompPartySizeProp) = c("comp", "partysize", "freq")
jointCompPartySizeProp$comp = as.character(jointCompPartySizeProp$comp)
jointCompPartySizeProp$comp[jointCompPartySizeProp$comp=="Sum"] = "Total"

# Cap joint comp party size at 5
jointCompPartySizeProp = jointCompPartySizeProp[jointCompPartySizeProp$partysize!="Sum",]
jointCompPartySizeProp$partysize = as.numeric(as.character(jointCompPartySizeProp$partysize))
jointCompPartySizeProp$freq[jointCompPartySizeProp$comp=="All Adult" & jointCompPartySizeProp$partysize==5] = 
  sum(jointCompPartySizeProp$freq[jointCompPartySizeProp$comp=="All Adult" & jointCompPartySizeProp$partysize>=5])
jointCompPartySizeProp$freq[jointCompPartySizeProp$comp=="All Children" & jointCompPartySizeProp$partysize==5] = 
  sum(jointCompPartySizeProp$freq[jointCompPartySizeProp$comp=="All Children" & jointCompPartySizeProp$partysize>=5])
jointCompPartySizeProp$freq[jointCompPartySizeProp$comp=="Mixed" & jointCompPartySizeProp$partysize==5] = 
  sum(jointCompPartySizeProp$freq[jointCompPartySizeProp$comp=="Mixed" & jointCompPartySizeProp$partysize>=5])
jointCompPartySizeProp$freq[jointCompPartySizeProp$comp=="Total" & jointCompPartySizeProp$partysize==5] = 
  sum(jointCompPartySizeProp$freq[jointCompPartySizeProp$comp=="Total" & jointCompPartySizeProp$partysize>=5])

jointCompPartySizeProp = jointCompPartySizeProp[jointCompPartySizeProp$partysize<=5,]



#ASR: PII WARNING. DO NOT WRITE THIS.
# write.csv(jtf, "jtf.csv", row.names = F)
write.csv(jointComp, "jointComp.csv", row.names = F)
write.csv(jointPartySize, "jointPartySize.csv", row.names = F)
write.csv(jointCompPartySizeProp, "jointCompPartySize.csv", row.names = F)
write.csv(jointToursHHSizeProp, "jointToursHHSize.csv", row.names = F)

# TOD Profile
tod1 = wtd.hist(tours$ANCHOR_DEPART_BIN[tours$TOURPURP==1 & tours$IS_SUBTOUR == 0], breaks = seq(1,48, by=1), freq = NULL, right=FALSE, weight = tours$finalweight[tours$TOURPURP==1 & tours$IS_SUBTOUR == 0])
tod2 = wtd.hist(tours$ANCHOR_DEPART_BIN[tours$TOURPURP==2 & tours$IS_SUBTOUR == 0], breaks = seq(1,48, by=1), freq = NULL, right=FALSE, weight = tours$finalweight[tours$TOURPURP==2 & tours$IS_SUBTOUR == 0])
tod3 = wtd.hist(tours$ANCHOR_DEPART_BIN[tours$TOURPURP==3 & tours$IS_SUBTOUR == 0], breaks = seq(1,48, by=1), freq = NULL, right=FALSE, weight = tours$finalweight[tours$TOURPURP==3 & tours$IS_SUBTOUR == 0])
tod4 = wtd.hist(tours$ANCHOR_DEPART_BIN[tours$TOURPURP==4 & tours$IS_SUBTOUR == 0], breaks = seq(1,48, by=1), freq = NULL, right=FALSE, weight = tours$finalweight[tours$TOURPURP==4 & tours$IS_SUBTOUR == 0])
todi56 = wtd.hist(tours$ANCHOR_DEPART_BIN[tours$TOURPURP>=5 & tours$TOURPURP<=6 & tours$FULLY_JOINT==0 & tours$IS_SUBTOUR == 0], breaks = seq(1,48, by=1), freq = NULL, right=FALSE, weight = tours$finalweight[tours$TOURPURP>=5 & tours$TOURPURP<=6 & tours$FULLY_JOINT==0 & tours$IS_SUBTOUR == 0])
todi789 = wtd.hist(tours$ANCHOR_DEPART_BIN[tours$TOURPURP>=7 & tours$TOURPURP<=9 & tours$FULLY_JOINT==0 & tours$IS_SUBTOUR == 0], breaks = seq(1,48, by=1), freq = NULL, right=FALSE, weight = tours$finalweight[tours$TOURPURP>=7 & tours$TOURPURP<=9 & tours$FULLY_JOINT==0 & tours$IS_SUBTOUR == 0])
todj56 = wtd.hist(jtours$ANCHOR_DEPART_BIN[jtours$JOINT_PURP>=5 & jtours$JOINT_PURP<=6], breaks = seq(1,48, by=1), freq = NULL, right=FALSE, weight = jtours$finalweight[jtours$JOINT_PURP>=5 & jtours$JOINT_PURP<=6])
todj789 = wtd.hist(jtours$ANCHOR_DEPART_BIN[jtours$JOINT_PURP>=7 & jtours$JOINT_PURP<=9], breaks = seq(1,48, by=1), freq = NULL, right=FALSE, weight = jtours$finalweight[jtours$JOINT_PURP>=7 & jtours$JOINT_PURP<=9])
tod15 = wtd.hist(tours$ANCHOR_DEPART_BIN[tours$IS_SUBTOUR == 1], breaks = seq(1,48, by=1), freq = NULL, right=FALSE, weight = tours$finalweight[tours$IS_SUBTOUR == 1])

todDepProfile = data.frame(tod1$counts, tod2$counts, tod3$counts, tod4$counts, todi56$counts, todi789$counts
                            , todj56$counts, todj789$counts, tod15$counts)
colnames(todDepProfile) = c("work", "univ", "sch", "esc", "imain", "idisc", 
                             "jmain", "jdisc", "atwork")
write.csv(todDepProfile, "todDepProfile.csv")

# prepare input for visualizer
todDepProfile_vis = todDepProfile
todDepProfile_vis$id = row.names(todDepProfile_vis)
todDepProfile_vis = reshape2::melt(todDepProfile_vis, id = c("id"))
colnames(todDepProfile_vis) = c("id", "purpose", "freq")

todDepProfile_vis$purpose = as.character(todDepProfile_vis$purpose)
todDepProfile_vis = xtabs(freq~id+purpose, todDepProfile_vis)
todDepProfile_vis = addmargins(as.table(todDepProfile_vis))
todDepProfile_vis = as.data.frame.matrix(todDepProfile_vis)
todDepProfile_vis$id = row.names(todDepProfile_vis)
todDepProfile_vis = reshape2::melt(todDepProfile_vis, id = c("id"))
colnames(todDepProfile_vis) = c("timebin", "PURPOSE", "freq")
todDepProfile_vis$PURPOSE = as.character(todDepProfile_vis$PURPOSE)
todDepProfile_vis$timebin = as.character(todDepProfile_vis$timebin)
todDepProfile_vis = todDepProfile_vis[todDepProfile_vis$timebin!="Sum",]
todDepProfile_vis$PURPOSE[todDepProfile_vis$PURPOSE=="Sum"] = "Total"
todDepProfile_vis$timebin = as.numeric(todDepProfile_vis$timebin)

arr1 = wtd.hist(tours$ANCHOR_ARRIVE_BIN[tours$TOURPURP==1 & tours$IS_SUBTOUR == 0], breaks = seq(1,48, by=1), freq = NULL, right=FALSE, weight = tours$finalweight[tours$TOURPURP==1 & tours$IS_SUBTOUR == 0])
arr2 = wtd.hist(tours$ANCHOR_ARRIVE_BIN[tours$TOURPURP==2 & tours$IS_SUBTOUR == 0], breaks = seq(1,48, by=1), freq = NULL, right=FALSE, weight = tours$finalweight[tours$TOURPURP==2 & tours$IS_SUBTOUR == 0])
arr3 = wtd.hist(tours$ANCHOR_ARRIVE_BIN[tours$TOURPURP==3 & tours$IS_SUBTOUR == 0], breaks = seq(1,48, by=1), freq = NULL, right=FALSE, weight = tours$finalweight[tours$TOURPURP==3 & tours$IS_SUBTOUR == 0])
arr4 = wtd.hist(tours$ANCHOR_ARRIVE_BIN[tours$TOURPURP==4 & tours$IS_SUBTOUR == 0], breaks = seq(1,48, by=1), freq = NULL, right=FALSE, weight = tours$finalweight[tours$TOURPURP==4 & tours$IS_SUBTOUR == 0])
arri56 = wtd.hist(tours$ANCHOR_ARRIVE_BIN[tours$TOURPURP>=5 & tours$TOURPURP<=6 & tours$FULLY_JOINT==0 & tours$IS_SUBTOUR == 0], breaks = seq(1,48, by=1), freq = NULL, right=FALSE, weight = tours$finalweight[tours$TOURPURP>=5 & tours$TOURPURP<=6 & tours$FULLY_JOINT==0 & tours$IS_SUBTOUR == 0])
arri789 = wtd.hist(tours$ANCHOR_ARRIVE_BIN[tours$TOURPURP>=7 & tours$TOURPURP<=9 & tours$FULLY_JOINT==0 & tours$IS_SUBTOUR == 0], breaks = seq(1,48, by=1), freq = NULL, right=FALSE, weight = tours$finalweight[tours$TOURPURP>=7 & tours$TOURPURP<=9 & tours$FULLY_JOINT==0 & tours$IS_SUBTOUR == 0])
arrj56 = wtd.hist(jtours$ANCHOR_ARRIVE_BIN[jtours$JOINT_PURP>=5 & jtours$JOINT_PURP<=6], breaks = seq(1,48, by=1), freq = NULL, right=FALSE, weight = jtours$finalweight[jtours$JOINT_PURP>=5 & jtours$JOINT_PURP<=6])
arrj789 = wtd.hist(jtours$ANCHOR_ARRIVE_BIN[jtours$JOINT_PURP>=7 & jtours$JOINT_PURP<=9], breaks = seq(1,48, by=1), freq = NULL, right=FALSE, weight = jtours$finalweight[jtours$JOINT_PURP>=7 & jtours$JOINT_PURP<=9])
arr15 = wtd.hist(tours$ANCHOR_ARRIVE_BIN[tours$IS_SUBTOUR == 1], breaks = seq(1,48, by=1), freq = NULL, right=FALSE, weight = tours$finalweight[tours$IS_SUBTOUR == 1])


todArrProfile = data.frame(arr1$counts, arr2$counts, arr3$counts, arr4$counts, arri56$counts, arri789$counts
                            , arrj56$counts, arrj789$counts, arr15$counts)
colnames(todArrProfile) = c("work", "univ", "sch", "esc", "imain", "idisc", 
                             "jmain", "jdisc", "atwork")
write.csv(todArrProfile, "todArrProfile.csv")

# prepare input for visualizer
todArrProfile_vis = todArrProfile
todArrProfile_vis$id = row.names(todArrProfile_vis)
todArrProfile_vis = reshape2::melt(todArrProfile_vis, id = c("id"))
colnames(todArrProfile_vis) = c("id", "purpose", "freq_arr")

todArrProfile_vis$purpose = as.character(todArrProfile_vis$purpose)
todArrProfile_vis = xtabs(freq_arr~id+purpose, todArrProfile_vis)
todArrProfile_vis = addmargins(as.table(todArrProfile_vis))
todArrProfile_vis = as.data.frame.matrix(todArrProfile_vis)
todArrProfile_vis$id = row.names(todArrProfile_vis)
todArrProfile_vis = reshape2::melt(todArrProfile_vis, id = c("id"))
colnames(todArrProfile_vis) = c("timebin", "PURPOSE", "freq")
todArrProfile_vis$PURPOSE = as.character(todArrProfile_vis$PURPOSE)
todArrProfile_vis$timebin = as.character(todArrProfile_vis$timebin)
todArrProfile_vis = todArrProfile_vis[todArrProfile_vis$timebin!="Sum",]
todArrProfile_vis$PURPOSE[todArrProfile_vis$PURPOSE=="Sum"] = "Total"
todArrProfile_vis$timebin = as.numeric(todArrProfile_vis$timebin)

tours_posdur = tours[tours$TOUR_DUR_BIN_RECODE >= 1,]
jtours_posdur = jtours[jtours$TOUR_DUR_BIN_RECODE >= 1,]

dur1 = wtd.hist(tours_posdur$TOUR_DUR_BIN_RECODE[tours_posdur$TOURPURP==1 & tours_posdur$IS_SUBTOUR == 0], breaks = seq(1,48, by=1), freq = NULL, right=FALSE, weight = tours_posdur$finalweight[tours_posdur$TOURPURP==1 & tours_posdur$IS_SUBTOUR == 0])
dur2 = wtd.hist(tours_posdur$TOUR_DUR_BIN_RECODE[tours_posdur$TOURPURP==2 & tours_posdur$IS_SUBTOUR == 0], breaks = seq(1,48, by=1), freq = NULL, right=FALSE, weight = tours_posdur$finalweight[tours_posdur$TOURPURP==2 & tours_posdur$IS_SUBTOUR == 0])
dur3 = wtd.hist(tours_posdur$TOUR_DUR_BIN_RECODE[tours_posdur$TOURPURP==3 & tours_posdur$IS_SUBTOUR == 0], breaks = seq(1,48, by=1), freq = NULL, right=FALSE, weight = tours_posdur$finalweight[tours_posdur$TOURPURP==3 & tours_posdur$IS_SUBTOUR == 0])
dur4 = wtd.hist(tours_posdur$TOUR_DUR_BIN_RECODE[tours_posdur$TOURPURP==4 & tours_posdur$IS_SUBTOUR == 0], breaks = seq(1,48, by=1), freq = NULL, right=FALSE, weight = tours_posdur$finalweight[tours_posdur$TOURPURP==4 & tours_posdur$IS_SUBTOUR == 0])
duri56 = wtd.hist(tours_posdur$TOUR_DUR_BIN_RECODE[tours_posdur$TOURPURP>=5 & tours_posdur$TOURPURP<=6 & tours_posdur$FULLY_JOINT==0 & tours_posdur$IS_SUBTOUR == 0], breaks = seq(1,48, by=1), freq = NULL, right=FALSE, weight = tours_posdur$finalweight[tours_posdur$TOURPURP>=5 & tours_posdur$TOURPURP<=6 & tours_posdur$FULLY_JOINT==0 & tours_posdur$IS_SUBTOUR == 0])
duri789 = wtd.hist(tours_posdur$TOUR_DUR_BIN_RECODE[tours_posdur$TOURPURP>=7 & tours_posdur$TOURPURP<=9 & tours_posdur$FULLY_JOINT==0 & tours_posdur$IS_SUBTOUR == 0], breaks = seq(1,48, by=1), freq = NULL, right=FALSE, weight = tours_posdur$finalweight[tours_posdur$TOURPURP>=7 & tours_posdur$TOURPURP<=9 & tours_posdur$FULLY_JOINT==0 & tours_posdur$IS_SUBTOUR == 0])
durj56 = wtd.hist(jtours_posdur$TOUR_DUR_BIN_RECODE[jtours_posdur$JOINT_PURP>=5 & jtours_posdur$JOINT_PURP<=6], breaks = seq(1,48, by=1), freq = NULL, right=FALSE, weight = jtours_posdur$finalweight[jtours_posdur$JOINT_PURP>=5 & jtours_posdur$JOINT_PURP<=6])
durj789 = wtd.hist(jtours_posdur$TOUR_DUR_BIN_RECODE[jtours_posdur$JOINT_PURP>=7 & jtours_posdur$JOINT_PURP<=9], breaks = seq(1,48, by=1), freq = NULL, right=FALSE, weight = jtours_posdur$finalweight[jtours_posdur$JOINT_PURP>=7 & jtours_posdur$JOINT_PURP<=9])
dur15 = wtd.hist(tours_posdur$TOUR_DUR_BIN_RECODE[tours_posdur$IS_SUBTOUR == 1], breaks = seq(1,48, by=1), freq = NULL, right=FALSE, weight = tours_posdur$finalweight[tours_posdur$IS_SUBTOUR == 1])

todDurProfile = data.frame(dur1$counts, dur2$counts, dur3$counts, dur4$counts, duri56$counts, duri789$counts
                            , durj56$counts, durj789$counts, dur15$counts)
colnames(todDurProfile) = c("work", "univ", "sch", "esc", "imain", "idisc", 
                             "jmain", "jdisc", "atwork")
write.csv(todDurProfile, "todDurProfile.csv")

# prepare input for visualizer
todDurProfile_vis = todDurProfile
todDurProfile_vis$id = row.names(todDurProfile_vis)
todDurProfile_vis = reshape2::melt(todDurProfile_vis, id = c("id"))
colnames(todDurProfile_vis) = c("id", "purpose", "freq_dur")

todDurProfile_vis$purpose = as.character(todDurProfile_vis$purpose)
todDurProfile_vis = xtabs(freq_dur~id+purpose, todDurProfile_vis)
todDurProfile_vis = addmargins(as.table(todDurProfile_vis))
todDurProfile_vis = as.data.frame.matrix(todDurProfile_vis)
todDurProfile_vis$id = row.names(todDurProfile_vis)
todDurProfile_vis = reshape2::melt(todDurProfile_vis, id = c("id"))
colnames(todDurProfile_vis) = c("timebin", "PURPOSE", "freq")
todDurProfile_vis$PURPOSE = as.character(todDurProfile_vis$PURPOSE)
todDurProfile_vis$timebin = as.character(todDurProfile_vis$timebin)
todDurProfile_vis = todDurProfile_vis[todDurProfile_vis$timebin!="Sum",]
todDurProfile_vis$PURPOSE[todDurProfile_vis$PURPOSE=="Sum"] = "Total"
todDurProfile_vis$timebin = as.numeric(todDurProfile_vis$timebin)

todDepProfile_vis = todDepProfile_vis[order(todDepProfile_vis$timebin, todDepProfile_vis$PURPOSE), ]
todArrProfile_vis = todArrProfile_vis[order(todArrProfile_vis$timebin, todArrProfile_vis$PURPOSE), ]
todDurProfile_vis = todDurProfile_vis[order(todDurProfile_vis$timebin, todDurProfile_vis$PURPOSE), ]
todProfile_vis = data.frame(todDepProfile_vis, todArrProfile_vis$freq, todDurProfile_vis$freq)
colnames(todProfile_vis) = c("id", "purpose", "freq_dep", "freq_arr", "freq_dur")


write.csv(todProfile_vis, "todProfile_vis.csv", row.names = F)

# Tour Mode X Auto Suff
tour_original = tours
tours = subset(tours, TOURMODE <= 11)

# Correct for SOV on Walk Transit Tours
tours$HHPERTOUR_ID = 10000 * tours$HH_ID + 100 * tours$PER_ID + tours$TOUR_ID
trips$HHPERTOUR_ID = 10000 * trips$HH_ID + 100 * trips$PER_ID + trips$TOUR_ID

dbg_trips = trips[trips$TOURMODE == 6 & trips$TRIPMODE == 1,]

tours$TOURMODE_X = tours$TOURMODE
tours[tours$HHPERTOUR_ID %in% dbg_trips$HHPERTOUR_ID,]$TOURMODE = 1
trips[trips$HHPERTOUR_ID %in% dbg_trips$HHPERTOUR_ID,]$TOURMODE = 1
print("marker 10")
print(table(jtours$TOURMODE[jtours$JOINT_PURP>=4 & jtours$JOINT_PURP<=6 & jtours$AUTOSUFF==0]))
tmode1_as0 = wtd.hist(tours$TOURMODE[!is.na(tours$TOURMODE) & tours$TOURPURP==1 & tours$IS_SUBTOUR == 0 & tours$AUTOSUFF==0], breaks = seq(1,12, by=1), freq = NULL, right=FALSE, weight = tours$finalweight[!is.na(tours$TOURMODE) & tours$TOURPURP==1 & tours$IS_SUBTOUR == 0 & tours$AUTOSUFF==0])
tmode2_as0 = wtd.hist(tours$TOURMODE[!is.na(tours$TOURMODE) & tours$TOURPURP==2 & tours$IS_SUBTOUR == 0 & tours$AUTOSUFF==0], breaks = seq(1,12, by=1), freq = NULL, right=FALSE, weight = tours$finalweight[!is.na(tours$TOURMODE) & tours$TOURPURP==2 & tours$IS_SUBTOUR == 0 & tours$AUTOSUFF==0])
tmode3_as0 = wtd.hist(tours$TOURMODE[!is.na(tours$TOURMODE) & tours$TOURPURP==3 & tours$IS_SUBTOUR == 0 & tours$AUTOSUFF==0], breaks = seq(1,12, by=1), freq = NULL, right=FALSE, weight = tours$finalweight[!is.na(tours$TOURMODE) & tours$TOURPURP==3 & tours$IS_SUBTOUR == 0 & tours$AUTOSUFF==0])
tmode4_as0 = wtd.hist(tours$TOURMODE[!is.na(tours$TOURMODE) & tours$TOURPURP>=4 & tours$TOURPURP<=6 & tours$IS_SUBTOUR == 0 & tours$FULLY_JOINT==0 & tours$AUTOSUFF==0], breaks = seq(1,12, by=1), freq = NULL, right=FALSE, weight = tours$finalweight[!is.na(tours$TOURMODE) & tours$TOURPURP>=4 & tours$TOURPURP<=6 & tours$IS_SUBTOUR == 0 & tours$FULLY_JOINT==0 & tours$AUTOSUFF==0])
tmode5_as0 = wtd.hist(tours$TOURMODE[!is.na(tours$TOURMODE) & tours$TOURPURP>=7 & tours$TOURPURP<=9 & tours$IS_SUBTOUR == 0 & tours$FULLY_JOINT==0 & tours$AUTOSUFF==0], breaks = seq(1,12, by=1), freq = NULL, right=FALSE, weight = tours$finalweight[!is.na(tours$TOURMODE) & tours$TOURPURP>=7 & tours$TOURPURP<=9 & tours$IS_SUBTOUR == 0 & tours$FULLY_JOINT==0 & tours$AUTOSUFF==0])
tmode6_as0 = wtd.hist(jtours$TOURMODE[jtours$JOINT_PURP>=4 & jtours$JOINT_PURP<=6 & jtours$AUTOSUFF==0], breaks = seq(1,12, by=1), freq = NULL, right=FALSE, weight = jtours$finalweight[jtours$JOINT_PURP>=4 & jtours$JOINT_PURP<=6 & jtours$AUTOSUFF==0])
tmode7_as0 = wtd.hist(jtours$TOURMODE[jtours$JOINT_PURP>=7 & jtours$JOINT_PURP<=9 & jtours$AUTOSUFF==0], breaks = seq(1,12, by=1), freq = NULL, right=FALSE, weight = jtours$finalweight[jtours$JOINT_PURP>=7 & jtours$JOINT_PURP<=9 & jtours$AUTOSUFF==0])
tmode8_as0 = wtd.hist(tours$TOURMODE[!is.na(tours$TOURMODE) & tours$IS_SUBTOUR==1 & tours$AUTOSUFF==0], breaks = seq(1,12, by=1), freq = NULL, right=FALSE, weight = tours$finalweight[!is.na(tours$TOURMODE) & tours$IS_SUBTOUR==1 & tours$AUTOSUFF==0])

tmodeAS0Profile = data.frame(tmode1_as0$counts, tmode2_as0$counts, tmode3_as0$counts, tmode4_as0$counts,
                              tmode5_as0$counts, tmode6_as0$counts, tmode7_as0$counts, tmode8_as0$counts)
colnames(tmodeAS0Profile) = c("work", "univ", "sch", "imain", "idisc", "jmain", "jdisc", "atwork")
write.csv(tmodeAS0Profile, "tmodeAS0Profile_HTS.csv")
print("marker 11")
# Prepeare data for visualizer
tmodeAS0Profile_vis = tmodeAS0Profile[1:10,]
tmodeAS0Profile_vis$id = row.names(tmodeAS0Profile_vis)
tmodeAS0Profile_vis = reshape2::melt(tmodeAS0Profile_vis, id = c("id"))
colnames(tmodeAS0Profile_vis) = c("id", "purpose", "freq_as0")

tmodeAS0Profile_vis = xtabs(freq_as0~id+purpose, tmodeAS0Profile_vis)
tmodeAS0Profile_vis[is.na(tmodeAS0Profile_vis)] = 0
tmodeAS0Profile_vis = addmargins(as.table(tmodeAS0Profile_vis))
tmodeAS0Profile_vis = as.data.frame.matrix(tmodeAS0Profile_vis)

tmodeAS0Profile_vis$id = row.names(tmodeAS0Profile_vis)
tmodeAS0Profile_vis = reshape2::melt(tmodeAS0Profile_vis, id = c("id"))
colnames(tmodeAS0Profile_vis) = c("id", "purpose", "freq_as0")
tmodeAS0Profile_vis$id = as.character(tmodeAS0Profile_vis$id)
tmodeAS0Profile_vis$purpose = as.character(tmodeAS0Profile_vis$purpose)
tmodeAS0Profile_vis = tmodeAS0Profile_vis[tmodeAS0Profile_vis$id!="Sum",]
tmodeAS0Profile_vis$purpose[tmodeAS0Profile_vis$purpose=="Sum"] = "Total"


tmode1_as1 = wtd.hist(tours$TOURMODE[!is.na(tours$TOURMODE) & tours$TOURPURP==1 & tours$IS_SUBTOUR == 0 & tours$AUTOSUFF==1], breaks = seq(1,12, by=1), freq = NULL, right=FALSE, weight = tours$finalweight[!is.na(tours$TOURMODE) & tours$TOURPURP==1 & tours$IS_SUBTOUR == 0 & tours$AUTOSUFF==1])
tmode2_as1 = wtd.hist(tours$TOURMODE[!is.na(tours$TOURMODE) & tours$TOURPURP==2 & tours$IS_SUBTOUR == 0 & tours$AUTOSUFF==1], breaks = seq(1,12, by=1), freq = NULL, right=FALSE, weight = tours$finalweight[!is.na(tours$TOURMODE) & tours$TOURPURP==2 & tours$IS_SUBTOUR == 0 & tours$AUTOSUFF==1])
tmode3_as1 = wtd.hist(tours$TOURMODE[!is.na(tours$TOURMODE) & tours$TOURPURP==3 & tours$IS_SUBTOUR == 0 & tours$AUTOSUFF==1], breaks = seq(1,12, by=1), freq = NULL, right=FALSE, weight = tours$finalweight[!is.na(tours$TOURMODE) & tours$TOURPURP==3 & tours$IS_SUBTOUR == 0 & tours$AUTOSUFF==1])
tmode4_as1 = wtd.hist(tours$TOURMODE[!is.na(tours$TOURMODE) & tours$TOURPURP>=4 & tours$TOURPURP<=6 & tours$IS_SUBTOUR == 0 & tours$FULLY_JOINT==0 & tours$AUTOSUFF==1], breaks = seq(1,12, by=1), freq = NULL, right=FALSE, weight = tours$finalweight[!is.na(tours$TOURMODE) & tours$TOURPURP>=4 & tours$TOURPURP<=6 & tours$IS_SUBTOUR == 0 & tours$FULLY_JOINT==0 & tours$AUTOSUFF==1])
tmode5_as1 = wtd.hist(tours$TOURMODE[!is.na(tours$TOURMODE) & tours$TOURPURP>=7 & tours$TOURPURP<=9 & tours$IS_SUBTOUR == 0 & tours$FULLY_JOINT==0 & tours$AUTOSUFF==1], breaks = seq(1,12, by=1), freq = NULL, right=FALSE, weight = tours$finalweight[!is.na(tours$TOURMODE) & tours$TOURPURP>=7 & tours$TOURPURP<=9 & tours$IS_SUBTOUR == 0 & tours$FULLY_JOINT==0 & tours$AUTOSUFF==1])
tmode6_as1 = wtd.hist(jtours$TOURMODE[jtours$JOINT_PURP>=4 & jtours$JOINT_PURP<=6 & jtours$AUTOSUFF==1], breaks = seq(1,12, by=1), freq = NULL, right=FALSE, weight = jtours$finalweight[jtours$JOINT_PURP>=4 & jtours$JOINT_PURP<=6 & jtours$AUTOSUFF==1])
tmode7_as1 = wtd.hist(jtours$TOURMODE[jtours$JOINT_PURP>=7 & jtours$JOINT_PURP<=9 & jtours$AUTOSUFF==1], breaks = seq(1,12, by=1), freq = NULL, right=FALSE, weight = jtours$finalweight[jtours$JOINT_PURP>=7 & jtours$JOINT_PURP<=9 & jtours$AUTOSUFF==1])
tmode8_as1 = wtd.hist(tours$TOURMODE[!is.na(tours$TOURMODE) & tours$IS_SUBTOUR==1 & tours$AUTOSUFF==1], breaks = seq(1,12, by=1), freq = NULL, right=FALSE, weight = tours$finalweight[!is.na(tours$TOURMODE) & tours$IS_SUBTOUR==1 & tours$AUTOSUFF==1])

tmodeAS1Profile = data.frame(tmode1_as1$counts, tmode2_as1$counts, tmode3_as1$counts, tmode4_as1$counts,
                              tmode5_as1$counts, tmode6_as1$counts, tmode7_as1$counts, tmode8_as1$counts)
colnames(tmodeAS1Profile) = c("work", "univ", "sch", "imain", "idisc", "jmain", "jdisc", "atwork")
write.csv(tmodeAS1Profile, "tmodeAS1Profile_HTS.csv")

# Prepeare data for visualizer
tmodeAS1Profile_vis = tmodeAS1Profile[1:10,]
tmodeAS1Profile_vis$id = row.names(tmodeAS1Profile_vis)
tmodeAS1Profile_vis = reshape2::melt(tmodeAS1Profile_vis, id = c("id"))
colnames(tmodeAS1Profile_vis) = c("id", "purpose", "freq_as1")

tmodeAS1Profile_vis = xtabs(freq_as1~id+purpose, tmodeAS1Profile_vis)
tmodeAS1Profile_vis[is.na(tmodeAS1Profile_vis)] = 0
tmodeAS1Profile_vis = addmargins(as.table(tmodeAS1Profile_vis))
tmodeAS1Profile_vis = as.data.frame.matrix(tmodeAS1Profile_vis)

tmodeAS1Profile_vis$id = row.names(tmodeAS1Profile_vis)
tmodeAS1Profile_vis = reshape2::melt(tmodeAS1Profile_vis, id = c("id"))
colnames(tmodeAS1Profile_vis) = c("id", "purpose", "freq_as1")
tmodeAS1Profile_vis$id = as.character(tmodeAS1Profile_vis$id)
tmodeAS1Profile_vis$purpose = as.character(tmodeAS1Profile_vis$purpose)
tmodeAS1Profile_vis = tmodeAS1Profile_vis[tmodeAS1Profile_vis$id!="Sum",]
tmodeAS1Profile_vis$purpose[tmodeAS1Profile_vis$purpose=="Sum"] = "Total"

tmode1_as2 = wtd.hist(tours$TOURMODE[!is.na(tours$TOURMODE) & tours$TOURPURP==1 & tours$IS_SUBTOUR == 0 & tours$AUTOSUFF==2], 
                       breaks = seq(1,12, by=1), freq = NULL, right=FALSE, 
                       weight = tours$finalweight[!is.na(tours$TOURMODE) & tours$TOURPURP==1 & tours$IS_SUBTOUR == 0 & tours$AUTOSUFF==2])
tmode2_as2 = wtd.hist(tours$TOURMODE[!is.na(tours$TOURMODE) & tours$TOURPURP==2 & tours$IS_SUBTOUR == 0 & tours$AUTOSUFF==2], breaks = seq(1,12, by=1), freq = NULL, right=FALSE, weight = tours$finalweight[!is.na(tours$TOURMODE) & tours$TOURPURP==2 & tours$IS_SUBTOUR == 0 & tours$AUTOSUFF==2])
tmode3_as2 = wtd.hist(tours$TOURMODE[!is.na(tours$TOURMODE) & tours$TOURPURP==3 & tours$IS_SUBTOUR == 0 & tours$AUTOSUFF==2], breaks = seq(1,12, by=1), freq = NULL, right=FALSE, weight = tours$finalweight[!is.na(tours$TOURMODE) & tours$TOURPURP==3 & tours$IS_SUBTOUR == 0 & tours$AUTOSUFF==2])
tmode4_as2 = wtd.hist(tours$TOURMODE[!is.na(tours$TOURMODE) & tours$TOURPURP>=4 & tours$TOURPURP<=6 & tours$IS_SUBTOUR == 0 & tours$FULLY_JOINT==0 & tours$AUTOSUFF==2], breaks = seq(1,12, by=1), freq = NULL, right=FALSE, weight = tours$finalweight[!is.na(tours$TOURMODE) & tours$TOURPURP>=4 & tours$TOURPURP<=6 & tours$IS_SUBTOUR == 0 & tours$FULLY_JOINT==0 & tours$AUTOSUFF==2])
tmode5_as2 = wtd.hist(tours$TOURMODE[!is.na(tours$TOURMODE) & tours$TOURPURP>=7 & tours$TOURPURP<=9 & tours$IS_SUBTOUR == 0 & tours$FULLY_JOINT==0 & tours$AUTOSUFF==2], breaks = seq(1,12, by=1), freq = NULL, right=FALSE, weight = tours$finalweight[!is.na(tours$TOURMODE) & tours$TOURPURP>=7 & tours$TOURPURP<=9 & tours$IS_SUBTOUR == 0 & tours$FULLY_JOINT==0 & tours$AUTOSUFF==2])
tmode6_as2 = wtd.hist(jtours$TOURMODE[jtours$JOINT_PURP>=4 & jtours$JOINT_PURP<=6 & jtours$AUTOSUFF==2], breaks = seq(1,12, by=1), freq = NULL, right=FALSE, weight = jtours$finalweight[jtours$JOINT_PURP>=4 & jtours$JOINT_PURP<=6 & jtours$AUTOSUFF==2])
tmode7_as2 = wtd.hist(jtours$TOURMODE[jtours$JOINT_PURP>=7 & jtours$JOINT_PURP<=9 & jtours$AUTOSUFF==2], breaks = seq(1,12, by=1), freq = NULL, right=FALSE, weight = jtours$finalweight[jtours$JOINT_PURP>=7 & jtours$JOINT_PURP<=9 & jtours$AUTOSUFF==2])
tmode8_as2 = wtd.hist(tours$TOURMODE[!is.na(tours$TOURMODE) & tours$IS_SUBTOUR==1 & tours$AUTOSUFF==2], breaks = seq(1,12, by=1), freq = NULL, right=FALSE, weight = tours$finalweight[!is.na(tours$TOURMODE) & tours$IS_SUBTOUR==1 & tours$AUTOSUFF==2])

tmodeAS2Profile = data.frame(tmode1_as2$counts, tmode2_as2$counts, tmode3_as2$counts, tmode4_as2$counts,
                              tmode5_as2$counts, tmode6_as2$counts, tmode7_as2$counts, tmode8_as2$counts)
colnames(tmodeAS2Profile) = c("work", "univ", "sch", "imain", "idisc", "jmain", "jdisc", "atwork")
write.csv(tmodeAS2Profile, "tmodeAS2Profile_HTS.csv")

# Prepeare data for visualizer
tmodeAS2Profile_vis = tmodeAS2Profile[1:10,]
tmodeAS2Profile_vis$id = row.names(tmodeAS2Profile_vis)
tmodeAS2Profile_vis = reshape2::melt(tmodeAS2Profile_vis, id = c("id"))
colnames(tmodeAS2Profile_vis) = c("id", "purpose", "freq_as2")

tmodeAS2Profile_vis = xtabs(freq_as2~id+purpose, tmodeAS2Profile_vis)
tmodeAS2Profile_vis[is.na(tmodeAS2Profile_vis)] = 0
tmodeAS2Profile_vis = addmargins(as.table(tmodeAS2Profile_vis))
tmodeAS2Profile_vis = as.data.frame.matrix(tmodeAS2Profile_vis)

tmodeAS2Profile_vis$id = row.names(tmodeAS2Profile_vis)
tmodeAS2Profile_vis = reshape2::melt(tmodeAS2Profile_vis, id = c("id"))
colnames(tmodeAS2Profile_vis) = c("id", "purpose", "freq_as2")
tmodeAS2Profile_vis$id = as.character(tmodeAS2Profile_vis$id)
tmodeAS2Profile_vis$purpose = as.character(tmodeAS2Profile_vis$purpose)
tmodeAS2Profile_vis = tmodeAS2Profile_vis[tmodeAS2Profile_vis$id!="Sum",]
tmodeAS2Profile_vis$purpose[tmodeAS2Profile_vis$purpose=="Sum"] = "Total"


# Combine three AS groups
tmodeProfile_vis = data.frame(tmodeAS0Profile_vis, tmodeAS1Profile_vis$freq_as1, tmodeAS2Profile_vis$freq_as2)
colnames(tmodeProfile_vis) = c("id", "purpose", "freq_as0", "freq_as1", "freq_as2")
tmodeProfile_vis$freq_all = tmodeProfile_vis$freq_as0 + tmodeProfile_vis$freq_as1 + tmodeProfile_vis$freq_as2
write.csv(tmodeProfile_vis, "tmodeProfile_vis_HTS.csv", row.names = F)

tours = tour_original

# Non-mandatory tour distance profile
tourdist4 = wtd.hist(tours$SKIMDIST[tours$TOURPURP==4 & tours$IS_SUBTOUR == 0 & !(is.na(tours$SKIMDIST))], breaks = c(seq(0,40, by=1), 9999), freq = NULL, right=FALSE, weight = tours$finalweight[tours$TOURPURP==4 & tours$IS_SUBTOUR == 0 & !(is.na(tours$SKIMDIST))])
tourdisti56 = wtd.hist(tours$SKIMDIST[tours$TOURPURP>=5 & tours$TOURPURP<=6 & tours$IS_SUBTOUR == 0 & tours$FULLY_JOINT==0 & !(is.na(tours$SKIMDIST))], breaks = c(seq(0,40, by=1), 9999), freq = NULL, right=FALSE, weight = tours$finalweight[tours$TOURPURP>=5 & tours$TOURPURP<=6 & tours$IS_SUBTOUR == 0 & tours$FULLY_JOINT==0 & !(is.na(tours$SKIMDIST))])
tourdisti789 = wtd.hist(tours$SKIMDIST[tours$TOURPURP>=7 & tours$TOURPURP<=9 & tours$IS_SUBTOUR == 0 & tours$FULLY_JOINT==0 & !(is.na(tours$SKIMDIST))], breaks = c(seq(0,40, by=1), 9999), freq = NULL, right=FALSE, weight = tours$finalweight[tours$TOURPURP>=7 & tours$TOURPURP<=9 & tours$IS_SUBTOUR == 0 & tours$FULLY_JOINT==0 & !(is.na(tours$SKIMDIST))])
tourdistj56 = wtd.hist(jtours$SKIMDIST[jtours$JOINT_PURP>=5 & jtours$JOINT_PURP<=6 & !(is.na(jtours$SKIMDIST))], breaks = c(seq(0,40, by=1), 9999), freq = NULL, right=FALSE, weight = jtours$finalweight[jtours$JOINT_PURP>=5 & jtours$JOINT_PURP<=6 & !(is.na(jtours$SKIMDIST))])
tourdistj789 = wtd.hist(jtours$SKIMDIST[jtours$JOINT_PURP>=7 & jtours$JOINT_PURP<=9 & !(is.na(jtours$SKIMDIST))], breaks = c(seq(0,40, by=1), 9999), freq = NULL, right=FALSE, weight = jtours$finalweight[jtours$JOINT_PURP>=7 & jtours$JOINT_PURP<=9 & !(is.na(jtours$SKIMDIST))])
tourdist10 = wtd.hist(tours$SKIMDIST[tours$IS_SUBTOUR == 1 & !(is.na(tours$SKIMDIST))], breaks = c(seq(0,40, by=1), 9999), freq = NULL, right=FALSE, weight = tours$finalweight[tours$IS_SUBTOUR == 1 & !(is.na(tours$SKIMDIST))])

tourDistProfile = data.frame(tourdist4$counts, tourdisti56$counts, tourdisti789$counts, tourdistj56$counts, tourdistj789$counts, tourdist10$counts)
colnames(tourDistProfile) = c("esco", "imain", "idisc", "jmain", "jdisc", "atwork")
write.csv(tourDistProfile, "nonMandTourDistProfile.csv")

#prepare input for visualizer
tourDistProfile_vis = tourDistProfile
tourDistProfile_vis$id = row.names(tourDistProfile_vis)
tourDistProfile_vis = reshape2::melt(tourDistProfile_vis, id = c("id"))
colnames(tourDistProfile_vis) = c("id", "purpose", "freq")

tourDistProfile_vis = xtabs(freq~id+purpose, tourDistProfile_vis)
tourDistProfile_vis = addmargins(as.table(tourDistProfile_vis))
tourDistProfile_vis = as.data.frame.matrix(tourDistProfile_vis)
tourDistProfile_vis$id = row.names(tourDistProfile_vis)
tourDistProfile_vis = reshape2::melt(tourDistProfile_vis, id = c("id"))
colnames(tourDistProfile_vis) = c("distbin", "PURPOSE", "freq")
tourDistProfile_vis$PURPOSE = as.character(tourDistProfile_vis$PURPOSE)
tourDistProfile_vis$distbin = as.character(tourDistProfile_vis$distbin)
tourDistProfile_vis = tourDistProfile_vis[tourDistProfile_vis$distbin!="Sum",]
tourDistProfile_vis$PURPOSE[tourDistProfile_vis$PURPOSE=="Sum"] = "Total"
tourDistProfile_vis$distbin = as.numeric(tourDistProfile_vis$distbin)

write.csv(tourDistProfile_vis, "tourDistProfile_vis.csv", row.names = F)

cat("\n Average Tour Distance [esco]: ", weighted.mean(tours$SKIMDIST[tours$TOURPURP==4 & tours$IS_SUBTOUR == 0], tours$finalweight[tours$TOURPURP==4 & tours$IS_SUBTOUR == 0], na.rm = TRUE))
cat("\n Average Tour Distance [imain]: ", weighted.mean(tours$SKIMDIST[tours$TOURPURP>=5 & tours$TOURPURP<=6 & tours$IS_SUBTOUR == 0 & tours$FULLY_JOINT==0], tours$finalweight[tours$TOURPURP>=5 & tours$TOURPURP<=6 & tours$IS_SUBTOUR == 0 & tours$FULLY_JOINT==0], na.rm = TRUE))
cat("\n Average Tour Distance [idisc]: ", weighted.mean(tours$SKIMDIST[tours$TOURPURP>=7 & tours$TOURPURP<=9 & tours$IS_SUBTOUR == 0 & tours$FULLY_JOINT==0], tours$finalweight[tours$TOURPURP>=7 & tours$TOURPURP<=9 & tours$IS_SUBTOUR == 0 & tours$FULLY_JOINT==0], na.rm = TRUE))
cat("\n Average Tour Distance [jmain]: ", weighted.mean(jtours$SKIMDIST[jtours$JOINT_PURP>=5 & jtours$JOINT_PURP<=6], jtours$finalweight[jtours$JOINT_PURP>=5 & jtours$JOINT_PURP<=6], na.rm = TRUE))
cat("\n Average Tour Distance [jdisc]: ", weighted.mean(jtours$SKIMDIST[jtours$JOINT_PURP>=7 & jtours$JOINT_PURP<=9], jtours$finalweight[jtours$JOINT_PURP>=7 & jtours$JOINT_PURP<=9], na.rm = TRUE))
cat("\n Average Tour Distance [atwork]: ", weighted.mean(tours$SKIMDIST[tours$IS_SUBTOUR == 1], tours$finalweight[tours$IS_SUBTOUR == 1], na.rm = TRUE))

## Output average trips lengths for visualizer

avgTripLengths = c(weighted.mean(tours$SKIMDIST[tours$TOURPURP==4 & tours$IS_SUBTOUR == 0], tours$finalweight[tours$TOURPURP==4 & tours$IS_SUBTOUR == 0], na.rm = TRUE),
                    weighted.mean(tours$SKIMDIST[tours$TOURPURP>=5 & tours$TOURPURP<=6 & tours$IS_SUBTOUR == 0 & tours$FULLY_JOINT==0], tours$finalweight[tours$TOURPURP>=5 & tours$TOURPURP<=6 & tours$IS_SUBTOUR == 0 & tours$FULLY_JOINT==0], na.rm = TRUE),
                    weighted.mean(tours$SKIMDIST[tours$TOURPURP>=7 & tours$TOURPURP<=9 & tours$IS_SUBTOUR == 0 & tours$FULLY_JOINT==0], tours$finalweight[tours$TOURPURP>=7 & tours$TOURPURP<=9 & tours$IS_SUBTOUR == 0 & tours$FULLY_JOINT==0], na.rm = TRUE),
                    weighted.mean(jtours$SKIMDIST[jtours$JOINT_PURP>=5 & jtours$JOINT_PURP<=6], jtours$finalweight[jtours$JOINT_PURP>=5 & jtours$JOINT_PURP<=6], na.rm = TRUE),
                    weighted.mean(jtours$SKIMDIST[jtours$JOINT_PURP>=7 & jtours$JOINT_PURP<=9], jtours$finalweight[jtours$JOINT_PURP>=7 & jtours$JOINT_PURP<=9], na.rm = TRUE),
                    weighted.mean(tours$SKIMDIST[tours$IS_SUBTOUR == 1], tours$finalweight[tours$IS_SUBTOUR == 1], na.rm = TRUE))


nmSkimDist = c(tours$SKIMDIST[tours$TOURPURP %in% c(4) & tours$IS_SUBTOUR == 0],
                tours$SKIMDIST[tours$TOURPURP %in% c(5,6,7,8,9) & tours$FULLY_JOINT==0 & tours$IS_SUBTOUR == 0],
                tours$SKIMDIST[tours$IS_SUBTOUR==1],
                jtours$SKIMDIST[jtours$JOINT_PURP %in% c(5,6,7,8,9)])
nmWeights  = c(tours$finalweight[tours$TOURPURP %in% c(4) & tours$IS_SUBTOUR == 0],
                tours$finalweight[tours$TOURPURP %in% c(5,6,7,8,9) & tours$FULLY_JOINT==0 & tours$IS_SUBTOUR == 0],
                tours$finalweight[tours$IS_SUBTOUR==1],
                jtours$finalweight[jtours$JOINT_PURP %in% c(5,6,7,8,9)])

totAvgNonMand = weighted.mean(nmSkimDist, nmWeights, na.rm = TRUE)

avgTripLengths = c(avgTripLengths, totAvgNonMand)

nonMandTourPurpose = c("esco", "imain", "idisc", "jmain", "jdisc", "atwork", "Total")

nonMandTripLengths = data.frame(purpose = nonMandTourPurpose, avgTripLength = avgTripLengths)

write.csv(nonMandTripLengths, "nonMandTripLengths.csv", row.names = F)


# STop Frequency
#Outbound
stopfreq1 = wtd.hist(tours$OUTBOUND_STOPS[tours$TOURPURP==1 & tours$IS_SUBTOUR == 0], breaks = c(seq(0,3, by=1), 9999), freq = NULL, right=FALSE, weight = tours$finalweight[tours$TOURPURP==1 & tours$IS_SUBTOUR == 0])
stopfreq2 = wtd.hist(tours$OUTBOUND_STOPS[tours$TOURPURP==2 & tours$IS_SUBTOUR == 0], breaks = c(seq(0,3, by=1), 9999), freq = NULL, right=FALSE, weight = tours$finalweight[tours$TOURPURP==2 & tours$IS_SUBTOUR == 0])
stopfreq3 = wtd.hist(tours$OUTBOUND_STOPS[tours$TOURPURP==3 & tours$IS_SUBTOUR == 0], breaks = c(seq(0,3, by=1), 9999), freq = NULL, right=FALSE, weight = tours$finalweight[tours$TOURPURP==3 & tours$IS_SUBTOUR == 0])
stopfreq4 = wtd.hist(tours$OUTBOUND_STOPS[tours$TOURPURP==4 & tours$IS_SUBTOUR == 0], breaks = c(seq(0,3, by=1), 9999), freq = NULL, right=FALSE, weight = tours$finalweight[tours$TOURPURP==4 & tours$IS_SUBTOUR == 0])
stopfreqi56 = wtd.hist(tours$OUTBOUND_STOPS[tours$TOURPURP>=5 & tours$TOURPURP<=6 & tours$FULLY_JOINT==0 & tours$IS_SUBTOUR == 0], breaks = c(seq(0,3, by=1), 9999), freq = NULL, right=FALSE, weight = tours$finalweight[tours$TOURPURP>=5 & tours$TOURPURP<=6 & tours$FULLY_JOINT==0 & tours$IS_SUBTOUR == 0])
stopfreqi789 = wtd.hist(tours$OUTBOUND_STOPS[tours$TOURPURP>=7 & tours$TOURPURP<=9 & tours$FULLY_JOINT==0 & tours$IS_SUBTOUR == 0], breaks = c(seq(0,3, by=1), 9999), freq = NULL, right=FALSE, weight = tours$finalweight[tours$TOURPURP>=7 & tours$TOURPURP<=9 & tours$FULLY_JOINT==0 & tours$IS_SUBTOUR == 0])
stopfreqj56 = wtd.hist(jtours$OUTBOUND_STOPS[jtours$JOINT_PURP>=5 & jtours$JOINT_PURP<=6], breaks = c(seq(0,3, by=1), 9999), freq = NULL, right=FALSE, weight = jtours$finalweight[jtours$JOINT_PURP>=5 & jtours$JOINT_PURP<=6])
stopfreqj789 = wtd.hist(jtours$OUTBOUND_STOPS[jtours$JOINT_PURP>=7 & jtours$JOINT_PURP<=9], breaks = c(seq(0,3, by=1), 9999), freq = NULL, right=FALSE, weight = jtours$finalweight[jtours$JOINT_PURP>=7 & jtours$JOINT_PURP<=9])
stopfreq10 = wtd.hist(tours$OUTBOUND_STOPS[tours$IS_SUBTOUR == 1], breaks = c(seq(0,3, by=1), 9999), freq = NULL, right=FALSE, weight = tours$finalweight[tours$IS_SUBTOUR == 1])

stopFreq = data.frame(stopfreq1$counts, stopfreq2$counts, stopfreq3$counts, stopfreq4$counts, stopfreqi56$counts
                       , stopfreqi789$counts, stopfreqj56$counts, stopfreqj789$counts, stopfreq10$counts)
colnames(stopFreq) = c("work", "univ", "sch", "esco","imain", "idisc", "jmain", "jdisc", "atwork")
write.csv(stopFreq, "stopFreqOutProfile.csv")

# prepare stop frequency input for visualizer
stopFreqout_vis = stopFreq
stopFreqout_vis$id = row.names(stopFreqout_vis)
stopFreqout_vis = reshape2::melt(stopFreqout_vis, id = c("id"))
colnames(stopFreqout_vis) = c("id", "purpose", "freq")

stopFreqout_vis = xtabs(freq~purpose+id, stopFreqout_vis)
stopFreqout_vis = addmargins(as.table(stopFreqout_vis))
stopFreqout_vis = as.data.frame.matrix(stopFreqout_vis)
stopFreqout_vis$id = row.names(stopFreqout_vis)
stopFreqout_vis = reshape2::melt(stopFreqout_vis, id = c("id"))
colnames(stopFreqout_vis) = c("purpose", "nstops", "freq")
stopFreqout_vis$purpose = as.character(stopFreqout_vis$purpose)
stopFreqout_vis$nstops = as.character(stopFreqout_vis$nstops)
stopFreqout_vis = stopFreqout_vis[stopFreqout_vis$nstops!="Sum",]
stopFreqout_vis$purpose[stopFreqout_vis$purpose=="Sum"] = "Total"


#Inbound
stopfreq1 = wtd.hist(tours$INBOUND_STOPS[tours$TOURPURP==1 & tours$IS_SUBTOUR == 0], breaks = c(seq(0,3, by=1), 9999), freq = NULL, right=FALSE, weight = tours$finalweight[tours$TOURPURP==1 & tours$IS_SUBTOUR == 0])
stopfreq2 = wtd.hist(tours$INBOUND_STOPS[tours$TOURPURP==2 & tours$IS_SUBTOUR == 0], breaks = c(seq(0,3, by=1), 9999), freq = NULL, right=FALSE, weight = tours$finalweight[tours$TOURPURP==2 & tours$IS_SUBTOUR == 0])
stopfreq3 = wtd.hist(tours$INBOUND_STOPS[tours$TOURPURP==3 & tours$IS_SUBTOUR == 0], breaks = c(seq(0,3, by=1), 9999), freq = NULL, right=FALSE, weight = tours$finalweight[tours$TOURPURP==3 & tours$IS_SUBTOUR == 0])
stopfreq4 = wtd.hist(tours$INBOUND_STOPS[tours$TOURPURP==4 & tours$IS_SUBTOUR == 0], breaks = c(seq(0,3, by=1), 9999), freq = NULL, right=FALSE, weight = tours$finalweight[tours$TOURPURP==4 & tours$IS_SUBTOUR == 0])
stopfreqi56 = wtd.hist(tours$INBOUND_STOPS[tours$TOURPURP>=5 & tours$TOURPURP<=6 & tours$FULLY_JOINT==0 & tours$IS_SUBTOUR == 0], breaks = c(seq(0,3, by=1), 9999), freq = NULL, right=FALSE, weight = tours$finalweight[tours$TOURPURP>=5 & tours$TOURPURP<=6 & tours$FULLY_JOINT==0 & tours$IS_SUBTOUR == 0])
stopfreqi789 = wtd.hist(tours$INBOUND_STOPS[tours$TOURPURP>=7 & tours$TOURPURP<=9 & tours$FULLY_JOINT==0 & tours$IS_SUBTOUR == 0], breaks = c(seq(0,3, by=1), 9999), freq = NULL, right=FALSE, weight = tours$finalweight[tours$TOURPURP>=7 & tours$TOURPURP<=9 & tours$FULLY_JOINT==0 & tours$IS_SUBTOUR == 0])
stopfreqj56 = wtd.hist(jtours$INBOUND_STOPS[jtours$JOINT_PURP>=5 & jtours$JOINT_PURP<=6], breaks = c(seq(0,3, by=1), 9999), freq = NULL, right=FALSE, weight = jtours$finalweight[jtours$JOINT_PURP>=5 & jtours$JOINT_PURP<=6])
stopfreqj789 = wtd.hist(jtours$INBOUND_STOPS[jtours$JOINT_PURP>=7 & jtours$JOINT_PURP<=9], breaks = c(seq(0,3, by=1), 9999), freq = NULL, right=FALSE, weight = jtours$finalweight[jtours$JOINT_PURP>=7 & jtours$JOINT_PURP<=9])
stopfreq10 = wtd.hist(tours$INBOUND_STOPS[tours$IS_SUBTOUR == 1], breaks = c(seq(0,3, by=1), 9999), freq = NULL, right=FALSE, weight = tours$finalweight[tours$IS_SUBTOUR == 1])

stopFreq = data.frame(stopfreq1$counts, stopfreq2$counts, stopfreq3$counts, stopfreq4$counts, stopfreqi56$counts
                       , stopfreqi789$counts, stopfreqj56$counts, stopfreqj789$counts, stopfreq10$counts)
colnames(stopFreq) = c("work", "univ", "sch", "esco","imain", "idisc", "jmain", "jdisc", "atwork")
write.csv(stopFreq, "stopFreqInbProfile.csv")

# prepare stop frequency input for visualizer
stopFreqinb_vis = stopFreq
stopFreqinb_vis$id = row.names(stopFreqinb_vis)
stopFreqinb_vis = reshape2::melt(stopFreqinb_vis, id = c("id"))
colnames(stopFreqinb_vis) = c("id", "purpose", "freq")

stopFreqinb_vis = xtabs(freq~purpose+id, stopFreqinb_vis)
stopFreqinb_vis = addmargins(as.table(stopFreqinb_vis))
stopFreqinb_vis = as.data.frame.matrix(stopFreqinb_vis)
stopFreqinb_vis$id = row.names(stopFreqinb_vis)
stopFreqinb_vis = reshape2::melt(stopFreqinb_vis, id = c("id"))
colnames(stopFreqinb_vis) = c("purpose", "nstops", "freq")
stopFreqinb_vis$purpose = as.character(stopFreqinb_vis$purpose)
stopFreqinb_vis$nstops = as.character(stopFreqinb_vis$nstops)
stopFreqinb_vis = stopFreqinb_vis[stopFreqinb_vis$nstops!="Sum",]
stopFreqinb_vis$purpose[stopFreqinb_vis$purpose=="Sum"] = "Total"


stopfreqDir_vis = data.frame(stopFreqout_vis, stopFreqinb_vis$freq)
colnames(stopfreqDir_vis) = c("purpose", "nstops", "freq_out", "freq_inb")
write.csv(stopfreqDir_vis, "stopfreqDir_vis.csv", row.names = F)


#Total

# computing adjusted total stops by capping outbound and inbound stops at 3
# to be consistent with model
tours$TOTAL_STOPS_ABM = ifelse(tours$OUTBOUND_STOPS>=3, 3, tours$OUTBOUND_STOPS) + ifelse(tours$INBOUND_STOPS>=3, 3, tours$INBOUND_STOPS)
jtours$TOTAL_STOPS_ABM = ifelse(jtours$OUTBOUND_STOPS>=3, 3, jtours$OUTBOUND_STOPS) + ifelse(jtours$INBOUND_STOPS>=3, 3, jtours$INBOUND_STOPS)

stopfreq1 = wtd.hist(tours$TOTAL_STOPS_ABM[tours$TOURPURP==1 & tours$IS_SUBTOUR == 0], breaks = c(seq(0,6, by=1), 9999), freq = NULL, right=FALSE, weight = tours$finalweight[tours$TOURPURP==1 & tours$IS_SUBTOUR == 0])
stopfreq2 = wtd.hist(tours$TOTAL_STOPS_ABM[tours$TOURPURP==2 & tours$IS_SUBTOUR == 0], breaks = c(seq(0,6, by=1), 9999), freq = NULL, right=FALSE, weight = tours$finalweight[tours$TOURPURP==2 & tours$IS_SUBTOUR == 0])
stopfreq3 = wtd.hist(tours$TOTAL_STOPS_ABM[tours$TOURPURP==3 & tours$IS_SUBTOUR == 0], breaks = c(seq(0,6, by=1), 9999), freq = NULL, right=FALSE, weight = tours$finalweight[tours$TOURPURP==3 & tours$IS_SUBTOUR == 0])
stopfreq4 = wtd.hist(tours$TOTAL_STOPS_ABM[tours$TOURPURP==4 & tours$IS_SUBTOUR == 0], breaks = c(seq(0,6, by=1), 9999), freq = NULL, right=FALSE, weight = tours$finalweight[tours$TOURPURP==4 & tours$IS_SUBTOUR == 0])
stopfreqi56 = wtd.hist(tours$TOTAL_STOPS_ABM[tours$TOURPURP>=5 & tours$TOURPURP<=6 & tours$FULLY_JOINT==0 & tours$IS_SUBTOUR == 0], breaks = c(seq(0,6, by=1), 9999), freq = NULL, right=FALSE, weight = tours$finalweight[tours$TOURPURP>=5 & tours$TOURPURP<=6 & tours$FULLY_JOINT==0 & tours$IS_SUBTOUR == 0])
stopfreqi789 = wtd.hist(tours$TOTAL_STOPS_ABM[tours$TOURPURP>=7 & tours$TOURPURP<=9 & tours$FULLY_JOINT==0 & tours$IS_SUBTOUR == 0], breaks = c(seq(0,6, by=1), 9999), freq = NULL, right=FALSE, weight = tours$finalweight[tours$TOURPURP>=7 & tours$TOURPURP<=9 & tours$FULLY_JOINT==0 & tours$IS_SUBTOUR == 0])
stopfreqj56 = wtd.hist(jtours$TOTAL_STOPS_ABM[jtours$JOINT_PURP>=5 & jtours$JOINT_PURP<=6], breaks = c(seq(0,6, by=1), 9999), freq = NULL, right=FALSE, weight = jtours$finalweight[jtours$JOINT_PURP>=5 & jtours$JOINT_PURP<=6])
stopfreqj789 = wtd.hist(jtours$TOTAL_STOPS_ABM[jtours$JOINT_PURP>=7 & jtours$JOINT_PURP<=9], breaks = c(seq(0,6, by=1), 9999), freq = NULL, right=FALSE, weight = jtours$finalweight[jtours$JOINT_PURP>=7 & jtours$JOINT_PURP<=9])
stopfreq10 = wtd.hist(tours$TOTAL_STOPS_ABM[tours$IS_SUBTOUR == 1], breaks = c(seq(0,6, by=1), 9999), freq = NULL, right=FALSE, weight = tours$finalweight[tours$IS_SUBTOUR == 1])

stopFreq = data.frame(stopfreq1$counts, stopfreq2$counts, stopfreq3$counts, stopfreq4$counts, stopfreqi56$counts
                       , stopfreqi789$counts, stopfreqj56$counts, stopfreqj789$counts, stopfreq10$counts)
colnames(stopFreq) = c("work", "univ", "sch", "esco","imain", "idisc", "jmain", "jdisc", "atwork")
write.csv(stopFreq, "stopFreqTotProfile.csv")

# prepare stop frequency input for visualizer
stopFreq_vis = stopFreq
stopFreq_vis$id = row.names(stopFreq_vis)
stopFreq_vis = reshape2::melt(stopFreq_vis, id = c("id"))
colnames(stopFreq_vis) = c("id", "purpose", "freq")

stopFreq_vis = xtabs(freq~purpose+id, stopFreq_vis)
stopFreq_vis = addmargins(as.table(stopFreq_vis))
stopFreq_vis = as.data.frame.matrix(stopFreq_vis)
stopFreq_vis$id = row.names(stopFreq_vis)
stopFreq_vis = reshape2::melt(stopFreq_vis, id = c("id"))
colnames(stopFreq_vis) = c("purpose", "nstops", "freq")
stopFreq_vis$purpose = as.character(stopFreq_vis$purpose)
stopFreq_vis$nstops = as.character(stopFreq_vis$nstops)
stopFreq_vis = stopFreq_vis[stopFreq_vis$nstops!="Sum",]
stopFreq_vis$purpose[stopFreq_vis$purpose=="Sum"] = "Total"

write.csv(stopFreq_vis, "stopfreq_total_vis.csv", row.names = F)

#Stop purpose X TourPurpose
stopfreq1 = wtd.hist(stops$DEST_PURP[stops$TOURPURP==1 & stops$IS_SUBTOUR == 0], breaks = c(seq(1,10, by=1), 9999), freq = NULL, right=FALSE, weight = stops$finalweight[stops$TOURPURP==1 & stops$IS_SUBTOUR == 0])
stopfreq2 = wtd.hist(stops$DEST_PURP[stops$TOURPURP==2 & stops$IS_SUBTOUR == 0], breaks = c(seq(1,10, by=1), 9999), freq = NULL, right=FALSE, weight = stops$finalweight[stops$TOURPURP==2 & stops$IS_SUBTOUR == 0])
stopfreq3 = wtd.hist(stops$DEST_PURP[stops$TOURPURP==3 & stops$IS_SUBTOUR == 0], breaks = c(seq(1,10, by=1), 9999), freq = NULL, right=FALSE, weight = stops$finalweight[stops$TOURPURP==3 & stops$IS_SUBTOUR == 0])
stopfreq4 = wtd.hist(stops$DEST_PURP[stops$TOURPURP==4 & stops$IS_SUBTOUR == 0], breaks = c(seq(1,10, by=1), 9999), freq = NULL, right=FALSE, weight = stops$finalweight[stops$TOURPURP==4 & stops$IS_SUBTOUR == 0])
stopfreqi56 = wtd.hist(stops$DEST_PURP[stops$TOURPURP>=5 & stops$TOURPURP<=6 & stops$FULLY_JOINT==0 & stops$IS_SUBTOUR == 0], breaks = c(seq(1,10, by=1), 9999), freq = NULL, right=FALSE, weight = stops$finalweight[stops$TOURPURP>=5 & stops$TOURPURP<=6 & stops$FULLY_JOINT==0 & stops$IS_SUBTOUR == 0])
stopfreqi789 = wtd.hist(stops$DEST_PURP[stops$TOURPURP>=7 & stops$TOURPURP<=9 & stops$FULLY_JOINT==0 & stops$IS_SUBTOUR == 0], breaks = c(seq(1,10, by=1), 9999), freq = NULL, right=FALSE, weight = stops$finalweight[stops$TOURPURP>=7 & stops$TOURPURP<=9 & stops$FULLY_JOINT==0 & stops$IS_SUBTOUR == 0])
stopfreqj56 = wtd.hist(jstops$DEST_PURP[jstops$TOURPURP>=5 & jstops$TOURPURP<=6], breaks = c(seq(1,10, by=1), 9999), freq = NULL, right=FALSE, weight = jstops$finalweight[jstops$TOURPURP>=5 & jstops$TOURPURP<=6])
stopfreqj789 = wtd.hist(jstops$DEST_PURP[jstops$TOURPURP>=7 & jstops$TOURPURP<=9], breaks = c(seq(1,10, by=1), 9999), freq = NULL, right=FALSE, weight = jstops$finalweight[jstops$TOURPURP>=7 & jstops$TOURPURP<=9])
stopfreq10 = wtd.hist(stops$DEST_PURP[stops$SUBTOUR==1], breaks = c(seq(1,10, by=1), 9999), freq = NULL, right=FALSE, weight = stops$finalweight[stops$SUBTOUR==1])

stopFreq = data.frame(stopfreq1$counts, stopfreq2$counts, stopfreq3$counts, stopfreq4$counts, stopfreqi56$counts
                       , stopfreqi789$counts, stopfreqj56$counts, stopfreqj789$counts, stopfreq10$counts)
colnames(stopFreq) = c("work", "univ", "sch", "esco","imain", "idisc", "jmain", "jdisc", "atwork")
write.csv(stopFreq, "stopPurposeByTourPurpose.csv")

# prepare stop frequency input for visualizer
stopFreq_vis = stopFreq
stopFreq_vis$id = row.names(stopFreq_vis)
stopFreq_vis = reshape2::melt(stopFreq_vis, id = c("id"))
colnames(stopFreq_vis) = c("stop_purp", "purpose", "freq")

stopFreq_vis = xtabs(freq~purpose+stop_purp, stopFreq_vis)
stopFreq_vis = addmargins(as.table(stopFreq_vis))
stopFreq_vis = as.data.frame.matrix(stopFreq_vis)
stopFreq_vis$purpose = row.names(stopFreq_vis)
stopFreq_vis = reshape2::melt(stopFreq_vis, id = c("purpose"))
colnames(stopFreq_vis) = c("purpose", "stop_purp", "freq")
stopFreq_vis$purpose = as.character(stopFreq_vis$purpose)
stopFreq_vis$stop_purp = as.character(stopFreq_vis$stop_purp)
stopFreq_vis = stopFreq_vis[stopFreq_vis$stop_purp!="Sum",]
stopFreq_vis$purpose[stopFreq_vis$purpose=="Sum"] = "Total"

write.csv(stopFreq_vis, "stoppurpose_tourpurpose_vis.csv", row.names = F)

#Out of direction - Stop Location
stopfreq1 = wtd.hist(stops$out_dir_dist[stops$TOURPURP==1 & stops$IS_SUBTOUR == 0], breaks = c(-9999,seq(0,40, by=1), 9999), freq = NULL, right=FALSE, weight = stops$finalweight[stops$TOURPURP==1 & stops$IS_SUBTOUR == 0])
stopfreq2 = wtd.hist(stops$out_dir_dist[stops$TOURPURP==2 & stops$IS_SUBTOUR == 0], breaks = c(-9999,seq(0,40, by=1), 9999), freq = NULL, right=FALSE, weight = stops$finalweight[stops$TOURPURP==2 & stops$IS_SUBTOUR == 0])
stopfreq3 = wtd.hist(stops$out_dir_dist[stops$TOURPURP==3 & stops$IS_SUBTOUR == 0], breaks = c(-9999,seq(0,40, by=1), 9999), freq = NULL, right=FALSE, weight = stops$finalweight[stops$TOURPURP==3 & stops$IS_SUBTOUR == 0])
stopfreq4 = wtd.hist(stops$out_dir_dist[stops$TOURPURP==4 & stops$IS_SUBTOUR == 0], breaks = c(-9999,seq(0,40, by=1), 9999), freq = NULL, right=FALSE, weight = stops$finalweight[stops$TOURPURP==4 & stops$IS_SUBTOUR == 0])
stopfreqi56 = wtd.hist(stops$out_dir_dist[stops$TOURPURP>=5 & stops$TOURPURP<=6 & stops$FULLY_JOINT==0 & stops$IS_SUBTOUR == 0], breaks = c(-9999,seq(0,40, by=1), 9999), freq = NULL, right=FALSE, weight = stops$finalweight[stops$TOURPURP>=5 & stops$TOURPURP<=6 & stops$FULLY_JOINT==0 & stops$IS_SUBTOUR == 0])
stopfreqi789 = wtd.hist(stops$out_dir_dist[stops$TOURPURP>=7 & stops$TOURPURP<=9 & stops$FULLY_JOINT==0 & stops$IS_SUBTOUR == 0], breaks = c(-9999,seq(0,40, by=1), 9999), freq = NULL, right=FALSE, weight = stops$finalweight[stops$TOURPURP>=7 & stops$TOURPURP<=9 & stops$FULLY_JOINT==0 & stops$IS_SUBTOUR == 0])
stopfreqj56 = wtd.hist(jstops$out_dir_dist[jstops$TOURPURP>=5 & jstops$TOURPURP<=6], breaks = c(-9999,seq(0,40, by=1), 9999), freq = NULL, right=FALSE, weight = jstops$finalweight[jstops$TOURPURP>=5 & jstops$TOURPURP<=6])
stopfreqj789 = wtd.hist(jstops$out_dir_dist[jstops$TOURPURP>=7 & jstops$TOURPURP<=9], breaks = c(-9999,seq(0,40, by=1), 9999), freq = NULL, right=FALSE, weight = jstops$finalweight[jstops$TOURPURP>=7 & jstops$TOURPURP<=9])
stopfreq10 = wtd.hist(stops$out_dir_dist[stops$SUBTOUR==1], breaks = c(-9999,seq(0,40, by=1), 9999), freq = NULL, right=FALSE, weight = stops$finalweight[stops$SUBTOUR==1])

stopFreq = data.frame(stopfreq1$counts, stopfreq2$counts, stopfreq3$counts, stopfreq4$counts, stopfreqi56$counts
                       , stopfreqi789$counts, stopfreqj56$counts, stopfreqj789$counts, stopfreq10$counts)
colnames(stopFreq) = c("work", "univ", "sch", "esco","imain", "idisc", "jmain", "jdisc", "atwork")
write.csv(stopFreq, "stopOutOfDirectionDC.csv")

# prepare stop location input for visualizer
stopDC_vis = stopFreq
stopDC_vis$id = row.names(stopDC_vis)
stopDC_vis = reshape2::melt(stopDC_vis, id = c("id"))
colnames(stopDC_vis) = c("id", "purpose", "freq")

stopDC_vis = xtabs(freq~id+purpose, stopDC_vis)
stopDC_vis = addmargins(as.table(stopDC_vis))
stopDC_vis = as.data.frame.matrix(stopDC_vis)
stopDC_vis$id = row.names(stopDC_vis)
stopDC_vis = reshape2::melt(stopDC_vis, id = c("id"))
colnames(stopDC_vis) = c("distbin", "PURPOSE", "freq")
stopDC_vis$PURPOSE = as.character(stopDC_vis$PURPOSE)
stopDC_vis$distbin = as.character(stopDC_vis$distbin)
stopDC_vis = stopDC_vis[stopDC_vis$distbin!="Sum",]
stopDC_vis$PURPOSE[stopDC_vis$PURPOSE=="Sum"] = "Total"
stopDC_vis$distbin = as.numeric(stopDC_vis$distbin)

write.csv(stopDC_vis, "stopDC_vis.csv", row.names = F)

# compute average out of dir distance for visualizer
avgDistances = c(weighted.mean(stops$out_dir_dist[stops$TOURPURP==1 & stops$IS_SUBTOUR == 0], weight = stops$finalweight[stops$TOURPURP==1 & stops$IS_SUBTOUR == 0], na.rm = TRUE),
                  weighted.mean(stops$out_dir_dist[stops$TOURPURP==2 & stops$IS_SUBTOUR == 0], weight = stops$finalweight[stops$TOURPURP==2 & stops$IS_SUBTOUR == 0], na.rm = TRUE),
                  weighted.mean(stops$out_dir_dist[stops$TOURPURP==3 & stops$IS_SUBTOUR == 0], weight = stops$finalweight[stops$TOURPURP==3 & stops$IS_SUBTOUR == 0], na.rm = TRUE),
                  weighted.mean(stops$out_dir_dist[stops$TOURPURP==4 & stops$IS_SUBTOUR == 0], weight = stops$finalweight[stops$TOURPURP==4 & stops$IS_SUBTOUR == 0], na.rm = TRUE),
                  weighted.mean(stops$out_dir_dist[stops$TOURPURP>=5 & stops$TOURPURP<=6 & stops$FULLY_JOINT==0 & stops$IS_SUBTOUR == 0], weight = stops$finalweight[stops$TOURPURP>=5 & stops$TOURPURP<=6 & stops$FULLY_JOINT==0 & stops$IS_SUBTOUR == 0], na.rm = TRUE),
                  weighted.mean(stops$out_dir_dist[stops$TOURPURP>=7 & stops$TOURPURP<=9 & stops$FULLY_JOINT==0 & stops$IS_SUBTOUR == 0], weight = stops$finalweight[stops$TOURPURP>=7 & stops$TOURPURP<=9 & stops$FULLY_JOINT==0 & stops$IS_SUBTOUR == 0], na.rm = TRUE),
                  weighted.mean(jstops$out_dir_dist[jstops$TOURPURP>=5 & jstops$TOURPURP<=6], weight = jstops$finalweight[jstops$TOURPURP>=5 & jstops$TOURPURP<=6], na.rm = TRUE),
                  weighted.mean(jstops$out_dir_dist[jstops$TOURPURP>=7 & jstops$TOURPURP<=9], weight = jstops$finalweight[jstops$TOURPURP>=7 & jstops$TOURPURP<=9], na.rm = TRUE),
                  weighted.mean(stops$out_dir_dist[stops$SUBTOUR==1], weight = stops$finalweight[stops$SUBTOUR==1], na.rm = TRUE))

purp = c("work", "univ", "sch", "esco","imain", "idisc", "jmain", "jdisc", "atwork", "total")

###
stopsDist = c(stops$out_dir_dist[stops$TOURPURP %in% c(4) & stops$IS_SUBTOUR==0], 
               stops$out_dir_dist[stops$TOURPURP %in% c(5,6,7,8,9) & stops$FULLY_JOINT==0 & stops$IS_SUBTOUR==0], 
                stops$out_dir_dist[stops$IS_SUBTOUR==1],
                jstops$out_dir_dist[jstops$JOINT_PURP %in% c(5,6,7,8,9)])
stopsWeights  = c(stops$finalweight[stops$TOURPURP %in% c(4) & stops$IS_SUBTOUR==0], 
                   stops$finalweight[stops$TOURPURP %in% c(5,6,7,8,9) & stops$FULLY_JOINT==0 & stops$IS_SUBTOUR==0], 
                stops$finalweight[stops$IS_SUBTOUR==1],
                jstops$finalweight[jstops$JOINT_PURP %in% c(5,6,7,8,9)])

totAvgStopDist = weighted.mean(stopsDist, stopsWeights, na.rm = TRUE)

avgDistances = c(avgDistances, totAvgStopDist)

###

avgStopOutofDirectionDist = data.frame(purpose = purp, avgDist = avgDistances)

write.csv(avgStopOutofDirectionDist, "avgStopOutofDirectionDist_vis.csv", row.names = F)


#Stop Departure Time
stopfreq1 = wtd.hist(stops$DEST_DEP_BIN[stops$TOURPURP==1 & stops$IS_SUBTOUR == 0], breaks = c(seq(1,48, by=1), 9999), freq = NULL, right=FALSE, weight = stops$finalweight[stops$TOURPURP==1 & stops$IS_SUBTOUR == 0])
stopfreq2 = wtd.hist(stops$DEST_DEP_BIN[stops$TOURPURP==2 & stops$IS_SUBTOUR == 0], breaks = c(seq(1,48, by=1), 9999), freq = NULL, right=FALSE, weight = stops$finalweight[stops$TOURPURP==2 & stops$IS_SUBTOUR == 0])
stopfreq3 = wtd.hist(stops$DEST_DEP_BIN[stops$TOURPURP==3 & stops$IS_SUBTOUR == 0], breaks = c(seq(1,48, by=1), 9999), freq = NULL, right=FALSE, weight = stops$finalweight[stops$TOURPURP==3 & stops$IS_SUBTOUR == 0])
stopfreq4 = wtd.hist(stops$DEST_DEP_BIN[stops$TOURPURP==4 & stops$IS_SUBTOUR == 0], breaks = c(seq(1,48, by=1), 9999), freq = NULL, right=FALSE, weight = stops$finalweight[stops$TOURPURP==4 & stops$IS_SUBTOUR == 0])
stopfreqi56 = wtd.hist(stops$DEST_DEP_BIN[stops$TOURPURP>=5 & stops$TOURPURP<=6 & stops$FULLY_JOINT==0 & stops$IS_SUBTOUR == 0], breaks = c(seq(1,48, by=1), 9999), freq = NULL, right=FALSE, weight = stops$finalweight[stops$TOURPURP>=5 & stops$TOURPURP<=6 & stops$FULLY_JOINT==0 & stops$IS_SUBTOUR == 0])
stopfreqi789 = wtd.hist(stops$DEST_DEP_BIN[stops$TOURPURP>=7 & stops$TOURPURP<=9 & stops$FULLY_JOINT==0 & stops$IS_SUBTOUR == 0], breaks = c(seq(1,48, by=1), 9999), freq = NULL, right=FALSE, weight = stops$finalweight[stops$TOURPURP>=7 & stops$TOURPURP<=9 & stops$FULLY_JOINT==0 & stops$IS_SUBTOUR == 0])
stopfreqj56 = wtd.hist(jstops$DEST_DEP_BIN[jstops$TOURPURP>=5 & jstops$TOURPURP<=6], breaks = c(seq(1,48, by=1), 9999), freq = NULL, right=FALSE, weight = jstops$finalweight[jstops$TOURPURP>=5 & jstops$TOURPURP<=6])
stopfreqj789 = wtd.hist(jstops$DEST_DEP_BIN[jstops$TOURPURP>=7 & jstops$TOURPURP<=9], breaks = c(seq(1,48, by=1), 9999), freq = NULL, right=FALSE, weight = jstops$finalweight[jstops$TOURPURP>=7 & jstops$TOURPURP<=9])
stopfreq10 = wtd.hist(stops$DEST_DEP_BIN[stops$SUBTOUR==1], breaks = c(seq(1,48, by=1), 9999), freq = NULL, right=FALSE, weight = stops$finalweight[stops$SUBTOUR==1])

stopFreq = data.frame(stopfreq1$counts, stopfreq2$counts, stopfreq3$counts, stopfreq4$counts, stopfreqi56$counts
                       , stopfreqi789$counts, stopfreqj56$counts, stopfreqj789$counts, stopfreq10$counts)
colnames(stopFreq) = c("work", "univ", "sch", "esco","imain", "idisc", "jmain", "jdisc", "atwork")
write.csv(stopFreq, "stopDeparture.csv")

# prepare stop departure input for visualizer
stopDep_vis = stopFreq
stopDep_vis$id = row.names(stopDep_vis)
stopDep_vis = reshape2::melt(stopDep_vis, id = c("id"))
colnames(stopDep_vis) = c("id", "purpose", "freq_stop")

stopDep_vis$purpose = as.character(stopDep_vis$purpose)
stopDep_vis = xtabs(freq_stop~id+purpose, stopDep_vis)
stopDep_vis = addmargins(as.table(stopDep_vis))
stopDep_vis = as.data.frame.matrix(stopDep_vis)
stopDep_vis$id = row.names(stopDep_vis)
stopDep_vis = reshape2::melt(stopDep_vis, id = c("id"))
colnames(stopDep_vis) = c("timebin", "PURPOSE", "freq")
stopDep_vis$PURPOSE = as.character(stopDep_vis$PURPOSE)
stopDep_vis$timebin = as.character(stopDep_vis$timebin)
stopDep_vis = stopDep_vis[stopDep_vis$timebin!="Sum",]
stopDep_vis$PURPOSE[stopDep_vis$PURPOSE=="Sum"] = "Total"
stopDep_vis$timebin = as.numeric(stopDep_vis$timebin)

#Trip Departure Time
stopfreq1 = wtd.hist(trips$ORIG_DEP_BIN[trips$TOURPURP==1 & trips$IS_SUBTOUR == 0], breaks = c(seq(1,48, by=1), 9999), freq = NULL, right=FALSE, weight = trips$finalweight[trips$TOURPURP==1 & trips$IS_SUBTOUR == 0])
stopfreq2 = wtd.hist(trips$ORIG_DEP_BIN[trips$TOURPURP==2 & trips$IS_SUBTOUR == 0], breaks = c(seq(1,48, by=1), 9999), freq = NULL, right=FALSE, weight = trips$finalweight[trips$TOURPURP==2 & trips$IS_SUBTOUR == 0])
stopfreq3 = wtd.hist(trips$ORIG_DEP_BIN[trips$TOURPURP==3 & trips$IS_SUBTOUR == 0], breaks = c(seq(1,48, by=1), 9999), freq = NULL, right=FALSE, weight = trips$finalweight[trips$TOURPURP==3 & trips$IS_SUBTOUR == 0])
stopfreq4 = wtd.hist(trips$ORIG_DEP_BIN[trips$TOURPURP==4 & trips$IS_SUBTOUR == 0], breaks = c(seq(1,48, by=1), 9999), freq = NULL, right=FALSE, weight = trips$finalweight[trips$TOURPURP==4 & trips$IS_SUBTOUR == 0])
stopfreqi56 = wtd.hist(trips$ORIG_DEP_BIN[trips$TOURPURP>=5 & trips$TOURPURP<=6 & trips$FULLY_JOINT==0 & trips$IS_SUBTOUR == 0], breaks = c(seq(1,48, by=1), 9999), freq = NULL, right=FALSE, weight = trips$finalweight[trips$TOURPURP>=5 & trips$TOURPURP<=6 & trips$FULLY_JOINT==0 & trips$IS_SUBTOUR == 0])
stopfreqi789 = wtd.hist(trips$ORIG_DEP_BIN[trips$TOURPURP>=7 & trips$TOURPURP<=9 & trips$FULLY_JOINT==0 & trips$IS_SUBTOUR == 0], breaks = c(seq(1,48, by=1), 9999), freq = NULL, right=FALSE, weight = trips$finalweight[trips$TOURPURP>=7 & trips$TOURPURP<=9 & trips$FULLY_JOINT==0 & trips$IS_SUBTOUR == 0])
stopfreqj56 = wtd.hist(jtrips$ORIG_DEP_BIN[jtrips$TOURPURP>=5 & jtrips$TOURPURP<=6], breaks = c(seq(1,48, by=1), 9999), freq = NULL, right=FALSE, weight = jtrips$finalweight[jtrips$TOURPURP>=5 & jtrips$TOURPURP<=6])
stopfreqj789 = wtd.hist(jtrips$ORIG_DEP_BIN[jtrips$TOURPURP>=7 & jtrips$TOURPURP<=9], breaks = c(seq(1,48, by=1), 9999), freq = NULL, right=FALSE, weight = jtrips$finalweight[jtrips$TOURPURP>=7 & jtrips$TOURPURP<=9])
stopfreq10 = wtd.hist(trips$ORIG_DEP_BIN[trips$SUBTOUR==1], breaks = c(seq(1,48, by=1), 9999), freq = NULL, right=FALSE, weight = trips$finalweight[trips$SUBTOUR==1])

stopFreq = data.frame(stopfreq1$counts, stopfreq2$counts, stopfreq3$counts, stopfreq4$counts, stopfreqi56$counts
                       , stopfreqi789$counts, stopfreqj56$counts, stopfreqj789$counts, stopfreq10$counts)
colnames(stopFreq) = c("work", "univ", "sch", "esco","imain", "idisc", "jmain", "jdisc", "atwork")
write.csv(stopFreq, "tripDeparture.csv")

# prepare stop departure input for visualizer
tripDep_vis = stopFreq
tripDep_vis$id = row.names(tripDep_vis)
tripDep_vis = reshape2::melt(tripDep_vis, id = c("id"))
colnames(tripDep_vis) = c("id", "purpose", "freq_trip")

tripDep_vis$purpose = as.character(tripDep_vis$purpose)
tripDep_vis = xtabs(freq_trip~id+purpose, tripDep_vis)
tripDep_vis = addmargins(as.table(tripDep_vis))
tripDep_vis = as.data.frame.matrix(tripDep_vis)
tripDep_vis$id = row.names(tripDep_vis)
tripDep_vis = reshape2::melt(tripDep_vis, id = c("id"))
colnames(tripDep_vis) = c("timebin", "PURPOSE", "freq")
tripDep_vis$PURPOSE = as.character(tripDep_vis$PURPOSE)
tripDep_vis$timebin = as.character(tripDep_vis$timebin)
tripDep_vis = tripDep_vis[tripDep_vis$timebin!="Sum",]
tripDep_vis$PURPOSE[tripDep_vis$PURPOSE=="Sum"] = "Total"
tripDep_vis$timebin = as.numeric(tripDep_vis$timebin)

stopTripDep_vis = data.frame(stopDep_vis, tripDep_vis$freq)
colnames(stopTripDep_vis) = c("timebin", "purpose", "freq_stop", "freq_trip")
write.csv(stopTripDep_vis, "stopTripDep_vis.csv", row.names = F)


getIndivTripMode <- function(trips, tourPurp, outFileName){
	# tourPurp
	tm1 = wtd.hist(trips$TRIPMODE[!is.na(trips$TRIPMODE) & trips$TRIPMODE>0 & trips$TOURPURP %in% tourPurp & trips$TOURMODE==1 & trips$IS_SUBTOUR==0], breaks = seq(1,11, by=1), freq = NULL, right=FALSE, weight = trips$finalweight[!is.na(trips$TRIPMODE) & trips$TRIPMODE>0  & trips$TOURPURP %in% tourPurp & trips$TOURMODE==1 & trips$IS_SUBTOUR==0])
	tm2 = wtd.hist(trips$TRIPMODE[!is.na(trips$TRIPMODE) & trips$TRIPMODE>0 & trips$TOURPURP %in% tourPurp & trips$TOURMODE==2 & trips$IS_SUBTOUR==0], breaks = seq(1,11, by=1), freq = NULL, right=FALSE, weight = trips$finalweight[!is.na(trips$TRIPMODE) & trips$TRIPMODE>0  & trips$TOURPURP %in% tourPurp & trips$TOURMODE==2 & trips$IS_SUBTOUR==0])
	tm3 = wtd.hist(trips$TRIPMODE[!is.na(trips$TRIPMODE) & trips$TRIPMODE>0 & trips$TOURPURP %in% tourPurp & trips$TOURMODE==3 & trips$IS_SUBTOUR==0], breaks = seq(1,11, by=1), freq = NULL, right=FALSE, weight = trips$finalweight[!is.na(trips$TRIPMODE) & trips$TRIPMODE>0  & trips$TOURPURP %in% tourPurp & trips$TOURMODE==3 & trips$IS_SUBTOUR==0])
	tm4 = wtd.hist(trips$TRIPMODE[!is.na(trips$TRIPMODE) & trips$TRIPMODE>0 & trips$TOURPURP %in% tourPurp & trips$TOURMODE==4 & trips$IS_SUBTOUR==0], breaks = seq(1,11, by=1), freq = NULL, right=FALSE, weight = trips$finalweight[!is.na(trips$TRIPMODE) & trips$TRIPMODE>0  & trips$TOURPURP %in% tourPurp & trips$TOURMODE==4 & trips$IS_SUBTOUR==0])
	tm5 = wtd.hist(trips$TRIPMODE[!is.na(trips$TRIPMODE) & trips$TRIPMODE>0 & trips$TOURPURP %in% tourPurp & trips$TOURMODE==5 & trips$IS_SUBTOUR==0], breaks = seq(1,11, by=1), freq = NULL, right=FALSE, weight = trips$finalweight[!is.na(trips$TRIPMODE) & trips$TRIPMODE>0  & trips$TOURPURP %in% tourPurp & trips$TOURMODE==5 & trips$IS_SUBTOUR==0])
	tm6 = wtd.hist(trips$TRIPMODE[!is.na(trips$TRIPMODE) & trips$TRIPMODE>0 & trips$TOURPURP %in% tourPurp & trips$TOURMODE==6 & trips$IS_SUBTOUR==0], breaks = seq(1,11, by=1), freq = NULL, right=FALSE, weight = trips$finalweight[!is.na(trips$TRIPMODE) & trips$TRIPMODE>0  & trips$TOURPURP %in% tourPurp & trips$TOURMODE==6 & trips$IS_SUBTOUR==0])
	tm7 = wtd.hist(trips$TRIPMODE[!is.na(trips$TRIPMODE) & trips$TRIPMODE>0 & trips$TOURPURP %in% tourPurp & trips$TOURMODE==7 & trips$IS_SUBTOUR==0], breaks = seq(1,11, by=1), freq = NULL, right=FALSE, weight = trips$finalweight[!is.na(trips$TRIPMODE) & trips$TRIPMODE>0  & trips$TOURPURP %in% tourPurp & trips$TOURMODE==7 & trips$IS_SUBTOUR==0])
	tm8 = wtd.hist(trips$TRIPMODE[!is.na(trips$TRIPMODE) & trips$TRIPMODE>0 & trips$TOURPURP %in% tourPurp & trips$TOURMODE==8 & trips$IS_SUBTOUR==0], breaks = seq(1,11, by=1), freq = NULL, right=FALSE, weight = trips$finalweight[!is.na(trips$TRIPMODE) & trips$TRIPMODE>0  & trips$TOURPURP %in% tourPurp & trips$TOURMODE==8 & trips$IS_SUBTOUR==0])
	tm9 = wtd.hist(trips$TRIPMODE[!is.na(trips$TRIPMODE) & trips$TRIPMODE>0 & trips$TOURPURP %in% tourPurp & trips$TOURMODE==9 & trips$IS_SUBTOUR==0], breaks = seq(1,11, by=1), freq = NULL, right=FALSE, weight = trips$finalweight[!is.na(trips$TRIPMODE) & trips$TRIPMODE>0  & trips$TOURPURP %in% tourPurp & trips$TOURMODE==9 & trips$IS_SUBTOUR==0])
	#tm10 = wtd.hist(trips$TRIPMODE[!is.na(trips$TRIPMODE) & trips$TRIPMODE>0 & trips$TOURPURP %in% tourPurp & trips$TOURMODE==10 & trips$IS_SUBTOUR==0], breaks = seq(1,12, by=1), freq = NULL, right=FALSE, weight = trips$finalweight[!is.na(trips$TRIPMODE) & trips$TRIPMODE>0  & trips$TOURPURP %in% tourPurp & trips$TOURMODE==10 & trips$IS_SUBTOUR==0])
	tmp = data.frame(tm1$counts, tm2$counts, tm3$counts, tm4$counts,
                              tm5$counts, tm6$counts, tm7$counts, tm8$counts, tm9$counts) 
                             #tm10$counts)
	colnames(tmp) = c("tourmode1", "tourmode2", "tourmode3", "tourmode4", "tourmode5", "tourmode6", "tourmode7", "tourmode8", 
                              "tourmode9")
							  
	
							  
							  
	write.csv(tmp, outFileName)
	
	# Prepeare data for visualizer
	tmp_vis = tmp[1:9,]
	tmp_vis$id = row.names(tmp_vis)
	tmp_vis = reshape2::melt(tmp_vis, id = c("id"))
	colnames(tmp_vis) = c("id", "purpose", "freq1")

	tmp_vis = xtabs(freq1~id+purpose, tmp_vis)
	tmp_vis[is.na(tmp_vis)] = 0
	tmp_vis = addmargins(as.table(tmp_vis))
	tmp_vis = as.data.frame.matrix(tmp_vis)

	tmp_vis$id = row.names(tmp_vis)
	tmp_vis = reshape2::melt(tmp_vis, id = c("id"))
	colnames(tmp_vis) = c("id", "purpose", "freq1")
	tmp_vis$id = as.character(tmp_vis$id)
	tmp_vis$purpose = as.character(tmp_vis$purpose)
	tmp_vis = tmp_vis[tmp_vis$id!="Sum",]
	tmp_vis$purpose[tmp_vis$purpose=="Sum"] = "Total"
	return(tmp_vis)
}

#Trip Mode Summary
trip_original = trips
trips = subset(trips, TRIPMODE <= 11)
#Work

jtrips$IS_SUBTOUR = 0

tripModeProfile1_vis = getIndivTripMode(trips, c(1), "tripModeProfile_Work_HTS.csv")
tripModeProfile2_vis = getIndivTripMode(trips, c(2), "tripModeProfile_Univ_HTS.csv")
tripModeProfile3_vis = getIndivTripMode(trips, c(3), "tripModeProfile_Schl_HTS.csv")
tripModeProfile4_vis = getIndivTripMode(trips, c(4, 5, 6), "tripModeProfile_iMain_HTS.csv")
tripModeProfile5_vis = getIndivTripMode(trips, c(7, 8, 9), "tripModeProfile_iDisc_HTS.csv")
tripModeProfile6_vis = getIndivTripMode(jtrips, c(4, 5, 6), "tripModeProfile_jMain_HTS.csv")

tripModeProfile7_vis = getIndivTripMode(jtrips, c(7, 8, 9), "tripModeProfile_jDisc_HTS.csv")
# 8 is at-work and needs to be handled differently
tripModeProfile9_vis = getIndivTripMode(trips, c(1, 2, 3, 4, 5, 6, 7, 8, 9), "tripModeProfile_Total_HTS.csv")


#At-work                                                       
tripmode1 = wtd.hist(trips$TRIPMODE[!is.na(trips$TRIPMODE) & trips$TRIPMODE>0  & trips$SUBTOUR==1 & trips$TOURMODE==1], breaks = seq(1,11, by=1), freq = NULL, right=FALSE, weight = trips$finalweight[!is.na(trips$TRIPMODE) & trips$TRIPMODE>0  & trips$SUBTOUR==1 & trips$TOURMODE==1])
tripmode2 = wtd.hist(trips$TRIPMODE[!is.na(trips$TRIPMODE) & trips$TRIPMODE>0  & trips$SUBTOUR==1 & trips$TOURMODE==2], breaks = seq(1,11, by=1), freq = NULL, right=FALSE, weight = trips$finalweight[!is.na(trips$TRIPMODE) & trips$TRIPMODE>0  & trips$SUBTOUR==1 & trips$TOURMODE==2])
tripmode3 = wtd.hist(trips$TRIPMODE[!is.na(trips$TRIPMODE) & trips$TRIPMODE>0  & trips$SUBTOUR==1 & trips$TOURMODE==3], breaks = seq(1,11, by=1), freq = NULL, right=FALSE, weight = trips$finalweight[!is.na(trips$TRIPMODE) & trips$TRIPMODE>0  & trips$SUBTOUR==1 & trips$TOURMODE==3])
tripmode4 = wtd.hist(trips$TRIPMODE[!is.na(trips$TRIPMODE) & trips$TRIPMODE>0  & trips$SUBTOUR==1 & trips$TOURMODE==4], breaks = seq(1,11, by=1), freq = NULL, right=FALSE, weight = trips$finalweight[!is.na(trips$TRIPMODE) & trips$TRIPMODE>0  & trips$SUBTOUR==1 & trips$TOURMODE==4])
tripmode5 = wtd.hist(trips$TRIPMODE[!is.na(trips$TRIPMODE) & trips$TRIPMODE>0  & trips$SUBTOUR==1 & trips$TOURMODE==5], breaks = seq(1,11, by=1), freq = NULL, right=FALSE, weight = trips$finalweight[!is.na(trips$TRIPMODE) & trips$TRIPMODE>0  & trips$SUBTOUR==1 & trips$TOURMODE==5])
tripmode6 = wtd.hist(trips$TRIPMODE[!is.na(trips$TRIPMODE) & trips$TRIPMODE>0  & trips$SUBTOUR==1 & trips$TOURMODE==6], breaks = seq(1,11, by=1), freq = NULL, right=FALSE, weight = trips$finalweight[!is.na(trips$TRIPMODE) & trips$TRIPMODE>0  & trips$SUBTOUR==1 & trips$TOURMODE==6])
tripmode7 = wtd.hist(trips$TRIPMODE[!is.na(trips$TRIPMODE) & trips$TRIPMODE>0  & trips$SUBTOUR==1 & trips$TOURMODE==7], breaks = seq(1,11, by=1), freq = NULL, right=FALSE, weight = trips$finalweight[!is.na(trips$TRIPMODE) & trips$TRIPMODE>0  & trips$SUBTOUR==1 & trips$TOURMODE==7])
tripmode8 = wtd.hist(trips$TRIPMODE[!is.na(trips$TRIPMODE) & trips$TRIPMODE>0  & trips$SUBTOUR==1 & trips$TOURMODE==8], breaks = seq(1,11, by=1), freq = NULL, right=FALSE, weight = trips$finalweight[!is.na(trips$TRIPMODE) & trips$TRIPMODE>0  & trips$SUBTOUR==1 & trips$TOURMODE==8])
tripmode9 = wtd.hist(trips$TRIPMODE[!is.na(trips$TRIPMODE) & trips$TRIPMODE>0  & trips$SUBTOUR==1 & trips$TOURMODE==9], breaks = seq(1,11, by=1), freq = NULL, right=FALSE, weight = trips$finalweight[!is.na(trips$TRIPMODE) & trips$TRIPMODE>0  & trips$SUBTOUR==1 & trips$TOURMODE==9])
tripmode10 = wtd.hist(trips$TRIPMODE[!is.na(trips$TRIPMODE) & trips$TRIPMODE>0  & trips$SUBTOUR==1 & trips$TOURMODE==10], breaks = seq(1,11, by=1), freq = NULL, right=FALSE, weight = trips$finalweight[!is.na(trips$TRIPMODE) & trips$TRIPMODE>0  & trips$SUBTOUR==1 & trips$TOURMODE==10])
# tripmode11 = wtd.hist(trips$TRIPMODE[!is.na(trips$TRIPMODE) & trips$TRIPMODE>0  & trips$SUBTOUR==1 & trips$TOURMODE==11], breaks = seq(1,11, by=1), freq = NULL, right=FALSE, weight = trips$finalweight[!is.na(trips$TRIPMODE) & trips$TRIPMODE>0  & trips$SUBTOUR==1 & trips$TOURMODE==11])

tripModeProfile = data.frame(tripmode1$counts, tripmode2$counts, tripmode3$counts, tripmode4$counts,
                             tripmode5$counts, tripmode6$counts, tripmode7$counts, tripmode8$counts, 
                             tripmode9$counts) #, tripmode10$counts)

colnames(tripModeProfile) = c("tourmode1", "tourmode2", "tourmode3", "tourmode4", "tourmode5", "tourmode6", "tourmode7", 
                              "tourmode8", "tourmode9")
write.csv(tripModeProfile, "tripModeProfile_ATW_HTS.csv")

tripModeProfile8_vis = tripModeProfile[1:9,]
tripModeProfile8_vis$id = row.names(tripModeProfile8_vis)
tripModeProfile8_vis = reshape2::melt(tripModeProfile8_vis, id = c("id"))
colnames(tripModeProfile8_vis) = c("id", "purpose", "freq1")

tripModeProfile8_vis = xtabs(freq1~id+purpose, tripModeProfile8_vis)
tripModeProfile8_vis[is.na(tripModeProfile8_vis)] = 0
tripModeProfile8_vis = addmargins(as.table(tripModeProfile8_vis))
tripModeProfile8_vis = as.data.frame.matrix(tripModeProfile8_vis)

tripModeProfile8_vis$id = row.names(tripModeProfile8_vis)
tripModeProfile8_vis = reshape2::melt(tripModeProfile8_vis, id = c("id"))
colnames(tripModeProfile8_vis) = c("id", "purpose", "freq1")
tripModeProfile8_vis$id = as.character(tripModeProfile8_vis$id)
tripModeProfile8_vis$purpose = as.character(tripModeProfile8_vis$purpose)
tripModeProfile8_vis = tripModeProfile8_vis[tripModeProfile8_vis$id!="Sum",]
tripModeProfile8_vis$purpose[tripModeProfile8_vis$purpose=="Sum"] = "Total"


# combine all tripmode profile for visualizer
tripModeProfile_vis = data.frame(tripModeProfile1_vis, tripModeProfile2_vis$freq1, tripModeProfile3_vis$freq1, 
	tripModeProfile4_vis$freq1, tripModeProfile5_vis$freq1, tripModeProfile6_vis$freq1, 
	tripModeProfile7_vis$freq1, tripModeProfile8_vis$freq1, tripModeProfile9_vis$freq1)
	
colnames(tripModeProfile_vis) = c("tripmode", "tourmode", "work", "univ", "schl", "imain", "idisc", "jmain", "jdisc", "atwork", "total")


temp = reshape2::melt(tripModeProfile_vis, id = c("tripmode", "tourmode"))
#tripModeProfile_vis = cast(temp, tripmode+variable~tourmode)
write.csv(tripModeProfile_vis, "tripModeProfile_vis.csv", row.names = F)
temp$grp_var = paste(temp$variable, temp$tourmode, sep = "")


# rename tour mode to standard names
temp$tourmode[temp$tourmode=="tourmode1"] = 'Auto SOV'
temp$tourmode[temp$tourmode=="tourmode2"] = 'Auto 2 Person'
temp$tourmode[temp$tourmode=="tourmode3"] = 'Auto 3+ Person'
temp$tourmode[temp$tourmode=="tourmode4"] = 'Walk'
temp$tourmode[temp$tourmode=="tourmode5"] = 'Bike/Moped'
temp$tourmode[temp$tourmode=="tourmode6"] = 'Walk-Transit'
temp$tourmode[temp$tourmode=="tourmode7"] = 'Drive-Transit'
temp$tourmode[temp$tourmode=="tourmode8"] = 'Ride Share'
temp$tourmode[temp$tourmode=="tourmode9"] = 'SchoolBus'

colnames(temp) = c("tripmode","tourmode","purpose","value","grp_var")

write.csv(temp, "tripModeProfile_vis_HTS.csv", row.names = F)

trips = trip_original

# Total number of stops, trips & tours
cat("\n\n Total number of stops : ", sum(stops$finalweight[stops$TOURPURP %in% c(1,2,3,4,5,6,7,8,9,10)]))
cat("\n Total number of trips : ", sum(trips$finalweight[trips$TOURPURP %in% c(1,2,3,4,5,6,7,8,9,10)]))
cat("\n Total number of tours : ", sum(tours$finalweight[tours$TOURPURP %in% c(1,2,3,4,5,6,7,8,9,10)]), "\n")

# output total numbers in a file
total_population = sum(per$finalweight)
total_households = sum(hh$finalweight)
total_stops = sum(stops$finalweight[stops$TOURPURP %in% c(1,2,3,4,5,6,7,8,9,10)])
total_trips = sum(trips$finalweight[trips$TOURPURP %in% c(1,2,3,4,5,6,7,8,9,10)])
total_tours = sum(tours$finalweight[tours$TOURPURP %in% c(1,2,3,4,5,6,7,8,9,10)])

trips$num_travel[trips$TRIPMODE==1] = 1
trips$num_travel[trips$TRIPMODE==2] = 2
trips$num_travel[trips$TRIPMODE==3] = 3.33
trips$num_travel[is.na(trips$num_travel)] = 0

total_vmt = sum((trips$finalweight[trips$TRIPMODE>0 & trips$TRIPMODE<=3]*trips$od_dist[trips$TRIPMODE>0 & trips$TRIPMODE<=3])/trips$num_travel[trips$TRIPMODE>0 & trips$TRIPMODE<=3])


totals_var = c("total_population", "total_households", "total_tours", "total_trips", "total_stops", "total_vmt")
totals_val = c(total_population,total_households, total_tours, total_trips, total_stops, total_vmt)

totals_df = data.frame(name = totals_var, value = totals_val)

write.csv(totals_df, "totals.csv", row.names = F)

# HH Size distribution
hhSizeDist = plyr::count(hh[!is.na(hh$HHSIZE),], c("HHSIZE"), "finalweight")
write.csv(hhSizeDist, "hhSizeDist.csv", row.names = F)

# Active Persons by person type
perDays$tourDays = per$tourDays[match(1000*perDays$HH_ID+10*perDays$PER_ID, 1000*per$SAMPN+10*per$PERNO)]
perDays$hhWt = perDays$finalweight / perDays$tourDays
actpertypeDistbn = plyr::count(perDays[(!is.na(perDays$PERTYPE) & (perDays$DAP!="H")),], c("PERTYPE"), "hhWt")

write.csv(actpertypeDistbn, "activePertypeDistbn.csv", row.names = TRUE)

# Non-drive and drive tours to parking constraint zone
tours$access_mode[tours$TOURMODE==6] = "walk"
tours$access_mode[tours$TOURMODE==7] = "pnr"
tours$access_mode[tours$TOURMODE==8] = "knr"
tours$access_mode[tours$TOURMODE==9] = "tnr"
# tours$dest_park = mazData$parkConstraint[match(tours$dest_mgra, mazData$MAZ)]
# No mazData for SEMCOG, setting dest_park to 0
tours$dest_park = 0

work_Tours = tours[tours$dest_park==1 & tours$TOURPURP==1,]
write.table("work_driveTours", "work_Tours.csv", sep = ",")
write.table(sum(work_Tours$finalweight[work_Tours$TOURMODE %in% c(1,2,3)]), "work_Tours.csv", sep = ",", row.names = F, append = T)
write.table("work_driveTours", "work_Tours.csv", sep = ",", row.names = F, append = T)
write.table(sum(work_Tours$finalweight[!work_Tours$TOURMODE %in% c(1,2,3)]), "work_Tours.csv", sep = ",", row.names = F, append = T)


### County-County trip flow by Tour Purpose and Trip Mode
trips_sample = trips[,c("OCOUNTY", "DCOUNTY", "TRIPMODE", "TOURPURP", "SUBTOUR", "finalweight")]

# Recode tour purpose into unique market segmentations
# Work         - [No Subtours ], [All], [TOURPURP - (1,10)] 
# University   - [No Subtours ], [All], [TOURPURP - (2)   ] 
# School       - [No Subtours ], [All], [TOURPURP - (3)   ]  
# Escort       - [No Subtours ], [All], [TOURPURP - (4)   ]   
# Shop         - [No Subtours ], [All], [TOURPURP - (5)   ]   
# Maintenance  - [No Subtours ], [All], [TOURPURP - (6)   ]       
# Eating Out   - [No Subtours ], [All], [TOURPURP - (7)   ]
# Visiting     - [No Subtours ], [All], [TOURPURP - (8)   ]   
# Discretionary- [No Subtours ], [All], [TOURPURP - (9)   ]   
# Work-based   - [All Subtours], [All], [TOURPURP - (All) ]    

trips_sample$tour_purpose = "Other"
trips_sample$tour_purpose[trips_sample$SUBTOUR==0 & trips_sample$TOURPURP %in% c(1,10)] = "Work"
trips_sample$tour_purpose[trips_sample$SUBTOUR==0 & trips_sample$TOURPURP %in% c(2)]    = "University"
trips_sample$tour_purpose[trips_sample$SUBTOUR==0 & trips_sample$TOURPURP %in% c(3)]    = "School"
trips_sample$tour_purpose[trips_sample$SUBTOUR==0 & trips_sample$TOURPURP %in% c(4)]    = "Escort"
trips_sample$tour_purpose[trips_sample$SUBTOUR==0 & trips_sample$TOURPURP %in% c(5)]    = "Shop"
trips_sample$tour_purpose[trips_sample$SUBTOUR==0 & trips_sample$TOURPURP %in% c(6)]    = "Maintenance"
trips_sample$tour_purpose[trips_sample$SUBTOUR==0 & trips_sample$TOURPURP %in% c(7)]    = "Eating Out"
trips_sample$tour_purpose[trips_sample$SUBTOUR==0 & trips_sample$TOURPURP %in% c(8)]    = "Visiting"
trips_sample$tour_purpose[trips_sample$SUBTOUR==0 & trips_sample$TOURPURP %in% c(9)]    = "Discretionary"
trips_sample$tour_purpose[trips_sample$SUBTOUR==1]                                      = "Work-based"

# delete other purpose and records with missing values
trips_sample = trips_sample[trips_sample$tour_purpose != "Other",]
trips_sample = trips_sample[trips_sample$OCOUNTY!="Missing" & trips_sample$DCOUNTY!="Missing",]
trips_sample = trips_sample[trips_sample$TRIPMODE>0 & trips_sample$TRIPMODE<10,]

tripModeNames = c('Auto SOV','Auto 2 Person','Auto 3+ Person','Walk','Bike/Moped','Walk-Transit','Drive-Transit', 'Taxi/TNC', 'School Bus')
tripModeCodes = c(1, 2, 3, 4, 5, 6, 7, 8, 9)
tripMode_df = data.frame(tripModeCodes, tripModeNames)
trips_sample$trip_mode = tripMode_df$tripModeNames[match(trips_sample$TRIPMODE, tripMode_df$tripModeCodes)]

trips_sample = trips_sample[,c("OCOUNTY", "DCOUNTY", "trip_mode", "tour_purpose", "finalweight")]
trips_sample = data.table(trips_sample)

trips_flow = trips_sample[, .(count = sum(finalweight)), by = list(OCOUNTY, DCOUNTY, trip_mode, tour_purpose)]
trips_flow_total = data.table(trips_flow[,c("OCOUNTY", "DCOUNTY", "trip_mode", "count")])
trips_flow_total = trips_flow_total[, (tot = sum(count)), by = list(OCOUNTY, DCOUNTY, trip_mode)]
trips_flow_total$tour_purpose = "Total"
names(trips_flow_total)[names(trips_flow_total) == "V1"] = "count"
trips_flow = rbind(trips_flow, trips_flow_total[,c("OCOUNTY", "DCOUNTY", "trip_mode", "tour_purpose", "count")])

trips_flow_total = data.table(trips_flow[,c("OCOUNTY", "DCOUNTY", "tour_purpose", "count")])
trips_flow_total = trips_flow_total[, (tot = sum(count)), by = list(OCOUNTY, DCOUNTY, tour_purpose)]
trips_flow_total$trip_mode = "Total"
names(trips_flow_total)[names(trips_flow_total) == "V1"] = "count"
trips_flow = rbind(trips_flow, trips_flow_total[,c("OCOUNTY", "DCOUNTY", "trip_mode", "tour_purpose", "count")])


write.table(trips_flow, paste(WD,"trips_flow.csv", sep = "//"), sep = ",", row.names = F)

###*********************************************************************
### Generate school escorting summaries
###*********************************************************************

## These summaries are created for the full OHAS data of Oregon state
## Therefore, clear workspace and reload the required files
print("Generating school escorting summaries...")
library(dplyr)
## INPUTS

tours$HHEXPFACT = hh$finalweight[match(tours$HH_ID, hh$SAMPN)]

tours$OUT_CHAUFFUER_ID <- as.numeric(tours$OUT_CHAUFFUER_ID)
tours$INB_CHAUFFUER_ID <- as.numeric(tours$INB_CHAUFFUER_ID)

tours_sample <- select(tours, HH_ID, PER_ID, TOUR_ID, TOURPURP, ESCORTED_TOUR, CHAUFFUER_ID, ESCORTING_TOUR, 
                       PERSONTYPE, OUT_ESCORT_TYPE, OUT_CHAUFFUER_ID, OUT_CHAUFFUER_PURP, OUT_CHAUFFUER_PTYPE, 
                       INB_ESCORT_TYPE, INB_CHAUFFUER_ID, INB_CHAUFFUER_PURP, INB_CHAUFFUER_PTYPE, HHEXPFACT)
tours_sample <- filter(tours_sample, TOURPURP==3 & PERSONTYPE>=6)



out_sample1 <- filter(tours_sample, !is.na(OUT_ESCORT_TYPE) & !is.na(PERSONTYPE) & OUT_ESCORT_TYPE!="NaN")
inb_sample1 <- filter(tours_sample, !is.na(INB_ESCORT_TYPE) & !is.na(PERSONTYPE) & INB_ESCORT_TYPE!="NaN")
out_table1  <- xtabs(HHEXPFACT~OUT_ESCORT_TYPE+PERSONTYPE, data = out_sample1)
inb_table1  <- xtabs(HHEXPFACT~INB_ESCORT_TYPE+PERSONTYPE, data = inb_sample1)

out_sample2 <- filter(tours_sample, !is.na(OUT_ESCORT_TYPE) & !is.na(OUT_CHAUFFUER_PTYPE) & OUT_ESCORT_TYPE!="NaN" & OUT_CHAUFFUER_PTYPE!="NaN")
inb_sample2 <- filter(tours_sample, !is.na(INB_ESCORT_TYPE) & !is.na(INB_CHAUFFUER_PTYPE) & INB_ESCORT_TYPE!="NaN" & INB_CHAUFFUER_PTYPE!="NaN")
out_table2  <- xtabs(HHEXPFACT~OUT_ESCORT_TYPE+OUT_CHAUFFUER_PTYPE, data = out_sample2)
inb_table2  <- xtabs(HHEXPFACT~INB_ESCORT_TYPE+INB_CHAUFFUER_PTYPE, data = inb_sample2)

print("debug schesc 1")
# summary of non-mandatory stops on pure escorting tours
pure_escort_tours <- tours[(tours$OUT_ESCORTING_TYPE==2 & tours$OUT_ESCORTEE_TOUR_PURP==3) |
                             (tours$INB_ESCORTING_TYPE==2 & tours$INB_ESCORTEE_TOUR_PURP==3) ,]

#trips$tempid = trips$HH_ID*1000 + trips$PER_ID*100 + trips$TOUR_ID
nonescortstops <- trips %>%
  mutate(nonescortstop = ifelse(DEST_PURP>0 & DEST_PURP<=10 & DEST_PURP!=4 & DEST_IS_TOUR_DEST==0, 1, 0)) %>%
  mutate(tempid = HH_ID * 1000 + PER_ID * 100 + TOUR_ID) %>%
  dplyr::group_by(tempid) %>%
  dplyr::summarise(nonescortstops = sum(nonescortstop)) %>%
  ungroup()

pure_escort_tours <- pure_escort_tours %>%
  mutate(tempid = HH_ID * 1000 + PER_ID * 100 + TOUR_ID) %>%
  left_join(nonescortstops, by = c("tempid"))

# summary of pure school escorting tours [outbound or inbound]
# frequency of non-escorting stops excluding the primary destination by chauffeur tour purpose
xtabs(HHEXPFACT~TOURPURP+nonescortstops, data = pure_escort_tours)


# Worker summary
# summary of worker with a child which went to school
# by escort type, can be separated by outbound and inbound direction

#get list of active workers with at least one work tour
active_workers <- tours %>%
  filter(TOURPURP %in% c(1,10)) %>%   #work and work-related
  filter(PERSONTYPE %in% c(1,2)) %>%  #full and part-time worker
  dplyr::group_by(HH_ID, PER_ID) %>%
  dplyr::summarise(PERSONTYPE=max(PERSONTYPE), HHEXPFACT=max(HHEXPFACT)) %>%
  ungroup()

workers <- per[per$PERSONTYPE %in% c(1,2), ]

#get list of students with at least one school tour
active_students <- tours %>%
  filter(TOURPURP %in% c(3)) %>%   #school tour
  filter(PERSONTYPE %in% c(6,7,8)) %>%  #all school students
  dplyr::group_by(HH_ID, PER_ID) %>%
  dplyr::summarise(PERSONTYPE=max(PERSONTYPE)) %>%
  ungroup()

students <- per[per$PERSONTYPE %in% c(6,7,8), ] 

hh_active_student <- active_students %>%
  dplyr::group_by(HH_ID) %>%
  mutate(active_student=1) %>%
  dplyr::summarise(active_student = max(active_student)) %>%
  ungroup()

#tag active workers with active students in household
active_workers <- active_workers %>%
  left_join(hh_active_student, by = c("HH_ID")) %>%
  mutate(active_student=ifelse(is.na(active_student), 0, active_student))

#list of workers who did ride share or pure escort for school student
out_rs_workers <- tours %>%
  select(HH_ID, PER_ID, TOUR_ID, TOURPURP, ESCORTED_TOUR, CHAUFFUER_ID, 
         OUT_ESCORT_TYPE, OUT_CHAUFFUER_ID, OUT_CHAUFFUER_PURP, OUT_CHAUFFUER_PTYPE) %>%
  filter(TOURPURP==3 & OUT_ESCORT_TYPE==1) %>%
  dplyr::group_by(HH_ID, OUT_CHAUFFUER_ID) %>%
  mutate(num_escort = 1) %>%
  dplyr::summarise(out_rs_escort = sum(num_escort))

out_pe_workers <- tours %>%
  select(HH_ID, PER_ID, TOUR_ID, TOURPURP, ESCORTED_TOUR, CHAUFFUER_ID, 
         OUT_ESCORT_TYPE, OUT_CHAUFFUER_ID, OUT_CHAUFFUER_PURP, OUT_CHAUFFUER_PTYPE) %>%
  filter(TOURPURP==3 & OUT_ESCORT_TYPE==2) %>%
  dplyr::group_by(HH_ID, OUT_CHAUFFUER_ID) %>%
  mutate(num_escort = 1) %>%
  dplyr::summarise(out_pe_escort = sum(num_escort))

inb_rs_workers <- tours %>%
  select(HH_ID, PER_ID, TOUR_ID, TOURPURP, ESCORTED_TOUR, CHAUFFUER_ID, 
         INB_ESCORT_TYPE, INB_CHAUFFUER_ID, INB_CHAUFFUER_PURP, INB_CHAUFFUER_PTYPE) %>%
  filter(TOURPURP==3 & INB_ESCORT_TYPE==1) %>%
  dplyr::group_by(HH_ID, INB_CHAUFFUER_ID) %>%
  mutate(num_escort = 1) %>%
  dplyr::summarise(inb_rs_escort = sum(num_escort))

inb_pe_workers <- tours %>%
  select(HH_ID, PER_ID, TOUR_ID, TOURPURP, ESCORTED_TOUR, CHAUFFUER_ID, 
         INB_ESCORT_TYPE, INB_CHAUFFUER_ID, INB_CHAUFFUER_PURP, INB_CHAUFFUER_PTYPE) %>%
  filter(TOURPURP==3 & INB_ESCORT_TYPE==2) %>%
  dplyr::group_by(HH_ID, INB_CHAUFFUER_ID) %>%
  mutate(num_escort = 1) %>%
  dplyr::summarise(inb_pe_escort = sum(num_escort))
print("debug schesc 2")
active_workers <- active_workers %>%
  left_join(out_rs_workers, by = c("HH_ID"="HH_ID", "PER_ID"="OUT_CHAUFFUER_ID")) %>%
  left_join(out_pe_workers, by = c("HH_ID"="HH_ID", "PER_ID"="OUT_CHAUFFUER_ID")) %>%
  left_join(inb_rs_workers, by = c("HH_ID"="HH_ID", "PER_ID"="INB_CHAUFFUER_ID")) %>%
  left_join(inb_pe_workers, by = c("HH_ID"="HH_ID", "PER_ID"="INB_CHAUFFUER_ID"))

active_workers[is.na(active_workers)] <- 0

active_workers <- active_workers %>%
  mutate(out_escort_type = 3) %>%
  mutate(out_escort_type = ifelse(out_rs_escort>0, 1, out_escort_type)) %>%
  mutate(out_escort_type = ifelse(out_pe_escort>0, 2, out_escort_type)) %>%
  mutate(inb_escort_type = 3) %>%
  mutate(inb_escort_type = ifelse(inb_rs_escort>0, 1, inb_escort_type)) %>%
  mutate(inb_escort_type = ifelse(inb_pe_escort>0, 2, inb_escort_type))

temp <- filter(active_workers, active_student==1)
worker_table <- xtabs(HHEXPFACT~out_escort_type+inb_escort_type, data = temp)

## add marginal totals to all final tables
out_table1   <- addmargins(as.table(out_table1))
inb_table1   <- addmargins(as.table(inb_table1))
out_table2   <- addmargins(as.table(out_table2))
inb_table2   <- addmargins(as.table(inb_table2))
worker_table <- addmargins(as.table(worker_table))
print("debug schesc 3")
## reshape data in required form for visualizer
out_table1 <- as.data.frame.matrix(out_table1)
out_table1$id <- row.names(out_table1)
out_table1 <- reshape2::melt(out_table1, id = c("id"))
colnames(out_table1) <- c("esc_type", "child_type", "freq_out")
out_table1$esc_type <- as.character(out_table1$esc_type)
out_table1$child_type <- as.character(out_table1$child_type)
out_table1 <- out_table1[out_table1$esc_type!="Sum",]
out_table1$child_type[out_table1$child_type=="Sum"] <- "Total"
inb_table1 <- as.data.frame.matrix(inb_table1)
inb_table1$id <- row.names(inb_table1)
inb_table1 <- reshape2::melt(inb_table1, id = c("id"))
colnames(inb_table1) <- c("esc_type", "child_type", "freq_inb")
inb_table1$esc_type <- as.character(inb_table1$esc_type)
inb_table1$child_type <- as.character(inb_table1$child_type)
inb_table1 <- inb_table1[inb_table1$esc_type!="Sum",]
inb_table1$child_type[inb_table1$child_type=="Sum"] <- "Total"
# Old code - garbage
#table1 <- out_table1
# Fixed to deal with potential missing records
table1 = data.frame(esc_type = rep(1:3, 4), child_type = rep(c(6, 7, 8, 'Total'), each = 3))

table1 = join(table1, out_table1) #, on = c('esc_type', 'child_type'))
table1 = join(table1, inb_table1) #, on = c('esc_type', 'child_type'))

table1$esc_type[table1$esc_type=='1'] <- "Ride Share"
table1$esc_type[table1$esc_type=='2'] <- "Pure Escort"
table1$esc_type[table1$esc_type=='3'] <- "No Escort"
table1$child_type[table1$child_type=='6'] <- 'Driv Student'
table1$child_type[table1$child_type=='7'] <- 'Non-DrivStudent'
table1$child_type[table1$child_type=='8'] <- 'Pre-Schooler'

out_table2 <- as.data.frame.matrix(out_table2)
out_table2$id <- row.names(out_table2)
out_table2 <- reshape2::melt(out_table2, id = c("id"))
colnames(out_table2) <- c("esc_type", "chauffeur", "freq_out")
out_table2$esc_type <- as.character(out_table2$esc_type)
out_table2$chauffeur <- as.character(out_table2$chauffeur)
out_table2 <- out_table2[out_table2$esc_type!="Sum",]
out_table2$chauffeur[out_table2$chauffeur=="Sum"] <- "Total"

inb_table2 <- as.data.frame.matrix(inb_table2)
inb_table2$id <- row.names(inb_table2)
inb_table2 <- melt(inb_table2, id = c("id"))
colnames(inb_table2) <- c("esc_type", "chauffeur", "freq_inb")
inb_table2$esc_type <- as.character(inb_table2$esc_type)
inb_table2$chauffeur <- as.character(inb_table2$chauffeur)
inb_table2 <- inb_table2[inb_table2$esc_type!="Sum",]
inb_table2$chauffeur[inb_table2$chauffeur=="Sum"] <- "Total"

table2 <- inb_table2[,1:2]
table2$freq_out <- out_table2$freq_out[match(paste(table2$esc_type, table2$chauffeur, sep = "-"), paste(out_table2$esc_type, out_table2$chauffeur, sep = "-"))]
table2$freq_inb <- inb_table2$freq_inb[match(paste(table2$esc_type, table2$chauffeur, sep = "-"), paste(inb_table2$esc_type, inb_table2$chauffeur, sep = "-"))]
#table2 <- out_table2
#table2$freq_inb <- inb_table2$freq_inb
table2$esc_type[table2$esc_type=="1"] <- "Ride Share"
table2$esc_type[table2$esc_type=="2"] <- "Pure Escort"
table2$esc_type[table2$esc_type=="3"] <- "No Escort"
table2$chauffeur[table2$chauffeur=='1'] <- "FT Worker"
table2$chauffeur[table2$chauffeur=='2'] <- "PT Worker"
table2$chauffeur[table2$chauffeur=='3'] <- "Univ Stud"
table2$chauffeur[table2$chauffeur=='4'] <- "Non-Worker"
table2$chauffeur[table2$chauffeur=='5'] <- "Retiree"
table2$chauffeur[table2$chauffeur=='6'] <- "Driv Student"
print("debug schesc 5")
worker_table <- as.data.frame.matrix(worker_table)
colnames(worker_table)[which(colnames(worker_table) == "1")] = "Ride Share"
colnames(worker_table)[which(colnames(worker_table) == "2")] = "Pure Escort"
colnames(worker_table)[which(colnames(worker_table) == "3")] = "No Escort"
colnames(worker_table)[which(colnames(worker_table) == "Sum")] = "Total"
#colnames(worker_table) <- c("Ride Share", "Pure Escort", "No Escort", "Total")
worker_table$DropOff <- row.names(worker_table)
worker_table$DropOff[worker_table$DropOff=="1"] <- "Ride Share"
worker_table$DropOff[worker_table$DropOff=="2"] <- "Pure Escort"
worker_table$DropOff[worker_table$DropOff=="3"] <- "No Escort"
worker_table$DropOff[worker_table$DropOff=="Sum"] <- "Total"

#worker_table <- worker_table[, c("DropOff", "Ride Share","Pure Escort","No Escort","Total")]

## write outputs
write.csv(table1, "esctype_by_childtype.csv", row.names = F)
write.csv(table2, "esctype_by_chauffeurtype.csv", row.names = F)
write.csv(worker_table, "worker_school_escorting.csv", row.names = F)


detach("package:dplyr", unload=TRUE)


### Employer Parking Provision
# No parking / MAZ info for SEMCOG region
# place_raw[is.na(place_raw)] = 0
# 
# workTrips = trips[trips$DEST_PURP==1,]
# workTrips$DEST_MAZ[is.na(workTrips$DEST_MAZ)] = 0
# workTrips$dest_park = mazData$parkarea[match(workTrips$DEST_MAZ, mazData$ZONE)]
# workTrips = workTrips[workTrips$dest_park==1, ]
# 
# workTrips$parked_payed = place_raw$parked_payed[match(paste(workTrips$HH_ID, workTrips$PER_ID, workTrips$DEST_PLACENO, sep = "-"), 
#                                                        paste(place_raw$sampno, place_raw$perno, place_raw$plano, sep = "-"))]
# 
# workTrips$fp_choice[workTrips$TOURMODE<=3 & workTrips$parked_payed==1] = 3  # reimburse
# workTrips$fp_choice[workTrips$TOURMODE<=3 & workTrips$parked_payed==2] = 1  # free
# workTrips$fp_choice[workTrips$TOURMODE>3 ] = 2  # pay
# 
# xtabs(finalweight~fp_choice, data = workTrips)

#finish

### ASR: DO NOT UNCOMMENT THIS. This writes PII to the output folder.
### write out trip files for creating trip departure/arrival lookups
# write.csv(trips, "trips.csv", row.names = F)
# write.csv(jtrips, "jtrips.csv", row.names = F)

end_time = Sys.time()
end_time - start_time

print(paste("per weight", sum(per$finalweight)))

cat("\n Script finished, run time: ", end_time - start_time, "mins \n")

