:: ############################################################################
:: # Batch file to generate HTML Visualizer
:: #
:: # 1. User should specify the path to the base and build summaries,
:: #    the specified directory should have all the files listed in
:: #    /templates/summaryFilesNames.csv
:: #
:: # 2. User should also specify the name of the base and build scenario if the
:: #    base/build scenario is specified as CHTS, scenario names are replaced
:: #    with appropriate Census sources names wherever applicable
:: ############################################################################

:: All environment variables should be set by set_parameters.bat

REM @ECHO off

::IF NOT DEFINED CENSUS_DATA_PATH CALL ..\..\set_parameters.bat
ECHO Parameters file: %PARAMETERS_FILE%
SET WORKING_DIR=%VIS_FOLDER%

ECHO Key,Value > %PARAMETERS_FILE%
ECHO BASE_SCENARIO_NAME,%BASE_SCENARIO_NAME% >> %PARAMETERS_FILE%
ECHO BUILD_SCENARIO_NAME,%BUILD_SCENARIO_NAME% >> %PARAMETERS_FILE%
ECHO CENSUS_SCENARIO_NAME,%CENSUS_SCENARIO_NAME% >> %PARAMETERS_FILE%
ECHO BASE_SAMPLE_RATE,%BASE_SAMPLE_RATE% >> %PARAMETERS_FILE%
ECHO BUILD_SAMPLE_RATE,%BUILD_SAMPLE_RATE% >> %PARAMETERS_FILE%
ECHO MAX_ITER,%MAX_ITER% >> %PARAMETERS_FILE%
ECHO R_LIBRARY,%R_LIBRARY% >> %PARAMETERS_FILE%
ECHO FULL_HTML_NAME,%FULL_HTML_NAME% >> %PARAMETERS_FILE%
ECHO CT_ZERO_AUTO_FILE_NAME,%CT_ZERO_AUTO_FILE_NAME% >> %PARAMETERS_FILE%
ECHO IS_BASE_SURVEY,%IS_BASE_SURVEY% >> %PARAMETERS_FILE%
ECHO VIS_ABM_INPUTS,%ASIM_DATA% >> %PARAMETERS_FILE%
ECHO VIS_SKIMS_DIR,%VIS_SKIMS% >> %PARAMETERS_FILE%
ECHO ABM_LAND_USE_DIR,%SE% >> %PARAMETERS_FILE%
ECHO VIS_ABM_DIR,%ASIM_OUT% >> %PARAMETERS_FILE%
ECHO VIS_ABM_SUMMARIES_DIR,%VIS_MODEL_DATA_FOLDER% >> %PARAMETERS_FILE%
ECHO VIS_ZONE_DIR,%VIS_ZONE_DIR% >> %PARAMETERS_FILE%
ECHO VIS_BASE_DATA_FOLDER,%VIS_BASE_DATA_FOLDER% >> %PARAMETERS_FILE%
ECHO VIS_ZONE_FILE,%VIS_ZONE_FILE% >> %PARAMETERS_FILE%
ECHO VIS_FOLDER,%VIS_FOLDER% >> %PARAMETERS_FILE%
ECHO CENSUS_DATA_PATH,%CENSUS_DATA_PATH% >> %PARAMETERS_FILE%
ECHO ASSIGNED,1  >> %PARAMETERS_FILE%
ECHO HTML_OUTPUT_PATH,%MAIN_DIRECTORY%\%SCENARIO_NAME% >> %PARAMETERS_FILE%
ECHO ASIM_CONFIG_DIR,%MAIN_DIRECTORY%\source\ActivitySim\configs >> %PARAMETERS_FILE%

ECHO Summarizing Loaded Highway Network
REM python.exe %VIS_FOLDER%\scripts\Summarize_model_HNET.py

ECHO Summarizing ActivitySim Outputs...
REM %R_SCRIPT% %VIS_FOLDER%\scripts\Summarize_ActivitySim_metc.R %PARAMETERS_FILE%

ECHO Preparing Auto Ownership Comparisons...
REM %R_SCRIPT% %VIS_FOLDER%\scripts\AutoOwnership_Census_MetC.R %PARAMETERS_FILE%

ECHO Preparing Worker Charts
%R_SCRIPT% %VIS_FOLDER%\scripts\workersByTAZ.R %PARAMETERS_FILE%

:: Call the master R script to generate full visualizer
:: #####################################################
ECHO Running R script to generate visualizer...
:RunViz

SET SWITCH=FULL
%R_SCRIPT% %VIS_FOLDER%\scripts\Master.R %PARAMETERS_FILE% %SWITCH%
IF %ERRORLEVEL% EQU 11 (
   ECHO File missing error. Check error file in outputs.
   EXIT /b %errorlevel%
)
IF %ERRORLEVEL% NEQ 0 GOTO MODEL_ERROR


ECHO Dashboard creation complete...
GOTO END

:MODEL_ERROR
ECHO Model Failed

:END
