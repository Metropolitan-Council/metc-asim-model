; Script for program GENERATION in file "D:\TourCast\MetCouncil_ABM02092015\CUBE\TSGEN00A.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=GENERATION MSG='Quick Response Freight Manual routine'
FILEO PAO[2] = "%SCENARIO_DIR%\TRK_PA.txt",
 FORM=6.0, LIST=Z, P[1],A[1], P[2], A[2]
FILEO PAO[1] = "%SCENARIO_DIR%\TRK_PA.dbf",
 FORM=6.0, DBF=T, LIST=Z, P[1], A[1], P[2], A[2]
FILEO PRINTO[1] = "%SCENARIO_DIR%\TRK_GENERATION.PRN"
FILEI ZDATI[2] = "%ext_sta%"
FILEI ZDATI[1] = "%zone_attribs%"
FILEI LOOKUPI[1] = "%qfrm%"

LOOKUP LOOKUPI=1, NAME=TGRates,      ; Rate Lookup Table
LOOKUP[1]=1,  RESULT=2,   ; Households Coefficient
LOOKUP[2]=1,  RESULT=3,   ; AMC Coefficient
LOOKUP[3]=1,  RESULT=4,   ; Manu Coefficient
LOOKUP[4]=1,  RESULT=5,   ; Retail Coefficient
LOOKUP[5]=1,  RESULT=6    ; Retail Coefficient

process phase = iloop

PARAMETERS ZONES = %ZONES%

    P[1] = (TGRates(1,1)*HOUSEHOLDS) + (TGRates(2,1)* AMC_EMP) + (TGRates(3,1)* MAN_EMP) + (TGRates(4,1)* RET_EMP) + (TGRates(5,1)* OFF_EMP) + ZI.2.HCAADT*0.14 ; 
    P[2] = (TGRates(1,2)*HOUSEHOLDS) + (TGRates(2,2)* AMC_EMP) + (TGRates(3,2)* MAN_EMP) + (TGRates(4,2)* RET_EMP) + (TGRates(5,2)* OFF_EMP) + ZI.2.HCAADT*0.36 ; 

    A[1] = P[1]
    A[2] = P[2]

ENDPROCESS

process phase = adjust
A[1] = P[1]
A[2] = P[2]
    PRINT CSV=F, LIST=' ', PRINTO=1
    PRINT CSV=F, LIST='TRUCK GENERATION OUTPUTS', PRINTO=1
    PRINT CSV=F, LIST='SINGLE-UNIT TRUCK TRIPS  = ',A[1][0], PRINTO=1
    PRINT CSV=F, LIST='COMBINATION TRUCK TRIPS  = ',A[2][0], PRINTO=1
    PRINT CSV=F, LIST=' ', PRINTO=1
ENDPROCESS

ENDRUN


; Script for program MATRIX in file "D:\TourCast\MetCouncil_ABM02092015\CUBE\TSMAT00H.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='External Auto Allocation and Mode Choice'
FILEO PRINTO[2] = "%SCENARIO_DIR%\HWY_EXT_MARGINAL_TARGET.txt"
FILEO RECO[1] = "%SCENARIO_DIR%\HWY_EXT.dbf",
 FIELDS=ZONE,AUTOS,EE,EI_DA,EI_S2,EI_S3,IE_DA,IE_S2,IE_S3
FILEI LOOKUPI[1] = "%LU_external%"
FILEI DBI[1] = "%ext_sta%"

  zones=1
  
  _autos = 0
  _ee = 0
  _ei_da = 0
  _ei_s2 = 0
  _ei_s3 = 0
  _ie_da = 0
  _ie_s2 = 0
  _ie_s3 = 0  
  
  
  LOOKUP LOOKUPI=1, LIST=N,
  NAME=EXT, 
  LOOKUP[1]=1, RESULT=2, ; EE share
  LOOKUP[2]=1, RESULT=5, ; IE_DA share
  LOOKUP[3]=1, RESULT=6, ; IE_S2 share
  LOOKUP[4]=1, RESULT=7, ; IE_S3 share
  LOOKUP[5]=1, RESULT=8, ; EI_DA share  
  LOOKUP[6]=1, RESULT=9, ; EI_S2 share
  LOOKUP[7]=1, RESULT=10 ; EI_S3 share
  
  ;PRINT CSV=T, LIST='ZONE','AUTOS','EE','EI_DA','EI_S2','EI_S3','IE_DA','IE_S2','IE_S3' PRINTO=1

  
; loop through each external zone 
LOOP  k=1,DBI.1.NUMRECORDS
  
  x=DBIReadRecord(1,k)
  
  _autos = DI.1.AADT - DI.1.HCAADT
  
  ; write out externals for each zone
  RO.ZONE = DI.1.ZONE
  RO.AUTOS = _autos
  RO.EE =   _autos * EXT(1, DI.1.ZONE) / 100
  RO.EI_DA =  _autos * EXT(2, DI.1.ZONE) / 100
  RO.EI_S2 =  _autos * EXT(3, DI.1.ZONE) / 100
  RO.EI_S3 =  _autos * EXT(4, DI.1.ZONE) / 100
  RO.IE_DA =  _autos * EXT(5, DI.1.ZONE) / 100
  RO.IE_S2 =  _autos * EXT(6, DI.1.ZONE) / 100
  RO.IE_S3 =  _autos * EXT(7, DI.1.ZONE) / 100
  
  WRITE RECO=1
  
  ; write out external - externals too
  PRINT CSV=F, LIST=DI.1.ZONE, (RO.EE / 2), (RO.EE / 2) PRINTO=2

ENDLOOP

ENDRUN


; Script for program MATRIX in file "D:\TourCast\MetCouncil_ABM02092015\CUBE\TSMAT00I.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Build distribution matrix for Auto EE IPF'
FILEO MATO[1] = "%SCENARIO_DIR%\HWY_EXT_JOINT_TARGET.TRP",
DEC=2, MO=1, NAME=EE_SURVEY

FILEI MATI[1] = "%ee_auto_dist%",
 PATTERN=IJ:V,FIELDS=#1,2,3

    zones = %zones%
    
    MW[1] = MI.1.1

ENDRUN


; Script for program FRATAR in file "D:\TourCast\MetCouncil_ABM02092015\CUBE\TSFRA00A.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=FRATAR MSG='Fratar station targets using distribution from survey'
FILEO MATO[1] = "%SCENARIO_DIR%\HWY_EXT_EETRIP.TRP",
 MO=1, NAME=EE_AUTO
FILEI MATI[1] = "%SCENARIO_DIR%\HWY_EXT_JOINT_TARGET.TRP"
FILEI LOOKUPI[1] = "%SCENARIO_DIR%\HWY_EXT_MARGINAL_TARGET.txt"

  LOOKUP LOOKUPI=1,
  NAME=FRATAR,
  LOOKUP[1]=1, RESULT=2,
  LOOKUP[2]=1, RESULT=3
  
  MAXITERS=20

  SETPA P[1]=FRATAR(1,J), A[1]=FRATAR(2,J) MW[1]=MI.1.1

ENDRUN


; Script for program MATRIX in file "D:\TourCast\MetCouncil_ABM02092015\CUBE\TSMAT00K.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Generate Airport Trips'
FILEO RECO[1] = "%SCENARIO_DIR%\HWY_SPC_PA.dbf",
 FIELDS=ORIG(8.0),DEST(8.0),TRIPS(10.2)
FILEI DBI[1] = "%zone_attribs%",
 SORT=ZONE

ZONES=1
 
LOOP k=1,DBI.1.NUMRECORDS
x=DBIReadRecord(1,k)
RO.ORIG=DBI.1.NFIELD[1]
RO.DEST=1521
RO.TRIPS=DBI.1.NFIELD[4]*0.0199
 
WRITE RECO=1
ENDLOOP

ENDRUN


; Script for program MATRIX in file "D:\TourCast\MetCouncil_ABM02092015\CUBE\TSMAT00L.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Create Special Generator Matrix'
FILEI LOOKUPI[1] = "%LU_spc_tod%"
FILEO MATO[1] = "%SCENARIO_DIR%\HWY_SPC_TRIP.trp",
 MO=1-11, NAME= AM1, AM2, AM3, AM4, MD, PM1, PM2, PM3, PM4, EV, ON
FILEI MATI[1] = "%SCENARIO_DIR%\HWY_SPC_PA.dbf",
 PATTERN=IJ:V, FIELDS=ORIG, DEST, TRIPS


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
  
  zones=%zones%
  
  MW[1]= MI.1.1 * TODL(1,1)
  MW[2]= MI.1.1 * TODL(2,1)
  MW[3]= MI.1.1 * TODL(3,1)
  MW[4]= MI.1.1 * TODL(4,1)
  MW[5]= MI.1.1 * TODL(5,1)        
  MW[6]= MI.1.1 * TODL(6,1)
  MW[7]= MI.1.1 * TODL(7,1)
  MW[8]= MI.1.1 * TODL(8,1)
  MW[9]= MI.1.1 * TODL(9,1)
  MW[10]= MI.1.1 * TODL(10,1)   
  MW[11]= MI.1.1 * TODL(11,1)          
        
        
ENDRUN


; Script for program FRATAR in file "D:\TOURCAST\METCOUNCIL_ABM02092015\CUBE\TSFRA00B.S"
;;<<Default Template>><<FRATAR>><<Default>>;;
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=FRATAR MSG='Fratar EE truck from FAF'
FILEO MATO[1] = "%SCENARIO_DIR%\EE_FRATAR_TMP.MAT",
 MO=1, DEC=1, NAME=EE_TRK
FILEI LOOKUPI[1] = "D:\TourCast\MetCouncil_ABM02092015\Input\EE_FRATAR.txt"
FILEI MATI[1] = "D:\TourCast\MetCouncil_ABM02092015\Input\EE_SEED_TRK_4.MAT"
LOOKUP LOOKUPI=1,
 NAME=FRATAR,
  LOOKUP[1]=1, RESULT=2,
  LOOKUP[2]=1, RESULT=3
    MAXRMSE=0.01
  MAXITERS=99
  SETPA P[1]=FRATAR(1,J), A[1]=FRATAR(2,J) MW[1]=MI.1.1

ENDRUN


; Script for program MATRIX in file "D:\TOURCAST\METCOUNCIL_ABM02092015\CUBE\TSMAT00M.S"
;;<<Default Template>><<MATRIX>><<Default>>;;
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Split into two types'
FILEO MATO[1] = "%SCENARIO_DIR%\EE_FRATAR_TRK.MAT",
 MO=1-2, DEC=1, NAME=SINGLEUNIT, COMBINATION
FILEI MATI[1] = "%SCENARIO_DIR%\EE_FRATAR_TMP.MAT"

MW[1]=MI.1.1*0.727
MW[2]=MI.1.1*0.273

ENDRUN


