::~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
@ECHO OFF
::SetLocal EnableDelayedExpansion
:: ----------------------------------------------------------------------------
::
:: Step 1:  Set the necessary path variables 
::
:: ----------------------------------------------------------------------------
:: Parameters are found in set_parameters.bat
:: Future work could move this to a folder and name parameter files after model run
CALL .\set_parameters.bat

COPY .\set_parameters.bat %SCENARIO_DIR%\set_parameters.txt

:: ----------------------------------------------------------------------------
::
:: Step 2:  Networks and initial skims 
::
:: ----------------------------------------------------------------------------
:: Generate zonal data for model run
COPY "%zone_attribs%" "%SCENARIO_DIR%\zones.dbf"

:: Make Networks
:: Filter the all_link and all_node shape files to create separate 
:: highway, bike, and walk networks.
::%beginComment%
::???runtpp %SCRIPT_PATH%\make_complete_network_from_file.s
::???%check_cube_errors%
::???runtpp %SCRIPT_PATH%\make_highway_network_from_file.s
::???%check_cube_errors%
::???runtpp %SCRIPT_PATH%\make_bike_network_from_file.s
::???%check_cube_errors%
::???runtpp %SCRIPT_PATH%\make_walk_network_from_file.s
::???%check_cube_errors%
:: FullMakeNetwork15.s uses hard codes that should be adjusted to match model years.
::???runtpp %SCRIPT_PATH%\FullMakeNetwork15.s
::%check_cube_errors%
::endComment

ECHO HIGHWAY
:: HIGHWAY
:: No current option to copy skims as a warm start, could be added.
::%beginComment%
:: Export highway network from temp file (candidate for streamlining)
runtpp %SCRIPT_PATH%\BNNET00B.s
%check_cube_errors%


ECHO INITIAL NETWORKS AND INITIAL SKIMS
:: NON-MOTORIZED
:: Skim bike and walk networks
::%beginComment%
runtpp %SCRIPT_PATH%\NMNET00A.s
%check_cube_errors%
runtpp %SCRIPT_PATH%\NMHWY00A.s
%check_cube_errors%
runtpp %SCRIPT_PATH%\NMHWY00B.s
%check_cube_errors%
runtpp %SCRIPT_PATH%\NMMAT00A.s
%check_cube_errors%
::endComment

:: HIGHWAY
:: No current option to copy skims as a warm start, could be added.

::%beginComment%
:: Export highway network from temp file (candidate for streamlining)
::??runtpp %SCRIPT_PATH%\BNNET00B.s
::??%check_cube_errors%
:: Set drive link speeds capacities, alpha/beta parameters

:initialSkim
ECHO Initial Skims
runtpp %SCRIPT_PATH%\HNNET00B.s
%check_cube_errors%
:: Set managed lanes (comments cannot go inside for loops)
FOR /L %%I IN (1, 1, 6) DO (
	SET TOD=%%I

	IF %%I EQU 1 (SET NETNAME=Overnight 7:00 PM to 5:00 AM)
	IF %%I EQU 2 (SET NETNAME=Reverse Lane Change Over 5:00 AM to 6:00 AM  and 1:00 PM to 2:00 PM)
	IF %%I EQU 3 (SET NETNAME=AM Peak Period 6:00 AM to 10:00 AM)
	IF %%I EQU 4 (SET NETNAME=Mid Day Period 10:00 AM to 1:00 PM)
	IF %%I EQU 5 (SET NETNAME=Pre PM Peak Period 2:00 PM to 3:00 PM)
	IF %%I EQU 6 (SET NETNAME=PM Peak Period 3:00 PM to 7:00 PM)

	runtpp %SCRIPT_PATH%\HNNET00C.s
    :: Need to test how exitRun works inside loop
    %check_cube_errors%
)

IF %FREE_FLOW%==1 (goto initialSkim) else (goto copySkims)

::: Skim free flow network
runtpp %SCRIPT_PATH%\FFHWY00A.s
%check_cube_errors%
:: Copy skims to all time periods
runtpp %SCRIPT_PATH%\FFPIL00A.s
%check_cube_errors%
::endComment

ECHO TRANSIT
:: No current option to copy skims as a warm start, could be added.
::%beginComment%
:: extract link and node dbfs, set rail zone nodes
runtpp %SCRIPT_PATH%\TSNET00A.s
%check_cube_errors%
runtpp %SCRIPT_PATH%\TSNET00B.s
%check_cube_errors%

:: Calculate transit speeds for each period
:: Build walk access, transfer access, and drive access connectors for each period
:: Skim walk transit and drive transit
FOR /L %%I IN (1, 1, 2) DO (

	SET TOD=%%I

	IF %%I EQU 1 (
        SET TPER=PK
        )
	IF %%I EQU 2 (
        SET TPER=OP
        )

	runtpp %SCRIPT_PATH%\TSNET00C.s
    %check_cube_errors%
    runtpp %SCRIPT_PATH%\TSPTR00D.s
    %check_cube_errors%
	runtpp %SCRIPT_PATH%\TSPTR00F.s
    %check_cube_errors%
	runtpp %SCRIPT_PATH%\TSPTR00H.s
    %check_cube_errors%
	runtpp %SCRIPT_PATH%\TSPIL00C.s
    %check_cube_errors%
	runtpp %SCRIPT_PATH%\TSPTR00A.s
    %check_cube_errors%
	runtpp %SCRIPT_PATH%\TSPTR00C.s
    %check_cube_errors%
	runtpp %SCRIPT_PATH%\TSMAT00A.s
    %check_cube_errors%
	runtpp %SCRIPT_PATH%\TSMAT00C.s
    %check_cube_errors%
)


goto ancillary

:copySkims
runtpp %SCRIPT_PATH%\CSPIL00A.s
%check_cube_errors%
runtpp %SCRIPT_PATH%\TCPIL00E.s
%check_cube_errors%   
runtpp %SCRIPT_PATH%\TCNET00B.S
%check_cube_errors%   

    
::endComment

:ancillary

:: ----------------------------------------------------------------------------
::
:: Step 3:  Trucks and Special Generators 
::
:: ----------------------------------------------------------------------------

ECHO INITIALIZE TRUCK AND SPECIAL GENERATOR
::%beginComment%
:: Quick response freight manual routine
runtpp %SCRIPT_PATH%\TSGEN00A.s
%check_cube_errors%
:: External auto allocation and mode choice
runtpp %SCRIPT_PATH%\TSMAT00H.s
%check_cube_errors%
:: Build distribution matrix for auto EE IPF
runtpp %SCRIPT_PATH%\TSMAT00I.s
%check_cube_errors%
:: Fratar station targets using distribution from survey
runtpp %SCRIPT_PATH%\TSFRA00A.s
%check_cube_errors%
:: Generate airport trips
runtpp %SCRIPT_PATH%\TSMAT00K.s
%check_cube_errors%
:: Create special generator matrix
runtpp %SCRIPT_PATH%\TSMAT00L.s
%check_cube_errors%
:: Fratar EE trucks from FAF
runtpp %SCRIPT_PATH%\TSFRA00B.s
%check_cube_errors%
:: Split freight into truck types
runtpp %SCRIPT_PATH%\TSMAT00M.s
%check_cube_errors%
::endComment

::now

:: ----------------------------------------------------------------------------
::
:: Step 4:  Start the Model Feedback Loop
::
:: ----------------------------------------------------------------------------

:: MODEL LOOP
:: Iteration loop returns to HERE
:head
:: ----------------------------------------------------------------------------
::
:: Step 4a:  Create Exogenous Variables (updated for ASIM)
::
:: ----------------------------------------------------------------------------

ECHO CREATE EXOGENOUS VARIABLES
::%beginComment%
IF %ITER% EQU 1 (COPY %SCENARIO_DIR%\zones.dbf %SCENARIO_DIR%\zones_%PREV_ITER%.dbf)
::%check_cube_errors%
:: Highway Accessibility
::runtpp %SCRIPT_PATH%\EVMAT00A.s
::%check_cube_errors%
:: Transit Accessibility
::runtpp %SCRIPT_PATH%\EVMAT00B.s
::%check_cube_errors%
:: Distance to external stations
::runtpp %SCRIPT_PATH%\EVMAT00C.s
::%check_cube_errors%
:: School TAZs
::runtpp %SCRIPT_PATH%\EVMAT00D.s
::%check_cube_errors%
:: University enrollment
::runtpp %SCRIPT_PATH%\EVMAT00E.s
::%check_cube_errors%
:: Update zonal database
::runtpp %SCRIPT_PATH%\EVMAT00F.s
::%check_cube_errors%
::endComment



:: Prepare skims for ActivitySim
:ASim
runtpp %SCRIPT_PATH%\EVMAT00G.s
%check_cube_errors%


:: Prepare sedata for ActivitySim
ECHO Prep
ECHO Python Path: %PYTHON_PATH%
ECHO Script Path: %SCRIPT_PATH%
ECHO Scenario Dir: %SCENARIO_DIR%

"%PYTHON_PATH%\python.exe" "%SCRIPT_PATH%\EVMAT00H.py" "%SCENARIO_DIR%\set_parameters.txt"
%check_cube_errors%

:: Run ActivitySim
%PYTHON_PATH%\python.exe ActivitySim\simulation.py -c ActivitySim\configs_chunktraining -c ActivitySim\configs -d ActivitySim\data -o ActivitySim\output
%check_python_errors%

ECHO Assuming there are no errors on the screen above, chunk training was completed successfully and the chunk setup file
ECHO is where it needs to be. Go ahead and run met_council_model.bat!

:endOfFile