; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK MSG='Export Raw Network From GeoDatabase'
FILEO NETO = "%SCENARIO_DIR%\highway\ALL_NET.tmp"
FILEI LINKI[1] = "%iHwyNet%"
FILEO LINKO = "%SCENARIO_DIR%\highway\link.shp" FORMAT=SHP
FILEO NODEO = "%SCENARIO_DIR%\highway\node.shp" FORMAT=SHP

ENDRUN
