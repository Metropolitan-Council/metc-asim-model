:: Run data preparation scripts

SET SETTINGS_FILE= "E:\Projects\Clients\MetCouncilASIM\tasks\survey_data_processing\metc_inputs.yml"
SET R_SCRIPT="C:\Program Files\R\R-4.0.3\bin\Rscript"
SET R_LIBRARY=E:/Projects/Clients/MetCouncilASIM/tasks/metc-asim-model/Visualizer/contrib/RPKG

@echo off
::%R_SCRIPT% pre_spa_processing.R %SETTINGS_FILE%
::python SPA\__init__.py %SETTINGS_FILE%

::%R_SCRIPT% Visualizer\scripts\install_packages.R

%R_SCRIPT% Visualizer\scripts\MetC_visualizer_prep.R %SETTINGS_FILE%

:: If census summaries don't exist, uncomment
::%R_SCRIPT% Visualizer\scripts\get_census_data_metc.R %SETTINGS_FILE%


