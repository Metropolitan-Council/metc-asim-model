; Script for program MATRIX in file "C:\Users\ehrlicjn\Desktop\MetCouncilABMPreRelease0.1\CUBE\FTMAT00A.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Create weighted skim times'
FILEO MATO[1] = "%SCENARIO_DIR%\TRK_SKIM_%ITER%.tmp",
 MO=1-2, DEC=D*2, NAME=SNGLTIME, MULTTIME
FILEI LOOKUPI[1] = "%qfrm%"
FILEI MATI[4] = "%SCENARIO_DIR%\HWY_SKIM_%PREV_ITER%_NT.SKM"
FILEI MATI[3] = "%SCENARIO_DIR%\HWY_SKIM_%PREV_ITER%_PM.SKM"
FILEI MATI[2] = "%SCENARIO_DIR%\HWY_SKIM_%PREV_ITER%_MD.SKM"
FILEI MATI[1] = "%SCENARIO_DIR%\HWY_SKIM_%PREV_ITER%_AM.SKM"

  LOOKUP LOOKUPI=1, NAME=TOD,  ;TOD Skim Shares
  LOOKUP[1]=1, RESULT=2, ; AM
  LOOKUP[2]=1, RESULT=3, ; MD
  LOOKUP[3]=1, RESULT=4, ; PM
  LOOKUP[4]=1, RESULT=5  ; NT

  ; Single Unit weighted travel time
  MW[1] = MI.1.DANTIME * TOD(1,3) +  ; AM
          MI.1.DANTIME * TOD(1,3) +  ; MD
          MI.3.DANTIME * TOD(3,3)  + ; PM
          MI.4.DANTIME * TOD(4,3)    ; NT 
          
 ; Multi Unit weighted travel time
  MW[2]=  MI.1.DANTIME * TOD(1,4)  + ; AM
          MI.2.DANTIME * TOD(2,4)  + ; MD
          MI.3.DANTIME * TOD(3,4)  + ; PM
          MI.4.DANTIME * TOD(4,4)    ; NT
        
 ; prevent EI trips from becoming EEs
 JLOOP
  IF (I>%int_zones% & J>%int_zones%)
    MW[1] = 1000
    MW[2] = 1000
    MW[3] = 1000
    MW[4] = 1000
  ENDIF
 ENDJLOOP
 
ENDRUN


; Script for program TRIPDIST in file "C:\Users\ehrlicjn\Desktop\MetCouncilABMPreRelease0.1\CUBE\FTTRD00A.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=TRIPDIST MSG='Truck gravity model'
FILEO MATO[1] = "%SCENARIO_DIR%\TRK_TRIP_%ITER%.tmp",
 MO=1-3, DEC=D,D,D, NAME=SINGLEUNIT, COMBINATION, HV
FILEI LOOKUPI[1] = "%qrfm_ff%"
FILEI MATI[1] = "%SCENARIO_DIR%\TRK_SKIM_%ITER%.tmp"
FILEI ZDATI[1] = "%SCENARIO_DIR%\TRK_PA.txt",
 Z=#1, P1=#2, A1=#3, P2=#4, A2=#5 ;PA DATA

 MAXITERS=10
 MAXRMSE=10

 LOOKUP LOOKUPI=1, FAIL=120,0,0, LIST=N, 
 NAME=FF,  ;FRICTION FACTOR LOOKUP TABLE
 LOOKUP[1]=1, RESULT=2,
 LOOKUP[2]=1, RESULT=3,
 INTERPOLATE=Y, SETUPPER=N

 SETPA P[1]= P1, P[2] = P2
 SETPA A[1]= A1, A[2] = A2
          
 ;*****
 ;Define Friction Factors for Single Unit and Combination Trucks;
 ;Note: Use these as KFACTOR matrices, because FFACTORS cannot be in matrix form;
 ;*****
 MW[10]= MI.1.1
 MW[11]= MI.1.2

 GRAVITY PURPOSE=1, LOS=MW[10], FFACTORS=FF,  LOSRANGE=0-999   ;SINGLE UNIT GRAVITY MODEL
 FREQUENCY VALUEMW=1, BASEMW=10, RANGE=1-100, TITLE='SINGLE UNIT TRIPS'
  
 GRAVITY PURPOSE=2, LOS=MW[11], FFACTORS=FF,  LOSRANGE=0-999   ;COMBINATION GRAVITY MODEL
 FREQUENCY VALUEMW=1, BASEMW=11, RANGE=1-100, TITLE='COMBINATION TRIPS'

 MW[3] = MW[1]+ MW[2] ; TOTAL TRUCK TRIPS
ENDRUN


; Script for program MATRIX in file "C:\Users\ehrlicjn\Desktop\MetCouncilABMPreRelease0.1\CUBE\FTMAT00B.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Time period splits'
FILEI MATI[2] = "%SCENARIO_DIR%\EE_FRATAR_TRK.MAT"
FILEO PRINTO[1] = "%SCENARIO_DIR%\TRK_TRIP_PRN_%ITER%.prn"
FILEI LOOKUPI[1] = "%qfrm%"
FILEO MATO[11] = "%SCENARIO_DIR%\TRK_TRIP_%ITER%_ON.trp",
 MO=111,112,113, NAME=Single, Combo, Total
FILEO MATO[10] = "%SCENARIO_DIR%\TRK_TRIP_%ITER%_EV.trp",
 MO=101,102,103, NAME=Single, Combo, Total
FILEO MATO[9] = "%SCENARIO_DIR%\TRK_TRIP_%ITER%_PM4.trp",
 MO=91,92,93, NAME=Single, Combo, Total
FILEO MATO[8] = "%SCENARIO_DIR%\TRK_TRIP_%ITER%_PM3.trp",
 MO=81,82,83, NAME=Single, Combo, Total
FILEO MATO[7] = "%SCENARIO_DIR%\TRK_TRIP_%ITER%_PM2.trp",
 MO=71,72,73, NAME=Single, Combo, Total
FILEO MATO[6] = "%SCENARIO_DIR%\TRK_TRIP_%ITER%_PM1.trp",
 MO=61,62,63, NAME=Single, Combo, Total
FILEO MATO[5] = "%SCENARIO_DIR%\TRK_TRIP_%ITER%_MD.trp",
 MO=51,52,53, NAME=Single, Combo, Total
FILEO MATO[4] = "%SCENARIO_DIR%\TRK_TRIP_%ITER%_AM4.trp",
 MO=41,42,43, NAME=Single, Combo, Total
FILEO MATO[3] = "%SCENARIO_DIR%\TRK_TRIP_%ITER%_AM3.trp",
 MO=31,32,33, NAME=Single, Combo, Total
FILEO MATO[2] = "%SCENARIO_DIR%\TRK_TRIP_%ITER%_AM2.trp",
 MO=21,22,23, NAME=Single, Combo, Total
FILEO MATO[1] = "%SCENARIO_DIR%\TRK_TRIP_%ITER%_AM1.trp",
 MO=11,12,13, NAME=Single, Combo, Total
FILEI MATI[1] = "%SCENARIO_DIR%\TRK_TRIP_%ITER%.tmp"

  
  LOOKUP LOOKUPI=1, NAME=TODL,
  LOOKUP[1]=1, RESULT=2, ; AM1
  LOOKUP[2]=1, RESULT=3, ; AM2
  LOOKUP[3]=1, RESULT=4, ; AM3
  LOOKUP[4]=1, RESULT=5, ; AM4
  LOOKUP[5]=1, RESULT=6, ; MD
  LOOKUP[6]=1, RESULT=7, ; PM1
  LOOKUP[7]=1, RESULT=8, ; PM2
  LOOKUP[8]=1, RESULT=9, ; PM3
  LOOKUP[9]=1, RESULT=10, ; PM4
  LOOKUP[10]=1, RESULT=11,  ; EV
  LOOKUP[11]=1, RESULT=12  ; NT
  
  ; Distribute by TOD
  
  ; AM1
	MW[11] = (MI.1.SINGLEUNIT + MI.2.1) * TODL(1,7)
	MW[12] = (MI.1.COMBINATION + MI.2.2)* TODL(1,8)
	MW[13] = MW[11] + MW[12]
	
  ;AM2
	MW[21] = (MI.1.SINGLEUNIT + MI.2.1) * TODL(2,7)
	MW[22] = (MI.1.COMBINATION + MI.2.2) * TODL(2,8)
	MW[23] = MW[21] + MW[22]
	
  ; AM3
	MW[31] = (MI.1.SINGLEUNIT + MI.2.1) * TODL(3,7)
	MW[32] = (MI.1.COMBINATION + MI.2.2) * TODL(3,8)
	MW[33] = MW[31] + MW[32]
	
  ; AM4
	MW[41] = (MI.1.SINGLEUNIT + MI.2.1) * TODL(4,7)
	MW[42] = (MI.1.COMBINATION + MI.2.2) * TODL(4,8)
	MW[43] = MW[41] + MW[42]
	
  ;MD
	MW[51] = (MI.1.SINGLEUNIT + MI.2.1) * TODL(5,7)
	MW[52] = (MI.1.COMBINATION + MI.2.2) * TODL(5,8)
	MW[53] = MW[51] + MW[52]
	
  ;PM1
	MW[61] = (MI.1.SINGLEUNIT + MI.2.1) * TODL(6,7)
	MW[62] = (MI.1.COMBINATION + MI.2.2) * TODL(6,8)
	MW[63] = MW[61] + MW[62]
	
  ;PM2
	MW[71] = (MI.1.SINGLEUNIT + MI.2.1) * TODL(7,7)
	MW[72] = (MI.1.COMBINATION + MI.2.2) * TODL(7,8)
	MW[73] = MW[71] + MW[72]
	
  ;PM3
	MW[81] = (MI.1.SINGLEUNIT + MI.2.1) * TODL(8,7)
	MW[82] = (MI.1.COMBINATION + MI.2.2) * TODL(8,8)
	MW[83] = MW[81] + MW[82]
	
  ;PM4
	MW[91] = (MI.1.SINGLEUNIT + MI.2.1) * TODL(9,7)
	MW[92] = (MI.1.COMBINATION + MI.2.2) * TODL(9,8)
	MW[93] = MW[91] + MW[92]
	
  ;EV
	MW[101] = (MI.1.SINGLEUNIT + MI.2.1) * TODL(10,7)
	MW[102] = (MI.1.COMBINATION + MI.2.2) * TODL(10,8)
	MW[103] = MW[101] + MW[102]
	
  ;NT
	MW[111] = (MI.1.SINGLEUNIT + MI.2.1) * TODL(11,7)
	MW[112] = (MI.1.COMBINATION + MI.2.2) * TODL(11,8)
	MW[113] = MW[111] + MW[112]

  JLOOP
    AM_SU = AM_SU + MW[11] + MW[21] + MW[31] + MW[41]
    AM_MU = AM_MU + MW[12] + MW[22] + MW[32] + MW[42]
 
    MD_SU = MD_SU + MW[51]
    MD_MU = MD_MU + MW[52]
    
    PM_SU = PM_SU + MW[61] + MW[71] + MW[81] + MW[91]
    PM_MU = PM_MU + MW[62] + MW[72] + MW[82] + MW[92]
    
    OP_SU = OP_SU + MW[101] + MW[111]
    OP_MU = OP_MU + MW[102] + MW[112]
  
  
  ENDJLOOP
    IF (I = %zones%)
      PRINT CSV=T, LIST='Truck,  AM,  MD,  PM,  OP',PRINTO=1
      PRINT CSV=T, LIST='Single,'   AM_SU, MD_SU, PM_SU, OP_SU, PRINTO=1
      PRINT CSV=T, LIST='Combo,'  AM_MU, MD_MU, PM_MU, OP_MU, PRINTO=1
      
    ENDIF


ENDRUN


; Script for program MATRIX in file "C:\Users\ehrlicjn\Desktop\MetCouncilABMPreRelease0.1\CUBE\EEMAT00A.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Auto EI / IE Destination Choice'
FILEI DBI[2] = "%SCENARIO_DIR%\HWY_EXT.dbf"
FILEI MATI[1] = "%SCENARIO_DIR%\HWY_SKIM_%PREV_ITER%_AM.skm"
FILEO MATO[2] = "%SCENARIO_DIR%\HWY_EXT_IETRIP_%ITER%.trp",
 MO=11-18, NAME=termTime,time,sizeVar, expU, prob, IE_DA, IE_S2, IE_S3
 
FILEO MATO[1] = "%SCENARIO_DIR%\HWY_EXT_EITRIP_%ITER%.trp",
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
      destTermT[k]=DI.1.CBD * 1.32
      destSizeV[k]= MAX(ln(DI.1.AREA + DI.1.TOT_EMP * 52.45),0)
      
      ; Internal to External (IE) - Origin Choice
      origTermT[k]=DI.1.CBD * -0.107 + DI.1.SUBURB2 * 0.489 + DI.1.RURAL * 1.65
      origSizeV[k]= MAX(ln(DI.1.AREA + DI.1.POPULATION * 23.81 + DI.1.TOT_EMP * 18.73),0)      
      
    ENDLOOP
  ENDIF
  
  ; Calculate utility function and probabilities for Extenal-Internal interchanges
  IF (I > %int_zones%)  
  
    ; prepare utility function
    JLOOP J=1,%int_zones%
      ; EI
      mw[1] = destTermT[J] 
      mw[2] = MI.1.1 * -0.116 + 0.00059 * MI.1.1 ^ 2 + -0.00000036 * MI.1.1 ^ 3 
      mw[3] = destSizeV[J]
      mw[4] = exp(mw[1] + mw[2]) * mw[3]

      ; IE
      mw[11] = origTermT[J] 
      mw[12] = MI.1.1 * -0.194 + 0.0020 * MI.1.1 ^ 2 + -0.0000073 * MI.1.1 ^ 3 
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


; Script for program MATRIX in file "C:\Users\ehrlicjn\Desktop\MetCouncilABMPreRelease0.1\CUBE\EEMAT00B.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Combine EI / IE trips with transpose and EE'
FILEI MATI[3] = "%SCENARIO_DIR%\HWY_EXT_EETRIP.TRP"
FILEO MATO[1] = "%SCENARIO_DIR%\HWY_EXT_TRIP_%ITER%.trp",
 MO=1-3, NAME=DA, SR2, SR3
FILEI MATI[2] = "%SCENARIO_DIR%\HWY_EXT_IETRIP_%ITER%.trp"
FILEI MATI[1] = "%SCENARIO_DIR%\HWY_EXT_EITRIP_%ITER%.trp"

  MW[1] = MI.1.6 + MI.1.6.T + MI.2.6 + MI.2.6.T + MI.3.1 ; exclude EE trips from MnPass
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
 IF(TOD=11) PER='ON'  
; End of PILOT Script

; Script for program MATRIX in file "C:\Users\ehrlicjn\Desktop\MetCouncilABMPreRelease0.1\CUBE\EEMAT00D.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Sum trips from each time period'
FILEI MATI[1] = "%SCENARIO_DIR%\HWY_TRIP_%ITER%_%PER%.trp"

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
    LIST= %TOD%, ' %PER%', _total FILE = "%SCENARIO_DIR%\HWY_TRIP_PRN_%ITER%.CSV",
 APPEND=T, CSV=T
  ENDIF
 

ENDRUN


; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.


ENDLOOP
; End of PILOT Script

; Script for program MATRIX in file "C:\Users\ehrlicjn\Desktop\MetCouncilABMPreRelease0.1\CUBE\EEMAT00E.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Split trips by TOD'
FILEO PRINTO[1] = "%SCENARIO_DIR%\HWY_EXT_TRIP_PRN_%ITER%.prn"
FILEO MATO[11] = "%SCENARIO_DIR%\HWY_EXT_TRIP_%ITER%_ON.trp",
 MO=111-113, NAME=DA, SR2, SR3
FILEO MATO[10] = "%SCENARIO_DIR%\HWY_EXT_TRIP_%ITER%_EV.trp",
 MO=101-103, NAME=DA, SR2, SR3
FILEO MATO[9] = "%SCENARIO_DIR%\HWY_EXT_TRIP_%ITER%_PM4.trp",
 MO=91-93, NAME=DA, SR2, SR3
FILEO MATO[8] = "%SCENARIO_DIR%\HWY_EXT_TRIP_%ITER%_PM3.trp",
 MO=81-83, NAME=DA, SR2, SR3
FILEO MATO[7] = "%SCENARIO_DIR%\HWY_EXT_TRIP_%ITER%_PM2.trp",
 MO=71-73, NAME=DA, SR2, SR3
FILEO MATO[6] = "%SCENARIO_DIR%\HWY_EXT_TRIP_%ITER%_PM1.trp",
 MO=61-63, NAME=DA, SR2, SR3
FILEO MATO[5] = "%SCENARIO_DIR%\HWY_EXT_TRIP_%ITER%_MD.trp",
 MO=51-53, NAME=DA, SR2, SR3
FILEO MATO[4] = "%SCENARIO_DIR%\HWY_EXT_TRIP_%ITER%_AM4.trp",
 MO=41-43, NAME=DA, SR2, SR3
FILEO MATO[3] = "%SCENARIO_DIR%\HWY_EXT_TRIP_%ITER%_AM3.trp",
 MO=31-33, NAME=DA, SR2, SR3
FILEO MATO[2] = "%SCENARIO_DIR%\HWY_EXT_TRIP_%ITER%_AM2.trp",
 MO=21-23, NAME=DA, SR2, SR3
FILEI DBI[1] = "%SCENARIO_DIR%\HWY_TRIP_PRN_%ITER%.csv",
DELIMITER[1]=",",
 FIELDS=3
FILEO MATO[1] = "%SCENARIO_DIR%\HWY_EXT_TRIP_%ITER%_AM1.trp",
 MO=11-13, NAME=DA, SR2, SR3
FILEI MATI[1] = "%SCENARIO_DIR%\HWY_EXT_TRIP_%ITER%.trp"

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
    
    ; Sum up external trips to check
    _totalExt = 0
    _am1Ext = 0 _am2Ext = 0 _am3Ext = 0 _am4Ext = 0 
    _mdExt = 0
    _pm1Ext = 0 _pm2Ext = 0 _pm3Ext = 0 _pm4Ext = 0 
    _evExt = 0 _ntExt = 0
        
  ENDIF
  
  ;
  ; Apply share to create TOD trip tables.
  ;
	MW[11] = MI.1.1 * share[1]	MW[12] = MI.1.2 * share[1]	MW[13] = MI.1.3 * share[1]
	MW[21] = MI.1.1 * share[2]	MW[22] = MI.1.2 * share[2]	MW[23] = MI.1.3 * share[2]
	MW[31] = MI.1.1 * share[3]	MW[32] = MI.1.2 * share[3]	MW[33] = MI.1.3 * share[3]
	MW[41] = MI.1.1 * share[4]	MW[42] = MI.1.2 * share[4]	MW[43] = MI.1.3 * share[4]
	MW[51] = MI.1.1 * share[5]	MW[52] = MI.1.2 * share[5]	MW[53] = MI.1.3 * share[5]
	MW[61] = MI.1.1 * share[6]	MW[62] = MI.1.2 * share[6]	MW[63] = MI.1.3 * share[6]  
	MW[71] = MI.1.1 * share[7]	MW[72] = MI.1.2 * share[7]	MW[73] = MI.1.3 * share[7]
	MW[81] = MI.1.1 * share[8]	MW[82] = MI.1.2 * share[8]	MW[83] = MI.1.3 * share[8]
	MW[91] = MI.1.1 * share[9]	MW[92] = MI.1.2 * share[9]	MW[93] = MI.1.3 * share[9]
	MW[101] = MI.1.1 * share[10]	MW[102] = MI.1.2 * share[10]	MW[103] = MI.1.3 * share[10]
	MW[111] = MI.1.1 * share[11]	MW[112] = MI.1.2 * share[11]	MW[113] = MI.1.3 * share[11]
  
  _am1Ext = ROWSUM(11) + ROWSUM(12) + ROWSUM(13)
  _am1Ext = ROWSUM(21) + ROWSUM(22) + ROWSUM(23)
  _am1Ext = ROWSUM(31) + ROWSUM(32) + ROWSUM(33)
  _am1Ext = ROWSUM(41) + ROWSUM(42) + ROWSUM(43)
  _am1Ext = ROWSUM(51) + ROWSUM(52) + ROWSUM(53)
  _am1Ext = ROWSUM(61) + ROWSUM(62) + ROWSUM(63)
  _am1Ext = ROWSUM(71) + ROWSUM(72) + ROWSUM(73)
  _am1Ext = ROWSUM(81) + ROWSUM(82) + ROWSUM(83)
  _am1Ext = ROWSUM(91) + ROWSUM(92) + ROWSUM(93)
  _am1Ext = ROWSUM(101) + ROWSUM(102) + ROWSUM(103)
  _am1Ext = ROWSUM(111) + ROWSUM(112) + ROWSUM(113)
  _am1Ext = ROWSUM(121) + ROWSUM(122) + ROWSUM(123)
  
  _totalExt = _am1Ext + _am2Ext + _am3Ext + _am4Ext + 
              _mdExt + _pm1Ext + _pm2Ext + _pm3Ext + _pm4Ext + _evExt + _ntExt
    
    IF (I = %zones%)
      PRINT CSV=T, LIST='Total, AM1, AM2, AM3, AM4, MD, PM1, PM2, PM3, PM4, EV, ON',PRINTO=1
      PRINT CSV=T, LIST=_totalExt,_am1Ext,_am2Ext,_am3Ext,_am4Ext,
              _mdExt,_pm1Ext,_pm2Ext,_pm3Ext,_pm4Ext,_evExt,_ntExt, PRINTO=1
      
    ENDIF
    
ENDRUN


; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.

;ITER = 1
;PREV_ITER = 0

READ FILE = "%SPC_MODECHOICE%"

LOOP TOD=1,11,1
 IF(TOD=1) PER='AM1' HPER='AM' TPER = 'PK'
 IF(TOD=2) PER='AM2' HPER='AM' TPER = 'PK' 
 IF(TOD=3) PER='AM3' HPER='AM' TPER = 'PK' 
 IF(TOD=4) PER='AM4' HPER='AM' TPER = 'PK'   
 IF(TOD=5) PER='MD'  HPER='MD' TPER = 'OP'
 IF(TOD=6) PER='PM1' HPER='PM' TPER = 'PK'  
 IF(TOD=7) PER='PM2' HPER='PM' TPER = 'PK' 
 IF(TOD=8) PER='PM3' HPER='PM' TPER = 'PK' 
 IF(TOD=9) PER='PM4' HPER='PM' TPER = 'PK'
 IF(TOD=10) PER='EV' HPER='NT' TPER = 'OP' 
 IF(TOD=11) PER='ON' HPER='NT' TPER = 'OP' 
; End of PILOT Script

; Script for program MATRIX in file "C:\Users\ehrlicjn\Desktop\MetCouncilABMPreRelease0.1\CUBE\SGMAT00A.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Airport Mode Choice'
FILEO MATO[1] = "%SCENARIO_DIR%\HWY_SPC_TRIP_%ITER%_%PER%.tmp",
 MO=134-138, DEC=3,3,3,3,3, NAME= DA,SR2,SR3,XIT_WK, XIT_DR
FILEI MATI[4] = "%SCENARIO_DIR%\HWY_SPC_TRIP.trp"
FILEI MATI[3] = "%SCENARIO_DIR%\HWY_SKIM_%PREV_ITER%_%HPER%.skm"
FILEI MATI[2] = "%SCENARIO_DIR%\XIT_DR_SKIM_%PREV_ITER%_%TPER%.skm"
FILEI MATI[1] = "%SCENARIO_DIR%\XIT_WK_SKIM_%PREV_ITER%_%TPER%.SKM"


 MW[3]=MI.3.1     ; AUTO IVTT
  MW[4]=MI.3.5     ; AUTO DISTANCE
  MW[5]=MI.3.2	   ; AUTO TOLL
  
  MW[203]=MI.3.6     ; SR2 IVTT
  MW[204]=MI.3.10    ; SR2 DISTANCE
  MW[205]=MI.3.7	 ; SR2 TOLL
  
  MW[303]=MI.3.11    ; SR3 IVTT
  MW[304]=MI.3.15    ; SR3 DISTANCE
  MW[305]=MI.3.12	 ; SR3 TOLL
  
  
  MW[6]= MI.1.2+MI.1.3+MI.1.4+MI.1.5+MI.1.6    ; WALK ACCESS OVTT
  MW[9]= MI.1.1                                ; IVTT, WALK ACCESS
  MW[10]= MI.1.8                               ; WALK ACCESS FARE

  MW[26]= MI.2.2+MI.2.3+MI.2.4+MI.2.5+MI.2.6    ; AUTO ACCESS OVTT
  MW[29]= MI.2.1                                ; IVTT, DRIVE ACCESS
  MW[30]= MI.2.8                                ; DRIVE ACCESS FARE

JLOOP INCLUDE=1521
  MW[41]= %TTIME_AUTO%*%HWTCOEFF% + MW[3]*%HWTCOEFF%   + MW[4]*%AUTOCOST%*%DA_COST%          + MW[5]*%DA_COST%    + 20*%DA_COST%      +%C_DA%    ; DA UTILITY
  MW[51]= %TTIME_SR%*%HWTCOEFF%   + MW[203]*%HWTCOEFF% + MW[204]*%AUTOCOST%*0.5*%SR2_COST%   + MW[205]*%SR2_COST% + 20*0.5*%SR2_COST% +%C_SR2%   ; SR2 UTILITY
  MW[61]= %TTIME_SR%*%HWTCOEFF%   + MW[303]*%HWTCOEFF% + MW[304]*%AUTOCOST%*0.285*%SR3_COST% + MW[305]*%SR3_COST% + 20*%SR3_COST%/3.5 +%C_SR3%   ; SR3 UTILITY
ENDJLOOP

JLOOP INCLUDE=1521
    ; WalkTransit
    IF(MW[9][J]>0)
      MW[71]=2.5*MW[6]*%TCOEFF_WA%+MW[9]*%TCOEFF_WA%+MW[10]*%FARECOST%/100+%C_TR%   ; WALK ACCESS UTILITY
    ELSE
      MW[71]=-9999
    ENDIF
    ; DriveTransit
    ;IF (MW[29][J]>0)
     ; MW[91]=2.5*MW[26]*%TCOEFF_DA%+MW[29]*%TCOEFF_DA%+MW[30]*%FARECOST%/100+%C_TR%   ; DRIVE ACCESS UTILITY
    ;ELSE
      MW[91]=-9999
    ;ENDIF
ENDJLOOP

JLOOP INCLUDE=1521
    IF(MW[9][J]=0) MW[71]=-9999
ENDJLOOP

; DO EXPONENTIAL OF UTILITIES

MW[101] = EXP(MW[41])*100000   ; DA

MW[111] = EXP(MW[51])*100000   ; SR2

MW[121] = EXP(MW[61])*100000   ; SR3

MW[131] = EXP(MW[71])*100000   ; WALK ACCESSS

MW[151] = EXP(MW[91])*100000   ; DRIVE ACCESS

; SHARES
MW[171] = 100*MW[101]/(MW[101]+MW[111]+MW[121]+MW[131]+MW[151])           ; DA SHARE 
MW[172] = 100*MW[111]/(MW[101]+MW[111]+MW[121]+MW[131]+MW[151])           ; SR2 SHARE 
MW[173] = 100*MW[121]/(MW[101]+MW[111]+MW[121]+MW[131]+MW[151])           ; SR3 SHARE 
MW[174] = 100*MW[131]/(MW[101]+MW[111]+MW[121]+MW[131]+MW[151])           ; Walk Access Transit Share
;MW[175] = 100*MW[151]/(MW[101]+MW[111]+MW[121]+MW[131]+MW[151])             ; Drive Access Transit Share

MW[197]=MI.4.%TOD% 

MW[134] = MW[171]*MW[197]/100                ;DA TRIPS 
MW[135] = MW[172]*MW[197]/100                ;SR2 TRIPS 
MW[136] = MW[173]*MW[197]/100                ;SR3+ 
MW[137] = MW[174]*MW[197]/100                ;WALK ACCESS TRANSIT TRIPS
;MW[138] = MW[175]*MW[197]/100               ;DRIVE ACCESS TRANSIT TRIPS


ENDRUN


; Script for program MATRIX in file "C:\Users\ehrlicjn\Desktop\MetCouncilABMPreRelease0.1\CUBE\SGMAT00B.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Add return trips'
FILEO MATO[1] = "%SCENARIO_DIR%\HWY_SPC_TRIP_%ITER%_%PER%.trp",
 MO=1-5, DEC=3,3,3,3,3, NAME= DA,SR2,SR3,XIT_WK, XIT_DR
FILEI MATI[1] = "%SCENARIO_DIR%\HWY_SPC_TRIP_%ITER%_%PER%.tmp"
 
 MW[1] = MI.1.1 + MI.1.1.T
 MW[2] = MI.1.2 + MI.1.2.T + (MI.1.2 + MI.1.2.T)*0.9391
 MW[3] = MI.1.3 + MI.1.3.T + (MI.1.3 + MI.1.3.T)*0.6308
 MW[4] = MI.1.4 + MI.1.4  ; NOTE: Transit is assigned in PA format
 MW[5] = MI.1.5 + MI.1.5  ; NOTE: Transit is assigned in PA format


ENDRUN


; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.

ENDLOOP
; End of PILOT Script

