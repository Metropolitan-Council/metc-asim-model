; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='TEMP: truck trip tables'
FILEO MATO[1] = "%SCENARIO_DIR%\%ITER%_%PER%_TRK.TRP",
                 MO=1, DEC[1]=5*2, NAME = Truck
FILEI MATI[1] = "%SCENARIO_DIR%\%ITER%_%PER%_HWY.TRP"

          MW[1] = MI.1.1 ; *****DUMMY******
          
ENDRUN
