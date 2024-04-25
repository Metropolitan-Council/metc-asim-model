; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Record stats and Convert to Vehicle Trip Tables %ASSIGNNAME%'
FILEO MATO[1] = "%SCENARIO_DIR%\specialgen\HWY_SPC_AUTO_TRIP_%ITER%_%PER%.trp",
 MO=41-43, DEC[1]=3*2, NAME=DA, SR2, SR3
FILEI MATI[4] = "%SCENARIO_DIR%\specialgen\HWY_SPC_TRIP_%ITER%_%PER%.TRP"
FILEI MATI[3] = "%SCENARIO_DIR%\external\HWY_EXT_TRIP_%ITER%_%PER%.TRP"
FILEI MATI[2] = "%SCENARIO_DIR%\truck\TRK_TRIP_%ITER%_%PER%.TRP"
; DISTRIBUTEINTRASTEP ProcessID="Intrastep", ProcessList=1-%NUMBER_OF_PROCESSORS%

FILEI MATI[1] = "%SCENARIO_DIR%\highway\HWY_TRIP_%ITER%_%PER%.TRP"


          MW[1] = MI.1.1
          MW[2] = MI.1.2
          MW[3] = MI.1.3
          MW[4] = MI.1.4/%hwy_HOV2OCC%
          MW[5] = MI.1.5/%hwy_HOV2OCC%
          MW[6] = MI.1.6/%hwy_HOV2OCC%
          MW[7] = MI.1.7/%hwy_HOV3OCC%
          MW[8] = MI.1.8/%hwy_HOV3OCC%
          MW[9] = MI.1.9/%hwy_HOV3OCC%
          MW[10]= MI.1.10
          MW[11]= MI.1.11
          MW[12]= MI.1.12
          
          
          MW[41] = MI.4.1
          MW[42] = MI.4.2/%hwy_HOV2OCC%
          MW[43] = MI.4.3/%hwy_HOV3OCC%
          
          MW[101] = MI.2.3
          MW[111] = MI.3.1
          MW[112] = MI.3.2
          MW[113] = MI.3.3
/*
          ; Log counts of each vehicle trip table
   _total = _total + ROWSUM(32) +
		ROWSUM(1) + 		ROWSUM(2) + 
		ROWSUM(3) + 		ROWSUM(4) + 
		ROWSUM(5) + 		ROWSUM(6) + 
		ROWSUM(7) + 		ROWSUM(8) + 
		ROWSUM(9) + 		ROWSUM(10) + 
		ROWSUM(11) +		ROWSUM(12) + 
		ROWSUM(13) +  	ROWSUM(14) +
		ROWSUM(15) + 		ROWSUM(16) + 
		ROWSUM(17) + 		ROWSUM(18) + 
		ROWSUM(19) + 		ROWSUM(20) + 
		ROWSUM(21) + 		ROWSUM(22) + 
		ROWSUM(23) + 		ROWSUM(24) + 
		ROWSUM(25) + 		ROWSUM(26) + 
		ROWSUM(27) + 		ROWSUM(28) + 
		ROWSUM(29) + 		ROWSUM(30) + 
		ROWSUM(31)
    
    _trucks = ROWSUM(101) + _trucks
    
    _eiieauto = ROWSUM(111) + ROWSUM(112) + ROWSUM(113) + _eiieauto
    
    _spc  = ROWSUM(41) + ROWSUM(42) + ROWSUM(43) + _spc
  
  IF(I==%zones%)
    LIST= %TOD%, ' %PER%', _total, _trucks, _eiieauto, _spc FILE = "%SCENARIO_DIR%\external\HWY_TRIP_PRN_%ITER%_VEHSUMM.CSV",
 APPEND=T, CSV=T
  ENDIF         
          
       */   
          
ENDRUN
