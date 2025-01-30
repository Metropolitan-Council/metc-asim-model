; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK MSG='Unbuild network'
FILEO LINKO = "%SCENARIO_DIR%\%PREV_ITER%_%PER%_LDLINK.DBF"
FILEI LINKI[1] = "%SCENARIO_DIR%\%PREV_ITER%_%PER%_LDNET.NET"


ENDRUN
