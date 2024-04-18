; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Export to csv'
FILEI DBI[1] = "%SCENARIO_DIR%\highway\HWY_LDNET_%ITER%_DAILY.dbf"
FILEO PRINTO[1] = "%SCENARIO_DIR%\highway\HWY_LDNET_%ITER%_DAILY.csv"

  zones = 1
 
  ; Loop through database and write out
 LOOP k=1,DBI.1.NUMRECORDS
  x=DBIReadRecord(1,k)


  PRINT CSV=T, LIST=DI.1.A(6), DI.1.B(6), DI.1.NC_NAME(20), DI.1.RCI(2), DI.1.AREA(2), DI.1.COUNTY(2), DI.1.SCREENLINE(2), 
                  DI.1.DISTANCE(9.6), DI.1.LANES(1), (DI.1.DISTANCE * DI.1.LANES)(9.6), 
                  DI.1.COUNT(11.5), DI.1.VOL_TOT_DAI(9.4), DI.1.VOL_TRK_DAI(9.4), DI.1.VOL_AUTO_DA(9.4), 
                  (DI.1.COUNT * DI.1.DISTANCE)(11.5), DI.1.VMT(10.4), 
                  DI.1.TVMT(10.4), DI.1.AVMT(10.4), DI.1.VHT(10.4), DI.1.TVHT(10.4), DI.1.AVHT(10.4), 
                  DI.1.CSPD_DAILY(4.2), (DI.1.VHT*60/DI.1.VOL_TOT_DAI), DI.1.GEH(4.2), 
                  DI.1.VOL_TOT_AM(9.4), DI.1.VOL_TOT_MD(9.4), DI.1.VOL_TOT_PM(9.4), DI.1.VOL_TOT_NT(9.4),
                  DI.1.AM_CNT(9.4), DI.1.MD_CNT(9.4), DI.1.PM_CNT(9.4), DI.1.NT_CNT(9.4), DI.1.VOL_DIFFSQ(10.4), DI.1.VMT_DIFFSQ(10.4) PRINTO=1

;ENDIF
 ENDLOOP

ENDRUN
