; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Aggregate Truck Trip Tables for Interm Assignment'
FILEO MATO[3] = "%SCENARIO_DIR%\TRK_TRIP_%ITER%_NT.TRP",
                 MO=201-203, DEC[1]=3*2, 
                 NAME = Single, Combo, Total
FILEO MATO[2] = "%SCENARIO_DIR%\TRK_TRIP_%ITER%_PM.TRP",
                 MO=101-103, DEC[1]=3*2, 
                 NAME = Single, Combo, Total
FILEI MATI[10] = "%SCENARIO_DIR%\TRK_TRIP_%ITER%_ON.TRP"
FILEI MATI[9] = "%SCENARIO_DIR%\TRK_TRIP_%ITER%_EV.TRP"
FILEI MATI[8] = "%SCENARIO_DIR%\TRK_TRIP_%ITER%_PM4.TRP"
FILEI MATI[7] = "%SCENARIO_DIR%\TRK_TRIP_%ITER%_PM3.TRP"
FILEI MATI[6] = "%SCENARIO_DIR%\TRK_TRIP_%ITER%_PM2.TRP"
FILEI MATI[5] = "%SCENARIO_DIR%\TRK_TRIP_%ITER%_PM1.TRP"
FILEO MATO[1] = "%SCENARIO_DIR%\TRK_TRIP_%ITER%_AM.TRP",
                 MO=1-3, DEC[1]=3*2, 
                 NAME = Single, Combo, Total
FILEI MATI[4] = "%SCENARIO_DIR%\TRK_TRIP_%ITER%_AM4.TRP"
FILEI MATI[3] = "%SCENARIO_DIR%\TRK_TRIP_%ITER%_AM3.TRP"
FILEI MATI[2] = "%SCENARIO_DIR%\TRK_TRIP_%ITER%_AM2.TRP"
FILEI MATI[1] = "%SCENARIO_DIR%\TRK_TRIP_%ITER%_AM1.TRP"

DISTRIBUTEINTRASTEP ProcessID='Intrastep', ProcessList=1-%max_threads%

  ; AM Period
	MW[1] = MI.1.1 + MI.2.1 + MI.3.1 + MI.4.1
	MW[2] = MI.1.2 + MI.2.2 + MI.3.2 + MI.4.2
	MW[3] = MI.1.3 + MI.2.3 + MI.3.3 + MI.4.3
  
 ; pm period
	MW[101] = MI.5.1 + MI.6.1 + MI.7.1 + MI.8.1
	MW[102] = MI.5.2 + MI.6.2 + MI.7.2 + MI.8.2
	MW[103] = MI.5.3 + MI.6.3 + MI.7.3 + MI.8.3
 
 ; overnight period
	MW[201] = MI.9.1 + MI.10.1
	MW[202] = MI.9.2 + MI.10.2
	MW[203] = MI.9.3 + MI.10.3


ENDRUN
