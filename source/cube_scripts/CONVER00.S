; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
ITER = 2
PREV_ITER = ITER - 1
;PER='NT' 

; tag the iteration time and date
*echo.  >> "%SCENARIO_DIR%\converge.txt"
*echo.  >> "%SCENARIO_DIR%\converge.txt"
*echo 'Checking convergence for iteration %ITER%'  >> "%SCENARIO_DIR%\converge.txt"
*echo %date% %time%  >> "%SCENARIO_DIR%\converge.txt"

LOOP TOD=1,4,1
 IF(TOD=1) PER='NT' 
 IF(TOD=2) PER='AM' 
 IF(TOD=3) PER='MD' 
 IF(TOD=4) PER='PM' 
 
 
; End of PILOT Script

; Script for program NETWORK in file "D:\TourCast\MetCouncil_ABM02092015\CUBE\CCNET00D.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK MSG='Unbuild network'
FILEO LINKO = "%SCENARIO_DIR%\HWY_LDNET_%ITER%_%PER%.dbf"
FILEI LINKI[1] = "%SCENARIO_DIR%\HWY_LDNET_%ITER%_%PER%.NET"


ENDRUN


; Script for program MATRIX in file "D:\TourCast\MetCouncil_ABM02092015\CUBE\CCMAT00A.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Calculate convergence stats'
FILEO PRINTO[1] = "%SCENARIO_DIR%\CONVERGE_%ITER%_%PER%.txt"
FILEI DBI[2] = "%SCENARIO_DIR%\HWY_LDNET_%PREV_ITER%_%PER%.dbf",
 SORT=A,B JOINTODBI=1 JOINTOFIELDS=A,B
FILEI DBI[1] = "%SCENARIO_DIR%\HWY_LDNET_%ITER%_%PER%.dbf",
 SORT=A,B 

  zones = 1
  
  _totLinks = 0
  _chgLinks = 0
  _prevVMT = 0
  _curVMT = 0
  _sumSE = 0
  
 ; First loop through each records and calculate differences
 LOOP k=1,DBI.1.NUMRECORDS
  
  x=DBIReadRecord(1,k)
  IF(DI.2.V_1 > 0 & DI.1.V_1 > 0)
    _totLinks = _totLinks + 1
  
    IF (((DI.2.V_1 - DI.1.V_1) / DI.1.V_1) > (%conv_LinkVol%/100))
    
      _chgLinks = _chgLinks + 1
      
    ENDIF
    
    _prevVMT = _prevVMT + DI.2.V_1*DI.2.DISTANCE
    _curVMT  = _curVMT  + DI.1.V_1*DI.1.DISTANCE
    _sumSE   = _sumSE   + ((DI.2.V_1 - DI.1.V_1)*DI.2.DISTANCE)^2

  ENDIF
  
 ENDLOOP

 ; Next, calculate overall PRMSE 
 _MSE = _sumSE / _totLinks
 _PRMSE = 100*SQRT(_MSE)/(_curVMT/_totLinks)
 _errLinks = (_chgLinks / _totLinks) * 100
 
 LOG PREFIX=%PER%, VAR=_errLinks
 LOG VAR = _errLinks
 
 PRINT CSV=F LIST='Convergence check for period %PER% iteration %ITER%' PRINTO=1 
 PRINT CSV=F LIST='Previous %PER% VMT was ', _prevVMT PRINTO=1
 PRINT CSV=F LIST='Current %PER% VMT is ', _curVMT PRINTO=1
 PRINT CSV=F LIST='The percent of %PER% link volumes exceeding ', %conv_LinkVol%, '% change is ', _errLinks, '%' PRINTO=1
 PRINT CSV=F LIST='%PER% PRMSE is ', _PRMSE, '%' PRINTO=1

ENDRUN


; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.

*echo.  >> "%SCENARIO_DIR%\converge.txt"
*type "%SCENARIO_DIR%\converge_%ITER%_%PER%.txt" >> "%SCENARIO_DIR%\converge.txt"
*echo.  >> "%SCENARIO_DIR%\converge.txt"

endloop

; check if converged

if ((OP._ERRLINKS > %conv_LinkPerc%) |
    (MD._ERRLINKS > %conv_LinkPerc%) |
    (AM._ERRLINKS > %conv_LinkPerc%) |
    (PM._ERRLINKS > %conv_LinkPerc%))
    
  *echo Iteration %ITER% Not Converged >> "%SCENARIO_DIR%\converge.txt"
  
else
 
  *echo Iteration %ITER% Converged! >> "%SCENARIO_DIR%\converge.txt"
  
   CONV = 1
   LOG VAR=CONV
   ;LOG PREFIX=CONVCHECK, VAR=CONV ; It appears that Cube does not write a prefix if logged from a Pilot program
   
endif

if (ITER == %max_feedback%)
  *echo.  >> "%SCENARIO_DIR%\converge.txt"
  *echo Maximum Iterations Hit >> "%SCENARIO_DIR%\converge.txt"
  *echo.  >> "%SCENARIO_DIR%\converge.txt"
  
    CONV = 1
   LOG VAR=CONV
endif
; End of PILOT Script

