; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK MSG='Export Raw Network From GeoDatabase'
FILEO NETO = "%SCENARIO_DIR%\ALL_NET.tmp"
FILEI LINKI[1] = "%iHwyNet%"


ENDRUN
