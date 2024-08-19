; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=HIGHWAY MSG='Assignment Period: %ASSIGNNAME%' PRNFILE="%SCENARIO_DIR%\highway\hassign_%ITER%_PRN_%PER%.prn" 
FILEI NETI = "%NETWORK_FOLDER%\%HWY_NET%"
FILEI MATI[1] = "%SCENARIO_DIR%\highway\HWY_ASIM_TRIP_%ITER%_%PER%.TRP"
FILEI MATI[2] = "%SCENARIO_DIR%\truck\TRK_TRIP_%ITER%_%PER%.TRP"
FILEI MATI[3] = "%SCENARIO_DIR%\external\HWY_EXT_TRIP_%ITER%_%PER%.TRP"
FILEI MATI[4] = "%SCENARIO_DIR%\specialgen\HWY_SPC_AUTO_TRIP_%ITER%_%PER%.trp"
FILEO NETO = "%SCENARIO_DIR%\highway\HWY_LDNET_%ITER%_%PER%.NET", INCLUDE = LW.TOLL_SOV, LW.TOLL_HOV2, LW.TOLL_HOV3, 
	LW.PC_SOV_L, LW.PC_SOV_M, LW.PC_SOV_H, LW.PC_HOV2_L, LW.PC_HOV2_M, LW.PC_HOV2_H, LW.PC_HOV3_L, LW.PC_HOV3_M, 
	LW.PC_HOV3_H, LW.PC_TRK

DISTRIBUTEINTRASTEP ProcessID='Intrastep', ProcessList=1-%max_threads%

	; Read Parameter File
	READ FILE = "%NETWORK_FOLDER%\%Assignment_Parameters%"
	
    ; Define Assignment Parameters--------------------------------------------------

    ;PARAMETERS RAAD = 0.0001 GAP = 0.0001 RELATIVEGAP = 0.00001 AAD = 0.01 MAXITERS = %hwy_assignIters%
	PARAMETERS CONSOLIDATE=2 COMBINE = EQUI, ENHANCE = 2, MULTITHREAD = %max_threads%, MAXITERS = %hwy_assignIters%


	; Define toll price scheme (reported by MnDOT) ----------------------------------

    LOOKUP NAME=TOLL,
           LOOKUP[1]=1,
		   RESULT=2,
           INTERPOLATE=Y,
           FAIL=25,800,
           R = '0.00 25',                  ; LOS-Toll table reported by MnDOT
               '0.35 50',
               '0.54 150',
               '0.77 250',
               '0.93 350',
               '1.00 600'

    PHASE=LINKREAD

		; Initialize price array -------------------------------------------------
		ARRAY _PRICE_ARRAY = 500
		ARRAY _PRICE_INCREASE = 500

		; Set input variables ----------------------------------------------------
		LANES = LI.LANES_%LPER%
		C = LI.CAPACITY_%LPER% * %CAPFAC%
        T0 = LI.TIME
        IF (LI.CAPACITY_%LPER%=0)
            T0 = 99999
        ENDIF
		
        ALPHA = LI.ALPHA
        BETA = LI.BETA
		LW.HOV = 0 ;LI.HOV
        LINKCLASS = LI.RCI
		DISTANCE = LI.DISTANCE

		LW.HOV_TIME_PNLTY = 0
		LW.TOLL_SOV = 0
		LW.MNPASS_CODE = LI.MNPASS_CODE
		LW.MNPASS_PAY = LI.MNPASS_PAY
		IF (LW.MNPASS_PAY > 0)
		    LW.TOLL_SOV = 25
			LW.HOV_TIME_PNLTY = HOV_TIME_PENALTY
		ENDIF

		LW.TOLL_HOV2 = LW.TOLL_SOV
		LW.TOLL_HOV3 = LW.TOLL_SOV

		IF (HWY_TOLLSETTING == 2)
		    LW.TOLL_HOV2 = 0
			LW.TOLL_HOV3 = 0
		ENDIF

		IF (HWY_TOLLSETTING == 3)
		    LW.TOLL_HOV3 = 0
		ENDIF

		; Create an HOV lane group and a no truck lane group ---------------------
		IF (LI.HOV_NO_MNPASS > 0) ADDTOGROUP = 1 ;Group 1 - HOV lanes with no MNPASS lanes, currently we don't have any in our region
		IF (LI.MANAGED = 1 || LI.HOV_NO_MNPASS > 0) ADDTOGROUP = 2 ;Group 2 - Managed and HOV lanes restricted to SOV with no transponders and trucks

		; Generalized path cost expressions -------------------------------------
		LW.PC_SOV_L = T0 + (0.6 / VOT_INCOME_01) * ((DISTANCE * AUTO_PER_MILE_COST) + LW.TOLL_SOV)
		LW.PC_SOV_M = T0 + (0.6 / VOT_INCOME_02) * ((DISTANCE * AUTO_PER_MILE_COST) + LW.TOLL_SOV)
		LW.PC_SOV_H = T0 + (0.6 / VOT_INCOME_03) * ((DISTANCE * AUTO_PER_MILE_COST) + LW.TOLL_SOV)

		LW.PC_HOV2_L = T0 + (0.6 / VOT_INCOME_01) * ((DISTANCE * AUTO_PER_MILE_COST) + (LW.TOLL_HOV2 / HWY_HOV2OCC) + LW.HOV_TIME_PNLTY)
		LW.PC_HOV2_M = T0 + (0.6 / VOT_INCOME_02) * ((DISTANCE * AUTO_PER_MILE_COST) + (LW.TOLL_HOV2 / HWY_HOV2OCC) + LW.HOV_TIME_PNLTY)
		LW.PC_HOV2_H = T0 + (0.6 / VOT_INCOME_03) * ((DISTANCE * AUTO_PER_MILE_COST) + (LW.TOLL_HOV2 / HWY_HOV2OCC) + LW.HOV_TIME_PNLTY)

		LW.PC_HOV3_L = T0 + (0.6 / VOT_INCOME_01) * ((DISTANCE * AUTO_PER_MILE_COST) + (LW.TOLL_HOV3 / HWY_HOV3OCC) + LW.HOV_TIME_PNLTY)
		LW.PC_HOV3_M = T0 + (0.6 / VOT_INCOME_02) * ((DISTANCE * AUTO_PER_MILE_COST) + (LW.TOLL_HOV3 / HWY_HOV3OCC) + LW.HOV_TIME_PNLTY)
		LW.PC_HOV3_H = T0 + (0.6 / VOT_INCOME_03) * ((DISTANCE * AUTO_PER_MILE_COST) + (LW.TOLL_HOV3 / HWY_HOV3OCC) + LW.HOV_TIME_PNLTY)
		
		LW.PC_TRK = T0 + (0.6 / VOT_TRK) * DISTANCE * TRUCK_PER_MILE_COST
		
    ENDPHASE

    PHASE=ILOOP
	    ; Set demand matrices ----------------------------------------------------

	    ; SOV, Income 1
	    MW[1] = MI.1.1

		; SOV, Income 2
		MW[2] = MI.1.2 

		; SOV, Income 3
		MW[3] = MI.1.3 

		; HOV2, Income 1
		MW[4] = MI.1.4 

		; HOV2, Income 2
		MW[5] = MI.1.5 

		; HOV2, Income 3
		MW[6] = MI.1.6 

		; HOV3, Income 1
		MW[7] = MI.1.7

		; HOV3, Income 2
		MW[8] = MI.1.8

		; HOV3, Income 3
		MW[9] = MI.1.9
		
		; SOV, no transponders, Income 1
		MW[10] = MI.1.10
		
		; SOV, no transponders, Income 2
		MW[11] = MI.1.11
		
		; SOV, no transponders, Income 3
		MW[12] = MI.1.12

		; SOV, externals, special generators
		MW[13] = MI.3.1 + MI.4.1

		; HOV2, externals, special generators
		MW[14] = MI.3.2 + MI.4.2

		; HOV3, externals, special generators
		MW[15] = MI.3.3 + MI.4.3

		; Trucks
		MW[16] = MI.2.3

		; SOV w/transponder
		PATHLOAD PATH = LW.PC_SOV_L, CONSOLIDATE=T, VOL[1] = MW[1], EXCLUDEGRP = 1
		PATHLOAD PATH = LW.PC_SOV_M, CONSOLIDATE=T, VOL[2] = MW[2], EXCLUDEGRP = 1
		PATHLOAD PATH = LW.PC_SOV_H, CONSOLIDATE=T, VOL[3] = MW[3], EXCLUDEGRP = 1
		; SR2
		PATHLOAD PATH = LW.PC_HOV2_L, CONSOLIDATE=T, VOL[4] = MW[4]
		PATHLOAD PATH = LW.PC_HOV2_M, CONSOLIDATE=T, VOL[5] = MW[5]
		PATHLOAD PATH = LW.PC_HOV2_H, CONSOLIDATE=T, VOL[6] = MW[6]
		; SR3
		PATHLOAD PATH = LW.PC_HOV3_L, CONSOLIDATE=T, VOL[7] = MW[7]
		PATHLOAD PATH = LW.PC_HOV3_M, CONSOLIDATE=T, VOL[8] = MW[8]
		PATHLOAD PATH = LW.PC_HOV3_H, CONSOLIDATE=T, VOL[9] = MW[9]
		; SOV no transponder
		PATHLOAD PATH = LW.PC_SOV_L, CONSOLIDATE=T, VOL[10] = MW[10], EXCLUDEGRP = 2
		PATHLOAD PATH = LW.PC_SOV_M, CONSOLIDATE=T, VOL[11] = MW[11], EXCLUDEGRP = 2
		PATHLOAD PATH = LW.PC_SOV_H, CONSOLIDATE=T, VOL[12] = MW[12], EXCLUDEGRP = 2
		; Ext, Spec Gen (SOV, SR2, SR3)
		PATHLOAD PATH = LW.PC_SOV_L, CONSOLIDATE=T, VOL[13] = MW[13]
		PATHLOAD PATH = LW.PC_SOV_M, CONSOLIDATE=T, VOL[14] = MW[14]
		PATHLOAD PATH = LW.PC_SOV_H, CONSOLIDATE=T, VOL[15] = MW[15]
		; Trucks
		PATHLOAD PATH = LW.PC_TRK, CONSOLIDATE=T, VOL[16] = MW[16], EXCLUDEGRP = 2

    ENDPHASE    ; ILOOP

    PHASE=ADJUST
		FUNCTION V = VOL[1] + VOL[2] + VOL[3] + VOL[4] + VOL[5] +
					 VOL[6] + VOL[7] + VOL[8] + VOL[9] + VOL[10] +
					 VOL[11] + VOL[12] + VOL[13] + VOL[14] + VOL[15] +
					 VOL[16] * HWY_TRKFAC
					 
		FUNCTION TC[1] = T0 * (1 + ALPHA*(V/C)^(BETA))
		FUNCTION TC[2] = T0 * (1 + ALPHA*(V/C)^(BETA))
		FUNCTION TC[3] = T0 * (1 + ALPHA*(V/C)^(BETA))
		FUNCTION TC[4] = T0 * (1 + ALPHA*(V/C)^(BETA))
		FUNCTION TC[5] = T0 * (1 + ALPHA*(V/C)^(BETA))
		FUNCTION TC[6] = T0 * (1 + ALPHA*(V/C)^(BETA))
		FUNCTION TC[7] = T0 * (1 + ALPHA*(V/C)^(BETA))
		FUNCTION TC[8] = T0 * (1 + ALPHA*(V/C)^(BETA))
		FUNCTION TC[9] = T0 * (1 + ALPHA*(V/C)^(BETA))
		FUNCTION TC[10] = T0 * (1 + ALPHA*(V/C)^(BETA))
		FUNCTION TC[11] = T0 * (1 + ALPHA*(V/C)^(BETA))
		FUNCTION TC[12] = T0 * (1 + ALPHA*(V/C)^(BETA))
		FUNCTION TC[13] = T0 * (1 + ALPHA*(V/C)^(BETA))
		FUNCTION TC[14] = T0 * (1 + ALPHA*(V/C)^(BETA))
		FUNCTION TC[15] = T0 * (1 + ALPHA*(V/C)^(BETA))
		FUNCTION TC[99] = T0 ;* (1 + ALPHA*(V/C)^(BETA))

		
	    ; Header for CSV ----------------------------------------------------------
		; IF (LINKNO == 1 && ITERATION == 1)
		    ; PRINT CSV=T LIST='Iteration,ANode,BNode,MNPASS_CODE,MNPASS_PAY,HOV,Volume,VC,TIME,DISTANCE,VHT,VMT,PRICE' PRINTO=1
		; ENDIF
		
; Reset the price increase indicator --------------------------------------
		IF (LINKNO == 1)
		    LOOP K = 1,500,1
			    _PRICE_INCREASE[K] = 0
		    ENDLOOP
		ENDIF

		; Update toll price -------------------------------------------------------
		IF (LW.MNPASS_CODE > 0 && C > 0)
		    _PRICE = TOLL(1,(V/C))

			IF (_PRICE > _PRICE_ARRAY[LW.MNPASS_CODE])

			    IF (_PRICE_INCREASE[LW.MNPASS_CODE] == 0)

				    _PRICE_INCREASE[LW.MNPASS_CODE] = 1
					_PRICE_ARRAY[LW.MNPASS_CODE] = _PRICE_ARRAY[LW.MNPASS_CODE] + 25

					IF ((_PRICE - _PRICE_INCREASE[LW.MNPASS_CODE]) > 200)
					    _PRICE_ARRAY[LW.MNPASS_CODE] = _PRICE_ARRAY[LW.MNPASS_CODE] + 25
					ENDIF

					IF (_PRICE_ARRAY[LW.MNPASS_CODE] > MAX_TOLL_PRICE)
						_PRICE_ARRAY[LW.MNPASS_CODE] = MAX_TOLL_PRICE
					ENDIF

				ENDIF

			ENDIF

			IF (LW.MNPASS_PAY > 0)
			    LW.TOLL_SOV = _PRICE_ARRAY[LW.MNPASS_PAY]
			ENDIF

			LW.TOLL_HOV2 = LW.TOLL_SOV
			LW.TOLL_HOV3 = LW.TOLL_SOV
			IF (HWY_TOLLSETTING == 2)
			    LW.TOLL_HOV2 = 0
				LW.TOLL_HOV3 = 0
			ENDIF
			IF (HWY_TOLLSETTING == 3)
			    LW.TOLL_HOV3 = 0
			ENDIF

		ENDIF
		
		; Update generalized cost functions ---------------------------------------
		LW.PC_SOV_L = TIME + (0.6 / VOT_INCOME_01) * (DISTANCE * AUTO_PER_MILE_COST + LW.TOLL_SOV)
		LW.PC_SOV_M = TIME + (0.6 / VOT_INCOME_02) * (DISTANCE * AUTO_PER_MILE_COST + LW.TOLL_SOV)
		LW.PC_SOV_H = TIME + (0.6 / VOT_INCOME_03) * (DISTANCE * AUTO_PER_MILE_COST + LW.TOLL_SOV)

		LW.PC_HOV2_L = TIME + (0.6 / VOT_INCOME_01) * (DISTANCE * AUTO_PER_MILE_COST + LW.TOLL_HOV2 / HWY_HOV2OCC) + LW.HOV_TIME_PNLTY
		LW.PC_HOV2_M = TIME + (0.6 / VOT_INCOME_02) * (DISTANCE * AUTO_PER_MILE_COST + LW.TOLL_HOV2 / HWY_HOV2OCC) + LW.HOV_TIME_PNLTY
		LW.PC_HOV2_H = TIME + (0.6 / VOT_INCOME_03) * (DISTANCE * AUTO_PER_MILE_COST + LW.TOLL_HOV2 / HWY_HOV2OCC) + LW.HOV_TIME_PNLTY

		LW.PC_HOV3_L = TIME + (0.6 / VOT_INCOME_01) * (DISTANCE * AUTO_PER_MILE_COST + LW.TOLL_HOV3 / HWY_HOV3OCC) + LW.HOV_TIME_PNLTY
		LW.PC_HOV3_M = TIME + (0.6 / VOT_INCOME_02) * (DISTANCE * AUTO_PER_MILE_COST + LW.TOLL_HOV3 / HWY_HOV3OCC) + LW.HOV_TIME_PNLTY
		LW.PC_HOV3_H = TIME + (0.6 / VOT_INCOME_03) * (DISTANCE * AUTO_PER_MILE_COST + LW.TOLL_HOV3 / HWY_HOV3OCC) + LW.HOV_TIME_PNLTY

		LW.PC_TRK = TIME + (0.6 / VOT_TRK) * DISTANCE * TRUCK_PER_MILE_COST

		;FUNCTION COST= ((TIME + DIST_COST_LOV * LI.DISTANCE) * V1 + (TIME + DIST_COST_HOV * LI.DISTANCE) * V2) / CmpNumRetNum(V,'=',0,1,V)

		; Debug print -------------------------------------------------------------
		; IF (LW.HOV > 0 || LW.MNPASS_PAY > 0)
		    ; PRINT CSV = T LIST = iteration(2.0),
			                     ; A(6.0),
								 ; B(6.0),
								 ; LW.MNPASS_CODE(4.0),
								 ; LW.MNPASS_PAY(4.0),
								 ; LW.HOV(4.0),
								 ; V(8.2),
								 ; V/C(8.42),
								 ; TIME(5.2),
								 ; DISTANCE(5.2),
								 ; V*TIME(15.2),
								 ; V*DISTANCE(15.2),
								 ; LW.TOLL_PRICE_SOV(8.2) PRINTO = 1
		; ENDIF

		; ASR Debugging
		; PRINT PRINTO=1 CSV=T LIST=ITERATION,A,B,LINKCLASS,V,C,TIME,VOL[1],VOL[2],VOL[3],VOL[4],VOL[5],VOL[6],VOL[7],VOL[8],VOL[9],VOL[10],
			; VOL[11],VOL[12],VOL[13],VOL[14],VOL[15],VOL[16],LW.PATHCOST_SOV_L,LW.PATHCOST_SOV_M,LW.PATHCOST_SOV_H,LW.PATHCOST_HOV2_L,
			; LW.PATHCOST_HOV2_M,LW.PATHCOST_HOV2_H,LW.PATHCOST_HOV3_L,LW.PATHCOST_HOV3_M,LW.PATHCOST_HOV3_H,LW.PATHCOST_TRK


    ENDPHASE
	
	PHASE=CONVERGE
		IF (ITERATION < 10) BREAK ; Minimum of 10 iterations
		IF (RGAP < 0.00001 || ITERATION >= %hwy_assignIters%) 
			; Save the toll prices and path costs for skimming in the next step
			BALANCE = 1
			BREAK
		ENDIF
	ENDPHASE


ENDRUN
