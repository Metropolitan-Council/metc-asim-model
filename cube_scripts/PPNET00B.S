; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK
FILEO LINKO = "%SCENARIO_DIR%\HWY_LDNET_%ITER%_%PER%_COMP.DBF"
FILEI LINKI[1] = "%SCENARIO_DIR%\HWY_LDNET_%ITER%_%PER%_COMP.NET"


ENDRUN
