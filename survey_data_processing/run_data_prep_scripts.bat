:: Run data preparation scripts

SET SETTINGS_FILE= "E:\Projects\Clients\MetCouncilASIM\tasks\survey_data_processing\metc_inputs.yml"

@echo off
::Rscript pre_spa_processing.R %SETTINGS_FILE%
python SPA\__init__.py %SETTINGS_FILE%

::Rscript Visualizer\scripts\install_packages.R
::Rscript Visualizer\scripts\MetC_visualizer_prep.R %SETTINGS_FILE%
::%R_SCRIPT% Visualizer\scripts\get_census_data_metc %SETTINGS_FILE%
::%R_SCRIPT% Visualizer\scripts\AutoOwnership_Census_MetC %SETTINGS_FILE%
::%R_SCRIPT% Visualizer\scripts\Summarize_ActivitySim_metc %SETTINGS_FILE%


cmd /k 
:: Then edit/run the visualizer .bat