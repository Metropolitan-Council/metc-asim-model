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
