; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Calculate convergence stats'
FILEO PRINTO[1] = "%SCENARIO_DIR%\CONVERGE_%ITER%_%PER%.txt"
FILEI DBI[1] = "%SCENARIO_DIR%\HWY_ITERCOMP_%PREV_ITER%_%ITER%_%PER%.dbf",
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
  
  ; only check for non-centroid connectors
  IF (DI.1.LINKCLASS <> 99)
 
    _totLinks = _totLinks + 1
    
    IF (ABS(DI.1.PRCLOADCHG) > (%conv_LinkVol%/100))
      
        _chgLinks = _chgLinks + 1
        
    ENDIF
      
    _prevVMT = _prevVMT + DI.1.LOAD1*DI.1.DISTANCE
    _curVMT  = _curVMT  + DI.1.LOAD2*DI.1.DISTANCE
    _sumSE   = _sumSE   + ((DI.1.LOAD1 - DI.1.LOAD2)*DI.1.DISTANCE)^2

  ENDIF ; centroid connector

  
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
