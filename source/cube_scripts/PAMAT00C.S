; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Combine Special Generator Trips into Peak/Off-Peak'
FILEO MATO[1] = "%SCENARIO_DIR%\transit\XIT_SPC_TRIP_%PREV_ITER%_EA.trp",
 MO=1-2, NAME=WK, DR
FILEO MATO[2] = "%SCENARIO_DIR%\transit\XIT_SPC_TRIP_%PREV_ITER%_AM.trp",
 MO=3-4, NAME=WK, DR
FILEO MATO[3] = "%SCENARIO_DIR%\transit\XIT_SPC_TRIP_%PREV_ITER%_MD.trp",
 MO=4-5, NAME=WK, DR
FILEO MATO[4] = "%SCENARIO_DIR%\transit\XIT_SPC_TRIP_%PREV_ITER%_PM.trp",
 MO=6-7, NAME=WK, DR
FILEO MATO[5] = "%SCENARIO_DIR%\transit\XIT_SPC_TRIP_%PREV_ITER%_NT.trp",
 MO=8-9, NAME=WK, DR

FILEI MATI[11] = "%SCENARIO_DIR%\specialgen\HWY_SPC_TRIP_%ITER%_ON.trp"
FILEI MATI[10] = "%SCENARIO_DIR%\specialgen\HWY_SPC_TRIP_%ITER%_EV.trp"
FILEI MATI[9] = "%SCENARIO_DIR%\specialgen\HWY_SPC_TRIP_%ITER%_MD.trp"
FILEI MATI[8] = "%SCENARIO_DIR%\specialgen\HWY_SPC_TRIP_%ITER%_PM4.trp"
FILEI MATI[7] = "%SCENARIO_DIR%\specialgen\HWY_SPC_TRIP_%ITER%_PM3.trp"
FILEI MATI[6] = "%SCENARIO_DIR%\specialgen\HWY_SPC_TRIP_%ITER%_PM2.trp"
FILEI MATI[5] = "%SCENARIO_DIR%\specialgen\HWY_SPC_TRIP_%ITER%_PM1.trp"
FILEI MATI[4] = "%SCENARIO_DIR%\specialgen\HWY_SPC_TRIP_%ITER%_AM4.trp"
FILEI MATI[3] = "%SCENARIO_DIR%\specialgen\HWY_SPC_TRIP_%ITER%_AM3.trp"
FILEI MATI[2] = "%SCENARIO_DIR%\specialgen\HWY_SPC_TRIP_%ITER%_AM2.trp"
FILEI MATI[1] = "%SCENARIO_DIR%\specialgen\HWY_SPC_TRIP_%ITER%_AM1.trp"

  ; ea
  MW[1] = MI.11.4
  MW[2] = MI.11.5
		
  ; am    
  MW[3] = MI.1.4 + MI.2.4 + MI.3.4 + MI.4.4 
  MW[4] = MI.1.5 + MI.2.5 + MI.3.5 + MI.4.5 
		
  ; md    
  MW[5] = MI.9.4
  MW[6] = MI.9.5
		
  ; pm    
  MW[7] = MI.5.4 + MI.6.4 + MI.7.4 + MI.8.4
  MW[8] = MI.5.5 + MI.6.5 + MI.7.5 + MI.8.5
		
  ; nt    
  MW[11] = MI.10.4 
  MW[12] = MI.10.5 

  
ENDRUN
