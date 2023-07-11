; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.

PREV_ITER = ITER - 1

IF (ITER==1)
  ;*copy "%CATALOG_DIR%\input\SchoolTAZs.csv" "%SCENARIO_DIR%\SchoolTAZs.csv"
  *copy "%zone_attribs%" "%SCENARIO_DIR%\zones_0.dbf"
ENDIF
