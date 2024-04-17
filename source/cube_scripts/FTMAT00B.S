; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Time period splits'
FILEI MATI[2] = "%SCENARIO_DIR%\truck\EE_FRATAR_TRK.MAT"
FILEO PRINTO[1] = "%SCENARIO_DIR%\truck\TRK_TRIP_PRN_%ITER%.prn"
FILEI LOOKUPI[1] = "%qrfm%"
FILEO MATO[11] = "%SCENARIO_DIR%\truck\TRK_TRIP_%ITER%_ON.trp",
 MO=111,112,113, NAME=Single, Combo, Total
FILEO MATO[10] = "%SCENARIO_DIR%\truck\TRK_TRIP_%ITER%_EV.trp",
 MO=101,102,103, NAME=Single, Combo, Total
FILEO MATO[9] = "%SCENARIO_DIR%\truck\TRK_TRIP_%ITER%_PM4.trp",
 MO=91,92,93, NAME=Single, Combo, Total
FILEO MATO[8] = "%SCENARIO_DIR%\truck\TRK_TRIP_%ITER%_PM3.trp",
 MO=81,82,83, NAME=Single, Combo, Total
FILEO MATO[7] = "%SCENARIO_DIR%\truck\TRK_TRIP_%ITER%_PM2.trp",
 MO=71,72,73, NAME=Single, Combo, Total
FILEO MATO[6] = "%SCENARIO_DIR%\truck\TRK_TRIP_%ITER%_PM1.trp",
 MO=61,62,63, NAME=Single, Combo, Total
FILEO MATO[5] = "%SCENARIO_DIR%\truck\TRK_TRIP_%ITER%_MD.trp",
 MO=51,52,53, NAME=Single, Combo, Total
FILEO MATO[4] = "%SCENARIO_DIR%\truck\TRK_TRIP_%ITER%_AM4.trp",
 MO=41,42,43, NAME=Single, Combo, Total
FILEO MATO[3] = "%SCENARIO_DIR%\truck\TRK_TRIP_%ITER%_AM3.trp",
 MO=31,32,33, NAME=Single, Combo, Total
FILEO MATO[2] = "%SCENARIO_DIR%\truck\TRK_TRIP_%ITER%_AM2.trp",
 MO=21,22,23, NAME=Single, Combo, Total
FILEO MATO[1] = "%SCENARIO_DIR%\truck\TRK_TRIP_%ITER%_AM1.trp",
 MO=11,12,13, NAME=Single, Combo, Total
FILEI MATI[1] = "%SCENARIO_DIR%\truck\TRK_TRIP_%ITER%.tmp"

  
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
