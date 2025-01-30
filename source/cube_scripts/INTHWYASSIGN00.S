; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
ITER = 2
DISTRIBUTE INTRASTEP=T
*Cluster Intrastep 1-%max_threads% START EXIT
; End of PILOT Script

; Script for program MATRIX in file "D:\TourCast\MetCouncil_ABM03192015\CUBE\HAMAT00E.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Aggregate Trip Tables for Interm Assignment'
DISTRIBUTEINTRASTEP ProcessID='Intrastep', ProcessList=1-%max_threads%
FILEO MATO[3] = "%SCENARIO_DIR%\HWY_TRIP_%ITER%_NT.TRP",
                 MO=201-232, DEC[1]=32*2, 
                 NAME = SOVW1, SOVW2, SOVW3, SOVW4, SOVW5,  
                 HOV2W1, HOV2W2, HOV2W3, HOV2W4, HOV2W5,  
                 HOV3W1, HOV3W2, HOV3W3, HOV3W4, HOV3W5,
                 SOVNW1,SOVNW2,SOVNW3,SOVNW4,SOVNW5, 
                 HOV2NW1,HOV2NW2,HOV2NW3,HOV2NW4,HOV2NW5, 
                 HOV3NW1,HOV3NW2,HOV3NW3,HOV3NW4,HOV3NW5,
                 SOVNO1,SOVNO25
FILEO MATO[2] = "%SCENARIO_DIR%\HWY_TRIP_%ITER%_PM.TRP",
                 MO=101-132, DEC[1]=32*2, 
                 NAME = SOVW1, SOVW2, SOVW3, SOVW4, SOVW5,  
                 HOV2W1, HOV2W2, HOV2W3, HOV2W4, HOV2W5,  
                 HOV3W1, HOV3W2, HOV3W3, HOV3W4, HOV3W5,
                 SOVNW1,SOVNW2,SOVNW3,SOVNW4,SOVNW5, 
                 HOV2NW1,HOV2NW2,HOV2NW3,HOV2NW4,HOV2NW5, 
                 HOV3NW1,HOV3NW2,HOV3NW3,HOV3NW4,HOV3NW5,
                 SOVNO1,SOVNO25
FILEI MATI[10] = "%SCENARIO_DIR%\HWY_TRIP_%ITER%_ON.TRP"
FILEI MATI[9] = "%SCENARIO_DIR%\HWY_TRIP_%ITER%_EV.TRP"
FILEI MATI[8] = "%SCENARIO_DIR%\HWY_TRIP_%ITER%_PM4.TRP"
FILEI MATI[7] = "%SCENARIO_DIR%\HWY_TRIP_%ITER%_PM3.TRP"
FILEI MATI[6] = "%SCENARIO_DIR%\HWY_TRIP_%ITER%_PM2.TRP"
FILEI MATI[5] = "%SCENARIO_DIR%\HWY_TRIP_%ITER%_PM1.TRP"
FILEO MATO[1] = "%SCENARIO_DIR%\HWY_TRIP_%ITER%_AM.TRP",
                 MO=1-32, DEC[1]=32*2, 
                 NAME = SOVW1, SOVW2, SOVW3, SOVW4, SOVW5,  
                 HOV2W1, HOV2W2, HOV2W3, HOV2W4, HOV2W5,  
                 HOV3W1, HOV3W2, HOV3W3, HOV3W4, HOV3W5,
                 SOVNW1,SOVNW2,SOVNW3,SOVNW4,SOVNW5, 
                 HOV2NW1,HOV2NW2,HOV2NW3,HOV2NW4,HOV2NW5, 
                 HOV3NW1,HOV3NW2,HOV3NW3,HOV3NW4,HOV3NW5,
                 SOVNO1,SOVNO25
FILEI MATI[4] = "%SCENARIO_DIR%\HWY_TRIP_%ITER%_AM4.TRP"
FILEI MATI[3] = "%SCENARIO_DIR%\HWY_TRIP_%ITER%_AM3.TRP"
FILEI MATI[2] = "%SCENARIO_DIR%\HWY_TRIP_%ITER%_AM2.TRP"
FILEI MATI[1] = "%SCENARIO_DIR%\HWY_TRIP_%ITER%_AM1.TRP"

  ; AM Period
	MW[1] = MI.1.1 + MI.2.1 + MI.3.1 + MI.4.1
	MW[2] = MI.1.2 + MI.2.2 + MI.3.2 + MI.4.2
	MW[3] = MI.1.3 + MI.2.3 + MI.3.3 + MI.4.3
	MW[4] = MI.1.4 + MI.2.4 + MI.3.4 + MI.4.4
	MW[5] = MI.1.5 + MI.2.5 + MI.3.5 + MI.4.5
	MW[6] = MI.1.6 + MI.2.6 + MI.3.6 + MI.4.6
	MW[7] = MI.1.7 + MI.2.7 + MI.3.7 + MI.4.7
	MW[8] = MI.1.8 + MI.2.8 + MI.3.8 + MI.4.8
	MW[9] = MI.1.9 + MI.2.9 + MI.3.9 + MI.4.9
	MW[10] = MI.1.10 + MI.2.10 + MI.3.10 + MI.4.10
	MW[11] = MI.1.11 + MI.2.11 + MI.3.11 + MI.4.11
	MW[12] = MI.1.12 + MI.2.12 + MI.3.12 + MI.4.12
	MW[13] = MI.1.13 + MI.2.13 + MI.3.13 + MI.4.13
	MW[14] = MI.1.14 + MI.2.14 + MI.3.14 + MI.4.14
	MW[15] = MI.1.15 + MI.2.15 + MI.3.15 + MI.4.15
	MW[16] = MI.1.16 + MI.2.16 + MI.3.16 + MI.4.16
	MW[17] = MI.1.17 + MI.2.17 + MI.3.17 + MI.4.17
	MW[18] = MI.1.18 + MI.2.18 + MI.3.18 + MI.4.18
	MW[19] = MI.1.19 + MI.2.19 + MI.3.19 + MI.4.19
	MW[20] = MI.1.20 + MI.2.20 + MI.3.20 + MI.4.20
	MW[21] = MI.1.21 + MI.2.21 + MI.3.21 + MI.4.21
	MW[22] = MI.1.22 + MI.2.22 + MI.3.22 + MI.4.22
	MW[23] = MI.1.23 + MI.2.23 + MI.3.23 + MI.4.23
	MW[24] = MI.1.24 + MI.2.24 + MI.3.24 + MI.4.24
	MW[25] = MI.1.25 + MI.2.25 + MI.3.25 + MI.4.25
	MW[26] = MI.1.26 + MI.2.26 + MI.3.26 + MI.4.26
	MW[27] = MI.1.27 + MI.2.27 + MI.3.27 + MI.4.27
	MW[28] = MI.1.28 + MI.2.28 + MI.3.28 + MI.4.28
	MW[29] = MI.1.29 + MI.2.29 + MI.3.29 + MI.4.29
	MW[30] = MI.1.30 + MI.2.30 + MI.3.30 + MI.4.30
	MW[31] = MI.1.31 + MI.2.31 + MI.3.31 + MI.4.31
	MW[32] = MI.1.32 + MI.2.32 + MI.3.32 + MI.4.32
  
 ; pm period
	MW[101] = MI.5.1 + MI.6.1 + MI.7.1 + MI.8.1
	MW[102] = MI.5.2 + MI.6.2 + MI.7.2 + MI.8.2
	MW[103] = MI.5.3 + MI.6.3 + MI.7.3 + MI.8.3
	MW[104] = MI.5.4 + MI.6.4 + MI.7.4 + MI.8.4
	MW[105] = MI.5.5 + MI.6.5 + MI.7.5 + MI.8.5
	MW[106] = MI.5.6 + MI.6.6 + MI.7.6 + MI.8.6
	MW[107] = MI.5.7 + MI.6.7 + MI.7.7 + MI.8.7
	MW[108] = MI.5.8 + MI.6.8 + MI.7.8 + MI.8.8
	MW[109] = MI.5.9 + MI.6.9 + MI.7.9 + MI.8.9
	MW[110] = MI.5.10 + MI.6.10 + MI.7.10 + MI.8.10
	MW[111] = MI.5.11 + MI.6.11 + MI.7.11 + MI.8.11
	MW[112] = MI.5.12 + MI.6.12 + MI.7.12 + MI.8.12
	MW[113] = MI.5.13 + MI.6.13 + MI.7.13 + MI.8.13
	MW[114] = MI.5.14 + MI.6.14 + MI.7.14 + MI.8.14
	MW[115] = MI.5.15 + MI.6.15 + MI.7.15 + MI.8.15
	MW[116] = MI.5.16 + MI.6.16 + MI.7.16 + MI.8.16
	MW[117] = MI.5.17 + MI.6.17 + MI.7.17 + MI.8.17
	MW[118] = MI.5.18 + MI.6.18 + MI.7.18 + MI.8.18
	MW[119] = MI.5.19 + MI.6.19 + MI.7.19 + MI.8.19
	MW[120] = MI.5.20 + MI.6.20 + MI.7.20 + MI.8.20
	MW[121] = MI.5.21 + MI.6.21 + MI.7.21 + MI.8.21
	MW[122] = MI.5.22 + MI.6.22 + MI.7.22 + MI.8.22
	MW[123] = MI.5.23 + MI.6.23 + MI.7.23 + MI.8.23
	MW[124] = MI.5.24 + MI.6.24 + MI.7.24 + MI.8.24
	MW[125] = MI.5.25 + MI.6.25 + MI.7.25 + MI.8.25
	MW[126] = MI.5.26 + MI.6.26 + MI.7.26 + MI.8.26
	MW[127] = MI.5.27 + MI.6.27 + MI.7.27 + MI.8.27
	MW[128] = MI.5.28 + MI.6.28 + MI.7.28 + MI.8.28
	MW[129] = MI.5.29 + MI.6.29 + MI.7.29 + MI.8.29
	MW[130] = MI.5.30 + MI.6.30 + MI.7.30 + MI.8.30
	MW[131] = MI.5.31 + MI.6.31 + MI.7.31 + MI.8.31
	MW[132] = MI.5.32 + MI.6.32 + MI.7.32 + MI.8.32
 
 ; overnight period
	MW[201] = MI.9.1 + MI.10.1
	MW[202] = MI.9.2 + MI.10.2
	MW[203] = MI.9.3 + MI.10.3
	MW[204] = MI.9.4 + MI.10.4
	MW[205] = MI.9.5 + MI.10.5
	MW[206] = MI.9.6 + MI.10.6
	MW[207] = MI.9.7 + MI.10.7
	MW[208] = MI.9.8 + MI.10.8
	MW[209] = MI.9.9 + MI.10.9
	MW[210] = MI.9.10 + MI.10.10
	MW[211] = MI.9.11 + MI.10.11
	MW[212] = MI.9.12 + MI.10.12
	MW[213] = MI.9.13 + MI.10.13
	MW[214] = MI.9.14 + MI.10.14
	MW[215] = MI.9.15 + MI.10.15
	MW[216] = MI.9.16 + MI.10.16
	MW[217] = MI.9.17 + MI.10.17
	MW[218] = MI.9.18 + MI.10.18
	MW[219] = MI.9.19 + MI.10.19
	MW[220] = MI.9.20 + MI.10.20
	MW[221] = MI.9.21 + MI.10.21
	MW[222] = MI.9.22 + MI.10.22
	MW[223] = MI.9.23 + MI.10.23
	MW[224] = MI.9.24 + MI.10.24
	MW[225] = MI.9.25 + MI.10.25
	MW[226] = MI.9.26 + MI.10.26
	MW[227] = MI.9.27 + MI.10.27
	MW[228] = MI.9.28 + MI.10.28
	MW[229] = MI.9.29 + MI.10.29
	MW[230] = MI.9.30 + MI.10.30
	MW[231] = MI.9.31 + MI.10.31
	MW[232] = MI.9.32 + MI.10.32
 


ENDRUN


; Script for program MATRIX in file "D:\TourCast\MetCouncil_ABM03192015\CUBE\HAMAT00G.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Aggregate Truck Trip Tables for Interm Assignment'
FILEO MATO[3] = "%SCENARIO_DIR%\TRK_TRIP_%ITER%_NT.TRP",
                 MO=201-203, DEC[1]=3*2, 
                 NAME = Single, Combo, Total
FILEO MATO[2] = "%SCENARIO_DIR%\TRK_TRIP_%ITER%_PM.TRP",
                 MO=101-103, DEC[1]=3*2, 
                 NAME = Single, Combo, Total
FILEI MATI[10] = "%SCENARIO_DIR%\TRK_TRIP_%ITER%_ON.TRP"
FILEI MATI[9] = "%SCENARIO_DIR%\TRK_TRIP_%ITER%_EV.TRP"
FILEI MATI[8] = "%SCENARIO_DIR%\TRK_TRIP_%ITER%_PM4.TRP"
FILEI MATI[7] = "%SCENARIO_DIR%\TRK_TRIP_%ITER%_PM3.TRP"
FILEI MATI[6] = "%SCENARIO_DIR%\TRK_TRIP_%ITER%_PM2.TRP"
FILEI MATI[5] = "%SCENARIO_DIR%\TRK_TRIP_%ITER%_PM1.TRP"
FILEO MATO[1] = "%SCENARIO_DIR%\TRK_TRIP_%ITER%_AM.TRP",
                 MO=1-3, DEC[1]=3*2, 
                 NAME = Single, Combo, Total
FILEI MATI[4] = "%SCENARIO_DIR%\TRK_TRIP_%ITER%_AM4.TRP"
FILEI MATI[3] = "%SCENARIO_DIR%\TRK_TRIP_%ITER%_AM3.TRP"
FILEI MATI[2] = "%SCENARIO_DIR%\TRK_TRIP_%ITER%_AM2.TRP"
FILEI MATI[1] = "%SCENARIO_DIR%\TRK_TRIP_%ITER%_AM1.TRP"

DISTRIBUTEINTRASTEP ProcessID='Intrastep', ProcessList=1-%max_threads%

  ; AM Period
	MW[1] = MI.1.1 + MI.2.1 + MI.3.1 + MI.4.1
	MW[2] = MI.1.2 + MI.2.2 + MI.3.2 + MI.4.2
	MW[3] = MI.1.3 + MI.2.3 + MI.3.3 + MI.4.3
  
 ; pm period
	MW[101] = MI.5.1 + MI.6.1 + MI.7.1 + MI.8.1
	MW[102] = MI.5.2 + MI.6.2 + MI.7.2 + MI.8.2
	MW[103] = MI.5.3 + MI.6.3 + MI.7.3 + MI.8.3
 
 ; overnight period
	MW[201] = MI.9.1 + MI.10.1
	MW[202] = MI.9.2 + MI.10.2
	MW[203] = MI.9.3 + MI.10.3


ENDRUN


; Script for program MATRIX in file "D:\TourCast\MetCouncil_ABM03192015\CUBE\HAMAT00I.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Aggregate IE/EI Trip Tables for Interm Assignment'
FILEO MATO[3] = "%SCENARIO_DIR%\HWY_EXT_TRIP_%ITER%_NT.TRP",
                 MO=201-203, DEC[1]=3*2, 
                 NAME = DA, SR2, SR3
FILEO MATO[2] = "%SCENARIO_DIR%\HWY_EXT_TRIP_%ITER%_PM.TRP",
                 MO=101-103, DEC[1]=3*2, 
                 NAME = DA, SR2, SR3
FILEI MATI[10] = "%SCENARIO_DIR%\HWY_EXT_TRIP_%ITER%_ON.TRP"
FILEI MATI[9] = "%SCENARIO_DIR%\HWY_EXT_TRIP_%ITER%_EV.TRP"
FILEI MATI[8] = "%SCENARIO_DIR%\HWY_EXT_TRIP_%ITER%_PM4.TRP"
FILEI MATI[7] = "%SCENARIO_DIR%\HWY_EXT_TRIP_%ITER%_PM3.TRP"
FILEI MATI[6] = "%SCENARIO_DIR%\HWY_EXT_TRIP_%ITER%_PM2.TRP"
FILEI MATI[5] = "%SCENARIO_DIR%\HWY_EXT_TRIP_%ITER%_PM1.TRP"
FILEO MATO[1] = "%SCENARIO_DIR%\HWY_EXT_TRIP_%ITER%_AM.TRP",
                 MO=1-3, DEC[1]=3*2, 
                 NAME = DA, SR2, SR3
FILEI MATI[4] = "%SCENARIO_DIR%\HWY_EXT_TRIP_%ITER%_AM4.TRP"
FILEI MATI[3] = "%SCENARIO_DIR%\HWY_EXT_TRIP_%ITER%_AM3.TRP"
FILEI MATI[2] = "%SCENARIO_DIR%\HWY_EXT_TRIP_%ITER%_AM2.TRP"
FILEI MATI[1] = "%SCENARIO_DIR%\HWY_EXT_TRIP_%ITER%_AM1.TRP"

DISTRIBUTEINTRASTEP ProcessID='Intrastep', ProcessList=1-%max_threads%

  ; AM Period
	MW[1] = MI.1.1 + MI.2.1 + MI.3.1 + MI.4.1
	MW[2] = MI.1.2 + MI.2.2 + MI.3.2 + MI.4.2
	MW[3] = MI.1.3 + MI.2.3 + MI.3.3 + MI.4.3
  
 ; pm period
	MW[101] = MI.5.1 + MI.6.1 + MI.7.1 + MI.8.1
	MW[102] = MI.5.2 + MI.6.2 + MI.7.2 + MI.8.2
	MW[103] = MI.5.3 + MI.6.3 + MI.7.3 + MI.8.3
 
 ; overnight period
	MW[201] = MI.9.1 + MI.10.1
	MW[202] = MI.9.2 + MI.10.2
	MW[203] = MI.9.3 + MI.10.3


ENDRUN


; Script for program MATRIX in file "D:\TourCast\MetCouncil_ABM03192015\CUBE\HAMAT00K.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Aggregate SPC Trip Tables for Interm Assignment'
FILEO MATO[3] = "%SCENARIO_DIR%\HWY_SPC_TRIP_%ITER%_NT.TRP",
                 MO=201-203, DEC[1]=3*2, 
                 NAME = DA, SR2, SR3
FILEO MATO[2] = "%SCENARIO_DIR%\HWY_SPC_TRIP_%ITER%_PM.TRP",
                 MO=101-103, DEC[1]=3*2, 
                 NAME = DA, SR2, SR3
FILEI MATI[10] = "%SCENARIO_DIR%\HWY_SPC_TRIP_%ITER%_ON.TRP"
FILEI MATI[9] = "%SCENARIO_DIR%\HWY_SPC_TRIP_%ITER%_EV.TRP"
FILEI MATI[8] = "%SCENARIO_DIR%\HWY_SPC_TRIP_%ITER%_PM4.TRP"
FILEI MATI[7] = "%SCENARIO_DIR%\HWY_SPC_TRIP_%ITER%_PM3.TRP"
FILEI MATI[6] = "%SCENARIO_DIR%\HWY_SPC_TRIP_%ITER%_PM2.TRP"
FILEI MATI[5] = "%SCENARIO_DIR%\HWY_SPC_TRIP_%ITER%_PM1.TRP"
FILEO MATO[1] = "%SCENARIO_DIR%\HWY_SPC_TRIP_%ITER%_AM.TRP",
                 MO=1-3, DEC[1]=3*2, 
                 NAME = DA, SR2, SR3
FILEI MATI[4] = "%SCENARIO_DIR%\HWY_SPC_TRIP_%ITER%_AM4.TRP"
FILEI MATI[3] = "%SCENARIO_DIR%\HWY_SPC_TRIP_%ITER%_AM3.TRP"
FILEI MATI[2] = "%SCENARIO_DIR%\HWY_SPC_TRIP_%ITER%_AM2.TRP"
FILEI MATI[1] = "%SCENARIO_DIR%\HWY_SPC_TRIP_%ITER%_AM1.TRP"

DISTRIBUTEINTRASTEP ProcessID='Intrastep', ProcessList=1-%max_threads%

  ; AM Period
	MW[1] = MI.1.1 + MI.2.1 + MI.3.1 + MI.4.1
	MW[2] = MI.1.2 + MI.2.2 + MI.3.2 + MI.4.2
	MW[3] = MI.1.3 + MI.2.3 + MI.3.3 + MI.4.3
  
 ; pm period
	MW[101] = MI.5.1 + MI.6.1 + MI.7.1 + MI.8.1
	MW[102] = MI.5.2 + MI.6.2 + MI.7.2 + MI.8.2
	MW[103] = MI.5.3 + MI.6.3 + MI.7.3 + MI.8.3
 
 ; overnight period
	MW[201] = MI.9.1 + MI.10.1
	MW[202] = MI.9.2 + MI.10.2
	MW[203] = MI.9.3 + MI.10.3


ENDRUN


; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.

;NEXTITER = ITER + 1

LOOP TOD=1,4,1
 IF(TOD=1) PER='AM' ASSIGNNAME='AM Peak Period'    HWY_NET ='HWY_NET_3.net'    NETNAME='AM Peak Period 6:00 AM to 10:00 AM'  CAPFAC = 3.75
 IF(TOD=2) PER='MD' ASSIGNNAME='Mid Day Period'    HWY_NET ='HWY_NET_4.net'    NETNAME='Mid Day Period 10:00 AM to 3:00 PM'  CAPFAC = 4.48
 IF(TOD=3) PER='PM' ASSIGNNAME='PM Peak Period'    HWY_NET ='HWY_NET_6.net'    NETNAME='PM Peak Period 3:00 PM to 7:00 PM'   CAPFAC = 3.9
 IF(TOD=4) PER='NT' ASSIGNNAME='Night'             HWY_NET ='HWY_NET_1.net'    NETNAME='Overnight 7:00 PM to 6:00 AM'        CAPFAC = 4.65

; End of PILOT Script

; Script for program MATRIX in file "D:\TourCast\MetCouncil_ABM03192015\CUBE\HAMAT00A.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Record stats and Convert to Vehicle Trip Tables %ASSIGNNAME%'
FILEO MATO[2] = "%SCENARIO_DIR%\HWY_SPC_AUTO_TRIP_%ITER%_%PER%.trp",
 MO=41-43, DEC[1]=3*2, NAME=DA, SR2, SR3
FILEI MATI[4] = "%SCENARIO_DIR%\HWY_SPC_TRIP_%ITER%_%PER%.TRP"
FILEI MATI[3] = "%SCENARIO_DIR%\HWY_EXT_TRIP_%ITER%_%PER%.TRP"
FILEI MATI[2] = "%SCENARIO_DIR%\TRK_TRIP_%ITER%_%PER%.TRP"
; DISTRIBUTEINTRASTEP ProcessID="Intrastep", ProcessList=1-%NUMBER_OF_PROCESSORS%
FILEO MATO[1] = "%SCENARIO_DIR%\HWY_AUTO_TRIP_%ITER%_%PER%.TRP",
                 MO=1-32, DEC[1]=32*2, NAME = SOVW1, SOVW2, SOVW3, SOVW4, SOVW5,  HOV2W1, HOV2W2, HOV2W3, HOV2W4, HOV2W5,  HOV3W1, HOV3W2, HOV3W3, HOV3W4, HOV3W5,
                                              SOVNW1,SOVNW2,SOVNW3,SOVNW4,SOVNW5, HOV2NW1,HOV2NW2,HOV2NW3,HOV2NW4,HOV2NW5, HOV3NW1,HOV3NW2,HOV3NW3,HOV3NW4,HOV3NW5,SOVNO1,SOVNO25
FILEI MATI[1] = "%SCENARIO_DIR%\HWY_TRIP_%ITER%_%PER%.TRP"


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
    LIST= %TOD%, ' %PER%', _total, _trucks, _eiieauto, _spc FILE = "%SCENARIO_DIR%\HWY_TRIP_PRN_%ITER%_VEHSUMM.CSV",
 APPEND=T, CSV=T
  ENDIF         
          
          
          
ENDRUN


; Script for program HIGHWAY in file "D:\TourCast\MetCouncil_ABM03192015\CUBE\HAHWY00A.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=HIGHWAY MSG='Assignment Period: %ASSIGNNAME%'
FILEI MATI[4] = "%SCENARIO_DIR%\HWY_SPC_AUTO_TRIP_%ITER%_%PER%.trp"
FILEI MATI[3] = "%SCENARIO_DIR%\HWY_EXT_TRIP_%ITER%_%PER%.TRP"
FILEI MATI[2] = "%SCENARIO_DIR%\TRK_TRIP_%ITER%_%PER%.TRP"
FILEO PRINTO[1] = "%SCENARIO_DIR%\HWY_LDNET_PRN_%ITER%_%PER%.txt"
FILEO MATO[1] = "%SCENARIO_DIR%\HWY_SKIM_%ITER%_%PER%.tmp",
                 MO=1-120, DEC[1]=5*120, COMBINE=T
FILEO NETO = "%SCENARIO_DIR%\HWY_LDNET_%ITER%_%PER%.NET"
FILEI NETI = "%SCENARIO_DIR%\%HWY_NET%"
FILEI LOOKUPI[1] = "%LU_will2pay%"
FILEI MATI[1] = "%SCENARIO_DIR%\HWY_AUTO_TRIP_%ITER%_%PER%.TRP"

DISTRIBUTEINTRASTEP ProcessID='Intrastep', ProcessList=1-%max_threads%

 ; **********   Define Assignment Parameters    ************
    
    PARAMETERS raad=0 gap = 0.0001 MAXITERS = %hwy_assignIters% COMBINE=EQUI
    FUNCTION TC[1] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    FUNCTION TC[2] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    FUNCTION TC[3] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    FUNCTION TC[4] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    FUNCTION TC[5] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    FUNCTION TC[6] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    FUNCTION TC[7] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    FUNCTION TC[8] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    FUNCTION TC[9] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    FUNCTION TC[10] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    FUNCTION TC[11] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    FUNCTION TC[12] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    FUNCTION TC[13] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    FUNCTION TC[14] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    FUNCTION TC[15] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    FUNCTION TC[99] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167)    

   FUNCTION V=VOL[1] + VOL[2] + VOL[3] + VOL[4] + VOL[5] + VOL[6] + VOL[7] + VOL[8] + VOL[9] + VOL[10] + VOL[11] + VOL[12] + VOL[13]*%hwy_TrkFac%

    LOOKUP NAME=TOLL, 
           LOOKUP[1]=1, RESULT=2,
           INTERPOLATE=Y,
           FAIL=25,800,
           R = '0.00 25',                  ; LOS-Toll table reported by MnDOT
               '0.35 50',
               '0.54 150',
               '0.77 250',
               '0.93 350',
               '1.00 600'
    LOOKUP LOOKUPI=1,INTERPOLATE=Y, FAIL = 5,100,
    NAME=DIVERT,
           LOOKUP[1]=1, RESULT=2,
           LOOKUP[2]=1, RESULT=3,
           LOOKUP[3]=1, RESULT=4,
           LOOKUP[4]=1, RESULT=5,
           LOOKUP[5]=1, RESULT=6,
           LOOKUP[6]=1, RESULT=7,
           LOOKUP[7]=1, RESULT=8,
           LOOKUP[8]=1, RESULT=9,
           LOOKUP[9]=1, RESULT=10,
           LOOKUP[10]=1,RESULT=11
           
    PHASE=LINKREAD

        T0      = LI.TIME
        IF (LI.CAPACITY=0)
            T0  = 99999
        ENDIF
        LW.HOV  = LI.HOV
        C       = LI.CAPACITY * %CAPFAC%
        Alpha   = LI.Alpha
        Beta    = LI.Beta
        LINKCLASS = LI.RCI


; **********   Create Link Groups    ************
; Group 1: All HOV Lanes
        IF (LI.HOV>0 && LI.HOV<99) ADDTOGROUP=30  ;Used as exclusion group on path building

; Group 2: HOV SECTIONS
        IF (LI.HOV=1,7,9)   ADDTOGROUP=1  ;I-35W	NB	STH-13 to I-494, I-494 to 48th St., and 48th St	to Downtown	Inbound
        IF (LI.HOV=2,8)     ADDTOGROUP=2  ;I-35W	SB	I-494	to STH-13, and 48th St to I-494	Outbound
        IF (LI.HOV=3,6,10)  ADDTOGROUP=3  ;I-394	WB/EB	Reversable Lane Ramp, I-94	to STH-100, and EB	Reversable Lane Ramp
        IF (LI.HOV=4)       ADDTOGROUP=4  ;I-394	WB	STH-100	I-494 Outbound
        IF (LI.HOV=5)       ADDTOGROUP=5  ;I-394	EB	I-494	STH-100	Inbound
        
        _toll1 = 25
        _toll2 = 25
        _toll3 = 25
        _toll4 = 25
        _toll5 = 25
   
    ENDPHASE 

    PHASE=ILOOP           

      MW[1] = MI.1.1    MW[2] = MI.1.2    MW[3] = MI.1.3    MW[4] = MI.1.4    MW[5] = MI.1.5 ; SOV Work
      MW[6] = MI.1.6    MW[7] = MI.1.7    MW[8] = MI.1.8    MW[9] = MI.1.9    MW[10]= MI.1.10 ; HOV2 Work
      MW[11]= MI.1.11   MW[12]= MI.1.12   MW[13]= MI.1.13   MW[14]= MI.1.14   MW[15]= MI.1.15 ; HOV3 Work
      MW[16]= MI.1.16   MW[17]= MI.1.17   MW[18]= MI.1.18   MW[19]= MI.1.19   MW[20]= MI.1.20 ; SOV NON Work
      MW[21]= MI.1.21   MW[22]= MI.1.22   MW[23]= MI.1.23   MW[24]= MI.1.24   MW[25]= MI.1.25 ; HOV2 NON Work
      MW[26]= MI.1.26   MW[27]= MI.1.27   MW[28]= MI.1.28   MW[29]= MI.1.29   MW[30]= MI.1.30 ; HOV3 NON Work
      MW[119] = MI.1.31    MW[120] = MI.1.32 + MI.3.1 + MI.3.2 + MI.3.3 + MI.4.1 + MI.4.2 + MI.4.3    ; SOVInc1, SOVInc25 - No Transponder / Externals / Spec Gen in with SOVInc25
      ; TODO: separate the Externals / Spec Gen in with SOVInc25 into their own by mode

    ; *** SKIMS ***
      ; Build SOV Truck Paths
      PATHLOAD PATH=TIME,                 
                EXCLUDEGRP=30,
                MW[31]=PATHCOST, MW[39]=PATHTRACE(LI.DISTANCE)
          
      ; Build HOV Paths 
       PATHLOAD PATH=TIME,                 
                MW[32]=PATHCOST, MW[40]=PATHTRACE(LI.DISTANCE)

      ; Build Unconstrained Paths That Use Any Lanes
       PATHLOAD PATH=TIME,
                MW[33] =PATHCOST,
                MW[81]=_toll1, selectgroup=1,
                MW[82]=_toll2, selectgroup=2,
                MW[83]=_toll3, selectgroup=3,
                MW[84]=_toll4, selectgroup=4,
                MW[85]=_toll5, selectgroup=5

    ; *** SOV Toll and Revenue Calculations ***
      ; Sum of tolls charged on each O-D path
        _HOV2PAY = 0
        _HOV3PAY = 0
        IF (%hwy_TollSetting%=2)
          _HOV2PAY = 1
        ENDIF
        IF (%hwy_TollSetting%=3)
          _HOV2PAY = 1
          _HOV3PAY = 1          
        ENDIF             
      
       MW[35] =  MW[81]+MW[82]+MW[83]+MW[84]+MW[85]
      ; Non-Pay Time - Pay Time
       MW[34] =  MW[31]-MW[33]
      ; Calculate %Diversion and Revenue
       JLOOP
        IF (I==J)
         MW[37] = 0 ; Percent willing to pay
        ELSE
         IF (MW[34]>0) ; If HOT Lanes save time
          MW[36] = MW[35]/MW[34]                                     ; SOV toll cost (cents) per minute saved (Toll/Time Saved)
          MW[37] = (MW[35]/%hwy_HOV2OCC%)/MW[34]*_HOV2PAY               ; HOV2 toll cost (cents) per minute saved (Toll/Time Saved)
          MW[38] = (MW[35]/%hwy_HOV3OCC%)/MW[34]*_HOV3PAY               ; HOV3 toll cost (cents) per minute saved (Toll/Time Saved)
          
          MW[41] = MW[1] * DIVERT(1,MW[36])/100     ; SOVW1 willing to pay at this level
          MW[42] = MW[2] * DIVERT(2,MW[36])/100     ; SOVW2 willing to pay at this level
          MW[43] = MW[3] * DIVERT(3,MW[36])/100     ; SOVW3 willing to pay at this level
          MW[44] = MW[4] * DIVERT(4,MW[36])/100     ; SOVW4 willing to pay at this level
          MW[45] = MW[5] * DIVERT(5,MW[36])/100     ; SOVW5 willing to pay at this level
          
          MW[46] = MW[6] * DIVERT(1,MW[37])/100     ; HOV2W1 willing to pay at this level
          MW[47] = MW[7] * DIVERT(2,MW[37])/100     ; HOV2W2 willing to pay at this level
          MW[48] = MW[8] * DIVERT(3,MW[37])/100     ; HOV2W3 willing to pay at this level
          MW[49] = MW[9] * DIVERT(4,MW[37])/100     ; HOV2W4 willing to pay at this level
          MW[50] = MW[10]* DIVERT(5,MW[37])/100     ; HOV2W5 willing to pay at this level
          
          MW[51] = MW[11]* DIVERT(1,MW[38])/100     ; HOV3W1 willing to pay at this level
          MW[52] = MW[12]* DIVERT(2,MW[38])/100     ; HOV3W2 willing to pay at this level
          MW[53] = MW[13]* DIVERT(3,MW[38])/100     ; HOV3W3 willing to pay at this level
          MW[54] = MW[14]* DIVERT(4,MW[38])/100     ; HOV3W4 willing to pay at this level
          MW[55] = MW[15]* DIVERT(5,MW[38])/100     ; HOV3W5 willing to pay at this level          
          
          MW[56] = MW[16]* DIVERT(6,MW[36])/100     ; SOVNW1 willing to pay at this level
          MW[57] = MW[17]* DIVERT(7,MW[36])/100     ; SOVNW2 willing to pay at this level
          MW[58] = MW[18]* DIVERT(8,MW[36])/100     ; SOVNW3 willing to pay at this level
          MW[59] = MW[19]* DIVERT(9,MW[36])/100     ; SOVNW4 willing to pay at this level
          MW[60] = MW[20]* DIVERT(10,MW[36])/100    ; SOVNW5 willing to pay at this level          

          MW[61] = MW[21]* DIVERT(6,MW[37])/100     ; HOV2NW1 willing to pay at this level
          MW[62] = MW[22]* DIVERT(7,MW[37])/100     ; HOV2NW2 willing to pay at this level
          MW[63] = MW[23]* DIVERT(8,MW[37])/100     ; HOV2NW3 willing to pay at this level
          MW[64] = MW[24]* DIVERT(9,MW[37])/100     ; HOV2NW4 willing to pay at this level
          MW[65] = MW[25]* DIVERT(10,MW[37])/100    ; HOV2NW5 willing to pay at this level          
          
          MW[66] = MW[26]* DIVERT(6,MW[38])/100     ; HOV3NW1 willing to pay at this level
          MW[67] = MW[27]* DIVERT(7,MW[38])/100     ; HOV3NW2 willing to pay at this level
          MW[68] = MW[28]* DIVERT(8,MW[38])/100     ; HOV3NW3 willing to pay at this level
          MW[69] = MW[29]* DIVERT(9,MW[38])/100     ; HOV3NW4 willing to pay at this level
          MW[70] = MW[30]* DIVERT(10,MW[38])/100    ; HOV3NW5 willing to pay at this level          
         
         ELSE
          MW[36]  = 0                         ; SOV toll cost (cents) per minute saved (Toll/Time Saved)
          MW[37]  = 0                         ; HOV2 toll cost (cents) per minute saved (Toll/Time Saved)
          MW[38]  = 0                         ; HOV3 toll cost (cents) per minute saved (Toll/Time Saved)


          MW[41] = 0
          MW[42] = 0
          MW[43] = 0
          MW[44] = 0
          MW[45] = 0
          
          MW[46] = 0
          MW[47] = 0
          MW[48] = 0
          MW[49] = 0
          MW[50] = 0
          
          MW[51] = 0
          MW[52] = 0
          MW[53] = 0
          MW[54] = 0
          MW[55] = 0
          
          MW[56] = 0
          MW[57] = 0
          MW[58] = 0
          MW[59] = 0
          MW[60] = 0

          MW[61] = 0
          MW[62] = 0
          MW[63] = 0
          MW[64] = 0
          MW[65] = 0
          
          MW[66] = 0
          MW[67] = 0
          MW[68] = 0
          MW[69] = 0
          MW[70] = 0
         ENDIF
        ENDIF
 
        ;Paying trips
          MW[71] = MW[41] + MW[46]*_HOV2PAY + MW[51]*_HOV3PAY                ; WORK INC 1 WILL PAY
          MW[72] = MW[42] + MW[47]*_HOV2PAY + MW[52]*_HOV3PAY                ; WORK INC 2 WILL PAY
          MW[73] = MW[43] + MW[48]*_HOV2PAY + MW[53]*_HOV3PAY                ; WORK INC 3 WILL PAY
          MW[74] = MW[44] + MW[49]*_HOV2PAY + MW[54]*_HOV3PAY                ; WORK INC 4 WILL PAY
          MW[75] = MW[45] + MW[50]*_HOV2PAY + MW[55]*_HOV3PAY                ; WORK INC 5 WILL PAY
          MW[76] = MW[56] + MW[61]*_HOV2PAY + MW[66]*_HOV3PAY                ; NON WORK INC 1 WILL PAY
          MW[77] = MW[57] + MW[62]*_HOV2PAY + MW[67]*_HOV3PAY                ; NON WORK INC 2 WILL PAY
          MW[78] = MW[58] + MW[63]*_HOV2PAY + MW[68]*_HOV3PAY                ; NON WORK INC 3 WILL PAY
          MW[79] = MW[59] + MW[64]*_HOV2PAY + MW[69]*_HOV3PAY                ; NON WORK INC 4 WILL PAY
          MW[80] = MW[60] + MW[65]*_HOV2PAY + MW[70]*_HOV3PAY                ; NON WORK INC 5 WILL PAY
          
        ;Income Groups 2-5
          MW[101] = MW[2] + MW[3] + MW[4] + MW[5] + MW[17] + MW[18] + MW[19] + MW[20] - MW[42] - MW[43] - MW[44] - MW[45] - MW[57] - MW[58] - MW[59] - MW[60] ; SOV INC25 Will NotPay
          MW[102] = MW[7] + MW[8] + MW[9] + MW[10]+ MW[22] + MW[23] + MW[24] + MW[25] - MW[47] - MW[48] - MW[49] - MW[50] - MW[62] - MW[63] - MW[64] - MW[65] ; HOV2 INC25 Will NotPay
          MW[103] = MW[12]+ MW[13]+ MW[14]+ MW[15] +MW[27] + MW[28] + MW[29] + MW[30] - MW[52] - MW[53] - MW[54] - MW[55] - MW[67] - MW[68] - MW[69] - MW[70] ; HOV3 INC25 Will NotPay
          MW[104] = MW[42] + MW[43] + MW[44] + MW[45] + MW[57] + MW[58] + MW[59] + MW[60] ; SOV  INC25 Will Pay
          MW[105] = MW[47] + MW[48] + MW[49] + MW[50] + MW[62] + MW[63] + MW[64] + MW[65] ; HOV2 INC25 Will Pay
          MW[106] = MW[52] + MW[53] + MW[54] + MW[55] + MW[67] + MW[68] + MW[69] + MW[70] ; HOV3 INC25 Will Pay
        ;Income Group 1
          MW[111] = MW[1] + MW[16] - MW[41] - MW[56] ; SOV  INC1 Will NotPay
          MW[112] = MW[6] + MW[21] - MW[46] - MW[61] ; HOV2 INC1 Will NotPay
          MW[113] = MW[11]+ MW[21] - MW[51] - MW[66] ; HOV3 INC1 Will NotPay
          MW[114] = MW[41]+ MW[56]                   ; SOV  INC1 Will Pay
          MW[115] = MW[46]+ MW[61]                   ; HOV2 INC1 Will Pay
          MW[116] = MW[51]+ MW[66]                   ; HOV3 INC1 Will Pay

        ; Revenue from Paying Vehicles based on "average" toll (average from one assignment to the next)
          MW[90] = MW[35] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80])   ; TOTAL revenue (Willing to Pay * Toll)
          MW[91] = MW[81] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80])   ; toll1 revenue
          MW[92] = MW[82] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80])   ; toll2 revenue
          MW[93] = MW[83] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80])   ; toll3 revenue
          MW[94] = MW[84] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80])   ; toll4 revenue
          MW[95] = MW[85] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80])   ; toll5 revenue
        
       ENDJLOOP
 
    ; *** ASSIGNMENT: LOAD VEHICLES ***

;  The following classes are used in the 7-class assignment:
;INCOME         2-5      2-5      2-5      2-5     2-5      2-5      1        1       1        1         1         1
;PAY OR NO      NO       NO       NO       PAY     PAY      PAY      NO       NO      NO       PAY       PAY       PAY
;OCCUPANCY      SOV      HOV2     HOV3     SOV     SOV2     HOV3     SOV      HOV2    HOV3     SOV       HOV2      HOV3     
   ;FUNCTION V=VOL[1] + VOL[2] + VOL[3] + VOL[4]  VOL[5] + VOL[6] + VOL[7] + VOL[8] +VOL[9] + VOL[10] + VOL[11] + VOL[12] + VOL[13]
   
       ; INCOME GROUPS 2-5
       ; SOV-No MNPASS
       ; Exclude SOV from HOT lanes
       PATHLOAD PATH=TIME, 
                EXCLUDEGRP=30,
                VOL[1]=MW[101] + MW[120]; SOV  INC2-5 NO MNPASS
       ; HOV2-No MNPASS              
       PATHLOAD PATH=TIME,
                EXCLUDEGRP=30,
                VOL[2]=MW[102]; HOV2  INC2-5 NO MNPASS
       ; HOV3-No MNPASS             
       PATHLOAD PATH=TIME,
                EXCLUDEGRP=30,
                VOL[3]=MW[103]; HOV3  INC2-5 NO MNPASS
                
       ; SOV-MNPASS
       ; Build Paths That Use Peak HOT Lanes
       PATHLOAD PATH=TIME, 
                VOL[4]=MW[104]; SOV  INC2-5 MNPASS
       ; HOV2-MNPASS
       PATHLOAD PATH=TIME,
                VOL[5]=MW[105]; HOV2  INC2-5 MNPASS
       ; HOV3-MNPASS                
       PATHLOAD PATH=TIME,
                VOL[6]=MW[106]; HOV3  INC2-5 MNPASS

       ; INCOME GROUP 1
       ; SOV-No MNPASS
       ; Exclude SOV from HOT lanes
       PATHLOAD PATH=TIME, 
                EXCLUDEGRP=30,
                VOL[7]=MW[111] + MW[119]; SOV  INC1 NO MNPASS
       ; HOV2-No MNPASS              
       PATHLOAD PATH=TIME,
                EXCLUDEGRP=30,
                VOL[8]=MW[112]; HOV2  INC1 NO MNPASS
       ; HOV3-No MNPASS             
       PATHLOAD PATH=TIME,
                EXCLUDEGRP=30,
                VOL[9]=MW[113]; HOV3  INC1 NO MNPASS
                
       ; SOV-MNPASS
       ; Build Paths That Use Peak HOT Lanes
       PATHLOAD PATH=TIME, 
                VOL[10]=MW[114]; SOV  INC1 MNPASS
       ; HOV2-MNPASS
       PATHLOAD PATH=TIME,
                VOL[11]=MW[115]; HOV2  INC1 MNPASS
       ; HOV3-MNPASS                
       PATHLOAD PATH=TIME,
                VOL[12]=MW[116]; HOV3  INC1 MNPASS
                
       ; Truck
       ; Exclude Trucks from HOT lanes
       PATHLOAD PATH=TIME, 
                EXCLUDEGRP=30,
                VOL[13]=MI.2.3               ; Trucks 

    ENDPHASE
    PHASE=ADJUST
         IF (LINKNO=1)
          _maxVC1 = 0
          _maxVC2 = 0
          _maxVC3 = 0
          _maxVC4 = 0
          _maxVC5 = 0
          IF (Iteration =1)
            PRINT CSV=T LIST='Iteration,ANode,BNode,HOV,Volume,VC,TIME,DISTANCE, VHT, VMT, Toll1, Toll2, Toll3, Toll4, Toll5' PRINTO=1          
          ENDIF
         ENDIF

; *** COMPUTE MAXIMUM V/C RATIO AND TOLL RATES FOR NEXT ITERATION ON TOLLED SEGMENTS ***
;HOT Lanes
        IF (LW.HOV=1,7,9 & C>0)
          IF ((V/C) > _maxVC1) _maxVC1 = (V/C)
        ENDIF
        IF (LW.HOV=2,8 & C>0)
          IF ((V/C) > _maxVC2) _maxVC2 = (V/C)          
        ENDIF
        IF (LW.HOV=3,6,10 & C>0)
          IF ((V/C) > _maxVC3) _maxVC3 = (V/C)
        ENDIF
        IF (LW.HOV=4 & C>0)
          IF ((V/C) > _maxVC4) _maxVC4 = (V/C)
        ENDIF
        IF (LW.HOV=5 & C>0)
          IF ((V/C) > _maxVC5) _maxVC5 = (V/C)
        ENDIF        
         
        ;Tolls for Next Assignment Iteration
        _toll1 = TOLL(1,_maxVC1)
        _toll2 = TOLL(1,_maxVC2)
        _toll3 = TOLL(1,_maxVC3)
        _toll4 = TOLL(1,_maxVC4)
        _toll5 = TOLL(1,_maxVC5)

        IF (LW.HOV>0 & V>0)
          PRINT CSV=T LIST=iteration(2.0),A(6.0),B(6.0),LW.HOV(4.0),V(8.2),V/C(8.42),TIME(5.2), DISTANCE(5.2), V*TIME(15.2), V*DISTANCE(15.2), _toll1(5.2), _toll2(5.2), _toll3(5.2), _toll4(5.2), _toll5(5.2) PRINTO=1
        ENDIF
    ENDPHASE

ENDRUN


; Script for program MATRIX in file "D:\TourCast\MetCouncil_ABM03192015\CUBE\HAMAT00C.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Create Highway Skims: %ASSIGNNAME%'
FILEO MATO[1] = "%SCENARIO_DIR%\HWY_SKIM_%ITER%_%PER%.skm",
 MO=1-16, 
  NAME=daptime, daptoll, dantime, dantoll, dapdist, a2ptime, a2ptoll, a2ntime, a2ntoll, a2pdist, 
  a3ptime, a3ptoll, a3ntime, a3ntoll, a3pdist, lnrtdist
FILEI MATI[1] = "%SCENARIO_DIR%\HWY_SKIM_%ITER%_%PER%.tmp"

DISTRIBUTEINTRASTEP ProcessID='Intrastep', ProcessList=1-%max_threads%
  zones = %zones%
    ; Drive alone
    mw[1] = MI.1.33
    mw[2] = MI.1.35    
    mw[3] = MI.1.31
    mw[4] = 0
    mw[5] = MI.1.40

    mw[1][I] = LOWEST(1,1,0.1,999,I)/2  
    mw[3][I] = LOWEST(3,1,0.1,999,I)/2      
    mw[5][I] = LOWEST(5,1,0.1,999,I)/2 
    
    ; TODO: add switch here to set toll values if HOVPay
    
    ; SR2
    mw[6] = mw[1]
    mw[7] = 0
    mw[8] = mw[1]
    mw[9] = 0
    mw[10] = mw[5]
    
    ; SR3
    mw[11] = mw[1]
    mw[12] = 0
    mw[13] = mw[1]
    mw[14] = 0
    mw[15] = mw[5]       
    
    ; ln(RT Dist + 1)
    mw[16] = LN(2 * mw[5]+1)

ENDRUN


; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.

ENDLOOP ; end of TOD assignment loop

*Cluster Intrastep 1-%max_threads% CLOSE EXIT
; End of PILOT Script

; Script for program NETWORK in file "D:\TourCast\MetCouncil_ABM03192015\CUBE\CANET00A.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK MSG='Combine Convergence Assignment Networks'
FILEI LINKI[4] = "%SCENARIO_DIR%\HWY_LDNET_%ITER%_NT.NET"
FILEI LINKI[3] = "%SCENARIO_DIR%\HWY_LDNET_%ITER%_PM.NET"
FILEI LINKI[2] = "%SCENARIO_DIR%\HWY_LDNET_%ITER%_MD.NET"
FILEI LINKI[1] = "%SCENARIO_DIR%\HWY_LDNET_%ITER%_AM.NET"

FILEO NETO = "%SCENARIO_DIR%\HWY_LDNET_%ITER%_DAILY.NET",
 INCLUDE = A, B, NC_NAME, LINKCLASS, AREA, COUNTY, RCI, DISTANCE, LANES, LANEMILES,
 SCREENLINE, COUNT, 
 VOL_TRK_AM, VOL_AUTO_AM, VOL_TOT_AM,
 VOL_TRK_MD, VOL_AUTO_MD, VOL_TOT_MD,
 VOL_TRK_PM, VOL_AUTO_PM, VOL_TOT_PM,
 VOL_TRK_NT, VOL_AUTO_NT, VOL_TOT_NT,
 VOL_TRK_DAILY, VOL_AUTO_DAILY, VOL_TOT_DAILY,
 FF_TIME, FF_SPD,
 CSPD_AM, 
 CSPD_MD, 
 CSPD_PM,  
 CSPD_NT,  
 CSPD_DAILY, 
 CAP_AM, CAP_MD, CAP_PM, CAP_NT,
 AM_CNT, MD_CNT, PM_CNT, NT_CNT,
 TIME_AM, TIME_MD, TIME_PM, TIME_NT,
 VMT, VHT, AVMT, AVHT, TVMT, TVHT, RATIO, 
 VMT_DIFF, VMT_DIFFSQ, VOL_DIFFSQ
  
 FF_SPD  = LI.1.SPEED
 FF_TIME = LI.1.TIME_
 LANEMILES = LI.1.LANES * LI.1.DISTANCE
 SCREENLINE = 0 ; TODO - hook this up
 COUNT = LI.1.DY_CNT + LI.1.AADT
 ;COUNT = LI.1.AADT
 
 ; AM Period
 CSPD_AM      = LI.1.CSPD_1
 VOL_AUTO_AM  = LI.1.V_1 - (LI.1.V13_1  * %hwy_TrkFac%)
 VOL_TRK_AM   = LI.1.V13_1 
 VOL_TOT_AM   = VOL_AUTO_AM + VOL_TRK_AM
 CAP_AM       = LI.1.CAPACITY
 TIME_AM      = LI.1.TIME_1
 
 ; MD Period
 CSPD_MD      = LI.2.CSPD_1
 VOL_AUTO_MD  = LI.2.V_1 - (LI.2.V13_1  * %hwy_TrkFac%)
 VOL_TRK_MD   = LI.2.V13_1 
 VOL_TOT_MD   = VOL_AUTO_MD + VOL_TRK_MD
 CAP_MD       = LI.2.CAPACITY
 TIME_MD      = LI.2.TIME_1
 
 ; PM Period
 CSPD_PM      = LI.3.CSPD_1
 VOL_AUTO_PM  = LI.3.V_1 - (LI.3.V13_1  * %hwy_TrkFac%)
 VOL_TRK_PM   = LI.3.V13_1 
 VOL_TOT_PM   = VOL_AUTO_PM + VOL_TRK_PM
 CAP_PM       = LI.3.CAPACITY
 TIME_PM      = LI.3.TIME_1
 
 ; NT Period
 CSPD_NT      = LI.4.CSPD_1
 VOL_AUTO_NT  = LI.4.V_1 - (LI.4.V13_1  * %hwy_TrkFac%)
 VOL_TRK_NT   = LI.4.V13_1 
 VOL_TOT_NT   = VOL_AUTO_NT + VOL_TRK_NT
 CAP_NT       = LI.4.CAPACITY 
 TIME_NT      = LI.4.TIME_1
 
 ; Daily
 VOL_TRK_DAILY = VOL_TRK_AM + VOL_TRK_MD + VOL_TRK_PM + VOL_TRK_NT
 VOL_AUTO_DAILY = VOL_AUTO_AM + VOL_AUTO_MD + VOL_AUTO_PM + VOL_AUTO_NT
 VOL_TOT_DAILY = VOL_TOT_AM + VOL_TOT_MD + VOL_TOT_PM + VOL_TOT_NT

 IF (VOL_TOT_DAILY > 0) 
  CSPD_DAILY = (VOL_TOT_AM * CSPD_AM + VOL_TOT_MD * CSPD_MD + VOL_TOT_PM * CSPD_PM + VOL_TOT_NT * CSPD_NT)/VOL_TOT_DAILY
 ELSE 
  CSPD_DAILY = CSPD_MD
 ENDIF

 IF (COUNT <> 0 & LINKCLASS <>99 & LINKCLASS<>0)
   GEH=sqrt((((VOL_TOT_DAILY - COUNT)^2)/((VOL_TOT_DAILY + COUNT)/2)))
   VOL_DIFF = COUNT - VOL_TOT_DAILY
   VOL_DIFFSQ = VOL_DIFF ^ 2
   VOL_PER_DIFF = VOL_DIFF / COUNT
 ENDIF 
 
 ; develop some stats for easier reports
 VMT  = (VOL_TOT_DAILY)*distance
 VHT  = (VOL_TOT_DAILY)*(distance/CSPD_DAILY)
 AVMT = (VOL_AUTO_DAILY)*distance
 AVHT = (VOL_AUTO_DAILY)*(distance/CSPD_DAILY)
 TVMT = (VOL_TRK_DAILY)*distance
 TVHT = (VOL_TRK_DAILY)*(distance/CSPD_DAILY)
 
 VMT_DIFF = (VOL_TOT_DAILY)*distance - COUNT*distance
 VMT_DIFFSQ = VMT_DIFF ^ 2
 
 RATIO = 0

 IF (COUNT > 0) RATIO = VOL_TOT_DAILY / COUNT
 
ENDRUN


; Script for program NETWORK in file "D:\TourCast\MetCouncil_ABM03192015\CUBE\CANET00B.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK MSG='Export link dbf'
FILEO LINKO = "%SCENARIO_DIR%\HWY_LDNET_%ITER%_DAILY.dbf"
FILEI LINKI[1] = "%SCENARIO_DIR%\HWY_LDNET_%ITER%_DAILY.NET"


ENDRUN


; Script for program MATRIX in file "D:\TourCast\MetCouncil_ABM03192015\CUBE\CAMAT00A.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Export to csv'
FILEI DBI[1] = "%SCENARIO_DIR%\HWY_LDNET_%ITER%_DAILY.dbf"
FILEO PRINTO[1] = "%SCENARIO_DIR%\HWY_LDNET_%ITER%_DAILY.csv"

  zones = 1
 
  ; Loop through database and write out
 LOOP k=1,DBI.1.NUMRECORDS
  x=DBIReadRecord(1,k)


  PRINT CSV=T, LIST=DI.1.A(6), DI.1.B(6), DI.1.NC_NAME(20), DI.1.RCI(2), DI.1.AREA(2), DI.1.COUNTY(2), DI.1.SCREENLINE(2), 
                  DI.1.DISTANCE(9.6), DI.1.LANES(1), (DI.1.DISTANCE * DI.1.LANES)(9.6), 
                  DI.1.COUNT(11.5), DI.1.VOL_TOT_DAI(9.4), DI.1.VOL_TRK_DAI(9.4), DI.1.VOL_AUTO_DA(9.4), 
                  (DI.1.COUNT * DI.1.DISTANCE)(11.5), DI.1.VMT(10.4), 
                  DI.1.TVMT(10.4), DI.1.AVMT(10.4), DI.1.VHT(10.4), DI.1.TVHT(10.4), DI.1.AVHT(10.4), 
                  DI.1.CSPD_DAILY(4.2), (DI.1.VHT*60/DI.1.VOL_TOT_DAI), DI.1.GEH(4.2), 
                  DI.1.VOL_TOT_AM(9.4), DI.1.VOL_TOT_MD(9.4), DI.1.VOL_TOT_PM(9.4), DI.1.VOL_TOT_NT(9.4),
                  DI.1.AM_CNT(9.4), DI.1.MD_CNT(9.4), DI.1.PM_CNT(9.4), DI.1.NT_CNT(9.4), DI.1.VOL_DIFFSQ(10.4), DI.1.VMT_DIFFSQ(10.4) PRINTO=1

;ENDIF
 ENDLOOP

ENDRUN


