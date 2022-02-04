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
%PYTHON_PATH%\python.exe ActivitySim\simulation.py  -c ActivitySim\configs_test -c ActivitySim\configs -d ActivitySim\data -o ActivitySim\output
%check_python_errors%

echo Iteration=%ITER%
:: Output ActivitySim Matrices
for /L %%I IN (1, 1, 11) DO (
    SET TOD=%%I
    
    IF %%I EQU 1 (SET PER=AM1)
    IF %%I EQU 2 (SET PER=AM2)
    IF %%I EQU 3 (SET PER=AM3)
    IF %%I EQU 4 (SET PER=AM4)  
    IF %%I EQU 5 (SET PER=MD)
    IF %%I EQU 6 (SET PER=PM1)
    IF %%I EQU 7 (SET PER=PM2)
    IF %%I EQU 8 (SET PER=PM3)
    IF %%I EQU 9 (SET PER=PM4)
    IF %%I EQU 10 (SET PER=EV)
    IF %%I EQU 11 (SET PER=ON)
    
	runtpp %SCRIPT_PATH%\ASPIL00A.S
	%check_cube_errors%
)

echo Iteration=%ITER%

::Convert Transit Trip Tables
for /L %%I IN (1, 1, 2) DO (    
    IF %%I EQU 1 (SET TPER=PK)
    IF %%I EQU 2 (SET TPER=OP)
	runtpp %SCRIPT_PATH%\ASPIL00B.S
	%check_cube_errors%
	)
echo Iteration=%ITER%


:: ----------------------------------------------------------------------------
::
:: Step 4c: Freight Externals and Special Generator Distribution
::
:: ----------------------------------------------------------------------------
::%beginComment%
ECHO FREIGHT
:: Create weighted skim times
runtpp %SCRIPT_PATH%\FTMAT00A.s
%check_cube_errors%
:: Truck gravity model
runtpp %SCRIPT_PATH%\FTTRD00A.s
%check_cube_errors%
:: Time period splits
runtpp %SCRIPT_PATH%\FTMAT00B.s
%check_cube_errors%
::endComment

ECHO EXTERNAL AUTOS
::%beginComment%
:: Auto EI/IE destination choice
runtpp %SCRIPT_PATH%\EEMAT00A.s
%check_cube_errors%
:: Combine EI/IE trips with tranpose and EE
runtpp %SCRIPT_PATH%\EEMAT00B.s
%check_cube_errors%

echo Iteration=%ITER%
:: Loop through time periods, sum trips from each time period
for /L %%I IN (1, 1, 11) DO (
    SET TOD=%%I
    
    IF %%I EQU 1 (SET PER=AM1)
    IF %%I EQU 2 (SET PER=AM2)
    IF %%I EQU 3 (SET PER=AM3)
    IF %%I EQU 4 (SET PER=AM4)  
    IF %%I EQU 5 (SET PER=MD)
    IF %%I EQU 6 (SET PER=PM1)
    IF %%I EQU 7 (SET PER=PM2)
    IF %%I EQU 8 (SET PER=PM3)
    IF %%I EQU 9 (SET PER=PM4)
    IF %%I EQU 10 (SET PER=EV)
    IF %%I EQU 11 (SET PER=ON)
    
    runtpp %SCRIPT_PATH%\EEMAT00D.s
    %check_cube_errors%
)

echo Iteration=%ITER%
:: Split trips by TOD
runtpp %SCRIPT_PATH%\EEMAT00E.s
%check_cube_errors%
::endComment


::%beginComment%
:: SPECIAL GENERATORS
:: Data from AirportModECHOiceParams.txt
for /L %%I IN (1, 1, 11) DO (
    SET TOD=%%I
    
    IF %%I EQU 1 (
        SET PER=AM1
        SET HPER=AM
        SET TPER=PK
    )
    IF %%I EQU 2 (
        SET PER=AM2
        SET HPER=AM
        SET TPER=PK
    ) 
    IF %%I EQU 3 (
        SET PER=AM3
        SET HPER=AM
        SET TPER=PK
    ) 
    IF %%I EQU 4 (
        SET PER=AM4
        SET HPER=AM
        SET TPER=PK
    )   
    IF %%I EQU 5 (
        SET PER=MD
        SET HPER=MD
        SET TPER=OP
    )
    IF %%I EQU 6 (
        SET PER=PM1
        SET HPER=PM
        SET TPER=PK
    )  
    IF %%I EQU 7 (
        SET PER=PM2
        SET HPER=PM
        SET TPER=PK
    ) 
    IF %%I EQU 8 (
        SET PER=PM3
        SET HPER=PM
        SET TPER=PK
    ) 
    IF %%I EQU 9 (
        SET PER=PM4
        SET HPER=PM
        SET TPER=PK
    )
    IF %%I EQU 10 (
        SET PER=EV
        SET HPER=NT
        SET TPER=OP
    ) 
    IF %%I EQU 11 (
        SET PER=ON
        SET HPER=NT
        SET TPER=OP
    )
    
    :: Airport mode choice
    :: Seeing errors from SGMAT00A.s - should we add a zero out option to prevent divide by 0 errors?
    runtpp %SCRIPT_PATH%\SGMAT00A.s
    %check_cube_errors%
    :: Return trips from airport
    runtpp %SCRIPT_PATH%\SGMAT00B.s
    %check_cube_errors%
)
::endComment

echo Iteration=%ITER%

::%beginComment%
:: ----------------------------------------------------------------------------
::
:: Step 4d: Assignment and Skimming
::
:: ----------------------------------------------------------------------------
:: HIGHWAY skims
:: Start cube cluster
runtpp %SCRIPT_PATH%\HAPIL00D.s
%check_cube_errors%
:: Aggregate trip tables for interim assignment
runtpp %SCRIPT_PATH%\HAMAT00E.s
%check_cube_errors%
:: Aggregtate truck trip tables for interim assignment
runtpp %SCRIPT_PATH%\HAMAT00G.s
%check_cube_errors%
:: Aggregtate IE/EI trip tables for interim assignment
runtpp %SCRIPT_PATH%\HAMAT00I.s
%check_cube_errors%
:: Aggregate SPC trip tables for interim assignment
runtpp %SCRIPT_PATH%\HAMAT00K.s
%check_cube_errors%


:: Loop over time of day
FOR /L %%I IN (1, 1, 4) DO (

	SET TOD=%%I

	IF %%I EQU 1 (
		SET PER=AM
		SET ASSIGNNAME=AM Peak Period
		SET HWY_NET=HWY_NET_3.net
		SET NETNAME=AM Peak Period 6:00 AM to 10:00 AM
		SET CAPFAC=3.75
		)
	IF %%I EQU 2 (
		SET PER=MD
		SET ASSIGNNAME=Mid Day Peak Period
		SET HWY_NET=HWY_NET_4.net
		SET NETNAME=Mid Day Period 10:00 AM to 3:00 PM
		SET CAPFAC=4.48
		)
	IF %%I EQU 3 (
		SET PER=PM
		SET ASSIGNNAME=PM Peak Period
		SET HWY_NET=HWY_NET_6.net
		SET NETNAME=PM Peak Period 3:00 PM to 7:00 PM
		SET CAPFAC=3.9
		)
	IF %%I EQU 4 (
		SET PER=NT
		SET ASSIGNNAME=Night
		SET HWY_NET=HWY_NET_1.net
		SET NETNAME=AM Peak Period 7:00 PM to 6:00 AM
		SET CAPFAC=4.65
		)

    :: Record stats and convert to vehicle trip tables
	runtpp %SCRIPT_PATH%\HAMAT00A.s
    %check_cube_errors%
    :: Highway assignment
	runtpp %SCRIPT_PATH%\HAHWY00A.s
    %check_cube_errors%
    :: Create highway skims
	runtpp %SCRIPT_PATH%\HAMAT00C.s
    %check_cube_errors%
	)

:: End cube cluster
runtpp %SCRIPT_PATH%\HAPIL00B.s
%check_cube_errors% 
:endComment

echo Iteration=%ITER%

:: HWY Assignment Post-Processor
:: Combine convergence assignment networks
runtpp %SCRIPT_PATH%\CANET00A.s
%check_cube_errors%
:: export link dbf
runtpp %SCRIPT_PATH%\CANET00B.s
%check_cube_errors%
:: Export files to csv
runtpp %SCRIPT_PATH%\CAMAT00A.s
%check_cube_errors%
::endComment

:: TRANSIT skimming
echo Iteration=%ITER%

::%beginComment%
::now
    :: Calculate transit speeds for period
    runtpp %SCRIPT_PATH%\TSNET00F_loop.s
    %check_cube_errors%

    :: Build period walk access connectors
    runtpp %SCRIPT_PATH%\TSPTR00N_loop.s

    %check_cube_errors%
    :: Build period transfer access connectors
    runtpp %SCRIPT_PATH%\TSPTR00S_loop.s
    %check_cube_errors%

    :: Build period drive access connectors
    runtpp %SCRIPT_PATH%\TSPTR00U_loop.s
    %check_cube_errors%

FOR /L %%I IN (1,1,2) DO (
    SET TOD=%%I
    IF %%I EQU 1 (
       SET TPER=PK
       SET ASSIGNNAME=Peak Period
       SET PER=AM
    )
    IF %%I EQU 2 (
        SET TPER=OP
        SET ASSIGNNAME=OffPeak Period
        SET PER=MD
    ) 
    :: Copy temp files to non-transit leg files
    COPY %SCENARIO_DIR%\XIT_WKACC_NTL_%ITER%_%TPER%.tmp+%TRANSIT_FOLDER%\WalkOverrides.txt %SCENARIO_DIR%\XIT_WKACC_NTL_%ITER%_%TPER%.ntl
    COPY %SCENARIO_DIR%\XIT_XFER_NTL_%ITER%_%TPER%.tmp + %TRANSIT_FOLDER%\TransferOverrides.txt %SCENARIO_DIR%\XIT_XFER_NTL_%ITER%_%TPER%.ntl
    COPY %SCENARIO_DIR%\XIT_DRACC_NTL_%ITER%_%TPER%.tmp + %TRANSIT_FOLDER%\DriveOverrides.txt %SCENARIO_DIR%\XIT_DRACC_NTL_%ITER%_%TPER%.ntl
    )

    :: Walk transit skim step 1
    runtpp %SCRIPT_PATH%\TSPTR00J_loop.s
    %check_cube_errors%

    :: Drive transit skim step 1
    runtpp %SCRIPT_PATH%\TSPTR00L_loop.s
    %check_cube_errors%

    :: Walk transit skim step 2
    runtpp %SCRIPT_PATH%\TSMAT00E_loop.s
    %check_cube_errors%

    :: Drive transit skim step 2
    runtpp %SCRIPT_PATH%\TSMAT00G_loop.s
    %check_cube_errors%

::now

::runtpp %SCRIPT_PATH%\TSPIL00E.S
:: ----------------------------------------------------------------------------
::
:: Step 4e: Check Convergence and Final Assignment
::
:: ----------------------------------------------------------------------------
:: CHECK CONVERGENCE
::%beginComment%
:: Skip convergence tests on first iteration, "unbuil network"
IF %ITER% EQU 1 (
    FOR /L %%I IN (1,1,4) DO (
        IF %%I EQU 1 (SET PER=NT)
        IF %%I EQU 2 (SET PER=AM)
        IF %%I EQU 3 (SET PER=MD)
        IF %%I EQU 4 (SET PER=PM)
        
        runtpp %SCRIPT_PATH%\IINET00C.s
        %check_cube_errors%
    )

)

::endComment

::%beginComment%
:: After first iteration, check convergence criteria
IF %ITER% GEQ 2 (
    
    @ECHO. >> %SCENARIO_DIR%\converge.txt
    @ECHO. >> %SCENARIO_DIR%\converge.txt
    @ECHO Checking convergence for iteration %ITER% >> %SCENARIO_DIR%\converge.txt
    @ECHO %date% %time% >> %SCENARIO_DIR%\converge.txt
    SET error_flag=0
    
    FOR /L %%I IN (1,1,4) DO (
        
        IF %%I EQU 1 (SET PER=NT)
        IF %%I EQU 2 (SET PER=AM)
        IF %%I EQU 3 (SET PER=MD)
        IF %%I EQU 4 (SET PER=PM)
        
        runtpp %SCRIPT_PATH%\CCNET00D.s
        %check_cube_errors%
        runtpp %SCRIPT_PATH%\CCMAT00A.s
        %check_cube_errors%
        
        @ECHO. >> %SCENARIO_DIR%\converge.txt
        @type %SCENARIO_DIR%\converge_%ITER%_!PER!.txt >> %SCENARIO_DIR%\converge.txt
        @ECHO. >> %SCENARIO_DIR%\converge_%ITER%_!PER!.txt
        
        FOR /f "tokens=*" %%a IN (TPPL.VAR) DO (
            SET %%a
        )
    )
      
    IF !OP._ERRLINKS! GTR %conv_LinkPerc% (
        SET error_flag=1
        )
    IF !MD._ERRLINKS! GTR %conv_LinkPerc% (
        SET error_flag=1
        )
    IF !AM._ERRLINKS! GTR %conv_LinkPerc% (
        SET error_flag=1
        )
    IF !PM._ERRLINKS! GTR %conv_LinkPerc% (
        SET error_flag=1
        )
    
    ECHO.
    ECHO Iteration %ITER%: error flag !error_flag!
    ECHO.
    
    IF !error_flag! EQU 1 (
        @ECHO Iteration %ITER% Not Converged >> %SCENARIO_DIR%\converge.txt
    )
    IF !error_flag! EQU 0 (
        @ECHO Iteration %ITER% Converged! >> %SCENARIO_DIR%\converge.txt        
        SET CONV=1
    )
    IF %ITER% EQU %max_feedback% (
        @ECHO. >> %SCENARIO_DIR%\converge.txt
        ECHO Maximum Iterations %max_feedback% Hit >> %SCENARIO_DIR%\converge.txt
        @ECHO. >> %SCENARIO_DIR%\converge.txt
        
        SET CONV=1
    )
)
::endComment


IF %CONV% EQU 0 (SET FinalAssign=1)
IF %CONV% EQU 1 (SET FinalAssign=2)

::%beginComment%
:: If the model is converged, run assignment one last time
IF %FinalAssign% EQU 2 (
    :: FINAL HIGHWAY 
    ::Start Cube Cluster
    runtpp %SCRIPT_PATH%\HTPIL00B.S
    %check_cube_errors%
    FOR /L %%I IN (1,1,11) DO (
        IF %%I EQU 1 (
            SET PER=AM1
            SET ASSIGNNAME=AM1 Peak Period
            SET HWY_NET=HWY_NET_3.net
            SET NETNAME=AM Peak Period 6:00 AM to 7:00 AM
            SET CAPFAC=1
        )
        IF %%I EQU 2 (
            SET PER=AM2
            SET ASSIGNNAME=AM2 Peak Period
            SET HWY_NET=HWY_NET_3.net
            SET NETNAME=AM Peak Period 7:00 AM to 8:00 AM
            SET CAPFAC=1
        )
        IF %%I EQU 3 (
            SET PER=AM3
            SET ASSIGNNAME=AM3 Peak Period
            SET HWY_NET=HWY_NET_3.net
            SET NETNAME=AM Peak Period 8:00 AM to 9:00 AM
            SET CAPFAC=1
        )
        IF %%I EQU 4 (
            SET PER=AM4
            SET ASSIGNNAME=AM4 Peak Period
            SET HWY_NET = HWY_NET_3.net
            SET NETNAME=AM Peak Period 9:00 AM to 10:00 AM
            SET CAPFAC=1
        )
        IF %%I EQU 5 (
            SET PER=MD
            SET ASSIGNNAME=Mid Day Period
            SET HWY_NET=HWY_NET_4.net
            SET NETNAME=Mid Day Period 10:00 AM to 3:00 PM
            SET CAPFAC=4.48
        )
        IF %%I EQU 6 (
            SET PER=PM1
            SET ASSIGNNAME=PM1 Peak Period
            SET HWY_NET = HWY_NET_6.net
            SET NETNAME=PM Peak Period 3:00 AM to 4:00 PM
            SET CAPFAC=1
        )
        IF %%I EQU 7 (
            SET PER=PM2
            SET ASSIGNNAME=PM2 Peak Period
            SET HWY_NET=HWY_NET_6.net
            SET NETNAME=PM Peak Period 4:00 AM to 5:00 PM
            SET CAPFAC=1
        )
        IF %%I EQU 8 (
            SET PER=PM3
            SET ASSIGNNAME=PM3 Peak Period
            SET HWY_NET=HWY_NET_6.net
            SET NETNAME=PM Peak Period 5:00 AM to 6:00 PM
            SET CAPFAC=1
        )
        IF %%I EQU 9 (
            SET PER=PM4
            SET ASSIGNNAME=PM4 Peak Period
            SET HWY_NET=HWY_NET_6.net
            SET NETNAME=PM Peak Period 6:00 AM to 7:00 PM
            SET CAPFAC=1
        )
        IF %%I EQU 10 (
            SET PER=EV
            SET ASSIGNNAME=Evening Period
            SET HWY_NET=HWY_NET_1.net
            SET NETNAME=Evening 7:00 PM to 12:00 AM
            SET CAPFAC=3.32
        )
        IF %%I EQU 11 (
            SET PER=ON
            SET ASSIGNNAME=Overnight Period
            SET HWY_NET=HWY_NET_1.net
            SET NETNAME=Overnight 12:00 AM to 6:00 AM
            SET CAPFAC=2.59
        )
        
        runtpp %SCRIPT_PATH%\HTMAT00B.s
        %check_cube_errors%
        runtpp %SCRIPT_PATH%\HTHWY00B.s
        %check_cube_errors%


 
    )

     :: End Cube Cluster
     runtpp %SCRIPT_PATH%\HTPIL00E.S
 


  
    :: FINAL TRANSIT
    runtpp %SCRIPT_PATH%\PAMAT00C.s
    %check_cube_errors%

    runtpp %SCRIPT_PATH%\PAMAT00A_loop.s
    %check_cube_errors%
::now
    runtpp %SCRIPT_PATH%\PAPTR00B_loop.s
    %check_cube_errors%
    runtpp %SCRIPT_PATH%\PAPTR00D_loop.s
    %check_cube_errors%



        FOR /L %%K IN (1,1,2) DO (
            IF %%K EQU 1 (SET ACC=WK)
            IF %%K EQU 2 (SET ACC=DR)
        
        runtpp %SCRIPT_PATH%\PAMAT00B_loop.s
        %check_cube_errors%
        )
    
    :: FINAL POSTPROCESSING
    FOR /L %%I IN (1,1,2) DO (
        IF %%I EQU 1 (SET PER=AM)
        IF %%I EQU 2 (SET PER=PM)
        
        :: Combine time period networks
        runtpp %SCRIPT_PATH%\PPNET00A.s
        %check_cube_errors%
        runtpp %SCRIPT_PATH%\PPNET00B.s
        %check_cube_errors%
        :: Export to csv
        runtpp %SCRIPT_PATH%\PPMAT00A.s
        %check_cube_errors%
    )
)



SET /a ITER=ITER+1
SET /a PREV_ITER=PREV_ITER+1

:: Return to beginning of model loop if model is no converged
IF %ITER% LEQ %max_feedback% (IF %CONV% EQU 0 (%returnToHead%))
::endComment

COPY *.prn %SCENARIO_DIR%\abm_logs\*.prn

:: Delete all the temporary TP+ printouts and cluster files
DEL *.prn

:Visualizer
cd Visualizer
generateDashboard_metc_vs_asim.bat

:endOfFile
@ECHO OFF
IF ERRORLEVEL 0 (
    ECHO RUN SUCCEEDED
)
IF ERRORLEVEL 1 (
    ECHO RUN FAILED IN ActivitySim
)
IF ERRORLEVEL 2 (
    ECHO RUN FAILED IN CUBE SCRIPTS
)



::cd ..\..\..