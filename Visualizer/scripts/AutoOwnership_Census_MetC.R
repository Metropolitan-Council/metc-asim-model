######################################################################################
# Creating leaflet comparing census tract level auto ownership with model
#
######################################################################################

start_time = Sys.time()

R_LIBRARY = Sys.getenv("R_LIBRARY")
.libPaths(c(R_LIBRARY, .libPaths()))

### Read Command Line Arguments
# args                = commandArgs(trailingOnly = TRUE)
# Parameters_File     = args[1]


LOAD_PKGS_LIST = c("leaflet", "htmlwidgets", "rgdal", "rgeos", "raster", "dplyr", 
                    "stringr", "data.table", "tigris", "yaml", "sf")
lib_sink = suppressWarnings(suppressMessages(lapply(LOAD_PKGS_LIST,  library, character.only = TRUE)))

args = commandArgs(trailingOnly = TRUE)
if(length(args) > 0){
  Parameters_File = args[1]
}else{
  Parameters_File = "C:/projects/metc-asim-model/Visualizer/runtime/parameters.csv"
}

parameters          <- read.csv(Parameters_File, header = TRUE)

### Read parameters from Parameters_File

ABM_DIR                 = trimws(paste(parameters$Value[parameters$Key=="VIS_ABM_DIR"]))
ABM_SUMMARY_DIR         = trimws(paste(parameters$Value[parameters$Key=="VIS_ABM_SUMMARIES_DIR"]))
ZONES_DIR               = trimws(paste(parameters$Value[parameters$Key=="VIS_ZONE_DIR"]))
BUILD_SAMPLE_RATE       = trimws(paste(parameters$Value[parameters$Key=="BUILD_SAMPLE_RATE"]))
CT_ZERO_AUTO_FILE_NAME  = trimws(paste(parameters$Value[parameters$Key=="CT_ZERO_AUTO_FILE_NAME"]))
SHP_FILE_NAME           = trimws(paste(parameters$Value[parameters$Key=="VIS_ZONE_FILE"]))
SHP_FILE_PATH           = trimws(paste(parameters$Value[parameters$Key=="VIS_ZONE_DIR"]))
CENSUS_DATA_PATH        = trimws(paste(parameters$Value[parameters$Key=="CENSUS_DATA_PATH"]))
# INPUTS
########

CensusData      = file.path(CENSUS_DATA_PATH, 'ACS_2018_5yr_AutoOwn.csv')

hh_file         = file.path(ABM_DIR, 'final_households.csv')

zone_file =file.path(SHP_FILE_PATH, SHP_FILE_NAME)

hh = read.csv(hh_file)
census = read.csv(CensusData, stringsAsFactors = F)

zones = st_read(zone_file)
zones_dt = setDT(copy(zones))
counties = unique(zones_dt[, .(CO_NAME, 
                               CO_NUM)])
counties[CO_NAME %in% c('Pierce', 'St. Croix', 'Polk'), state := 55]
counties[is.na(state), state := 27]
# zones_dt[, county_shortfips := substr(county_fip, 3, 5)]
# zones_dt[, state_shortfips := substr(county_fip, 1, 2)]
# USe Tigris to get census tract shapefile

mn_shp = tracts(state = 27, county = counties[state == 27, str_pad(CO_NUM, width = 3, side = "left", pad = "0")], class = 'sp')
wi_shp = tracts(state = 55, county = counties[state == 55, str_pad(CO_NUM, width = 3, side = "left", pad = "0")], class = 'sp')

ct_shp = rbind_tigris(mn_shp, wi_shp)
ct_shp = spTransform(ct_shp, CRS("+proj=longlat +ellps=GRS80"))
zones_proj = st_transform(zones, CRS("+proj=longlat +ellps=GRS80"))

# TAZ xwalk

ct_shp_sf = st_as_sf(ct_shp)
tazXWalk = st_join(zones_proj, ct_shp_sf)
tazXWalk = setDT(tazXWalk, key = "TAZ")

setwd(ABM_SUMMARY_DIR) # output dir

# Calculating auto availability and merging Census Tract ID

hh$HH_VEH_CAT = 0
hh[hh$auto_ownership < hh$num_workers,]$HH_VEH_CAT = 1
hh[hh$auto_ownership == hh$num_workers,]$HH_VEH_CAT = 2
hh[hh$auto_ownership > hh$num_workers,]$HH_VEH_CAT = 3
hh[hh$auto_ownership == 0,]$HH_VEH_CAT = 0

hh$finalweight = 1 / hh$sample_rate
hh$hasZeroAutos = ifelse(hh$HH_VEH_CAT==0, 1, 0)
hh$hasZeroAutosWeighted = hh$hasZeroAutos / hh$finalweight

hh$TAZ <- hh$home_zone_id

setDT(hh, key = "TAZ")
hh[tazXWalk, HH_TRACT_FIPS := str_sub(GEOID, start = 1, end = 11)]

# num_hh_per_taz = aggregate(hh$finalweight, by=list(Category=hh$TAZ), FUN=sum)
num_hh_per_ct = aggregate(hh$finalweight, by=list(Category=hh$HH_TRACT_FIPS), FUN=sum)
# zero_auto_hh_by_taz = aggregate(hh$hasZeroAutosWeighted, by=list(Category=hh$TAZ), FUN=sum)
zero_auto_hh_by_CT = aggregate(hh$hasZeroAutosWeighted, by=list(Category=hh$HH_TRACT_FIPS), FUN=sum)

# names(zero_auto_hh_by_taz)[names(zero_auto_hh_by_taz)=="Category"] = "TAZ"
# names(zero_auto_hh_by_taz)[names(zero_auto_hh_by_taz)=="x"] = "ZeroAutoHH"
# 
zero_auto_hh_by_CT$HH = num_hh_per_ct$x
# setDT(zero_auto_hh_by_taz)
# zero_auto_hh_by_taz[tazXWalk, CTIDFP := i.GEOID, on = .(TAZ = zone17)]
# 
# tazXWalk[, county_fips := county_fip]
# 
# zero_auto_hh_by_taz$COUNTYFP = tazXWalk$county_fips[match(zero_auto_hh_by_taz$TAZ, tazXWalk$TAZ)]
# zero_auto_hh_by_taz$COUNTYFP = tazXWalk$county_fips[match(zero_auto_hh_by_taz$TAZ, tazXWalk$TAZ)]
# 
# COUNTYFPs = unique(zero_auto_hh_by_taz$COUNTYFP)
# COUNTYFPs = COUNTYFPs[!is.na(COUNTYFPs)]

zero_auto_hh_by_CT = zero_auto_hh_by_CT %>%
  group_by(CTIDFP= Category) %>%
  #summarise(HH = sum(zero_auto_hh_by_taz$HH)) %>%
  #summarise(ZeroAutoHH = sum(zero_auto_hh_by_taz$ZeroAutoHH))
  summarise_at(vars(HH, ZeroAutoHH = x), list(sum))

zero_auto_hh_by_CT = zero_auto_hh_by_CT[!is.na(zero_auto_hh_by_CT$CTIDFP),]

model = zero_auto_hh_by_CT


# ct_shp = ct_shp[ct_shp$COUNTYFP %in% COUNTYFPs,]
ct_shp$GEOID = as.numeric(ct_shp$GEOID)

# Create DF
names(model)[names(model)=="HH"] = "Model_HH"
names(model)[names(model)=="ZeroAutoHH"] = "Model_A0"

census$Census_Auto0Prop = (census$Census_A0/census$Census_HH)*100
census[is.na(census)] = 0

setDT(model)
model[, CTIDFP := as.numeric(CTIDFP)]

model$Model_Auto0Prop = (model$Model_A0/model$Model_HH)*100
model[is.na(model)] = 0

df = census %>%
  left_join(model, by = c("TractID"="CTIDFP")) %>%
  mutate(Model_Auto0Prop = ifelse(is.na(Model_Auto0Prop), 0, Model_Auto0Prop),
		Census_Auto0Prop = ifelse(is.na(Census_Auto0Prop), 0, Census_Auto0Prop)) %>%
  mutate(Diff_ZeroAuto = Model_Auto0Prop - Census_Auto0Prop)
df[is.na(df)] = 0

#Copy plot variable to SHP
ct_shp@data$GEOID = as.numeric(ct_shp@data$GEOID)
ct_shp@data = ct_shp@data %>%
  left_join(df, by = c("GEOID"="TractID"))

ct_shp@data[is.na(ct_shp@data)] = 0

# Create Map
#ct_shp@data = ct_shp@data[!is.na(ct_shp@data$Diff_ZeroAuto),]
ct_shp@data$textComment1 = paste("Total Census HH: ", ct_shp@data$Census_HH, sep = "")
ct_shp@data$textComment2 = ifelse(ct_shp@data$Diff_ZeroAuto<0,'Model under predicts by',
                                     ifelse(ct_shp@data$Diff_ZeroAuto==0,"Model correct",'Model over predicts by'))

print(paste("ASR -> Writing ", sub(".shp", "", CT_ZERO_AUTO_FILE_NAME), sep = ""))
writeOGR(ct_shp, ABM_SUMMARY_DIR, 
         sub(".shp", "", CT_ZERO_AUTO_FILE_NAME), driver="ESRI Shapefile", check_exists = TRUE, overwrite_layer = TRUE)

# labels = sprintf(
#   "<strong>%s</strong><br/><strong>%s %.2f %s</strong><br/> %s",
#   ct_shp@data$CensusTract, ct_shp@data$textComment2, ct_shp@data$Diff_ZeroAuto, "%", ct_shp@data$textComment1
# ) %>% lapply(htmltools::HTML)
# 
# 
# bins = c(-Inf, -100, -75, -50, -25, -5, 5, 25, 50, 75, 100, Inf)
# pal = colorBin("PiYG", domain = ct_shp@data$Diff_ZeroAuto, na.color="transparent", bins = bins)
# 
# m = leaflet(data = ct_shp)%>%
#   addTiles() %>%
#   addProviderTiles(providers$OpenStreetMap, group = "Background Map") %>%
#   addLayersControl(
#     overlayGroups = "Background Map", options = layersControlOptions(collapsed = FALSE)
#   ) %>%
#   addPolygons(group='ZeroCarDiff',
#               fillColor = ~pal(Diff_ZeroAuto),
#               weight = 0.2,
#               opacity = 1,
#               color = "gray",
#               stroke=T,
#               dashArray = "5, 1",
#               fillOpacity = 0.7,
#               highlight = highlightOptions(
#                 weight = 1,
#                 color = "blue",
#                 dashArray = "",
#                 fillOpacity = 0.7,
#                 bringToFront = TRUE),
#               label = labels,
#               labelOptions = labelOptions(
#                 style = list("font-weight" = "normal", padding = "3px 8px"),
#                 textsize = "15px",
#                 direction = "auto")) %>%
#   addLegend(pal = pal, values = ~density, opacity = 0.7, title = "Estimated(%) - Observed(%) Bins",
#             position = "bottomright")
# 
# 
# # Output HTML
# saveWidget(m, file=paste(Out_Dir, "CT_ZeroAutoDiff_Census_vs_Model.html", sep = "/"), selfcontained = TRUE)
# 
# 
# # Write tabular CSV
# write.csv(df, paste(Out_Dir, "Data_CT_ZeroAutoDiff_Census_vs_Model.csv", sep = "/"), row.names = F)
# 
# print("Map Created!")

end_time = Sys.time()
end_time - start_time
cat("\n Script finished, run time: ", end_time - start_time, "sec \n")
