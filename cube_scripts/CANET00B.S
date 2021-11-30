; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK MSG='Export link dbf'
FILEO LINKO = "%SCENARIO_DIR%\HWY_LDNET_%ITER%_DAILY.dbf"
FILEI LINKI[1] = "%SCENARIO_DIR%\HWY_LDNET_%ITER%_DAILY.NET"


ENDRUN
