; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=HIGHWAY MSG='Free Flow Speed Skims'
FILEO MATO[1] = "%SCENARIO_DIR%\DAILY_HWY.skm"
FILEI NETI = "%SCENARIO_DIR%\FFSpdNetwork.NET"


ENDRUN
