RUN PGM = MATRIX MSG='Prepare Skims for ActivitySim'
FILEI MATI[1] = "%SCENARIO_DIR%\HWY_SKIM_%PREV_ITER%_AM.skm"
FILEI MATI[2] = "%SCENARIO_DIR%\HWY_SKIM_%PREV_ITER%_MD.skm"
FILEI MATI[3] = "%SCENARIO_DIR%\HWY_SKIM_%PREV_ITER%_PM.skm"
FILEI MATI[4] = "%SCENARIO_DIR%\HWY_SKIM_%PREV_ITER%_NT.skm"
FILEI MATI[5] = "%SCENARIO_DIR%\XIT_WK_SKIM_%PREV_ITER%_PK.skm"
FILEI MATI[6] = "%SCENARIO_DIR%\XIT_WK_SKIM_%PREV_ITER%_OP.skm"
FILEI MATI[7] = "%SCENARIO_DIR%\XIT_DR_SKIM_%PREV_ITER%_PK.skm"
FILEI MATI[8] = "%SCENARIO_DIR%\XIT_DR_SKIM_%PREV_ITER%_OP.skm"
FILEO MATO[1] = "%SCENARIO_DIR%\allskims_%PREV_ITER%.mat" MO=112-148, 1-155, 155 NAME=SOV_P_TIME__EA,
	SOV_P_TOLL__EA, SOV_N_TIME__EA, SOV_N_TOLL__EA, SOV_DIST__EA, HOV2_P_TIME__EA, HOV2_P_TOLL__EA, HOV2_N_TIME__EA, 
	HOV2_N_TOLL__EA, HOV2_DIST__EA, HOV3_P_TIME__EA, HOV3_P_TOLL__EA, HOV3_N_TIME__EA, HOV3_N_TOLL__EA, HOV3_DIST__EA, 
	WLK_TRN_IVT__EA, WLK_TRN_ACC__EA, WLK_TRN_WLKXFER__EA, WLK_TRN_WLKEGR__EA, WLK_TRN_IWAIT__EA, WLK_TRN_XWAIT__EA, 
	WLK_TRN_XFERS__EA, WLK_TRN_FARE__EA, WLK_TRN_FAREP__EA, WLK_TRN_FARER__EA, WLK_TRN_FARES__EA, DRV_TRN_IVT__EA, 
	DRV_TRN_DRACC__EA, DRV_TRN_WLKXFER__EA, DRV_TRN_WLKEGR__EA, DRV_TRN_IWAIT__EA, DRV_TRN_XWAIT__EA, DRV_TRN_XFERS__EA,
	DRV_TRN_FARE__EA, DRV_TRN_FAREP__EA, DRV_TRN_FARER__EA, DRV_TRN_FARES__EA, SOV_P_TIME__AM, SOV_P_TOLL__AM,
	SOV_N_TIME__AM, SOV_N_TOLL__AM, SOV_DIST__AM, HOV2_P_TIME__AM, HOV2_P_TOLL__AM, HOV2_N_TIME__AM, HOV2_N_TOLL__AM, HOV2_DIST__AM,
	HOV3_P_TIME__AM, HOV3_P_TOLL__AM, HOV3_N_TIME__AM, HOV3_N_TOLL__AM, HOV3_DIST__AM, WLK_TRN_IVT__AM, WLK_TRN_ACC__AM,
	WLK_TRN_WLKXFER__AM, WLK_TRN_WLKEGR__AM, WLK_TRN_IWAIT__AM, WLK_TRN_XWAIT__AM, WLK_TRN_XFERS__AM, WLK_TRN_FARE__AM, 
	WLK_TRN_FAREP__AM, WLK_TRN_FARER__AM, WLK_TRN_FARES__AM, DRV_TRN_IVT__AM, DRV_TRN_DRACC__AM, DRV_TRN_WLKXFER__AM,
	DRV_TRN_WLKEGR__AM, DRV_TRN_IWAIT__AM, DRV_TRN_XWAIT__AM, DRV_TRN_XFERS__AM, DRV_TRN_FARE__AM, DRV_TRN_FAREP__AM, 
	DRV_TRN_FARER__AM, DRV_TRN_FARES__AM, SOV_P_TIME__MD, SOV_P_TOLL__MD, SOV_N_TIME__MD, SOV_N_TOLL__MD, SOV_DIST__MD,
	HOV2_P_TIME__MD, HOV2_P_TOLL__MD, HOV2_N_TIME__MD, HOV2_N_TOLL__MD, HOV2_DIST__MD, HOV3_P_TIME__MD, HOV3_P_TOLL__MD,
	HOV3_N_TIME__MD, HOV3_N_TOLL__MD, HOV3_DIST__MD, WLK_TRN_IVT__MD, WLK_TRN_ACC__MD, WLK_TRN_WLKXFER__MD, WLK_TRN_WLKEGR__MD,
	WLK_TRN_IWAIT__MD, WLK_TRN_XWAIT__MD, WLK_TRN_XFERS__MD, WLK_TRN_FARE__MD, WLK_TRN_FAREP__MD, WLK_TRN_FARER__MD, 
	WLK_TRN_FARES__MD, DRV_TRN_IVT__MD, DRV_TRN_DRACC__MD, DRV_TRN_WLKXFER__MD, DRV_TRN_WLKEGR__MD, DRV_TRN_IWAIT__MD,
	DRV_TRN_XWAIT__MD, DRV_TRN_XFERS__MD, DRV_TRN_FARE__MD, DRV_TRN_FAREP__MD, DRV_TRN_FARER__MD, DRV_TRN_FARES__MD, SOV_P_TIME__PM, 
    SOV_P_TOLL__PM, SOV_N_TIME__PM, SOV_N_TOLL__PM, SOV_DIST__PM, HOV2_P_TIME__PM, HOV2_P_TOLL__PM,
	HOV2_N_TIME__PM, HOV2_N_TOLL__PM, HOV2_DIST__PM, HOV3_P_TIME__PM, HOV3_P_TOLL__PM, HOV3_N_TIME__PM, HOV3_N_TOLL__PM, 
	HOV3_DIST__PM, WLK_TRN_IVT__PM, WLK_TRN_ACC__PM, WLK_TRN_WLKXFER__PM, WLK_TRN_WLKEGR__PM, WLK_TRN_IWAIT__PM, 
	WLK_TRN_XWAIT__PM, WLK_TRN_XFERS__PM, WLK_TRN_FARE__PM, WLK_TRN_FAREP__PM, WLK_TRN_FARER__PM, WLK_TRN_FARES__PM, 
	DRV_TRN_IVT__PM, DRV_TRN_DRACC__PM, DRV_TRN_WLKXFER__PM, DRV_TRN_WLKEGR__PM, DRV_TRN_IWAIT__PM, DRV_TRN_XWAIT__PM,
	DRV_TRN_XFERS__PM, DRV_TRN_FARE__PM, DRV_TRN_FAREP__PM, DRV_TRN_FARER__PM, DRV_TRN_FARES__PM, SOV_P_TIME__NT,
	SOV_P_TOLL__NT, SOV_N_TIME__NT, SOV_N_TOLL__NT, SOV_DIST__NT, HOV2_P_TIME__NT, HOV2_P_TOLL__NT, HOV2_N_TIME__NT, 
	HOV2_N_TOLL__NT, HOV2_DIST__NT, HOV3_P_TIME__NT, HOV3_P_TOLL__NT, HOV3_N_TIME__NT, HOV3_N_TOLL__NT, HOV3_DIST__NT, 
	WLK_TRN_IVT__NT, WLK_TRN_ACC__NT, WLK_TRN_WLKXFER__NT, WLK_TRN_WLKEGR__NT, WLK_TRN_IWAIT__NT, WLK_TRN_XWAIT__NT, 
	WLK_TRN_XFERS__NT, WLK_TRN_FARE__NT, WLK_TRN_FAREP__NT, WLK_TRN_FARER__NT, WLK_TRN_FARES__NT, DRV_TRN_IVT__NT, 
	DRV_TRN_DRACC__NT, DRV_TRN_WLKXFER__NT, DRV_TRN_WLKEGR__NT, DRV_TRN_IWAIT__NT, DRV_TRN_XWAIT__NT, DRV_TRN_XFERS__NT,
	DRV_TRN_FARE__NT, DRV_TRN_FAREP__NT, DRV_TRN_FARER__NT, DRV_TRN_FARES__NT, DIST, DISTWALK, DISTBIKE, DRV_TRN_DRACCDIST__AM,
	 DRV_TRN_DRACCDIST__MD, DRV_TRN_DRACCDIST__PM, DRV_TRN_DRACCDIST__NT, DRV_TRN_DRACCDIST__EA
	
MW[1] = MI.1.daptime
MW[2] = MI.1.daptoll
MW[3] = MI.1.dantime
MW[4] = MI.1.dantoll
MW[5] = MI.1.dapdist
MW[6] = MI.1.a2ptime
MW[7] = MI.1.a2ptoll
MW[8] = MI.1.a2ntime
MW[9] = MI.1.a2ntoll
MW[10] = MI.1.a2pdist
MW[11] = MI.1.a3ptime
MW[12] = MI.1.a3ptoll
MW[13] = MI.1.a3ntime
MW[14] = MI.1.a3ntoll
MW[15] = MI.1.a3pdist
MW[16] = MI.5.TRNTIME
MW[17] = MI.5.WLKACC
MW[18] = MI.5.WLKXFER
MW[19] = MI.5.WLKEGR
MW[20] = MI.5.IWAIT
MW[21] = MI.5.XWAIT
MW[22] = MI.5.XFERS
MW[23] = MI.5.FARE
MW[24] = MI.5.FAREP
MW[25] = MI.5.FARER
MW[26] = MI.5.FARES
MW[27] = MI.7.TRNTIME
MW[28] = MI.7.DRACC
MW[29] = MI.7.WLKXFER
MW[30] = MI.7.WLKEGR
MW[31] = MI.7.IWAIT
MW[32] = MI.7.XWAIT
MW[33] = MI.7.XFERS
MW[34] = MI.7.FARE
MW[35] = MI.7.FAREP
MW[36] = MI.7.FARER
MW[37] = MI.7.FARES

MW[38] = MI.2.daptime
MW[39] = MI.2.daptoll
MW[40] = MI.2.dantime
MW[41] = MI.2.dantoll
MW[42] = MI.2.dapdist
MW[43] = MI.2.a2ptime
MW[44] = MI.2.a2ptoll
MW[45] = MI.2.a2ntime
MW[46] = MI.2.a2ntoll
MW[47] = MI.2.a2pdist
MW[48] = MI.2.a3ptime
MW[49] = MI.2.a3ptoll
MW[50] = MI.2.a3ntime
MW[51] = MI.2.a3ntoll
MW[52] = MI.2.a3pdist
MW[53] = MI.6.TRNTIME
MW[54] = MI.6.WLKACC
MW[55] = MI.6.WLKXFER
MW[56] = MI.6.WLKEGR
MW[57] = MI.6.IWAIT
MW[58] = MI.6.XWAIT
MW[59] = MI.6.XFERS
MW[60] = MI.6.FARE
MW[61] = MI.6.FAREP
MW[62] = MI.6.FARER
MW[63] = MI.6.FARES
MW[64] = MI.8.TRNTIME
MW[65] = MI.8.DRACC
MW[66] = MI.8.WLKXFER
MW[67] = MI.8.WLKEGR
MW[68] = MI.8.IWAIT
MW[69] = MI.8.XWAIT
MW[70] = MI.8.XFERS
MW[71] = MI.8.FARE
MW[72] = MI.8.FAREP
MW[73] = MI.8.FARER
MW[74] = MI.8.FARES

MW[75] = MI.3.daptime
MW[76] = MI.3.daptoll
MW[77] = MI.3.dantime
MW[78] = MI.3.dantoll
MW[79] = MI.3.dapdist
MW[80] = MI.3.a2ptime
MW[81] = MI.3.a2ptoll
MW[82] = MI.3.a2ntime
MW[83] = MI.3.a2ntoll
MW[84] = MI.3.a2pdist
MW[85] = MI.3.a3ptime
MW[86] = MI.3.a3ptoll
MW[87] = MI.3.a3ntime
MW[88] = MI.3.a3ntoll
MW[89] = MI.3.a3pdist
MW[90] = MI.5.TRNTIME.T
MW[91] = MI.5.WLKACC.T
MW[92] = MI.5.WLKXFER.T
MW[93] = MI.5.WLKEGR.T
MW[94] = MI.5.IWAIT.T
MW[95] = MI.5.XWAIT.T
MW[96] = MI.5.XFERS.T
MW[97] = MI.5.FARE.T
MW[98] = MI.5.FAREP.T
MW[99] = MI.5.FARER.T
MW[100] = MI.5.FARES.T
MW[101] = MI.7.TRNTIME.T
MW[102] = MI.7.DRACC.T
MW[103] = MI.7.WLKXFER.T
MW[104] = MI.7.WLKEGR.T
MW[105] = MI.7.IWAIT.T
MW[106] = MI.7.XWAIT.T
MW[107] = MI.7.XFERS.T
MW[108] = MI.7.FARE.T
MW[109] = MI.7.FAREP.T
MW[110] = MI.7.FARER.T
MW[111] = MI.7.FARES.T

MW[112] = MI.4.daptime
MW[113] = MI.4.daptoll
MW[114] = MI.4.dantime
MW[115] = MI.4.dantoll
MW[116] = MI.4.dapdist
MW[117] = MI.4.a2ptime
MW[118] = MI.4.a2ptoll
MW[119] = MI.4.a2ntime
MW[120] = MI.4.a2ntoll
MW[121] = MI.4.a2pdist
MW[122] = MI.4.a3ptime
MW[123] = MI.4.a3ptoll
MW[124] = MI.4.a3ntime
MW[125] = MI.4.a3ntoll
MW[126] = MI.4.a3pdist
MW[127] = MI.6.TRNTIME
MW[128] = MI.6.WLKACC
MW[129] = MI.6.WLKXFER
MW[130] = MI.6.WLKEGR
MW[131] = MI.6.IWAIT
MW[132] = MI.6.XWAIT
MW[133] = MI.6.XFERS
MW[134] = MI.6.FARE
MW[135] = MI.6.FAREP
MW[136] = MI.6.FARER
MW[137] = MI.6.FARES
MW[138] = MI.8.TRNTIME
MW[139] = MI.8.DRACC
MW[140] = MI.8.WLKXFER
MW[141] = MI.8.WLKEGR
MW[142] = MI.8.IWAIT
MW[143] = MI.8.XWAIT
MW[144] = MI.8.XFERS
MW[145] = MI.8.FARE
MW[146] = MI.8.FAREP
MW[147] = MI.8.FARER
MW[148] = MI.8.FARES
MW[149] = MI.1.dapdist
MW[150] = MI.1.dapdist
MW[151] = MI.1.dapdist

MW[152] = MI.7.DRACCDIST
MW[153] = MI.8.DRACCDIST
MW[154] = MI.7.DRACCDIST.T
MW[155] = MI.8.DRACC

ENDRUN

CONVERTMAT FROM="%SCENARIO_DIR%\allskims_%PREV_ITER%.mat" TO="%SCENARIO_DIR%\OMX\allskims.omx" COMPRESSION=4