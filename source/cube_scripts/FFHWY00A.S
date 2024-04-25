; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=HIGHWAY MSG='Skim Free Flow Network for period %TOD%'
;FIXME: setup for periods by Andrew for use with period nets
FILEI NETI = "%NETWORK_FOLDER%\HWY_NET_%TOD%.net"
;FILEO NETO = "%SCENARIO_DIR%\highway\temp_%PER%.net" INCLUDE=LW.GENCOST_L
;FILEI NETI = "%SCENARIO_DIR%\highway\ALL_NET.tmp"
;FILEO MATO[1] = "%SCENARIO_DIR%\HWY_SKIM.tmp",  changed by Dennis Farmer; this should have extenstion .skm to work and get copied in next script
FILEO MATO[1] = "%SCENARIO_DIR%\highway\HWY_SKIM_0_%PER%_L.skm",
 MO=1-15, 
  NAME=daptime, daptoll, dantime, dantoll, dapdist, a2ptime, a2ptoll, a2ntime, a2ntoll, a2pdist, 
  a3ptime, a3ptoll, a3ntime, a3ntoll, a3pdist
  
FILEO MATO[2] = "%SCENARIO_DIR%\highway\HWY_SKIM_0_%PER%_M.skm",
 MO=16-30, 
  NAME=daptime, daptoll, dantime, dantoll, dapdist, a2ptime, a2ptoll, a2ntime, a2ntoll, a2pdist, 
  a3ptime, a3ptoll, a3ntime, a3ntoll, a3pdist
  
FILEO MATO[3] = "%SCENARIO_DIR%\highway\HWY_SKIM_0_%PER%_H.skm",
 MO=31-45, 
  NAME=daptime, daptoll, dantime, dantoll, dapdist, a2ptime, a2ptoll, a2ntime, a2ntoll, a2pdist, a3ptime, a3ptoll, a3ntime, a3ntoll, a3pdist

DISTRIBUTEINTRASTEP ProcessID='Intrastep', ProcessList=1-%max_threads%

READ FILE = "%NETWORK_FOLDER%\%Assignment_Parameters%"

; VoTs in cents/hour
_VOT_LOW = VOT_INCOME_01 / 100
_VOT_MED = VOT_INCOME_02 / 100
_VOT_HIGH = VOT_INCOME_03 / 100

PHASE = LINKREAD
	LW.HOV_TIME_PNLTY = 0
	LW.TOLL_PRICE_SOV = 0
	LW.MNPASS_CODE = LI.MNPASS_CODE
	LW.MNPASS_PAY = LI.MNPASS_PAY
	IF (LW.MNPASS_PAY > 0)
		LW.TOLL_PRICE_SOV = 25
	ENDIF
	; Create an HOV lane group and a no truck lane group ---------------------
	IF (LI.HOV_NO_MNPASS > 0) ADDTOGROUP = 1
	IF (LI.MNPASS_CODE > 0 || LI.HOV_NO_MNPASS > 0) ADDTOGROUP = 2
	IF (LW.MNPASS_PAY > 0) ADDTOGROUP = 3
	;
	LW.GENCOST_L = LI.TIME + 60 * LW.TOLL_PRICE_SOV / _VOT_LOW + (60 * LI.DISTANCE * AUTO_PER_MILE_COST) / _VOT_LOW
	LW.GENCOST_M = LI.TIME + 60 * LW.TOLL_PRICE_SOV / _VOT_MED + (60 * LI.DISTANCE * AUTO_PER_MILE_COST) / _VOT_MED
	LW.GENCOST_H = LI.TIME + 60 * LW.TOLL_PRICE_SOV / _VOT_HIGH + (60 * LI.DISTANCE * AUTO_PER_MILE_COST) / _VOT_HIGH
ENDPROCESS

PROCESS PHASE=ILOOP
	MW[100] = 0
	;  Low VoT Skims	
	; SOV with pass
    PATHLOAD PATH = LW.GENCOST_L,  
		mw[1] = PATHTRACE(TIME) NOACCESS=1000,
		mw[2] = PATHTRACE(LW.TOLL_PRICE_SOV) NOACCESS = 0,
		mw[5] = PATHTRACE(li.DISTANCE) NOACCESS=1000;,
		;VOL[1] = MW[100]
		
    ; Intrazonal time / distance is half that to nearest zone
    mw[1][I] = LOWEST(1,1,0.1,999,I)/2 
    mw[5][I] = LOWEST(5,1,0.1,999,I)/2 
	
	;SOV No Pass (no toll)
	PATHLOAD PATH = TIME,  
		mw[3] = PATHTRACE(TIME) NOACCESS=1000,
		mw[4] = PATHTRACE(LW.TOLL_PRICE_SOV) NOACCESS = 0,
		EXCLUDEGROUP = 3
    mw[3][I] = LOWEST(3,1,0.1,999,I)/2 
    
	;HOV (no toll, allowed to use toll facil)
	PATHLOAD PATH = TIME,  
		mw[6] = PATHTRACE(TIME) NOACCESS=1000,
		mw[7] = PATHTRACE(LW.TOLL_PRICE_SOV) NOACCESS = 0
    mw[6][I] = LOWEST(6,1,0.1,999,I)/2 
	
    ; SR2
    mw[8] = mw[6]
    mw[9] = 0
    mw[10] = mw[5]
    
    ; SR3
    mw[11] = mw[6]
    mw[12] = 0
    mw[13] = mw[6]
    mw[14] = 0
    mw[15] = mw[5]   
	
	;  Mid VoT Skims		
    ; SOV with pass
    PATHLOAD PATH = LW.GENCOST_M,  
		mw[16] = PATHTRACE(TIME) NOACCESS=1000,
		mw[17] = PATHTRACE(LW.TOLL_PRICE_SOV) NOACCESS = 0,
		mw[20] = PATHTRACE(li.DISTANCE) NOACCESS=1000
		
    ; Intrazonal time / distance is half that to nearest zone
    mw[16][I] = LOWEST(16,1,0.1,999,I)/2 
    mw[20][I] = LOWEST(20,1,0.1,999,I)/2 
	
	;SOV No Pass (no toll)
	PATHLOAD PATH = TIME,  
		mw[18] = PATHTRACE(TIME) NOACCESS=1000,
		mw[19] = PATHTRACE(LW.TOLL_PRICE_SOV) NOACCESS = 0,
		EXCLUDEGROUP = 2
    mw[18][I] = LOWEST(18,1,0.1,999,I)/2 
    
    ;HOV (no toll, allowed to use toll facil)
	PATHLOAD PATH = TIME,  
		mw[21] = PATHTRACE(TIME) NOACCESS=1000,
		mw[22] = PATHTRACE(LW.TOLL_PRICE_SOV) NOACCESS = 0
    mw[21][I] = LOWEST(21,1,0.1,999,I)/2 
	
    ; SR2
    mw[23] = mw[21]
    mw[24] = 0
    mw[25] = mw[20]
    
    ; SR3
    mw[26] = mw[21]
    mw[27] = 0
    mw[28] = mw[21]
    mw[29] = 0
    mw[30] = mw[20]  

	; High VoT Skims		
    ; SOV with pass
    PATHLOAD PATH = LW.GENCOST_H,  
		mw[31] = PATHTRACE(TIME) NOACCESS=1000,
		mw[32] = PATHTRACE(LW.TOLL_PRICE_SOV) NOACCESS = 0,
		mw[35] = PATHTRACE(li.DISTANCE) NOACCESS=1000
		
    ; Intrazonal time / distance is half that to nearest zone
    mw[31][I] = LOWEST(31,1,0.1,999,I)/2 
    mw[35][I] = LOWEST(35,1,0.1,999,I)/2 
	
	;SOV No Pass (no toll)
	PATHLOAD PATH = TIME,  
		mw[33] = PATHTRACE(TIME) NOACCESS=1000,
		mw[34] = PATHTRACE(LW.TOLL_PRICE_SOV) NOACCESS = 0,
		EXCLUDEGROUP = 2
    mw[33][I] = LOWEST(33,1,0.1,999,I)/2 
    
    ;HOV (no toll, allowed to use toll facil)
	PATHLOAD PATH = TIME,  
		mw[36] = PATHTRACE(TIME) NOACCESS=1000,
		mw[37] = PATHTRACE(LW.TOLL_PRICE_SOV) NOACCESS = 0
    mw[36][I] = LOWEST(36,1,0.1,999,I)/2 
	
    ; SR2
    mw[38] = mw[36]
    mw[39] = 0
    mw[40] = mw[35]
    
    ; SR3
    mw[41] = mw[36]
    mw[42] = 0
    mw[43] = mw[36]
    mw[44] = 0
    mw[45] = mw[35]  

ENDPROCESS

PROCESS PHASE=ADJUST
	LW.GENCOST_L = t0 + 60 * LW.TOLL_PRICE_SOV / _VOT_LOW + (60 * LI.DISTANCE * AUTO_PER_MILE_COST) / _VOT_LOW
	LW.GENCOST_M = t0 + 60 * LW.TOLL_PRICE_SOV / _VOT_MED + (60 * LI.DISTANCE * AUTO_PER_MILE_COST) / _VOT_MED
	LW.GENCOST_H = t0 + 60 * LW.TOLL_PRICE_SOV / _VOT_HIGH + (60 * LI.DISTANCE * AUTO_PER_MILE_COST) / _VOT_HIGH
ENDPROCESS

ENDRUN
