; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=FRATAR MSG='Fratar station targets using distribution from survey'
FILEO MATO[1] = "%SCENARIO_DIR%\external\HWY_EXT_EETRIP.TRP",
 MO=1, NAME=EE_AUTO
FILEI MATI[1] = "%SCENARIO_DIR%\external\HWY_EXT_JOINT_TARGET.TRP"
FILEI LOOKUPI[1] = "%SCENARIO_DIR%\external\HWY_EXT_MARGINAL_TARGET.txt"

  LOOKUP LOOKUPI=1,
  NAME=FRATAR,
  LOOKUP[1]=1, RESULT=2,
  LOOKUP[2]=1, RESULT=3
  
  MAXITERS=20

  SETPA P[1]=FRATAR(1,J), A[1]=FRATAR(2,J) MW[1]=MI.1.EE_SURVEY

ENDRUN
