; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Add return trips'
FILEO MATO[1] = "%SCENARIO_DIR%\HWY_SPC_TRIP_%ITER%_%PER%.trp",
 MO=1-5, DEC=3,3,3,3,3, NAME= DA,SR2,SR3,XIT_WK, XIT_DR
FILEI MATI[1] = "%SCENARIO_DIR%\HWY_SPC_TRIP_%ITER%_%PER%.tmp"
 
 MW[1] = MI.1.1 + MI.1.1.T
 MW[2] = MI.1.2 + MI.1.2.T + (MI.1.2 + MI.1.2.T)*0.9391
 MW[3] = MI.1.3 + MI.1.3.T + (MI.1.3 + MI.1.3.T)*0.6308
 MW[4] = MI.1.4 + MI.1.4  ; NOTE: Transit is assigned in PA format
 MW[5] = MI.1.5 + MI.1.5  ; NOTE: Transit is assigned in PA format


ENDRUN
