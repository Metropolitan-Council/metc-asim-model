; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Aggregate Trip Tables for Interm Assignment'
FILEO MATO[1] = "%SCENARIO_DIR%\%ITER%_%PER%_HWY.trp"
FILEI MATI[4] = "%SCENARIO_DIR%\%ITER%_AM4_HWY.trp"
FILEI MATI[3] = "%SCENARIO_DIR%\%ITER%_AM3_HWY.trp"
FILEI MATI[2] = "%SCENARIO_DIR%\%ITER%_AM2_HWY.trp"
FILEI MATI[1] = "%SCENARIO_DIR%\%ITER%_AM1_HWY.trp"


ENDRUN
