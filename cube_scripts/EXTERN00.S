; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.


ITER = 1
PREV_ITER = 0
; End of PILOT Script

; Script for program MATRIX in file "D:\TourCast\CATALOG\CUBE\EEMAT00A.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Auto EI / IE Destination Choice'
FILEI DBI[2] = "%SCENARIO_DIR%\AUTO_EXT.dbf"
FILEI MATI[1] = "%SCENARIO_DIR%\%PREV_ITER%_AM_HWY.skm"
FILEO MATO[2] = "%SCENARIO_DIR%\%ITER%_IE.tmp",
 MO=11-18, NAME=termTime,time,sizeVar, expU, prob, IE_DA, IE_S2, IE_S3
 
FILEO MATO[1] = "%SCENARIO_DIR%\%ITER%_EI.tmp",
 MO=1-8, NAME=termTime,time,sizeVar, expU, prob, EI_DA,	EI_S2,	EI_S3

FILEI DBI[1] = "%zone_attribs%"

 zones = %zones%
 
  ARRAY destTermT=%int_zones%, destSizeV=%int_zones%, destTrips=(%ext_zones%)
  ARRAY origTermT=%int_zones%, origSizeV=%int_zones%, origTrips=(%ext_zones%)
  
  
  ; read in vectors of zonal data  
  IF (I=1)
    LOOP k=1,%int_zones%
    
      x=DBIReadRecord(1,k)
      
      ; External to Internal (EI) - Destination Choice
      destTermT[k]=DI.1.CBD * 5 + DI.1.SUBURB3 * 3 + DI.1.RURAL * 1
      destSizeV[k]= MAX(ln(DI.1.AREA + DI.1.TOT_EMP * 112.2),0)
      
      ; Internal to External (IE) - Origin Choice
      origTermT[k]=DI.1.CBD * 5 + DI.1.SUBURB3 * 3 + DI.1.RURAL * 1
      origSizeV[k]= MAX(ln(DI.1.AREA + DI.1.TOT_EMP * 112.2 + DI.1.TOT_EMP * 112.2),0)      
      
    ENDLOOP
  ENDIF
  
  ; Calculate utility function and probabilities for Extenal-Internal interchanges
  IF (I > %int_zones%)  
  
    ; prepare utility function
    JLOOP J=1,%int_zones%
      ; EI
      mw[1] = destTermT[J] 
      mw[2] = MI.1.1 * -0.0985 + 0.00051 * MI.1.1 ^ 2 + -0.00000048 * MI.1.1 ^ 3 
      mw[3] = destSizeV[J]
      mw[4] = exp(mw[1] + mw[2]) * mw[3]

      ; IE
      mw[11] = origTermT[J] 
      mw[12] = MI.1.1 * -0.0985 + 0.00051 * MI.1.1 ^ 2 + -0.00000048 * MI.1.1 ^ 3 
      mw[13] = origSizeV[J]
      mw[14] = exp(mw[11] + mw[12]) * mw[13]  
      
    ENDJLOOP  
    
    destRowsum = ROWSUM(4)
    origRowsum = ROWSUM(14)
    
    ; calculate probabilities and apply to EI / IE trips
     JLOOP J=1,%int_zones%
      mw[5] = (mw[4] * 100) / destRowsum   
      mw[15] = (mw[14] * 100) / origRowsum 
      
      ; Read in external trips
      x=DBIReadRecord(2,I - %int_zones%)
      
      mw[6] = mw[5] * DI.2.EI_DA / 2 / 100 
      mw[7] = mw[5] * DI.2.EI_S2 / 2 / 100 
      mw[8] = mw[5] * DI.2.EI_S3 / 2 / 100 
      
      mw[16] = mw[15] * DI.2.IE_DA / 2 / 100 
      mw[17] = mw[15] * DI.2.IE_S2 / 2 / 100 
      mw[18] = mw[15] * DI.2.IE_S3 / 2 / 100       

    ENDJLOOP     
    
    
    
    
  ENDIF 



ENDRUN


; Script for program MATRIX in file "D:\TourCast\CATALOG\CUBE\EEMAT00B.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Combine EI / IE trips with transpose and EE'
FILEO MATO[1] = "%SCENARIO_DIR%\%ITER%_EI_IE.tmp",
 MO=1-3, NAME=DA, SR2, SR3
FILEI MATI[2] = "%SCENARIO_DIR%\%ITER%_IE.tmp"
FILEI MATI[1] = "%SCENARIO_DIR%\%ITER%_EI.tmp"

  MW[1] = MI.1.6 + MI.1.6.T + MI.2.6 + MI.2.6.T
  MW[2] = MI.1.7 + MI.1.7.T + MI.2.7 + MI.2.7.T
  MW[3] = MI.1.8 + MI.1.8.T + MI.2.8 + MI.2.8.T  

ENDRUN


; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.



LOOP TOD=1,11,1
 IF(TOD=1) PER='AM1'
 IF(TOD=2) PER='AM2'
 IF(TOD=3) PER='AM3'
 IF(TOD=4) PER='AM4'  
 IF(TOD=5) PER='MD' 
 IF(TOD=6) PER='PM1'
 IF(TOD=7) PER='PM2'
 IF(TOD=8) PER='PM3'
 IF(TOD=9) PER='PM4'
 IF(TOD=10) PER='EV' 
 IF(TOD=11) PER='NT'  ; End of PILOT Script

; Script for program MATRIX in file "D:\TourCast\CATALOG\CUBE\EEMAT00D.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Sum trips from each time period'
FILEI MATI[1] = "%SCENARIO_DIR%\%ITER%_%PER%_HWY.trp"

  ;_total = 0

	MW[1] = MI.1.1
	MW[2] = MI.1.2
	MW[3] = MI.1.3
	MW[4] = MI.1.4
	MW[5] = MI.1.5
	MW[6] = MI.1.6
	MW[7] = MI.1.7
	MW[8] = MI.1.8
	MW[9] = MI.1.9
	MW[10] = MI.1.10
	MW[11] = MI.1.11
	MW[12] = MI.1.12
	MW[13] = MI.1.13
	MW[14] = MI.1.14
	MW[15] = MI.1.15
	MW[16] = MI.1.16
	MW[17] = MI.1.17
	MW[18] = MI.1.18
	MW[19] = MI.1.19
	MW[20] = MI.1.20
	MW[21] = MI.1.21
	MW[22] = MI.1.22
	MW[23] = MI.1.23
	MW[24] = MI.1.24
	MW[25] = MI.1.25
	MW[26] = MI.1.26
	MW[27] = MI.1.27
	MW[28] = MI.1.28
	MW[29] = MI.1.29
	MW[30] = MI.1.30
	MW[31] = MI.1.31
	MW[32] = MI.1.32

  
  _total = _total + 
		ROWSUM(1) + 
		ROWSUM(2) + 
		ROWSUM(3) + 
		ROWSUM(4) + 
		ROWSUM(5) + 
		ROWSUM(6) + 
		ROWSUM(7) + 
		ROWSUM(8) + 
		ROWSUM(9) + 
		ROWSUM(10) + 
		ROWSUM(11) + 
		ROWSUM(12) + 
		ROWSUM(13) + 
		ROWSUM(14) + 
		ROWSUM(15) + 
		ROWSUM(16) + 
		ROWSUM(17) + 
		ROWSUM(18) + 
		ROWSUM(19) + 
		ROWSUM(20) + 
		ROWSUM(21) + 
		ROWSUM(22) + 
		ROWSUM(23) + 
		ROWSUM(24) + 
		ROWSUM(25) + 
		ROWSUM(26) + 
		ROWSUM(27) + 
		ROWSUM(28) + 
		ROWSUM(29) + 
		ROWSUM(30) + 
		ROWSUM(31) + 
		ROWSUM(32) 
  
  IF(I==%int_zones%)
    LIST= %TOD%, ' %PER%', _total FILE = "%SCENARIO_DIR%\%ITER%_HWY_TRIPTOTALS.CSV",
 APPEND=T, CSV=T
  ENDIF
 

ENDRUN


; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.


ENDLOOP
; End of PILOT Script

; Script for program MATRIX in file "D:\TourCast\CATALOG\CUBE\EEMAT00E.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Split trips by TOD'
FILEO MATO[11] = "%SCENARIO_DIR%\%ITER%_NT_AUTO_EXT.trp",
 MO=111-113, NAME=DA, SR2, SR3
FILEO MATO[10] = "%SCENARIO_DIR%\%ITER%_EV_AUTO_EXT.trp",
 MO=101-103, NAME=DA, SR2, SR3
FILEO MATO[9] = "%SCENARIO_DIR%\%ITER%_PM4_AUTO_EXT.trp",
 MO=91-93, NAME=DA, SR2, SR3
FILEO MATO[8] = "%SCENARIO_DIR%\%ITER%_PM3_AUTO_EXT.trp",
 MO=81-83, NAME=DA, SR2, SR3
FILEO MATO[7] = "%SCENARIO_DIR%\%ITER%_PM2_AUTO_EXT.trp",
 MO=71-73, NAME=DA, SR2, SR3
FILEO MATO[6] = "%SCENARIO_DIR%\%ITER%_PM1_AUTO_EXT.trp",
 MO=61-63, NAME=DA, SR2, SR3
FILEO MATO[5] = "%SCENARIO_DIR%\%ITER%_MD_AUTO_EXT.trp",
 MO=51-53, NAME=DA, SR2, SR3
FILEO MATO[4] = "%SCENARIO_DIR%\%ITER%_AM4_AUTO_EXT.trp",
 MO=41-43, NAME=DA, SR2, SR3
FILEO MATO[3] = "%SCENARIO_DIR%\%ITER%_AM3_AUTO_EXT.trp",
 MO=31-33, NAME=DA, SR2, SR3
FILEO MATO[2] = "%SCENARIO_DIR%\%ITER%_AM2_AUTO_EXT.trp",
 MO=21-23, NAME=DA, SR2, SR3
FILEI DBI[1] = "%SCENARIO_DIR%\%ITER%_HWY_TRIPTOTALS.csv",
DELIMITER[1]=",",
 FIELDS=3
FILEO MATO[1] = "%SCENARIO_DIR%\%ITER%_AM1_AUTO_EXT.trp",
 MO=11-13, NAME=DA, SR2, SR3
FILEI MATI[1] = "%SCENARIO_DIR%\%ITER%_EI_IE.tmp"

  ; 
  ; Caculate TOD share based on TourCast outputs
  ;
  ARRAY share = 11
  
  IF(I==1)
    _total = 0

    ; First calculate total trips
    LOOP k=1,11
        x=DBIReadRecord(1,k)
        _total = _total + DI.1.FIELD1
        ;PRINT LIST=DI.1.FIELD1, k, _total PRINTO=1
    ENDLOOP
    
     ; Next calculate share per time period
    LOOP k=1,11
        x=DBIReadRecord(1,k)
        share[k] =  DI.1.FIELD1 / _total
        ;PRINT LIST=DI.1.FIELD1, k, _total, share[k] PRINTO=1
    ENDLOOP   
        
  ENDIF
  
  ;
  ; Apply share to create TOD trip tables.
  ;
	MW[11] = MI.1.1 * share[1]	MW[12] = MI.1.2 * share[1]	MW[13] = MI.1.3 * share[1]
	MW[21] = MI.1.1 * share[2]	MW[22] = MI.1.2 * share[2]	MW[23] = MI.1.3 * share[2]
	MW[31] = MI.1.1 * share[3]	MW[32] = MI.1.2 * share[3]	MW[33] = MI.1.3 * share[3]
	MW[71] = MI.1.1 * share[7]	MW[72] = MI.1.2 * share[7]	MW[73] = MI.1.3 * share[7]
	MW[81] = MI.1.1 * share[8]	MW[82] = MI.1.2 * share[8]	MW[83] = MI.1.3 * share[8]
	MW[91] = MI.1.1 * share[9]	MW[92] = MI.1.2 * share[9]	MW[93] = MI.1.3 * share[9]
	MW[101] = MI.1.1 * share[10]	MW[102] = MI.1.2 * share[10]	MW[103] = MI.1.3 * share[10]
	MW[111] = MI.1.1 * share[11]	MW[112] = MI.1.2 * share[11]	MW[113] = MI.1.3 * share[11]

ENDRUN


