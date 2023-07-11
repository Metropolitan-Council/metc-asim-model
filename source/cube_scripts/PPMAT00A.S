; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Export to CSV'
FILEO PRINTO[1] = "%SCENARIO_DIR%\HWY_LDNET_%ITER%_%PER%_COMP.CSV"
FILEI DBI[1] = "%SCENARIO_DIR%\HWY_LDNET_%ITER%_%PER%_COMP.DBF"

zones = 1
 LOOP k=1,DBI.1.NUMRECORDS
  x=DBIReadRecord(1,k)


PRINT CSV=T, LIST=DI.1.A(6), DI.1.B(6), DI.1.NC_NAME(20), DI.1.RCI(2), DI.1.AREA(2), DI.1.COUNTY(2),  
                  DI.1.DISTANCE(9.6), DI.1.VOL_TOT_HR(9.4), DI.1.VOL_TOT_PD(9.4), 
                  DI.1.VHT_HR(10.4), DI.1.VHT_PD(10.4), 
                  DI.1.CSPD_HR(10.4), DI.1.CSPD_PD(10.4), DI.1.CSPD_PER_DI(10.4), DI.1.VHT_DIFFSQ(10.4) PRINTO=1
                  ;,(DI.1.VOL_DIFF - _volErrAve)^2(10.4) 
                  
 ENDLOOP

ENDRUN
