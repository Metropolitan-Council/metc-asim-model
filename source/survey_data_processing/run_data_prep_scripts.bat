:: Run data preparation scripts

SET SETTINGS_FILE= "E:\Met_Council\metc-asim-model\source\survey_data_processing\metc_inputs.yml"
SET R_SCRIPT="C:\Program Files\R\R-4.0.3\bin\Rscript"
SET R_LIBRARY=E:/Projects/Clients/MetCouncilASIM/tasks/metc-asim-model/Visualizer/contrib/RPKG
SET WORKING_FOLDER=E:\Met_Council\survey_data\Phase1

@echo off
::cd %WORKING_FOLDER%
::%R_SCRIPT% pre_spa_processing_phase2.R %SETTINGS_FILE%

::python SPA\__init__.py %SETTINGS_FILE%

::%R_SCRIPT% Visualizer\scripts\install_packages.R

%R_SCRIPT% ..\Visualizer\scripts\MetC_visualizer_prep.R %SETTINGS_FILE%

:: If census summaries don't exist, uncomment
::%R_SCRIPT% Visualizer\scripts\get_census_data_metc.R %SETTINGS_FILE%


