; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.


;ITER = 4
iter = 1; End of PILOT Script

; Script for program NETWORK in file "C:\Users\ehrlicjn\Desktop\MetCouncilABMPreRelease0.1\CUBE\CANET00A.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK MSG='Combine Convergence Assignment Networks'
FILEI LINKI[4] = "%SCENARIO_DIR%\HWY_LDNET_%ITER%_NT.NET"
FILEI LINKI[3] = "%SCENARIO_DIR%\HWY_LDNET_%ITER%_PM.NET"
FILEI LINKI[2] = "%SCENARIO_DIR%\HWY_LDNET_%ITER%_MD.NET"
FILEI LINKI[1] = "%SCENARIO_DIR%\HWY_LDNET_%ITER%_AM.NET"

FILEO NETO = "%SCENARIO_DIR%\HWY_LDNET_%ITER%_DAILY.NET",
 INCLUDE = A, B, NC_NAME, LINKCLASS, AREA, COUNTY, RCI, DISTANCE, LANES, LANEMILES,
 SCREENLINE, COUNT, 
 VOL_TRK_AM, VOL_AUTO_AM, VOL_TOT_AM,
 VOL_TRK_MD, VOL_AUTO_MD, VOL_TOT_MD,
 VOL_TRK_PM, VOL_AUTO_PM, VOL_TOT_PM,
 VOL_TRK_NT, VOL_AUTO_NT, VOL_TOT_NT,
 VOL_TRK_DAILY, VOL_AUTO_DAILY, VOL_TOT_DAILY,
 FF_TIME, FF_SPD,
 CSPD_AM, 
 CSPD_MD, 
 CSPD_PM,  
 CSPD_NT,  
 CSPD_DAILY, 
 CAP_AM, CAP_MD, CAP_PM, CAP_NT,
 AM_CNT, MD_CNT, PM_CNT, NT_CNT,
 TIME_AM, TIME_MD, TIME_PM, TIME_NT,
 VMT, VHT, AVMT, AVHT, TVMT, TVHT, RATIO, 
 VMT_DIFF, VMT_DIFFSQ, VOL_DIFFSQ, HOV
  
 FF_SPD  = LI.1.SPEED
 FF_TIME = LI.1.TIME_1
 LANEMILES = LI.1.LANES * LI.1.DISTANCE
 SCREENLINE = 0 ; TODO - hook this up
 COUNT = LI.1.DY_CNT + LI.1.AADT
 ;COUNT = LI.1.AADT
 
 ; AM Period
 CSPD_AM      = LI.1.CSPD_1
 VOL_AUTO_AM  = LI.1.V_1 - (LI.1.V13_1  * %hwy_TrkFac%)
 VOL_TRK_AM   = LI.1.V13_1 
 VOL_TOT_AM   = VOL_AUTO_AM + VOL_TRK_AM
 CAP_AM       = LI.1.CAPACITY
 TIME_AM      = LI.1.TIME_1
 
 ; MD Period
 CSPD_MD      = LI.2.CSPD_1
 VOL_AUTO_MD  = LI.2.V_1 - (LI.2.V13_1  * %hwy_TrkFac%)
 VOL_TRK_MD   = LI.2.V13_1 
 VOL_TOT_MD   = VOL_AUTO_MD + VOL_TRK_MD
 CAP_MD       = LI.2.CAPACITY
 TIME_MD      = LI.2.TIME_1
 
 ; PM Period
 CSPD_PM      = LI.3.CSPD_1
 VOL_AUTO_PM  = LI.3.V_1 - (LI.3.V13_1  * %hwy_TrkFac%)
 VOL_TRK_PM   = LI.3.V13_1 
 VOL_TOT_PM   = VOL_AUTO_PM + VOL_TRK_PM
 CAP_PM       = LI.3.CAPACITY
 TIME_PM      = LI.3.TIME_1
 
 ; NT Period
 CSPD_NT      = LI.4.CSPD_1
 VOL_AUTO_NT  = LI.4.V_1 - (LI.4.V13_1  * %hwy_TrkFac%)
 VOL_TRK_NT   = LI.4.V13_1 
 VOL_TOT_NT   = VOL_AUTO_NT + VOL_TRK_NT
 CAP_NT       = LI.4.CAPACITY 
 TIME_NT      = LI.4.TIME_1
 
 ; Daily
 VOL_TRK_DAILY = VOL_TRK_AM + VOL_TRK_MD + VOL_TRK_PM + VOL_TRK_NT
 VOL_AUTO_DAILY = VOL_AUTO_AM + VOL_AUTO_MD + VOL_AUTO_PM + VOL_AUTO_NT
 VOL_TOT_DAILY = VOL_TOT_AM + VOL_TOT_MD + VOL_TOT_PM + VOL_TOT_NT

 IF (VOL_TOT_DAILY > 0) 
  CSPD_DAILY = (VOL_TOT_AM * CSPD_AM + VOL_TOT_MD * CSPD_MD + VOL_TOT_PM * CSPD_PM + VOL_TOT_NT * CSPD_NT)/VOL_TOT_DAILY
 ELSE 
  CSPD_DAILY = CSPD_MD
 ENDIF

 IF (COUNT <> 0 & LINKCLASS <>99 & LINKCLASS<>0)
   GEH=sqrt((((VOL_TOT_DAILY - COUNT)^2)/((VOL_TOT_DAILY + COUNT)/2)))
   VOL_DIFF = COUNT - VOL_TOT_DAILY
   VOL_DIFFSQ = VOL_DIFF ^ 2
   VOL_PER_DIFF = VOL_DIFF / COUNT
 ENDIF 
 
 ; develop some stats for easier reports
 VMT  = (VOL_TOT_DAILY)*distance
 VHT  = (VOL_TOT_DAILY)*(distance/CSPD_DAILY)
 AVMT = (VOL_AUTO_DAILY)*distance
 AVHT = (VOL_AUTO_DAILY)*(distance/CSPD_DAILY)
 TVMT = (VOL_TRK_DAILY)*distance
 TVHT = (VOL_TRK_DAILY)*(distance/CSPD_DAILY)
 
 VMT_DIFF = (VOL_TOT_DAILY)*distance - COUNT*distance
 VMT_DIFFSQ = VMT_DIFF ^ 2
 
 RATIO = 0

 IF (COUNT > 0) RATIO = VOL_TOT_DAILY / COUNT
 
ENDRUN


; Script for program NETWORK in file "C:\Users\ehrlicjn\Desktop\MetCouncilABMPreRelease0.1\CUBE\CANET00B.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK MSG='Export link dbf'
FILEO LINKO = "%SCENARIO_DIR%\HWY_LDNET_%ITER%_DAILY.dbf"
FILEI LINKI[1] = "%SCENARIO_DIR%\HWY_LDNET_%ITER%_DAILY.NET"


ENDRUN


; Script for program MATRIX in file "C:\Users\ehrlicjn\Desktop\MetCouncilABMPreRelease0.1\CUBE\CAMAT00A.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Export to csv'
FILEI DBI[1] = "%SCENARIO_DIR%\HWY_LDNET_%ITER%_DAILY.dbf"
FILEO PRINTO[1] = "%SCENARIO_DIR%\HWY_LDNET_%ITER%_DAILY.csv"

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


