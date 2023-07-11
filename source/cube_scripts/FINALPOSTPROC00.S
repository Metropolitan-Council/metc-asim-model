; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.

ITER=4

LOOP TOD=1,2,1

  IF(TOD==1) PER='AM'
  IF(TOD==2) PER='PM'
; End of PILOT Script

; Script for program NETWORK in file "D:\8296\TestAssignment\CUBE\PPNET00A.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK MSG='Combine 11 and 4 time period networks'
FILEO NETO = "%SCENARIO_DIR%\HWY_LDNET_%ITER%_%PER%_COMP.NET",
 INCLUDE = A, B, NC_NAME(20), AREA, COUNTY, RCI, DISTANCE, 
 VOL_TRK_HR, VOL_AUTO_HR, VOL_TOT_HR, 
 VOL_TRK_PD, VOL_AUTO_PD, VOL_TOT_PD, 
 VHT_HR, VHT_PD,
 CSPD_HR, CSPD_PD, 
 VOL_DIFF, VMT_DIFF, VMT_DIFFSQ
 
FILEI LINKI[5] = "%SCENARIO_DIR%\HWY_LDNET_%ITER%_%PER%.NET"
FILEI LINKI[4] = "%SCENARIO_DIR%\HWY_LDNET_%ITER%_%PER%4.NET"
FILEI LINKI[3] = "%SCENARIO_DIR%\HWY_LDNET_%ITER%_%PER%3.NET"
FILEI LINKI[2] = "%SCENARIO_DIR%\HWY_LDNET_%ITER%_%PER%2.NET"
FILEI LINKI[1] = "%SCENARIO_DIR%\HWY_LDNET_%ITER%_%PER%1.NET"


 VOL_TOT_HR   = LI.1.V_1 + LI.2.V_1 + LI.3.V_1 + LI.4.V_1
 VOL_TRK_HR   = LI.1.V13_1 + LI.2.V13_1 + LI.3.V13_1 + LI.4.V13_1 
 VOL_AUTO_HR  = VOL_TOT_HR - VOL_TRK_HR
 VMT_TOT_HR   = VOL_TOT_HR * DISTANCE
 
 VOL_TOT_PD   = LI.5.V_1
 VOL_TRK_PD   = LI.5.V13_1
 VOL_AUTO_PD  = VOL_TOT_PD - VOL_TRK_PD
 VMT_TOT_PD   = VOL_TOT_PD * DISTANCE
 
 VOL_DIFF = VOL_TOT_HR - VOL_TOT_PD
 VMT_DIFF = VMT_TOT_HR - VMT_TOT_PD
 VMT_DIFFSQ = VMT_DIFF ^ 2
 
 CSPD_PD = LI.5.CSPD_1
  
 IF (VOL_TOT_HR > 0) 
  CSPD_HR = (LI.1.V_1 * LI.1.CSPD_1 + LI.2.V_1 * LI.2.CSPD_1 + LI.3.V_1 * LI.3.CSPD_1 + LI.4.V_1 * LI.4.CSPD_1)/VOL_TOT_HR
 ELSE 
  CSPD_HR = LI.1.CSPD_1
 ENDIF 
 
 VHT_HR = VOL_TOT_HR * (DISTANCE / CSPD_HR)
 VHT_PD = VOL_TOT_PD * (DISTANCE / CSPD_PD) 
 
 VHT_DIFF = VHT_HR - VHT_PD
 VHT_DIFFSQ = VHT_DIFF ^ 2 
 
 CSPD_DIFF = CSPD_HR - CSPD_PD
 CSPD_PER_DIFF = ABS(CSPD_DIFF / CSPD_HR)
 
ENDRUN


; Script for program NETWORK in file "D:\8296\TestAssignment\CUBE\PPNET00B.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK
FILEO LINKO = "%SCENARIO_DIR%\HWY_LDNET_%ITER%_%PER%_COMP.DBF"
FILEI LINKI[1] = "%SCENARIO_DIR%\HWY_LDNET_%ITER%_%PER%_COMP.NET"


ENDRUN


; Script for program MATRIX in file "D:\8296\TestAssignment\CUBE\PPMAT00A.S"
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


; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.


ENDLOOP


; End of PILOT Script

