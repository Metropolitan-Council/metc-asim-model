; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Create weighted skim times'
FILEO MATO[1] = "%SCENARIO_DIR%\TRK_SKIM_%ITER%.tmp",
 MO=1-2, DEC=D*2, NAME=SNGLTIME, MULTTIME
FILEI LOOKUPI[1] = "%qrfm%"
FILEI MATI[4] = "%SCENARIO_DIR%\HWY_SKIM_%PREV_ITER%_NT.SKM"
FILEI MATI[3] = "%SCENARIO_DIR%\HWY_SKIM_%PREV_ITER%_PM.SKM"
FILEI MATI[2] = "%SCENARIO_DIR%\HWY_SKIM_%PREV_ITER%_MD.SKM"
FILEI MATI[1] = "%SCENARIO_DIR%\HWY_SKIM_%PREV_ITER%_AM.SKM"

  LOOKUP LOOKUPI=1, NAME=TOD,  ;TOD Skim Shares
  LOOKUP[1]=1, RESULT=2, ; AM
  LOOKUP[2]=1, RESULT=3, ; MD
  LOOKUP[3]=1, RESULT=4, ; PM
  LOOKUP[4]=1, RESULT=5  ; NT

  ; Single Unit weighted travel time
  MW[1] = MI.1.DANTIME * TOD(1,3) +  ; AM
          MI.1.DANTIME * TOD(1,3) +  ; MD
          MI.3.DANTIME * TOD(3,3)  + ; PM
          MI.4.DANTIME * TOD(4,3)    ; NT 
          
 ; Multi Unit weighted travel time
  MW[2]=  MI.1.DANTIME * TOD(1,4)  + ; AM
          MI.2.DANTIME * TOD(2,4)  + ; MD
          MI.3.DANTIME * TOD(3,4)  + ; PM
          MI.4.DANTIME * TOD(4,4)    ; NT
        
 ; prevent EI trips from becoming EEs
 JLOOP
  IF (I>%int_zones% & J>%int_zones%)
    MW[1] = 1000
    MW[2] = 1000
    MW[3] = 1000
    MW[4] = 1000
  ENDIF
 ENDJLOOP
 
ENDRUN
