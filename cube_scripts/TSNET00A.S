; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK MSG='TEMP: extract link and node dbfs'
FILEO NODEO = "%SCENARIO_DIR%\node.dbf"
FILEO LINKO = "%SCENARIO_DIR%\link.dbf"
FILEI LINKI[1] = "%SCENARIO_DIR%\ALL_NET.net"


ENDRUN
