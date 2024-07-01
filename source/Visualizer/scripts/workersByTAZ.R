##########################################################
### Script to summarize workers by TAZ and Income Group

start_time <- Sys.time()

### Read Command Line Arguments
args                <- commandArgs(trailingOnly = TRUE)
Parameters_File     <- args[1]

SYSTEM_REPORT_PKGS <- c("reshape", "dplyr", "ggplot2", "plotly", "foreign")
lib_sink <- suppressWarnings(suppressMessages(lapply(SYSTEM_REPORT_PKGS, library, character.only = TRUE))) 

### Read parameters from Parameters_File
parameters          <- read.csv(Parameters_File, header = TRUE)
ABM_DIR             <- trimws(paste(parameters$Value[parameters$Key=="VIS_ABM_DIR"]))
ABM_SUMMARY_DIR     <- trimws(paste(parameters$Value[parameters$Key=="VIS_ABM_SUMMARIES_DIR"]))
SKIMS_DIR           <- trimws(paste(parameters$Value[parameters$Key=="SKIMS_DIR"]))
ZONES_DIR           <- trimws(paste(parameters$Value[parameters$Key=="VIS_ZONE_DIR"]))
LAND_USE_DIR        <- trimws(paste(parameters$Value[parameters$Key=="LAND_USE_DIR"]))
R_LIBRARY           <- trimws(paste(parameters$Value[parameters$Key=="R_LIBRARY"]))
BUILD_SAMPLE_RATE   <- trimws(paste(parameters$Value[parameters$Key=="BUILD_SAMPLE_RATE"]))
ASIM_CONFIG_DIR     <- trimws(paste(parameters$Value[parameters$Key=="ASIM_CONFIG_DIR"]))

# read data
setwd(ASIM_CONFIG_DIR)
destination_choice_size_terms     <- read.csv("destination_choice_size_terms.csv", header = TRUE)

setwd(ABM_DIR)
hh   <- read.csv("final_households.csv", header = TRUE)
per  <- read.csv("final_persons.csv", header = TRUE)
land_use <- read.csv("final_land_use.csv", header = TRUE)

print("Finished reading ABM Out")
xwalk_file = file.path(ZONES_DIR, "TAZ2010.dbf")
print(xwalk_file)
xwalk <- read.dbf(xwalk_file)
# districtList <- sort(unique(xwalk$co_name))
# countynames <- data.frame(code = seq(1,26),
#                           name = districtList)

countynames = xwalk %>%
  group_by(code = CO_NUM, name = CO_NAME) %>%
  summarize()

land_use$ZONE <- land_use$zone_id
land_use$TAZ <- land_use$zone_id #TODO: check to see if land_use$TAZ is in use below
land_use$COUNTY_NAME <- land_use$COUNTY
land_use$COUNTY <- countynames$code[match(land_use$COUNTY_NAME, countynames$name)]
land_use$tot_emp <- land_use$TOT_EMP
setwd(ABM_SUMMARY_DIR)

employment_categories <- colnames(destination_choice_size_terms[,-c(1:5)])
income_segments_df <- data.frame(code = c(1,2,3,4),
                                 segment = c("work_low", "work_med", "work_high", "work_veryhigh"))

# --------------------------------------------------
### Functions
lm_eqn <- function(df){
  m <- lm(y ~ x - 1, df);
  eq <- paste("Y = ", format(coef(m)[1], digits = 2), " * X, ", " r2 = ", format(summary(m)$r.squared, digits = 3), sep = "")
  return(eq)
}
lm_eqn_labeled <- function(df){
  m <- lm(tot_workers ~ tot_emp - 1, df);
  eq <- paste("Y = ", format(coef(m)[1], digits = 2), " * X, ", " r2 = ", format(summary(m)$r.squared, digits = 3), sep = "")
  return(eq)
}

createMultiColorScatter <- function(df, color_label, title, save_name){
  
  x_pos <- max(df$x) * .75
  y_pos1 <- max(df$y) * .2
  y_pos2 <- max(df$y) * .1
  
  p <- ggplot(df, aes(x=x, y=y, colour=color_var)) +
    geom_point(alpha=.5) + 
    geom_smooth(method=lm, formula = y ~ x - 1, se=FALSE) +
    # geom_smooth(method=lm, alpha=0.5, color="black") + 
    geom_abline(intercept = 0, slope = 1, linetype = 2) + 
    geom_text(x = x_pos, y = y_pos2,label = "- - - - : 45 Deg Line",  parse = FALSE, color = "black") +
    labs(x="Employment", y="Workers", colour=color_label, title=title)
  # plot(p)
  ggsave(file=save_name, width=12, height=10)
  
}

createSingleColorScatter <- function(df, title, save_name){

  x_pos <- max(df$x) * .75
  y_pos1 <- max(df$y) * .2
  y_pos2 <- max(df$y) * .1
  
  p <- ggplot(df, aes(x=x, y=y)) +
    geom_point(shape=1, color = "#0072B2")  + 
    geom_smooth(method=lm, formula = y ~ x - 1, se=FALSE) +
    # geom_smooth(method=lm, alpha=0.5, color="black") + 
    geom_text(x = x_pos, y = y_pos1,label = as.character(lm_eqn(df)) ,  parse = FALSE, color = "#0072B2", size = 6) +
    geom_abline(intercept = 0, slope = 1, linetype = 2) + 
    geom_text(x = x_pos, y = y_pos2, label = "- - - - : 45 Deg Line",  parse = FALSE, color = "black") +
    labs(x="Employment", y="Workers", title=title)
  # plot(p)
  ggsave(file=save_name, width=12, height=10)
  
}

# ------------------------------------------
# Processing person file
per$finalweight <- 1/as.numeric(BUILD_SAMPLE_RATE)
per$income_segment <- hh$income_segment[match(per$household_id, hh$household_id)]

workers <- per[per$workplace_zone_id > 0 & per$is_worker == "True",]
workers$work_county <- land_use$COUNTY[match(workers$workplace_zone_id, land_use$ZONE)]

income_factors <- destination_choice_size_terms[destination_choice_size_terms$model_selector == "workplace",]
income_factors$income_segment <- income_segments_df$code[match(income_factors$segment, income_segments_df$segment)]

# -----------------------------------------
# Workers vs Employment by County
# print("Creating Workers vs Employment by County...")

# employmentbyCounty <- land_use %>%
#   group_by(COUNTY) %>%
#   summarize(tot_emp = sum(tot_emp)) %>%
#   select(COUNTY, tot_emp)

# workersbyCounty <- workers %>%
#   group_by(work_county) %>%
#   summarize(tot_workers = sum(finalweight)) %>%
#   left_join(employmentbyCounty, by = c("work_county" = "COUNTY")) %>%
#   select(work_county, tot_workers, tot_emp)

# workersbyCounty$county_name <- countynames$name[match(workersbyCounty$work_county, countynames$code)]

# x_pos <- max(workersbyCounty$tot_emp) * .75
# y_pos1 <- max(workersbyCounty$tot_workers) * .2
# y_pos2 <- max(workersbyCounty$tot_workers) * .1
  
# write.csv(workersbyCounty, "workersbyCounty.csv", row.names = TRUE)

# pCounty <- ggplot(workersbyCounty, aes(x=tot_emp, y=tot_workers, colour=county_name)) +
#   #geom_point(shape=1, color = "#0072B2") + 
#   geom_point() + 
#   geom_smooth(method=lm, formula = y ~ x - 1, se=FALSE, color = "#0072B2") +
#   geom_abline(intercept = 0, slope = 1, linetype = 2) + 
#   geom_text(x=x_pos, y=y_pos1, aes(label = as.character(lm_eqn_labeled(workersbyCounty))) ,  parse = FALSE, color = "#0072B2", size = 4) +
#   geom_text(x=x_pos, y=y_pos2, label = "- - - - : 45 Deg Line",  parse = FALSE, color = "black") +
#   geom_label(data=workersbyCounty, aes(label=county_name), nudge_y = 60000) + 
#   labs(x="Employment", y="Workers", colour="County", title="Workers vs Employment by County") +
#   theme(legend.position="none")

# ggsave(file="workersbyCounty.jpeg", width=12, height=10)



# -------------------------------------------
# Workers vs Employment by TAZ
print("Creating Workers vs Employment for all occupations and tazs...")
employmentbyTAZ <- land_use %>%
  select(ZONE, COUNTY_NAME, tot_emp)

workersbyTAZ <- workers %>%
  group_by(workplace_zone_id) %>%
  summarize(tot_workers = sum(finalweight)) %>%
  left_join(employmentbyTAZ, by = c("workplace_zone_id" = "ZONE")) %>%
  select(workplace_zone_id, COUNTY_NAME, tot_workers, tot_emp)

# workersbyTAZ$county_name <- countynames$name[match(workersbyTAZ$COUNTY_NAME, countynames$code)]

workersbyTAZ$x <- workersbyTAZ$tot_emp
workersbyTAZ$y <- workersbyTAZ$tot_workers
workersbyTAZ$color_var <- workersbyTAZ$COUNTY_NAME

title <- "All TAZs By County"
save_name <- "workersbyTAZ_County.jpeg"
createMultiColorScatter(df=workersbyTAZ, color_label="County", title, save_name)

title <- "All TAZs"
save_name <- "workersbyTAZ.jpeg"
createSingleColorScatter(df=workersbyTAZ, title, save_name)

workersbyTAZ$work_to_job_ratio <- workersbyTAZ$tot_workers / workersbyTAZ$tot_emp
avg_work_to_job_ratio <- mean(workersbyTAZ$work_to_job_ratio)

write.csv(workersbyTAZ, "workersbyTAZ.csv", row.names = TRUE)

# -------------------------------------------
# Workers vs Employment by Occupation for each TAZ
print("Creating Workers vs Employment for all income groups...")

employmentbyOcc <- land_use %>%
  select(ZONE, employment_categories) %>%
  melt(id="ZONE") %>%
  rename(emp_cat = variable, num_emp = value)

workersbyOccInc <- workers %>%
  group_by(workplace_zone_id, income_segment) %>%
  summarize(tot_workers = sum(finalweight)) %>%
  left_join(income_factors, by=("income_segment")) %>%
  select(workplace_zone_id, income_segment, tot_workers, employment_categories)

# distributing taz workers into employment categories based on destination_choice_size_terms
for (i in seq(length(employment_categories))){
  emp_cat <- employment_categories[i]
  workersbyOccInc[emp_cat] <- round(workersbyOccInc[emp_cat] * workersbyOccInc$tot_workers)
}

workersbyOcc <- workersbyOccInc %>%
  group_by(workplace_zone_id) %>%
  select(workplace_zone_id, employment_categories)

workersbyOcc <- as.data.frame(workersbyOcc)
workersbyOcc <- workersbyOcc %>%
  melt(id = "workplace_zone_id") %>%
  rename(emp_cat = variable, tot_workers = value) %>%
  left_join(employmentbyOcc, by = c("workplace_zone_id" = "ZONE", "emp_cat" = "emp_cat")) %>%
  rename(tot_emp = num_emp)
  
workersbyOcc$x <- workersbyOcc$tot_emp
workersbyOcc$y <- workersbyOcc$tot_workers
workersbyOcc$color_var <- workersbyOcc$emp_cat

title <- "All Income Groups"
save_name <- "workers_incAll.jpeg"
createMultiColorScatter(df=workersbyOcc, color_label="Employment Category", title, save_name)

for (emp_cat in employment_categories){
  workersSingleOcc <- workersbyOcc[workersbyOcc$emp_cat == emp_cat,]
  title <- paste("Employment Category ", emp_cat, sep="")
  save_name <- paste("workers_incAll_",emp_cat,".jpeg", sep="")
  createSingleColorScatter(workersSingleOcc, title, save_name)
}


# -------------------------------------------
# Workers vs Employment by Occupation and income group for each TAZ
print("Creating Workers vs Employment for individual income groups...")

employmentbyInc <- land_use %>%
  select(ZONE, employment_categories)

i <- 0
for (inc_seg in unique(workersbyOccInc$income_segment)){
  i <- i + 1
  workersbyOccInc_i <- workersbyOccInc[workersbyOccInc$income_segment == inc_seg,]
  income_factors_i <- income_factors[income_factors$income_segment == inc_seg,]
  employmentbyInc_i <- employmentbyInc
  
  # applying income factos to the land use data
  for (emp_cat in employment_categories){
    # cat("income factor for ", emp_cat, ": " , income_factors_i[[emp_cat]], "\n")
    employmentbyInc_i[emp_cat] <- round(employmentbyInc[emp_cat] * income_factors_i[[emp_cat]])
  }
  
  employmentbyInc_i <- employmentbyInc_i %>%
    melt(id = "ZONE") %>%
    rename(emp_cat = variable, tot_emp = value)
  
  workersbyOccInc_i <- data.frame(workersbyOccInc_i)
  workersbyOccInc_i <- workersbyOccInc_i %>%
    select(workplace_zone_id, employment_categories)%>%
    melt(id = "workplace_zone_id") %>%
    rename(emp_cat = variable, tot_workers = value) %>%
    left_join(employmentbyInc_i, by=c("workplace_zone_id" = "ZONE", "emp_cat" = "emp_cat"))
  
  workersbyOccInc_i$x <- workersbyOccInc_i$tot_emp
  workersbyOccInc_i$y <- workersbyOccInc_i$tot_workers
  workersbyOccInc_i$color_var <- workersbyOccInc_i$emp_cat
  
  title <- paste("Income Segment ", i,"", sep="")
  save_name <- paste("workersbyEmpCat_inc",i,".jpeg", sep="")
  createMultiColorScatter(df=workersbyOccInc_i, color_label="Employment Category", title, save_name)
  
  for (emp_cat in employment_categories){
    workersSingleOccInc_i <- workersbyOccInc_i[workersbyOccInc_i$emp_cat == emp_cat,]
    title <- paste("Employment Category ", emp_cat, sep="")
    save_name <- paste("workers_inc",i,"_",emp_cat,".jpeg", sep="")
    createSingleColorScatter(workersSingleOccInc_i, title, save_name)
  }
    
  workersbyInc_i <- workersbyOccInc_i %>%
    select(workplace_zone_id, tot_emp, tot_workers) %>%
    group_by(workplace_zone_id) %>%
    summarize_at(c("tot_emp", "tot_workers"), sum) %>%
    mutate(x = tot_emp) %>%
    mutate(y = tot_workers)
  
  title <- paste("Income Group ", i, " Total Employment", sep="")
  save_name <- paste("workers_inc",i,"_total.jpeg", sep="")
  createSingleColorScatter(workersbyInc_i, title, save_name)
}


end_time <- Sys.time()
end_time - start_time
cat("\n Script finished, run time: ", end_time - start_time, "sec \n")

# finish