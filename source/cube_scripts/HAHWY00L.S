RUN PGM=HIGHWAY MSG='Skim Assigned Network: %ASSIGNNAME%'
FILEI NETI = "%SCENARIO_DIR%\highway\HWY_LDNET_%ITER%_%PER%.NET"
FILEO MATO[1] = "%SCENARIO_DIR%\highway\HWY_SKIM_%ITER%_%PER%_%IC%.skm",
 MO=1-15, NAME=daptime, daptoll, dantime, dantoll, dapdist, a2ptime, a2ptoll, a2ntime, a2ntoll, a2pdist, 
  a3ptime, a3ptoll, a3ntime, a3ntoll, a3pdist
FILEI MATI[1] = "%SCENARIO_DIR%\highway\HWY_SKIM_%PREV_ITER%_%PER%_%IC%.skm"

DISTRIBUTEINTRASTEP ProcessID='Intrastep', ProcessList=1-%max_threads%

READ FILE = "%NETWORK_FOLDER%\%Assignment_Parameters%"

PHASE=LINKREAD

	; Initialize price array -------------------------------------------------
	ARRAY _PRICE_ARRAY = 500
	ARRAY _PRICE_INCREASE = 500

	; Set input variables ----------------------------------------------------
	T0 = LI.TIME_1
	;IF (LI.CAPACITY_%LPER%=0)
	;	T0 = 99999
	;ENDIF
	;C = LI.CAPACITY * %CAPFAC%
	;ALPHA = LI.ALPHA
	;BETA = LI.BETA
	LW.HOV = 0 ;LI.HOV
	LINKCLASS = LI.RCI
	DISTANCE = LI.DISTANCE

	LW.HOV_TIME_PNLTY = 0
	LW.TOLL_PRICE_SOV = 0
	LW.MNPASS_CODE = LI.MNPASS_CODE
	LW.MNPASS_PAY = LI.MNPASS_PAY
	IF (LW.MNPASS_PAY > 0)
		LW.TOLL_PRICE_SOV = 25
		LW.HOV_TIME_PNLTY = HOV_TIME_PENALTY
	ENDIF

	LW.TOLL_PRICE_HOV2 = LW.TOLL_PRICE_SOV
	LW.TOLL_PRICE_HOV3 = LW.TOLL_PRICE_SOV

	IF (HWY_TOLLSETTING == 2)
		LW.TOLL_PRICE_HOV2 = 0
		LW.TOLL_PRICE_HOV3 = 0
	ENDIF

	IF (HWY_TOLLSETTING == 3)
		LW.TOLL_PRICE_HOV3 = 0
	ENDIF

	; Create an HOV lane group and a no truck lane group ---------------------
	IF (LI.HOV_NO_MNPASS > 0) ADDTOGROUP = 1
	IF (LI.MNPASS_CODE > 0 || LI.HOV_NO_MNPASS > 0) ADDTOGROUP = 2
	
ENDPHASE

PROCESS PHASE = ILOOP
	; SOV w/transponder
	PATHLOAD PATH = LI.LW_PC_SOV_%IC%_1, CONSOLIDATE=T, EXCLUDEGRP = 1, 
		MW[101] = PATHTRACE(TIME), NOACCESS = 10000, 
		MW[102] = PATHTRACE(LI.LW_TOLL_SOV_1), NOACCESS = 0,
		MW[105] = PATHTRACE(LI.DISTANCE), NOACCESS = 10000
	; SOV no transponder
	PATHLOAD PATH = LI.LW_PC_SOV_%IC%_1, CONSOLIDATE=T, EXCLUDEGRP = 2, 
		MW[103] = PATHTRACE(TIME), NOACCESS = 10000,
		MW[104] = PATHTRACE(LI.LW_TOLL_SOV_1), NOACCESS = 0	
;daptime, daptoll, dantime, dantoll, dapdist,

	; SR2
	PATHLOAD PATH = LI.LW_PC_HOV2_%IC%_1, CONSOLIDATE=T,
		MW[106] = PATHTRACE(TIME), NOACCESS = 10000, 
		MW[107] = PATHTRACE(LI.LW_TOLL_HOV2_1), NOACCESS = 0,
		MW[110] = PATHTRACE(LI.DISTANCE), NOACCESS = 10000
	MW[109] = MW[107]
	MW[108] = MW[106]
	
	; SR3
	PATHLOAD PATH = LI.LW_PC_HOV3_%IC%_1, CONSOLIDATE=T,
		MW[111] = PATHTRACE(TIME), NOACCESS = 10000,
		MW[112] = PATHTRACE(LI.LW_TOLL_HOV3_1), NOACCESS = 0,
		MW[115] = PATHTRACE(LI.DISTANCE), NOACCESS = 10000
	MW[113] = MW[111]
	MW[114] = MW[112]
	
	mw[1] = MW[101] * (1/(%ITER%)) + MI.1.a2ptime * ((%ITER%-1)/(%ITER%))
    mw[2] = MW[102] * (1/(%ITER%)) + MI.1.a2ptoll * ((%ITER%-1)/(%ITER%))  
    mw[3] = MW[1]
    mw[4] = MW[2]
    mw[5] = MW[105] * (1/(%ITER%)) + MI.1.a2pdist * ((%ITER%-1)/(%ITER%))

    mw[1][I] = LOWEST(1,1,0.1,999,I)/2  
    mw[3][I] = LOWEST(3,1,0.1,999,I)/2      
    mw[5][I] = LOWEST(5,1,0.1,999,I)/2 
    
    ; SR2
    mw[6] = MW[106] * (1/(%ITER%)) + MI.1.a3ptime * ((%ITER%-1)/(%ITER%))
    mw[7] = MW[107] * (1/(%ITER%)) + MI.1.a3ptoll * ((%ITER%-1)/(%ITER%))
    mw[8] = MW[6]
    mw[9] = MW[7]
    mw[10] = MW[110] * (1/(%ITER%)) + MI.1.a3pdist * ((%ITER%-1)/(%ITER%))
    
	mw[6][I] = LOWEST(6,1,0.1,999,I)/2  
    mw[8][I] = LOWEST(8,1,0.1,999,I)/2      
    mw[10][I] = LOWEST(10,1,0.1,999,I)/2 
	
    ; SR3
    mw[11] = MW[111] * (1/(%ITER%)) + MI.1.daptime * ((%ITER%-1)/(%ITER%))
    mw[12] = MW[112] * (1/(%ITER%)) + MI.1.daptoll * ((%ITER%-1)/(%ITER%))
    mw[13] = MW[11]
    mw[14] = MW[12]
    mw[15] = MW[115] * (1/(%ITER%)) + MI.1.dapdist * ((%ITER%-1)/(%ITER%))  
	
	mw[11][I] = LOWEST(11,1,0.1,999,I)/2  
    mw[13][I] = LOWEST(13,1,0.1,999,I)/2      
    mw[15][I] = LOWEST(15,1,0.1,999,I)/2 
ENDPHASE

ENDRUN