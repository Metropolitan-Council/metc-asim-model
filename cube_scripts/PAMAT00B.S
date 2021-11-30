; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
FILEI DBI[1] = "%SCENARIO_DIR%\XIT_%ACC%_LD_%ITER%_@TPER@.dbf"
FILEO PRINTO[1] = "%SCENARIO_DIR%\XIT_%ACC%_LD_%ITER%_@TPER@_SUMM.csv"
zones = 1

ons = 0 name = 0 mode = 0 op = 0

 PRINT CSV=T, LIST='Route, Mode, Operator, Boardings', PRINTO=1

; Read first record to get name reference
x=DBIReadREcord(1,k)
name = val(DI.1.NAME)
strname = DI.1.NAME
mode = DI.1.MODE
op   = DI.1.OPERATOR

; Walk-Transit
  LOOP k=1,DBI.1.NUMRECORDS
    x=DBIReadREcord(1,k)
    
    IF (strname == DI.1.NAME)
      ons = ons + DI.1.ONA
    ELSE
      PRINT CSV=T, LIST=strname, mode, op, ons PRINTO=1
      name = val(DI.1.NAME)
      strname = DI.1.NAME
      mode = DI.1.MODE
      op   = DI.1.OPERATOR
      ons  = DI.1.ONA
    ENDIF

  ENDLOOP

ENDRUN
