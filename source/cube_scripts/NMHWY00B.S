RUN PGM=HIGHWAY MSG='Skim Walk Path Distance'
FILEO MATO[1] = "%SCENARIO_DIR%\nonmotorized\NM_SKIM_WALK.skm",
 MO=1-4, NAME=DISTANCE, B3DIST, B2DIST, B1DIST
FILEI NETI = "%SCENARIO_DIR%\nonmotorized\NM_NET.net"

DISTRIBUTEINTRASTEP ProcessID='Intrastep', ProcessList=1-%max_threads%

PROCESS PHASE=ILOOP

  PATHLOAD PATH=LI.DISTANCE, MW[1]=pathtrace(LI.DISTANCE), MW[2]=pathtrace(LI.B3DIST),
                          MW[3]=pathtrace(LI.B2DIST), MW[4]=pathtrace(LI.B1DIST)  
      MW[1][I] = ROWMIN(1) * 0.5  ; Intrazonal time
      MW[2][I] = ROWMIN(2) * 0.5
      MW[3][I] = ROWMIN(3) * 0.5
      MW[4][I] = ROWMIN(4) * 0.5
ENDPROCESS

ENDRUN
