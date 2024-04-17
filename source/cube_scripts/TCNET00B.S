; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK MSG='TEMP: extract link and node dbfs'
FILEO NODEO = "%SCENARIO_DIR%\highway\NODE.DBF"
FILEO LINKO = "%SCENARIO_DIR%\highway\LINK.DBF"
FILEI LINKI[1] = "%SCENARIO_DIR%\highway\ALL_NET.NET"


ENDRUN
