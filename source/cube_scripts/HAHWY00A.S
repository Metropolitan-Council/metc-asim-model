; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=HIGHWAY MSG='Assignment Period: %ASSIGNNAME%'
FILEI NETI = "%NETWORK_FOLDER%\%HWY_NET%"
FILEI MATI[1] = "%SCENARIO_DIR%\highway\HWY_TRIP_%ITER%_%PER%.TRP"
FILEI MATI[2] = "%SCENARIO_DIR%\truck\TRK_TRIP_%ITER%_%PER%.TRP"
FILEI MATI[3] = "%SCENARIO_DIR%\external\HWY_EXT_TRIP_%ITER%_%PER%.TRP"
FILEI MATI[4] = "%SCENARIO_DIR%\specialgen\HWY_SPC_AUTO_TRIP_%ITER%_%PER%.trp"
FILEO MATO[1] = "%SCENARIO_DIR%\highway\HWY_SKIM_%ITER%_%PER%.tmp", MO=21-24
FILEO PRINTO[1] = "%SCENARIO_DIR%\highway\HWY_LDNET_PRN_%ITER%_%PER%.txt"
FILEO NETO = "%SCENARIO_DIR%\highway\HWY_LDNET_%ITER%_%PER%.NET"

DISTRIBUTEINTRASTEP ProcessID='Intrastep', ProcessList=1-%max_threads%

	; Read Parameter File
	READ FILE = "%NETWORK_FOLDER%\%Assignment_Parameters%"
	
    ; Define Assignment Parameters--------------------------------------------------

    ;PARAMETERS RAAD = 0.0001 GAP = 0.0001 RELATIVEGAP = 0.00001 AAD = 0.01 MAXITERS = %hwy_assignIters%
	PARAMETERS  COMBINE = EQUI, MAXITERS = %hwy_assignIters%, ENHANCE=2, MULTITHREAD=2

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
    FUNCTION TC[99] = T0 * (1 + ALPHA*(V/C)^(BETA))

	FUNCTION V = VOL[1] + VOL[2] + VOL[3] + VOL[4] + VOL[5] +
	             VOL[6] + VOL[7] + VOL[8] + VOL[9] + VOL[10] +
				 VOL[11] + VOL[12] + VOL[13] + VOL[14] + VOL[15] +
				 VOL[16] * HWY_TRKFAC

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
        T0 = LI.TIME
        IF (LI.CAPACITY=0)
            T0 = 99999
        ENDIF
        C = LI.CAPACITY * %CAPFAC%
        ALPHA = LI.ALPHA
        BETA = LI.BETA
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

		; Generalized path cost expressions -------------------------------------
		LW.PATHCOST_SOV_L = T0 + (0.6 / VOT_INCOME_01) * ((DISTANCE * AUTO_PER_MILE_COST) + LW.TOLL_PRICE_SOV)
		LW.PATHCOST_SOV_M = T0 + (0.6 / VOT_INCOME_02) * ((DISTANCE * AUTO_PER_MILE_COST) + LW.TOLL_PRICE_SOV)
		LW.PATHCOST_SOV_H = T0 + (0.6 / VOT_INCOME_03) * ((DISTANCE * AUTO_PER_MILE_COST) + LW.TOLL_PRICE_SOV)

		LW.PATHCOST_HOV2_L = T0 + (0.6 / VOT_INCOME_01) * ((DISTANCE * AUTO_PER_MILE_COST) + (LW.TOLL_PRICE_HOV2 / HWY_HOV2OCC) + LW.HOV_TIME_PNLTY)
		LW.PATHCOST_HOV2_M = T0 + (0.6 / VOT_INCOME_02) * ((DISTANCE * AUTO_PER_MILE_COST) + (LW.TOLL_PRICE_HOV2 / HWY_HOV2OCC) + LW.HOV_TIME_PNLTY)
		LW.PATHCOST_HOV2_H = T0 + (0.6 / VOT_INCOME_03) * ((DISTANCE * AUTO_PER_MILE_COST) + (LW.TOLL_PRICE_HOV2 / HWY_HOV2OCC) + LW.HOV_TIME_PNLTY)

		LW.PATHCOST_HOV3_L = T0 + (0.6 / VOT_INCOME_01) * ((DISTANCE * AUTO_PER_MILE_COST) + (LW.TOLL_PRICE_HOV3 / HWY_HOV3OCC) + LW.HOV_TIME_PNLTY)
		LW.PATHCOST_HOV3_M = T0 + (0.6 / VOT_INCOME_02) * ((DISTANCE * AUTO_PER_MILE_COST) + (LW.TOLL_PRICE_HOV3 / HWY_HOV3OCC) + LW.HOV_TIME_PNLTY)
		LW.PATHCOST_HOV3_H = T0 + (0.6 / VOT_INCOME_03) * ((DISTANCE * AUTO_PER_MILE_COST) + (LW.TOLL_PRICE_HOV3 / HWY_HOV3OCC) + LW.HOV_TIME_PNLTY)
		
		LW.PATHCOST_TRK = T0 + (0.6 / VOT_TRK) * DISTANCE * TRUCK_PER_MILE_COST
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
		PATHLOAD PATH = LW.PATHCOST_SOV_L, VOL[1] = MW[1], EXCLUDEGRP = 1
		PATHLOAD PATH = LW.PATHCOST_SOV_M, VOL[2] = MW[2], EXCLUDEGRP = 1
		PATHLOAD PATH = LW.PATHCOST_SOV_H, VOL[3] = MW[3], EXCLUDEGRP = 1
		; SR2
		PATHLOAD PATH = LW.PATHCOST_HOV2_L, VOL[4] = MW[4]
		PATHLOAD PATH = LW.PATHCOST_HOV2_M, VOL[5] = MW[5]
		PATHLOAD PATH = LW.PATHCOST_HOV2_H, VOL[6] = MW[6]
		; SR3
		PATHLOAD PATH = LW.PATHCOST_HOV3_L, VOL[7] = MW[7]
		PATHLOAD PATH = LW.PATHCOST_HOV3_M, VOL[8] = MW[8]
		PATHLOAD PATH = LW.PATHCOST_HOV3_H, VOL[9] = MW[9]
		; SOV no transponder
		PATHLOAD PATH = LW.PATHCOST_SOV_L, VOL[10] = MW[10], EXCLUDEGRP = 2
		PATHLOAD PATH = LW.PATHCOST_SOV_M, VOL[11] = MW[10], EXCLUDEGRP = 2
		PATHLOAD PATH = LW.PATHCOST_SOV_H, VOL[12] = MW[12], EXCLUDEGRP = 2
		; Ext, Spec Gen (SOV, SR2, SR3)
		PATHLOAD PATH = LW.PATHCOST_SOV_L, VOL[13] = MW[13]
		PATHLOAD PATH = LW.PATHCOST_HOV2_M, VOL[14] = MW[14]
		PATHLOAD PATH = LW.PATHCOST_HOV3_H, VOL[15] = MW[15]
		; Trucks
		PATHLOAD PATH = LW.PATHCOST_TRK, VOL[16] = MW[16], EXCLUDEGRP = 2

    PATHLOAD PATH = LW.PATHCOST_SOV_M, EXCLUDEGRP = 1,
         MW[21] = PATHTRACE(TIME),
         MW[22] = PATHTRACE(LW.TOLL_PRICE_SOV),
         MW[23] = PATHTRACE(LI.DISTANCE)

	  PATHLOAD PATH = LW.PATHCOST_SOV_M, EXCLUDEGRP = 2,
         MW[24] = PATHTRACE(TIME)

    ENDPHASE    ; ILOOP

    PHASE=ADJUST
	    ; Header for CSV ----------------------------------------------------------
		IF (LINKNO == 1 && ITERATION == 1)
		    PRINT CSV=T LIST='Iteration,ANode,BNode,MNPASS_CODE,MNPASS_PAY,HOV,Volume,VC,TIME,DISTANCE,VHT,VMT,PRICE' PRINTO=1
		ENDIF

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
			    LW.TOLL_PRICE_SOV = _PRICE_ARRAY[LW.MNPASS_PAY]
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

		ENDIF

		; Update generalized cost functions ---------------------------------------
		LW.PATHCOST_SOV_L = TIME + (0.6 / VOT_INCOME_01) * (DISTANCE * AUTO_PER_MILE_COST + LW.TOLL_PRICE_SOV)
		LW.PATHCOST_SOV_M = TIME + (0.6 / VOT_INCOME_02) * (DISTANCE * AUTO_PER_MILE_COST + LW.TOLL_PRICE_SOV)
		LW.PATHCOST_SOV_H = TIME + (0.6 / VOT_INCOME_03) * (DISTANCE * AUTO_PER_MILE_COST + LW.TOLL_PRICE_SOV)

		LW.PATHCOST_HOV2_L = TIME + (0.6 / VOT_INCOME_01) * (DISTANCE * AUTO_PER_MILE_COST + LW.TOLL_PRICE_HOV2 / HWY_HOV2OCC) + LW.HOV_TIME_PNLTY
		LW.PATHCOST_HOV2_M = TIME + (0.6 / VOT_INCOME_02) * (DISTANCE * AUTO_PER_MILE_COST + LW.TOLL_PRICE_HOV2 / HWY_HOV2OCC) + LW.HOV_TIME_PNLTY
		LW.PATHCOST_HOV2_H = TIME + (0.6 / VOT_INCOME_03) * (DISTANCE * AUTO_PER_MILE_COST + LW.TOLL_PRICE_HOV2 / HWY_HOV2OCC) + LW.HOV_TIME_PNLTY

		LW.PATHCOST_HOV3_L = TIME + (0.6 / VOT_INCOME_01) * (DISTANCE * AUTO_PER_MILE_COST + LW.TOLL_PRICE_HOV3 / HWY_HOV3OCC) + LW.HOV_TIME_PNLTY
		LW.PATHCOST_HOV3_M = TIME + (0.6 / VOT_INCOME_02) * (DISTANCE * AUTO_PER_MILE_COST + LW.TOLL_PRICE_HOV3 / HWY_HOV3OCC) + LW.HOV_TIME_PNLTY
		LW.PATHCOST_HOV3_H = TIME + (0.6 / VOT_INCOME_03) * (DISTANCE * AUTO_PER_MILE_COST + LW.TOLL_PRICE_HOV3 / HWY_HOV3OCC) + LW.HOV_TIME_PNLTY

		LW.PATHCOST_TRK = TIME + (0.6 / VOT_TRK) * DISTANCE * TRUCK_PER_MILE_COST

		; Debug print -------------------------------------------------------------
		IF (LW.HOV > 0 || LW.MNPASS_PAY > 0)
		    PRINT CSV = T LIST = iteration(2.0),
			                     A(6.0),
								 B(6.0),
								 LW.MNPASS_CODE(4.0),
								 LW.MNPASS_PAY(4.0),
								 LW.HOV(4.0),
								 V(8.2),
								 V/C(8.42),
								 TIME(5.2),
								 DISTANCE(5.2),
								 V*TIME(15.2),
								 V*DISTANCE(15.2),
								 LW.TOLL_PRICE_SOV(8.2) PRINTO = 1
		ENDIF

    ENDPHASE
	
	PHASE=CONVERGE
		IF (ITERATION < 10) BREAK ; Minimum of 10 iterations
		IF (RGAP < 0.00001) 
			BALANCE = 1
			BREAK
		ENDIF
		IF (ITERATION >= %hwy_assignIters%)
			BALANCE = 1
			BREAK
		ENDIF
	ENDPHASE


ENDRUN
