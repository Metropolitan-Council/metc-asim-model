; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK MSG='Export Highway Network from GeoDatabase'
FILEI LINKI[1] = "%geoDB%"
FILEO NETO = "%SCENARIO_DIR%\HighwayNetwork.net"


ENDRUN
