; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Calculate trip shares per time period'
FILEI RECI = "%SCENARIO_DIR%\%ITER%_HWY_TRIPTOTALS.csv"


ENDRUN
