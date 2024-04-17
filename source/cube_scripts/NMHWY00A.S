RUN PGM=HIGHWAY MSG='Skim Bike Path Times'
FILEO MATO[1] = "%SCENARIO_DIR%\nonmotorized\NM_SKIM_BIKE.skm",
 MO=1-6, NAME=PERCTIME, BIKETIME, DISTANCE, B3DIST, B2DIST, B1DIST
FILEI NETI = "%SCENARIO_DIR%\nonmotorized\NM_NET.net"

DISTRIBUTEINTRASTEP PROCESSID=mcskim PROCESSLIST=1-%max_threads%

PROCESS PHASE=ILOOP

  PATHLOAD PATH=LI.PTIME, MW[1]=pathtrace(LI.PTIME), MW[2]=pathtrace(LI.BIKETIME),
                          MW[3]=pathtrace(LI.DISTANCE), MW[4]=pathtrace(LI.B3DIST),
                          MW[5]=pathtrace(LI.B2DIST), MW[6]=pathtrace(LI.B1DIST)  
      MW[1][I] = ROWMIN(1) * 0.5  ; Intrazonal time
      MW[2][I] = ROWMIN(2) * 0.5
      MW[3][I] = ROWMIN(3) * 0.5
      MW[4][I] = ROWMIN(3) ; use total distance intrazonal, not just dist on this facility type - NOTE: do not need to divide by 2 b/c done on line 14
      MW[5][I] = 0 ; assume no bike paths on the intrazonal
      MW[6][I] = 0 ; assume no bike paths on the intrazonal
ENDPROCESS

ENDRUN
