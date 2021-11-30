:: Run data preparation scripts

SET SETTINGS_FILE= "F:\Projects\Clients\MetCouncilASIM\tasks\metc-asim-model\survey_data_processing\metc_inputs.yml"
SET R_SCRIPT="C:\Program Files\R\R-4.0.3\bin\Rscript"
SET R_LIBRARY="F:/Projects/Clients/MetCouncilASIM/tasks/metc-asim-model/survey_data_processing/RPKG"

@echo off
::%R_SCRIPT% pre_spa_processing.R %SETTINGS_FILE%
python SPA\__init__.py %SETTINGS_FILE%

::Rscript Visualizer\scripts\install_packages.R
%R_SCRIPT% Visualizer\scripts\MetC_visualizer_prep.R %SETTINGS_FILE%

:: If census summaries don't exist, uncomment

::%R_SCRIPT% Visualizer\scripts\get_census_data_metc %SETTINGS_FILE%
::%R_SCRIPT% Visualizer\scripts\AutoOwnership_Census_MetC %SETTINGS_FILE%



cmd /k 
:: Then edit/run the visualizer .bat