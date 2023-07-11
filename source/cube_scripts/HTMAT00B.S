; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Convert to Vehicle Trip Tables %ASSIGNNAME%'
FILEO MATO[2] = "%SCENARIO_DIR%\HWY_SPC_AUTO_TRIP_%ITER%_%PER%.trp",
 MO=41-43, DEC[1]=3*2, NAME=DA, SR2, SR3
FILEI MATI[4] = "%SCENARIO_DIR%\HWY_SPC_TRIP_%ITER%_%PER%.trp"
FILEI MATI[3] = "%SCENARIO_DIR%\HWY_EXT_TRIP_%ITER%_%PER%.trp"
FILEI MATI[2] = "%SCENARIO_DIR%\TRK_TRIP_%ITER%_%PER%.trp"
DISTRIBUTEINTRASTEP ProcessID="Intrastep", ProcessList=1-%max_threads%
FILEO MATO[1] = "%SCENARIO_DIR%\HWY_AUTO_TRIP_%ITER%_%PER%.trp",
                 MO=1-32, DEC[1]=32*2, NAME = SOVW1, SOVW2, SOVW3, SOVW4, SOVW5,  HOV2W1, HOV2W2, HOV2W3, HOV2W4, HOV2W5,  HOV3W1, HOV3W2, HOV3W3, HOV3W4, HOV3W5,
                                              SOVNW1,SOVNW2,SOVNW3,SOVNW4,SOVNW5, HOV2NW1,HOV2NW2,HOV2NW3,HOV2NW4,HOV2NW5, HOV3NW1,HOV3NW2,HOV3NW3,HOV3NW4,HOV3NW5,SOVNO1,SOVNO25
FILEI MATI[1] = "%SCENARIO_DIR%\HWY_TRIP_%ITER%_%PER%.trp"

          MW[1] = MI.1.1
          MW[2] = MI.1.2
          MW[3] = MI.1.3
          MW[4] = MI.1.4
          MW[5] = MI.1.5
          MW[6] = MI.1.6/%hwy_HOV2OCC%
          MW[7] = MI.1.7/%hwy_HOV2OCC%
          MW[8] = MI.1.8/%hwy_HOV2OCC%
          MW[9] = MI.1.9/%hwy_HOV2OCC%
          MW[10]= MI.1.10/%hwy_HOV2OCC%
          MW[11]= MI.1.11/%hwy_HOV3OCC%
          MW[12]= MI.1.12/%hwy_HOV3OCC%
          MW[13]= MI.1.13/%hwy_HOV3OCC%
          MW[14]= MI.1.14/%hwy_HOV3OCC%
          MW[15]= MI.1.15/%hwy_HOV3OCC%
          MW[16]= MI.1.16
          MW[17]= MI.1.17
          MW[18]= MI.1.18
          MW[19]= MI.1.19
          MW[20]= MI.1.20
          MW[21]= MI.1.21/%hwy_HOV2OCC%
          MW[22]= MI.1.22/%hwy_HOV2OCC%
          MW[23]= MI.1.23/%hwy_HOV2OCC%
          MW[24]= MI.1.24/%hwy_HOV2OCC%
          MW[25]= MI.1.25/%hwy_HOV2OCC%
          MW[26]= MI.1.26/%hwy_HOV3OCC%
          MW[27]= MI.1.27/%hwy_HOV3OCC%
          MW[28]= MI.1.28/%hwy_HOV3OCC%
          MW[29]= MI.1.29/%hwy_HOV3OCC%
          MW[30]= MI.1.30/%hwy_HOV3OCC%
          MW[31]= MI.1.31
          MW[32]= MI.1.32
          
          MW[41] = MI.4.1
          MW[42] = MI.4.2/%hwy_HOV2OCC%
          MW[43] = MI.4.3/%hwy_HOV3OCC%         
          
          MW[101] = MI.2.3
          MW[111] = MI.3.1
          MW[112] = MI.3.2
          MW[113] = MI.3.3          

          ; Log counts of each vehicle trip table
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
  
    _trucks = ROWSUM(101) + _trucks
    
    _eiieauto = ROWSUM(111) + ROWSUM(112) + ROWSUM(113) + _eiieauto
    
    _spc  = ROWSUM(41) + ROWSUM(42) + ROWSUM(43) + _spc    
  
  IF(I==%zones%)
    LIST= %TOD%, ' %PER%', _total, _trucks, _eiieauto, _spc FILE = "%SCENARIO_DIR%\HWY_TRIP_PRN_%ITER%_VEHSUMM.CSV",
 APPEND=T, CSV=T
  ENDIF        
                 
          
ENDRUN
