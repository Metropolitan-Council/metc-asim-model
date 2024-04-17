; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Combine EI / IE trips with transpose and EE'
FILEI MATI[3] = "%SCENARIO_DIR%\external\HWY_EXT_EETRIP.TRP"
FILEO MATO[1] = "%SCENARIO_DIR%\external\HWY_EXT_TRIP_%ITER%.trp",
 MO=1-3, NAME=DA, SR2, SR3
FILEI MATI[2] = "%SCENARIO_DIR%\external\HWY_EXT_IETRIP_%ITER%.trp"
FILEI MATI[1] = "%SCENARIO_DIR%\external\HWY_EXT_EITRIP_%ITER%.trp"

  MW[1] = MI.1.6 + MI.1.6.T + MI.2.6 + MI.2.6.T + MI.3.1 ; exclude EE trips from MnPass
  MW[2] = MI.1.7 + MI.1.7.T + MI.2.7 + MI.2.7.T
  MW[3] = MI.1.8 + MI.1.8.T + MI.2.8 + MI.2.8.T  

ENDRUN
