; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=GENERATION MSG='Quick Response Freight Manual routine'
FILEO PAO[2] = "%SCENARIO_DIR%\truck\TRK_PA.txt",
 FORM=6.0, LIST=Z, P[1],A[1], P[2], A[2]
FILEO PAO[1] = "%SCENARIO_DIR%\truck\TRK_PA.dbf",
 FORM=6.0, DBF=T, LIST=Z, P[1], A[1], P[2], A[2] ;, NAMES=Z,SUT_P,SUT_A,MUT_P,MUT_A
FILEO PRINTO[1] = "%SCENARIO_DIR%\truck\TRK_GENERATION.PRN"
FILEI ZDATI[2] = "%ext_sta%"
FILEI ZDATI[1] = "%zone_attribs%"
;FILEI LOOKUPI[1] = "%qfrm%" fixed by Dennis Farmer due to mispelling
FILEI LOOKUPI[1] = "%qrfm%"

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
