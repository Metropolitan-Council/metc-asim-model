:: Set user parameters for Met Council Model
@ECHO OFF
:: Section 1: Set up new scenario - do not use a space in the file path!
SET MAIN_DIRECTORY=C:\projects\metc-asim-model
SET MODEL_YEAR=2018
SET SCENARIO_NAME=Base_2018


:: Section 2: Set up socioeconomic and land use data
SET POP_NAME=population2018_Dec20.dbf
SET HH_NAME=households2018_Dec20.dbf
SET ZONE_NAME=zones_2018_Dec20.dbf
SET SCHOOL_TAZ=schoolTAZs.csv
SET TAZ_COUNTY=TAZ_County.dbf

:: Section 3: Set up highway network
SET HIGHWAY_NAME=HighwayNetwork15.net

:: Section 4: Set up transit network
SET TRANSIT_NAME=PT_2015.lin


:: Section 5: Initial skims set up
:: Determine whether model uses creates intital uncongested skims ("cold start") or uses previous congested skims ("warm start")
:: set to 0 (no, or "warm start") or 1 ("yes, cold start")
SET FREE_FLOW=0

:: If "warm start", location of congested skims
SET hwy_AMskims_name=HWY_SKIM_4_AM.skm
SET hwy_PMskims_name=HWY_SKIM_4_PM.skm
SET hwy_NTskims_name=HWY_SKIM_4_NT.skm
SET hwy_MDskims_name=HWY_SKIM_4_MD.skm

SET xit_WK_PKskims_name=XIT_WK_SKIM_0_PK.skm
SET xit_WK_OPskims_name=XIT_WK_SKIM_0_OP.skm
SET xit_DR_PKskims_name=XIT_DR_SKIM_0_PK.skm
SET xit_DR_OPskims_name=XIT_DR_SKIM_0_OP.skm

:: Section 7: Catalog Run Parameters
:: Initialize the model run to an unconverged state
SET CONV=0
:: Set congergence criteria (percent expressed as integer out of 100)
SET conv_LinkVol=10
SET conv_LinkPerc=1
:: Initialize model to begin on iteration 1
SET ITER=1
SET PREV_ITER=0
:: Set cube cluster threads
SET max_threads=16
:: Set max feedback loops
SET max_feedback=4
:: Set max iterations of highway assignment
SET hwy_assignIters=100

::Section 8: Other Highway Parameters: Set number of zones (total, internal, external)
SET zones=3061
SET int_zones=3030
SET ext_zones=31
:: Set HOV occupancy
SET hwy_HOV2OCC=2
SET hwy_HOV3OCC=3.2
:: Set highway toll settings
SET hwy_TollSetting=1
SET T_PRIORITY_FILE=T_Priority.dbf
SET T_MANTIME_FILE=T_MANTIME.dbf
SET DISTANCE_FILE=Distances.dbf
SET WILL_TO_PAY=Will2Pay_oneCurve.txt
SET ALPHA_BETA=AlphaBetaLookup.txt
SET CAPACITY=CapacityLookup.txt
SET SPEED_LOOKUP=SpeedLookup85.txt

:: Section 9: Set nonmotorized parameters
:: Set default bike and walk speeds
SET bikeSpeed1=13
SET bikeSpeed2=13
SET bikeSpeed3=10
SET bikeFact1=0.8
SET walkSpeed=2.5

:: Section 10: Set other transit parameters
SET SYSTEM_NAME=PT_SYSTEM_2010.PTS
SET FARE_MATRIX=FAREMAT_2010.txt
SET FARE_FILE=PT_FARE_2010.FAR
SET PARKRIDE_FILE=GENERATE_PNR_ACCESS.s
::Set model transit year
SET xit_fac_year=2010

:: Section 11: Set other truck factors
SET hwy_TrkFac=2

::Section 12: Set external station factors
SET EXTERNAL_STATION=ext_sta.dbf
SET EXT_LU=EI_IE_EE_Lookup.txt
SET EE_AUTO_DIST_FILE=eeAutoJointDist.csv

::Section 13: Set freight model factors
SET QRFM_FILE=QRFM.txt
SET QRFM_FF_FILE=QRFM_FF.txt
SET EE_FRATAR_FILE=EE_FRATAR.txt
SET EE_TRUCK_DIST_FILE=EE_SEED_TRK_4.mat

::Section 14: Set airport factors
SET LU_SPC_FILE=AirportTODParams.txt

::Mode special generator choice coefficients
SET TTIME_AUTO=10.0
SET TTIME_SR=7.5
SET AUTOCOST=0.20
SET C_DA=0.0
SET DA_COST=-0.134
SET C_SR2=-1.35          
SET SR2_COST=-0.134 
SET C_SR3=-2.72
SET SR3_COST=-0.134 
SET HWTCOEFF=-0.0263
:: TRANSIT coefficients
SET TCOEFF_WA=-0.0263
SET FARE_WA=-0.134
SET TCOEFF_DA=-0.0263
SET FARECOST=-0.134 
SET C_TR=-0.677

:: Section 15: Set file paths
::Socioeconomic file path (population, households, zonal data)
SET SE=%MAIN_DIRECTORY%\Input\socioeconomic
:: Set highway network file path
SET NETWORK_FOLDER=%MAIN_DIRECTORY%\Input\network
:: Set transit network file path
SET TRANSIT_FOLDER=%MAIN_DIRECTORY%\Input\transit
:: Set script path
SET SCRIPT_PATH=%MAIN_DIRECTORY%\source\cube_scripts
:: Set freight path
SET FREIGHT_DATA=%MAIN_DIRECTORY%\Input\freight
::SET EXTERNAL DATA PATH
SET EXTERNAL_DATA=%MAIN_DIRECTORY%\Input\external
::Set airport model data
SET AIRPORT=%MAIN_DIRECTORY%\Input\airport

SET CATALOG_DIR=%MAIN_DIRECTORY%
MKDIR = .\%SCENARIO_NAME%
MKDIR = .\%SCENARIO_NAME%\abm_logs
SET SCENARIO_DIR=%MAIN_DIRECTORY%\%SCENARIO_NAME%

:: Original cube scripts contained a separate trip directory. This could be revisited.
SET TRIP_DIR=%SCENARIO_DIR%
SET LOOKUP_DIR=%MAIN_DIRECTORY%\Input
SET INPUT_DIR=%MAIN_DIRECTORY%\Input
::SET TOURCAST_DIR=%MAIN_DIRECTORY%\TourCast

::SET ASIM_DATA=%MAIN_DIRECTORY%\Input\activitysim\data
SET ASIM_OUT=%SCENARIO_NAME%\activitysim\output
MKDIR %SCENARIO_NAME%\activitysim\output
MKDIR %SCENARIO_NAME%\activitysim\output\log
MKDIR %SCENARIO_NAME%\activitysim\output\cache
MKDIR %SCENARIO_NAME%\OMX
COPY %MAIN_DIRECTORY%\source\activitysim\cache\chunk_cache.csv %SCENARIO_NAME%\activitysim\output\cache

:: Section 16: set INPUT FILE paths
:: Set zones
SET zone_attribs=%SE%\%ZONE_NAME%
:: Set link and node paths for complete network
::SET LINK_PATH=%NETWORK_FOLDER%\all_link.dbf
::SET NODE_PATH=%NETWORK_FOLDER%\all_node.dbf
:: Set transit paths
SET xit_lines=%TRANSIT_FOLDER%\%TRANSIT_NAME%
SET xit_system=%TRANSIT_FOLDER%\%SYSTEM_NAME%
SET xit_faremat=%TRANSIT_FOLDER%\%FARE_MATRIX%
SET xit_fare=%TRANSIT_FOLDER%\%FARE_FILE%
SET xit_pnrnodes=%TRANSIT_FOLDER%\%PARKRIDE_FILE%
SET T_PRIORITY_PATH=%NETWORK_FOLDER%\%T_PRIORITY_FILE%
SET T_MANTIME_PATH=%NETWORK_FOLDER%\%T_MANTIME_FILE%
SET T_DISTANCE_PATH=%NETWORK_FOLDER%\%DISTANCE_FILE%
:: Set willingness to pay tolls
SET LU_will2pay=%NETWORK_FOLDER%\%WILL_TO_PAY%
:: Set highway network (perhaps scripts should be reworked to avoid this step?)
SET iHwyNet=%NETWORK_FOLDER%\%HIGHWAY_NAME%
:: Set highway network parameters
SET LU_AlphaBeta=%NETWORK_FOLDER%\%ALPHA_BETA%
SET LU_capacity=%NETWORK_FOLDER%\%CAPACITY%
SET LU_speed=%NETWORK_FOLDER%\%SPEED_LOOKUP%
:: Set truck and special generator files
SET ext_sta=%EXTERNAL_DATA%\%EXTERNAL_STATION%
SET qrfm=%FREIGHT_DATA%\%QRFM_FILE%
SET qrfm_ff=%FREIGHT_DATA%\%QRFM_FF_FILE%
SET LU_external=%EXTERNAL_DATA%\%EXT_LU%
SET ee_auto_dist=%EXTERNAL_DATA%\%EE_AUTO_DIST_FILE%
SET LU_spc_tod=%AIRPORT%\%LU_SPC_FILE%
SET ee_fratar=%FREIGHT_DATA%\%EE_FRATAR_FILE%
SET ee_trk_dist=%FREIGHT_DATA%\%EE_TRUCK_DIST_FILE%
:: Set household and person files
SET households=%SE%\%HH_NAME%
SET persons=%SE%\%POP_NAME%
SET hwy_AMskims=%MAIN_DIRECTORY%\Input\skims\%hwy_AMskims_name%
SET hwy_PMskims=%MAIN_DIRECTORY%\Input\skims\%hwy_PMskims_name%
SET hwy_NTskims=%MAIN_DIRECTORY%\Input\skims\%hwy_NTskims_name%
SET hwy_MDskims=%MAIN_DIRECTORY%\Input\skims\%hwy_MDskims_name%
SET xit_WK_PKskims=%MAIN_DIRECTORY%\Input\skims\%xit_WK_PKskims_name%
SET xit_WK_OPskims=%MAIN_DIRECTORY%\Input\skims\%xit_WK_OPskims_name%
SET xit_DR_PKskims=%MAIN_DIRECTORY%\Input\skims\%xit_DR_PKskims_name%
SET xit_DR_OPskims=%MAIN_DIRECTORY%\Input\skims\%xit_DR_OPskims_name%

:: Section 17: PATH variables
:: !!WARNING!!
:: Do not change unless program installations are non-standard
:: !! WARNING!!

:: The location of the runtpp executable from Citilabs - 64bit first
SET TPP_PATH=C:\Program Files\Citilabs\CubeVoyager;C:\Program Files (x86)\Citilabs\CubeVoyager

:: The location of python
SET PYTHON_PATH=C:\Users\%username%\.conda\envs\metcouncil
::C:\Python27\ArcGIS10.7
::SET PYTHON_PATH=C:\Python27\ArcGIS10.5

:: Add these variables to the PATH environment variable, moving the current path to the back

SET OLD_PATH=%PATH%
SET PATH=%TPP_PATH%;%OLD_PATH%
::%PYTHON_PATH%;C:\Users\%username%\.conda\envs\metcouncil\Scripts;C:\Users\%username%\.conda\envs\metcouncil\Library\mingw-w64\bin\;C:\Users\%username%\.conda\envs\metcouncil\Library;C:\Users\%username%\.conda\envs\metcouncil\Library\bin;

:: Set shortcut keys
SET "beginComment=goto :endComment"
SET "returnToHead=goto :head"
SET "exitRun=goto :endOfFile"
SET "check_cube_errors=IF ERRORLEVEL 2 %exitRun%"
SET "check_python_errors=IF ERRORLEVEL 1 %exitRun%"

::
:: Section 18: Visualizer Inputs
::
SET VIS_FOLDER=%MAIN_DIRECTORY%\Visualizer
::
:: This is the base condition, either a survey or a different run. This data is only read
SET VIS_BASE_DATA_FOLDER=%VIS_FOLDER%\data\base
SET BASE_SCENARIO_NAME=Survey
SET BASE_SAMPLE_RATE=1.0
:: for survey base legend names are different [Yes/No]
SET IS_BASE_SURVEY=Yes

::
:: This is the build condition
:: NOTE: ACTIVITYSIM SUMMARIZED OUTPUT WILL GO HERE
SET VIS_MODEL_DATA_FOLDER=%VIS_FOLDER%\data\calibration_runs\summarized
SET BUILD_SCENARIO_NAME=Model
SET BUILD_SAMPLE_RATE=1.0

:: Common data
SET VIS_ZONE_DIR=%VIS_FOLDER%/data/SHP
SET VIS_ZONE_FILE=TAZ2010.shp
SET CT_ZERO_AUTO_FILE_NAME=ct_zero_auto.shp
SET CENSUS_DATA_PATH=%VIS_FOLDER%/data/census
:: Executable and library paths
SET R_SCRIPT="C:\projects\mwcog\Gen3_Model\source\visualizer\dependencies\R-4.1.2\bin\RScript"
SET R_LIBRARY=%VIS_FOLDER%\contrib\RPKG
:: Set PANDOC path
SET RSTUDIO_PANDOC=%VIS_FOLDER%\contrib\pandoc-2.14.2

:: In general, these shouldn't be changed
::#TODO: Check and see where that MAX_ITER is used, it seems odd
SET PARAMETERS_FILE=%VIS_FOLDER%\runtime\parameters.csv
SET FULL_HTML_NAME=MetCouncil_visualizer
SET MAX_ITER=1
SET PROJ_LIB=%R_LIBRARY%\rgdal\proj

