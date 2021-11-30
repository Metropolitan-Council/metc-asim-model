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
