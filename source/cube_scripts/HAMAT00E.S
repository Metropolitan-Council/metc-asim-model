; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Aggregate Trip Tables for Interm Assignment'
DISTRIBUTEINTRASTEP ProcessID='Intrastep', ProcessList=1-%max_threads%
FILEI MATI[1] = "%SCENARIO_DIR%\highway\HWY_ASIM_TRIP_%ITER%_AM1.TRP"				 
FILEI MATI[2] = "%SCENARIO_DIR%\highway\HWY_ASIM_TRIP_%ITER%_AM2.TRP"
FILEI MATI[3] = "%SCENARIO_DIR%\highway\HWY_ASIM_TRIP_%ITER%_AM3.TRP"
FILEI MATI[4] = "%SCENARIO_DIR%\highway\HWY_ASIM_TRIP_%ITER%_AM4.TRP"
FILEI MATI[5] = "%SCENARIO_DIR%\highway\HWY_ASIM_TRIP_%ITER%_MD.TRP"
FILEI MATI[6] = "%SCENARIO_DIR%\highway\HWY_ASIM_TRIP_%ITER%_PM1.TRP"
FILEI MATI[7] = "%SCENARIO_DIR%\highway\HWY_ASIM_TRIP_%ITER%_PM2.TRP"
FILEI MATI[8] = "%SCENARIO_DIR%\highway\HWY_ASIM_TRIP_%ITER%_PM3.TRP"
FILEI MATI[9] = "%SCENARIO_DIR%\highway\HWY_ASIM_TRIP_%ITER%_PM4.TRP"
FILEI MATI[10] = "%SCENARIO_DIR%\highway\HWY_ASIM_TRIP_%ITER%_EV.TRP"
FILEI MATI[11] = "%SCENARIO_DIR%\highway\HWY_ASIM_TRIP_%ITER%_ON.TRP"
FILEO MATO[1] = "%SCENARIO_DIR%\highway\HWY_TRIP_%ITER%_AM.TRP",
                 MO=1-12, DEC[1]=12*2, 
                 NAME = SOV_T_L, SOV_T_M, SOV_T_H,
                 HOV2_L, HOV2_M, HOV2_H, 
                 HOV3_L, HOV3_M, HOV3_H, 
                 SOV_N_L,SOV_N_M,SOV_N_H
FILEO MATO[2] = "%SCENARIO_DIR%\highway\HWY_TRIP_%ITER%_MD.TRP",
                 MO=13-24, DEC[1]=12*2, 
                 NAME = SOV_T_L, SOV_T_M, SOV_T_H,
                 HOV2_L, HOV2_M, HOV2_H, 
                 HOV3_L, HOV3_M, HOV3_H, 
                 SOV_N_L,SOV_N_M,SOV_N_H
FILEO MATO[3] = "%SCENARIO_DIR%\highway\HWY_TRIP_%ITER%_PM.TRP",
                 MO=25-36, DEC[1]=12*2, 
                 NAME = SOV_T_L, SOV_T_M, SOV_T_H,
                 HOV2_L, HOV2_M, HOV2_H, 
                 HOV3_L, HOV3_M, HOV3_H, 
                 SOV_N_L,SOV_N_M,SOV_N_H
FILEO MATO[4] = "%SCENARIO_DIR%\highway\HWY_TRIP_%ITER%_NT.TRP",
                 MO=37-48, DEC[1]=12*2, 
                 NAME = SOV_T_L, SOV_T_M, SOV_T_H,
                 HOV2_L, HOV2_M, HOV2_H, 
                 HOV3_L, HOV3_M, HOV3_H, 
                 SOV_N_L,SOV_N_M,SOV_N_H

    ; AM Period - SOV w/transponder (MI 1-4)
	MW[1] = MI.1.4 + MI.2.4 + MI.3.4 + MI.4.4 + MI.1.10 + MI.2.10 + MI.3.10 + MI.4.10
	MW[2] = MI.1.5 + MI.2.5 + MI.3.5 + MI.4.5 + MI.1.11 + MI.2.11 + MI.3.11 + MI.4.11
	MW[3] = MI.1.6 + MI.2.6 + MI.3.6 + MI.4.6 + MI.1.12 + MI.2.12 + MI.3.12 + MI.4.12
	; AM S2
	MW[4] = MI.1.13 + MI.2.13 + MI.3.13 + MI.4.13 + MI.1.16 + MI.2.16 + MI.3.16 + MI.4.16 + 
		MI.1.19 + MI.2.19 + MI.3.19 + MI.4.19 + MI.1.22 + MI.2.22 + MI.3.22 + MI.4.22
	MW[5] = MI.1.14 + MI.2.14 + MI.3.14 + MI.4.14 + MI.1.17 + MI.2.17 + MI.3.17 + MI.4.17 + 
		MI.1.20 + MI.2.20 + MI.3.20 + MI.4.20 + MI.1.23 + MI.2.23 + MI.3.23 + MI.4.23
	MW[6] = MI.1.15 + MI.2.15 + MI.3.15 + MI.4.15 + MI.1.18 + MI.2.18 + MI.3.18 + MI.4.18 + 
		MI.1.21 + MI.2.21 + MI.3.21 + MI.4.21 + MI.1.24 + MI.2.24 + MI.3.24 + MI.4.24
	; AM S3
	MW[7] = MI.1.25 + MI.2.25 + MI.3.25 + MI.4.25 + MI.1.28 + MI.2.28 + MI.3.28 + MI.4.28 +
		MI.1.31 + MI.2.31 + MI.3.31 + MI.4.31 + MI.1.34 + MI.2.34 + MI.3.34 + MI.4.34
	MW[8] = MI.1.26 + MI.2.26 + MI.3.26 + MI.4.26 + MI.1.29 + MI.2.29 + MI.3.29 + MI.4.29 +
		MI.1.32 + MI.2.32 + MI.3.32 + MI.4.32 + MI.1.35 + MI.2.35 + MI.3.35 + MI.4.35
	MW[9] = MI.1.27 + MI.2.27 + MI.3.27 + MI.4.27 + MI.1.30 + MI.2.30 + MI.3.30 + MI.4.30 +
		MI.1.33 + MI.2.33 + MI.3.33 + MI.4.33 + MI.1.36 + MI.2.36 + MI.3.36 + MI.4.36
	; AM SOV no transponder
	MW[10] = MI.1.1 + MI.2.1 + MI.3.1 + MI.4.1 + MI.1.7 + MI.2.7 + MI.3.7 + MI.4.7
	MW[11] = MI.1.2 + MI.2.2 + MI.3.2 + MI.4.2 + MI.1.8 + MI.2.8 + MI.3.8 + MI.4.8
	MW[12] = MI.1.3 + MI.2.3 + MI.3.3 + MI.4.3 + MI.1.9 + MI.2.9 + MI.3.9 + MI.4.9
	
	; MD Period - SOV w/transponder (MI 5)
	MW[13] = MI.5.4 + MI.5.10
	MW[14] = MI.5.5 + MI.5.11 
	MW[15] = MI.5.6 + MI.5.12
	; MD S2
	MW[16] = MI.5.13 + MI.5.16 + MI.5.19 + MI.5.22
	MW[17] = MI.5.14 + MI.5.17 + MI.5.20 + MI.5.23 
	MW[18] = MI.5.15 + MI.5.18 + MI.5.21 + MI.5.24 
	; MD S3
	MW[19] = MI.5.25 + MI.5.28 + MI.5.31 + MI.5.34
	MW[20] = MI.5.26 + MI.5.29 + MI.5.32 + MI.5.35
	MW[21] = MI.5.27 + MI.5.30 + MI.5.33 + MI.5.36
	; MD SOV no transponder
	MW[22] = MI.5.1 + MI.5.7
	MW[23] = MI.5.2 + MI.5.8
	MW[24] = MI.5.3 + MI.5.9
	
	; PM Period - SOV w/transponder (MI 6-9)
	MW[25] = MI.6.4 + MI.7.4 + MI.8.4 + MI.9.4 + MI.6.10 + MI.7.10 + MI.8.10 + MI.9.10
	MW[26] = MI.6.5 + MI.7.5 + MI.8.5 + MI.9.5 + MI.6.11 + MI.7.11 + MI.8.11 + MI.9.11
	MW[27] = MI.6.6 + MI.7.6 + MI.8.6 + MI.9.6 + MI.6.12 + MI.7.12 + MI.8.12 + MI.9.12
	; PM S2
	MW[28] = MI.6.13 + MI.7.13 + MI.8.13 + MI.9.13 + MI.6.16 + MI.7.16 + MI.8.16 + MI.9.16 + 
		MI.6.19 + MI.7.19 + MI.8.19 + MI.9.19 + MI.6.22 + MI.7.22 + MI.8.22 + MI.9.22
	MW[29] = MI.6.14 + MI.7.14 + MI.8.14 + MI.9.14 + MI.6.17 + MI.7.17 + MI.8.17 + MI.9.17 + 
		MI.6.20 + MI.7.20 + MI.8.20 + MI.9.20 + MI.6.23 + MI.7.23 + MI.8.23 + MI.9.23
	MW[30] = MI.6.15 + MI.7.15 + MI.8.15 + MI.9.15 + MI.6.18 + MI.7.18 + MI.8.18 + MI.9.18 + 
		MI.6.21 + MI.7.21 + MI.8.21 + MI.9.21 + MI.6.24 + MI.7.24 + MI.8.24 + MI.9.24
	; PM S3
	MW[31] = MI.6.25 + MI.7.25 + MI.8.25 + MI.9.25 + MI.6.28 + MI.7.28 + MI.8.28 + MI.9.28 +
		MI.6.31 + MI.7.31 + MI.8.31 + MI.9.31 + MI.6.34 + MI.7.34 + MI.8.34 + MI.9.34
	MW[32] = MI.6.26 + MI.7.26 + MI.8.26 + MI.9.26 + MI.6.29 + MI.7.29 + MI.8.29 + MI.9.29 +
		MI.6.32 + MI.7.32 + MI.8.32 + MI.9.32 + MI.6.35 + MI.7.35 + MI.8.35 + MI.9.35
	MW[33] = MI.6.27 + MI.7.27 + MI.8.27 + MI.9.27 + MI.6.30 + MI.7.30 + MI.8.30 + MI.9.30 +
		MI.6.33 + MI.7.33 + MI.8.33 + MI.9.33 + MI.6.36 + MI.7.36 + MI.8.36 + MI.9.36
	; PM SOV no transponder
	MW[34] = MI.6.1 + MI.7.1 + MI.8.1 + MI.9.1 + MI.6.7 + MI.7.7 + MI.8.7 + MI.9.7
	MW[35] = MI.6.2 + MI.7.2 + MI.8.2 + MI.9.2 + MI.6.8 + MI.7.8 + MI.8.8 + MI.9.8
	MW[36] = MI.6.3 + MI.7.3 + MI.8.3 + MI.9.3 + MI.6.9 + MI.7.9 + MI.8.9 + MI.9.9
	
	; NT Period - SOV w/transponder (MI 10-11)
	MW[37] = MI.10.4 + MI.11.4 + MI.10.10 + MI.11.10
	MW[38] = MI.10.5 + MI.11.5 + MI.10.11 + MI.11.11
	MW[39] = MI.10.6 + MI.11.6 + MI.10.12 + MI.11.12
	; NT S2
	MW[40] = MI.10.13 + MI.11.13 + MI.10.16 + MI.11.16 + MI.10.19 + MI.11.19 + MI.10.22 + MI.11.22 
	MW[41] = MI.10.14 + MI.11.14 + MI.10.17 + MI.11.17 + MI.10.20 + MI.11.20 + MI.10.23 + MI.11.23
	MW[42] = MI.10.15 + MI.11.15 + MI.10.18 + MI.11.18 + MI.10.21 + MI.11.21 + MI.10.24 + MI.11.24
	; NT S3
	MW[43] = MI.10.25 + MI.11.25 + MI.10.28 + MI.11.28 + MI.10.31 + MI.11.31 + MI.10.34 + MI.11.34
	MW[44] = MI.10.26 + MI.11.26 + MI.10.29 + MI.11.29 + MI.10.32 + MI.11.32 + MI.10.35 + MI.11.35
	MW[45] = MI.10.27 + MI.11.27 + MI.10.30 + MI.11.30 + MI.10.33 + MI.11.33 + MI.10.36 + MI.11.36
	; NT SOV no transponder
	MW[46] = MI.10.1 + MI.11.1 + MI.10.7 + MI.11.7
	MW[47] = MI.10.2 + MI.11.2 + MI.10.8 + MI.11.8
	MW[48] = MI.10.3 + MI.11.3 + MI.10.9 + MI.11.9

ENDRUN
