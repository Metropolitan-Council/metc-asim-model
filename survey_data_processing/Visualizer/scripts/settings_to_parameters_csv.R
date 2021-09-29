# translate settings to parameters file so that we can avoid re-stating paths in visualizer batch file

library(yaml)



args                <- commandArgs(trailingOnly = TRUE)
Parameters_File     <- args[1]
settingsFile = args[2]


parameters          <- read.csv(Parameters_File, header = TRUE)
R_LIBRARY           <- trimws(paste(parameters$Value[parameters$Key=="R_LIBRARY"]))

.libPaths(c(.libPaths(), R_LIBRARY))
if("yaml" %in% rownames(installed.packages()) == FALSE) install.packages("yaml", lib=R_LIBRARY, repos='http://cran.us.r-project.org')

library(yaml)

settings = yaml.load_file(settingsFile)

working_dir = data.frame(Key = 'WORKING_DIR', Value = settings$visualizer_dir)
project_dir = data.frame(Key = 'PROJECT_DIR', Value = settings$visualizer_dir)
abm_summaries_dir = data.frame(Key = 'ABM_SUMMARY_DIR', Value = settings$abm_summaries_dir)
calib_dir = data.frame(Key = 'CALIBRATION_DIR', Value = file.path(settings$visualizer_dir, 'calibration_targets'))
base_summary_dir = data.frame(Key = 'BASE_SUMMARY_DIR', Value = file.path(settings$visualizer_dir, 'data/base/'))
build_summary_dir = data.frame(Key = 'BUILD_SUMMARY_DIR', Value = file.path(settings$abm_summaries_dir))
shp_file_name = data.frame(Key = 'SHP_FILE_NAME', Value = file.path(settings$zone_shp_file))


parameters = rbind(parameters, working_dir, project_dir, abm_summaries_dir, calib_dir, base_summary_dir,
                   build_summary_dir, shp_file_name)

write.csv(parameters, Parameters_File, row.names = FALSE)
