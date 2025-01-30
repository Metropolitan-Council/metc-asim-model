HighwaySkimBranch=-1
TransitSkim=-1
ConvergeCheck=-1
FinalAssign=-1
; Script for program NETWORK in file "C:\ABM\CUBE\BNNET00B.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK MSG='Export Raw Network From GeoDatabase'
FILEO NETO = "%SCENARIO_DIR%\ALL_NET.tmp"
FILEI LINKI[1] = "%iHwyNet%"


ENDRUN


; Script for program NETWORK in file "C:\ABM\CUBE\NMNET00A.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK MSG='Export Bike Network from Geodatabase'
FILEO NETO = "%SCENARIO_DIR%\NM_NET.net"
FILEI LINKI[1] = "%SCENARIO_DIR%\ALL_NET.tmp"

;Length corrections
;DISTANCE = SHAPE_Length/1609.344 ; Adds distance to any new link that was not coded with a distance

BIKESPEED=0
IF (BIKE=0) DELETE
IF (BIKE=1) BIKESPEED=%bikeSpeed1%
IF (BIKE=2) BIKESPEED=%bikeSpeed2%
IF (BIKE=3) BIKESPEED=%bikeSpeed3%

BIKETIME=60*(DISTANCE/BIKESPEED)
PTIME=BIKETIME
B1DIST=0
B2DIST=0
B3DIST=0

IF (BIKE=3)
  B3DIST=DISTANCE
ENDIF
IF (BIKE=2)
  B2DIST=DISTANCE
ENDIF
IF (BIKE=1)
  B1DIST=DISTANCE
  PTIME=BIKETIME*%bikeFact1%
ENDIF

ENDRUN


; Script for program HIGHWAY in file "C:\ABM\CUBE\NMHWY00A.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=HIGHWAY MSG='Skim Bike Path Times'
FILEO MATO[1] = "%SCENARIO_DIR%\NM_SKIM_BIKE.skm",
 MO=1-6, NAME=PERCTIME, BIKETIME, DISTANCE, B3DIST, B2DIST, B1DIST
FILEI NETI = "%SCENARIO_DIR%\NM_NET.net"

PROCESS PHASE=ILOOP

  PATHLOAD PATH=LI.PTIME, MW[1]=pathtrace(LI.PTIME), MW[2]=pathtrace(LI.BIKETIME),
                          MW[3]=pathtrace(LI.DISTANCE), MW[4]=pathtrace(LI.B3DIST),
                          MW[5]=pathtrace(LI.B2DIST), MW[6]=pathtrace(LI.B1DIST)  
      MW[1][I] = ROWMIN(1) * 0.5  ; Intrazonal time
      MW[2][I] = ROWMIN(2) * 0.5
      MW[3][I] = ROWMIN(3) * 0.5
      MW[4][I] = ROWMIN(3) ; use total distance intrazonal, not just dist on this facility type - NOTE: do not need to divide by 2 b/c done on line 14
      MW[5][I] = 0 ; assume no bike paths on the intrazonal
      MW[6][I] = 0 ; assume no bike paths on the intrazonal
ENDPROCESS


ENDRUN


; Script for program HIGHWAY in file "C:\ABM\CUBE\NMHWY00B.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=HIGHWAY MSG='Skim Walk Path Distance'
FILEO MATO[1] = "%SCENARIO_DIR%\NM_SKIM_WALK.skm",
 MO=1-4, NAME=DISTANCE, B3DIST, B2DIST, B1DIST
FILEI NETI = "%SCENARIO_DIR%\NM_NET.net"
PROCESS PHASE=ILOOP

  PATHLOAD PATH=LI.DISTANCE, MW[1]=pathtrace(LI.DISTANCE), MW[2]=pathtrace(LI.B3DIST),
                          MW[3]=pathtrace(LI.B2DIST), MW[4]=pathtrace(LI.B1DIST)  
      MW[1][I] = ROWMIN(1) * 0.5  ; Intrazonal time
      MW[2][I] = ROWMIN(2) * 0.5
      MW[3][I] = ROWMIN(3) * 0.5
      MW[4][I] = ROWMIN(4) * 0.5
ENDPROCESS

ENDRUN


; Script for program MATRIX in file "C:\ABM\CUBE\NMMAT00A.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Calculate Bike and Walk Distances'
FILEI MATI[2] = "%SCENARIO_DIR%\NM_SKIM_WALK.skm"
FILEI MATI[1] = "%SCENARIO_DIR%\NM_SKIM_BIKE.skm"
FILEO MATO[1] = "%SCENARIO_DIR%\NM_SKIM.SKM",
 MO=1-3, NAME=BIKEDIST, WALKDIST, RATIO  ; add ratio to check calcs

  MW[1] = MI.1.4 + (%bikeSpeed3%/%bikeSpeed2%) * MI.1.5 + (%bikeSpeed3%/%bikeSpeed1%) * %bikeFact1% * MI.1.6
  MW[2] = MI.2.1  
  MW[2][I] = MW[1][I]  ; intrazonal distances should be the same.
  MW[3] = MW[1] / MW[2]



ENDRUN


; Script for program NETWORK in file "C:\ABM\CUBE\HNNET00B.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK MSG='Set highway link speeds, capacities, and AB'
FILEI LOOKUPI[3] = "%LU_AlphaBeta%"
FILEI LOOKUPI[2] = "%LU_capacity%"
FILEI LOOKUPI[1] = "%LU_speed%"
FILEI LINKI[1] = "%SCENARIO_DIR%\ALL_NET.tmp"
FILEO NETO = "%SCENARIO_DIR%\ALL_NET.net"
 
;Length corrections
  ;DISTANCE = SHAPE_Length/1609.344 ; Adds distance to any new link that was not coded with a distance
/*
  LOOKUP LOOKUPI=1, NAME=Spd,
    LOOKUP[1]=1, RESULT=2,
    LOOKUP[2]=1, RESULT=3,
    LOOKUP[3]=1, RESULT=4,
    LOOKUP[4]=1, RESULT=5,
		LOOKUP[5]=1, RESULT=6,
		LOOKUP[6]=1, RESULT=7,
		LOOKUP[7]=1, RESULT=8,
		LOOKUP[8]=1, RESULT=9,
		LOOKUP[9]=1, RESULT=10,
		LOOKUP[10]=1, RESULT=11,
		LOOKUP[11]=1, RESULT=12,
		LOOKUP[12]=1, RESULT=13,
		LOOKUP[13]=1, RESULT=14,
		LOOKUP[14]=1, RESULT=15
    Speed = Spd(AREA,RCI)
		if(speed > 0) time=60*(distance/speed)

  LOOKUP LOOKUPI=2, NAME=Cap,
    LOOKUP[1]=1, RESULT=2,
    LOOKUP[2]=1, RESULT=3,
    LOOKUP[3]=1, RESULT=4,
    LOOKUP[4]=1, RESULT=5,
		LOOKUP[5]=1, RESULT=6,
		LOOKUP[6]=1, RESULT=7,
		LOOKUP[7]=1, RESULT=8,
		LOOKUP[8]=1, RESULT=9,
		LOOKUP[9]=1, RESULT=10,
		LOOKUP[10]=1, RESULT=11,
		LOOKUP[11]=1, RESULT=12,
		LOOKUP[12]=1, RESULT=13,
		LOOKUP[13]=1, RESULT=14,
		LOOKUP[14]=1, RESULT=15,
	  LOOKUP[15]=1, RESULT=16
    Capacity = Cap(AREA,RCI) * lanes
  */  
  LOOKUP LOOKUPI=3, NAME=AB,
    LOOKUP[1]=1, RESULT=2,
    LOOKUP[2]=1, RESULT=3,
    LOOKUP[3]=1, RESULT=4,
    LOOKUP[4]=1, RESULT=5,
		LOOKUP[5]=1, RESULT=6,
		LOOKUP[6]=1, RESULT=7,
		LOOKUP[7]=1, RESULT=8,
		LOOKUP[8]=1, RESULT=9,
		LOOKUP[9]=1, RESULT=10,
		LOOKUP[10]=1, RESULT=11,
		LOOKUP[11]=1, RESULT=12,
		LOOKUP[12]=1, RESULT=13,
		LOOKUP[13]=1, RESULT=14,
		LOOKUP[14]=1, RESULT=15,
	  LOOKUP[15]=1, RESULT=16
    ALPHA = AB(1,RCI)
    BETA = AB(2,RCI)


ENDRUN


; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.


LOOP TOD=1,6,1 ; There are six unique network configurations
 IF(TOD=1) NETNAME='Overnight 7:00 PM to 5:00 AM'
 IF(TOD=2) NETNAME='Reverse Lane Change Over 5:00 AM to 6:00 AM  and 1:00 PM to 2:00 PM'
 IF(TOD=3) NETNAME='AM Peak Period 6:00 AM to 10:00 AM'
 IF(TOD=4) NETNAME='Mid Day Period 10:00 AM to 1:00 PM'
 IF(TOD=5) NETNAME='Pre PM Peak Period 2:00 PM to 3:00 PM'
 IF(TOD=6) NETNAME='PM Peak Period 3:00 PM to 7:00 PM'
; End of PILOT Script

; Script for program NETWORK in file "C:\ABM\CUBE\HNNET00C.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK MSG='Set Managed Lanes for: %NETNAME%'

FILEI LINKI[1] = "%SCENARIO_DIR%\ALL_NET.net"
FILEO NETO = "%SCENARIO_DIR%\HWY_NET_%TOD%.net"


  IF (RCI=100) DELETE ; Remove Rail
  IF (Bike=1) DELETE ;Remove Bike paths
  
  IF (RCI=98 | RCI=101) DELETE

  ;ENDIF

; Rachel editing below to reflect HOV/mnpass of increased revenue scenario. will also work for the current revenue scenario and the existing 2040 model. 
  IF (HOV > 0)
  ;HOV Lane Configurations
  ;MnPass On is the default condition
   _ON=1
  ;For Mainline Lane ADD and MINUS the default condition is Zero - depending how the lane is coded, some require adding lanes when MNPASS off and some require reducing mainline lanes when mnpass is on. see Rewriting_HOVScripts_HNNETOOC.xlxs and FullMakeNetworkXX.s for HOV groupings 
   _ADD=0

  IF (%TOD%=1) ; Overnight 7:00 PM to 5:00 AM , all off 
    IF (HOV=1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,61) ;MnPass Off
      _ON=0
    ENDIF
    IF (HOV=111,112,113,114,118,119,122,123,126,127,130,131,132,133,134,135,136,137,139,141,142,143,144,145) ;Mainline Lane increase when off 
      _ADD=1
    ENDIF
  ENDIF
  
  IF (%TOD%=2)  ; Reverse Lane Change over 5:00 AM to 6:00 AM  and 1:00 PM to 2:00 PM ; all off same as above 
    IF (HOV=1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,61) ;MnPass Off
      _ON=0
    ENDIF
    IF (HOV=111,112,113,114,118,119,122,123,126,127,130,131,132,133,134,135,136,137,139,141,142,143,144,145) ;Mainline Lane increase when off 
      _ADD=1
    ENDIF
  ENDIF  
  
  IF (%TOD%=3)  ; AM Peak Period 6:00 AM to 10:00 AM
    IF (HOV=2,3,4,6,8,10,11,13,17,19,20,22,25,27,29,31,33,35,40,41,42,45) ;MnPass Off
      _ON=0
    ENDIF
    IF (HOV=101,105,107,109,121,124,128,138) ;Mainline Lane Decrease
      _ADD=-1
    ENDIF
    IF (HOV=111,113,119,122,127,131,133,135,141,142,145) ;Mainline Lane increase when off 
      _ADD=1
    ENDIF
  ENDIF  
  
  IF (%TOD%=4)  ; Mid Day Period 10:00 AM to 1:00 PM same as overnight, first TOD period
    IF (HOV=1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,61) ;MnPass Off
      _ON=0
    ENDIF
    IF (HOV=111,112,113,114,118,119,122,123,126,127,130,131,132,133,134,135,136,137,139,141,142,143,144,145) ;Mainline Lane increase when off 
      _ADD=1
    ENDIF
  ENDIF
  
  IF (%TOD%=5)  ; Pre PM Peak Period 2:00 PM to 3:00 PM same as overnight, first period 
    IF (HOV=1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,61) ;MnPass Off
      _ON=0
    ENDIF
    IF (HOV=111,112,113,114,118,119,122,123,126,127,130,131,132,133,134,135,136,137,139,141,142,143,144,145) ;Mainline Lane increase when off 
      _ADD=1
    ENDIF
  ENDIF
  
  IF (%TOD%=6)  ; PM Peak Period 3:00 PM to 7:00 PM
    IF (HOV=1,3,5,7,9,10,12,14,18,21,23,24,26,28,30,32,34,38,39,43,44,61) ;MnPass Off
      _ON=0
    ENDIF
    IF (HOV=102,104,108,117,120,125,129,140) ;Mainline Lane Decrease
      _ADD=-1
    ENDIF
    IF (HOV=112,114,118,123,126,130,132,134,139,143,144) ;Mainline Lane Increase
      _ADD=1
    ENDIF
  ENDIF
  
  ; Update capacity
  IF (_ON=1) 
    Capacity=Capacity * ((lanes+_ADD) / lanes)
  ELSE 
    Capacity = 0
  ENDIF
  
  ENDIF  ; HOV links
  
ENDRUN


; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.


ENDLOOP
; End of PILOT Script

; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.

if (%ffSkims% = 1)
  HighwaySkimBranch = 2
else
  HighwaySkimBranch = 1
endif
; End of PILOT Script

If (HighwaySkimBranch=1)
  goto HighwaySkimBranch_1
Elseif (HighwaySkimBranch=2)
  goto HighwaySkimBranch_2
Else
  PRINT LIST='Application Error: No Branch Selected from Branch Control "HighwaySkimBranch"'
  ABORT
Endif

:HighwaySkimBranch_1
; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.


*copy "%hwy_AMskims%" "%SCENARIO_DIR%\HWY_SKIM_0_AM.skm"
*copy "%hwy_MDskims%" "%SCENARIO_DIR%\HWY_SKIM_0_MD.skm"
*copy "%hwy_PMskims%" "%SCENARIO_DIR%\HWY_SKIM_0_PM.skm"
*copy "%hwy_NTskims%" "%SCENARIO_DIR%\HWY_SKIM_0_NT.skm"

  IF (ReturnCode == 1) 
    PRINT LIST='Missing Highway Initial Skim file - check scenario key settings in the Scenario Manager'
    abort
  ENDIF 
; End of PILOT Script

goto HighwaySkimBranch_END

:HighwaySkimBranch_2
; Script for program HIGHWAY in file "C:\ABM\CUBE\FFHWY00A.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=HIGHWAY MSG='Skim Free Flow Network'
FILEI NETI = "%SCENARIO_DIR%\ALL_NET.net"
FILEO MATO[1] = "%SCENARIO_DIR%\HWY_SKIM.tmp",
 MO=1-16, 
  NAME=daptime, daptoll, dantime, dantoll, dapdist, a2ptime, a2ptoll, a2ntime, a2ntoll, a2pdist, 
  a3ptime, a3ptoll, a3ntime, a3ntoll, a3pdist, lnrtdist

PROCESS PHASE=ILOOP
    PATHLOAD PATH = TIME,  
    mw[1] = PATHTRACE(TIME) NOACCESS=1000,
    mw[5] = PATHTRACE(li.DISTANCE) NOACCESS=1000 

    ; Intrazonal time / distance is half that to nearest zone
    mw[1][I] = LOWEST(1,1,0.1,999,I)/2 
    mw[5][I] = LOWEST(5,1,0.1,999,I)/2 

    mw[2] = 0
    mw[3] = mw[1]
    mw[4] = mw[2]
    
    ; SR2
    mw[6] = mw[1]
    mw[7] = mw[2]
    mw[8] = mw[3]
    mw[9] = mw[4]
    mw[10] = mw[5]
    
    ; SR3
    mw[11] = mw[1]
    mw[12] = mw[2]
    mw[13] = mw[3]
    mw[14] = mw[4]
    mw[15] = mw[5]   
    
    ; ln(RT Dist + 1)
    mw[16] = LN(2 * mw[5]+1)
    
ENDPROCESS



ENDRUN


; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.


*copy "%SCENARIO_DIR%\HWY_SKIM.skm" "%SCENARIO_DIR%\HWY_SKIM_0_AM.skm"
*copy "%SCENARIO_DIR%\HWY_SKIM.skm" "%SCENARIO_DIR%\HWY_SKIM_0_MD.skm"
*copy "%SCENARIO_DIR%\HWY_SKIM.skm" "%SCENARIO_DIR%\HWY_SKIM_0_PM.skm"
*copy "%SCENARIO_DIR%\HWY_SKIM.skm" "%SCENARIO_DIR%\HWY_SKIM_0_NT.skm"
; End of PILOT Script

goto HighwaySkimBranch_END

:HighwaySkimBranch_END
; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.


if (%ffSkims% = 1)
  TransitSkim = 2
else
  TransitSkim = 1
endif
; End of PILOT Script

If (TransitSkim=1)
  goto TransitSkim_1
Elseif (TransitSkim=2)
  goto TransitSkim_2
Else
  PRINT LIST='Application Error: No Branch Selected from Branch Control "TransitSkim"'
  ABORT
Endif

:TransitSkim_1
; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.


*copy "%xit_WK_PKskims%" "%SCENARIO_DIR%\XIT_WK_SKIM_0_PK.skm"
*copy "%xit_WK_OPskim%" "%SCENARIO_DIR%\XIT_WK_SKIM_0_OP.skm"
*copy "%xit_DR_PKskim%" "%SCENARIO_DIR%\XIT_DR_SKIM_0_PK.skm"
*copy "%xit_DR_OPskim%" "%SCENARIO_DIR%\XIT_DR_SKIM_0_OP.skm"

  IF (ReturnCode == 1) 
    PRINT LIST='Missing Highway Initial Skim file - check scenario key settings in the Scenario Manager'
    abort
  ENDIF 
; End of PILOT Script

; Script for program NETWORK in file "C:\ABM\CUBE\TCNET00B.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK MSG='TEMP: extract link and node dbfs'
FILEO NODEO = "%SCENARIO_DIR%\NODE.DBF"
FILEO LINKO = "%SCENARIO_DIR%\LINK.DBF"
FILEI LINKI[1] = "%SCENARIO_DIR%\ALL_NET.NET"


ENDRUN


goto TransitSkim_END

:TransitSkim_2
; Script for program NETWORK in file "C:\ABM\CUBE\TSNET00A.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK MSG='TEMP: extract link and node dbfs'
FILEO NODEO = "%SCENARIO_DIR%\node.dbf"
FILEO LINKO = "%SCENARIO_DIR%\link.dbf"
FILEI LINKI[1] = "%SCENARIO_DIR%\ALL_NET.net"


ENDRUN


; Script for program NETWORK in file "C:\ABM\CUBE\TSNET00B.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK MSG='TEMP: set rail zone node field'
FILEI LINKI[4] = "C:\ABM\Input\network\T_Priority.dbf"
FILEI LINKI[3] = "C:\ABM\Input\network\T_MANTIME.dbf"
FILEI LINKI[2] = "C:\ABM\Input\network\Distances.dbf"
FILEO NETO = "%SCENARIO_DIR%\TransitBase.NET"
FILEI NODEI[1] = "%SCENARIO_DIR%\node.dbf"
FILEI LINKI[1] = "%SCENARIO_DIR%\link.dbf"

    ZONES=%zones%
    
    ; TODO: Move this into the GeoDB
    PHASE=NODEMERGE FILEI=NI.1 
      IF (N=17502)
        FAREZONE=1
      ENDIF
      IF (N=19759)
        FAREZONE=2
      ENDIF
      IF (N=19761)
        FAREZONE=3
      ENDIF
      IF (N=19762)
        FAREZONE=4
      ENDIF
      IF (N=19763)
        FAREZONE=5
      ENDIF
      IF (N=19764)
        FAREZONE=6
      ENDIF
      
    ENDPROCESS
      
ENDRUN


; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.

*cluster transit 1-2 START EXIT

LOOP TOD=1,2,1 ; Loop through peak and off-peak
  IF(TOD=1) TPER='PK'
  IF(TOD=2) TPER='OP'
  
 DISTRIBUTEMULTISTEP PROCESSID='transit' PROCESSNUM=%TOD%
; End of PILOT Script

; Script for program NETWORK in file "C:\ABM\CUBE\TSNET00C.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK MSG='Calculate Transit Speeds for %TPER%'
FILEO NETO = "%SCENARIO_DIR%\XIT_NET_0_%TPER%.net"
FILEI LOOKUPI[2] = "%CATALOG_DIR%\input\transit\%TPER%ExpressDelays.txt"
FILEI LOOKUPI[1] = "%CATALOG_DIR%\input\transit\%TPER%LocalDelays.txt"
FILEI LINKI[1] = "%SCENARIO_DIR%\TransitBase.NET"

    ;  transit time = congested time +  distance * link delay
    ;   Delays are calibrated by AREA and facility type and time period.
    LOOKUP NAME=locdelay, LOOKUP[1]=1, RESULT=2,
                            LOOKUP[2]=1, RESULT=3,
                            LOOKUP[3]=1, RESULT=4,
                            LOOKUP[4]=1, RESULT=5,
                            LOOKUP[5]=1, RESULT=6,
                            LOOKUP[6]=1, RESULT=7,
                            LOOKUP[7]=1, RESULT=7,
                            LOOKUP[8]=1, RESULT=7,
                            LOOKUP[9]=1, RESULT=7,
                            LOOKUP[10]=1, RESULT=7,
                            FAIL=0,0,0, INTERPOLATE=N,
                            LOOKUPI=1, LIST=Y

    LOOKUP NAME=expdelay, LOOKUP[1]=1, RESULT=2,
                            LOOKUP[2]=1, RESULT=3,
                            LOOKUP[3]=1, RESULT=4,
                            LOOKUP[4]=1, RESULT=5,
                            LOOKUP[5]=1, RESULT=6,
                            LOOKUP[6]=1, RESULT=7,
                            LOOKUP[7]=1, RESULT=7,
                            LOOKUP[8]=1, RESULT=7,
                            LOOKUP[9]=1, RESULT=7,
                            LOOKUP[10]=1, RESULT=2,         ; 1 and 10 are rural area types
                            FAIL=0,0,0, INTERPOLATE=N,
                            LOOKUPI=2, LIST=Y


;;--------------------------------------------------------------------------

    ; Set transit speeds - same for PK/OP
    IF(LI.1.SPEED=0)
      SPEED=0.1
    ELSE
      SPEED=LI.1.SPEED
    ENDIF
    
;;--------------------------------------------------------------------------

    ; Code free flow speed for all links
    LOCTIME = (DISTANCE * 60 / SPEED)
    EXPTIME = (DISTANCE * 60 / SPEED)
    
;;--------------------------------------------------------------------------    

    ; Override manually coded speed for transit only links
    IF (LI.1.T_MANTIME>0)
        LOCTIME = T_MANTIME
        EXPTIME = T_MANTIME
        LRTTIME = T_MANTIME
    ENDIF    

;;--------------------------------------------------------------------------

    ;Calculate Local Bus Transit Travel Time
    IF (LOCTIME=0)
         _DELAY = locdelay(LI.1.AREA,LI.1.RCI)
         IF (T_Priority=2)
            IF ((SPEED+15)<50)
                _tspeed = MIN(SPEED+15,35)
            ELSE
                _tspeed=MAX(SPEED,35)
            ENDIF
            LOCTIME = (DISTANCE * 60 / _tspeed) + (DISTANCE * _DELAY)
         ELSE
            LOCTIME = (DISTANCE * 60 / SPEED) + (DISTANCE * _DELAY)
         ENDIF
    
        IF (LOCTIME=0) 
            PRINT LIST='LOCAL BUS TIME IS ZERO FOR - ', A(6), B(6)
        ENDIF        
    ENDIF
;;--------------------------------------------------------------------------
    
    ;Calculate Express Bus Transit Travel Time
    IF (EXPTIME=0)
        _DELAY = expdelay(LI.1.AREA,LI.1.RCI)
         IF (T_Priority=2)
            IF ((SPEED+15)<50)
                _tspeed = MIN(SPEED+15,35)
            ELSE
                _tspeed=MAX(SPEED,35)
            ENDIF
            EXPTIME = (DISTANCE * 60 / _tspeed) + (DISTANCE * _DELAY)
         ELSE
            EXPTIME = (DISTANCE * 60 / SPEED) + (DISTANCE * _DELAY)
         ENDIF
    
        IF (EXPTIME=0) 
            PRINT LIST='EXPRESS BUS TIME IS ZERO FOR - ', A(6), B(6)
        ENDIF
    ENDIF       

ENDRUN


; Script for program PUBLIC TRANSPORT in file "C:\ABM\CUBE\TSPTR00D.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=PUBLIC TRANSPORT MSG='Build %TPER% Walk Access Connectors'
FILEO NTLEGO = "%SCENARIO_DIR%\XIT_WKACC_NTL_0_%TPER%.tmp"
FILEO REPORTO = "%SCENARIO_DIR%\XIT_WKACC_RPT_0_%TPER%.rpt"
FILEO NETO = "%SCENARIO_DIR%\XIT_WKACC_NET_0_%TPER%.NET"
FILEI SYSTEMI = "%xit_system%"
FILEI FACTORI[1] = "%CATALOG_DIR%\input\transit\%TPER%_WK_2010.FAC"
FILEI LINEI[1] = "%xit_lines%"
FILEI NETI = "%SCENARIO_DIR%\XIT_NET_0_%TPER%.net"

    REPORT Lines=T
    REREPORT Accesslegs=T, Egresslegs=T, Xferlegs=T, Lines=T, STOPNODES=T
    HDWAYPERIOD=%TOD%

    PHASE=LINKREAD
        _wlkspd = 2.5   ;mph
    ENDPHASE

    PHASE=DATAPREP
        Print List='Build Peak Walk Access Connectors', printo=0

        ;set transit travel time
        TRANTIME[5]=li.loctime       ; local
        TRANTIME[6]=li.loctime       ; local
        TRANTIME[7]=li.exptime       ; express
        TRANTIME[8]=li.lrttime       ; lrt
        TRANTIME[9]=li.exptime       ; commuter bus

        generate,
        fromnode=1-3061,
        tonode=3100-99999,
        direction=3,
        oneway=F,
        cost=li.Distance,
        extractcost=(Li.Distance*60/_wlkspd),
        excludelink=(li.RCI=1-5,13,14),   ;no walking on freeway, tollway,ramps and managed links
        maxcost=4*0,5*2,                 ;set maximum walking distance to 2 Miles
        maxntlegs=4*1,5*99,
        ntlegmode=1
    ENDPHASE


ENDRUN


; Script for program PUBLIC TRANSPORT in file "C:\ABM\CUBE\TSPTR00F.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=PUBLIC TRANSPORT MSG='Build %TPER% Transfer Access Connectors'
FILEO NTLEGO = "%SCENARIO_DIR%\XIT_XFER_NTL_0_%TPER%.TMP"
FILEO REPORTO = "%SCENARIO_DIR%\XIT_XFER_RPT_0_%TPER%.RPT"
FILEO NETO = "%SCENARIO_DIR%\XIT_XFER_NET_0_%TPER%.NET"
FILEI SYSTEMI = "%XIT_SYSTEM%"
FILEI FACTORI[1] = "%CATALOG_DIR%\INPUT\TRANSIT\%TPER%_WK_2010.FAC"
FILEI LINEI[1] = "%XIT_LINES%"
FILEI NETI = "%SCENARIO_DIR%\XIT_NET_0_%TPER%.net"
 
    SKIPBADLINES = Y
    REPORT Lines=T
    REREPORT Accesslegs=T, Egresslegs=T, Xferlegs=T, Lines=T, STOPNODES=T
    HDWAYPERIOD=%TOD%

 
    PHASE=LINKREAD
        _wlkspd = 2.5   ;mph
    ENDPHASE

    PHASE=DATAPREP
     
        Print List='Build Peak Transfer Connectors', printo=0
        ;set transit travel time
        TRANTIME[5]=li.loctime       ; local
        TRANTIME[6]=li.loctime       ; local
        TRANTIME[7]=li.exptime       ; express
        TRANTIME[8]=li.lrttime       ; lrt
        TRANTIME[9]=li.exptime       ; commuter bus

        ;*************************************
        ;    TRANSFER CONNECTORS
        ;*************************************
        ;generate the transfer legs based on transfer links
        generate,
        fromnode=3100-99999,
        tonode=3100-99999,
        direction=3,
        oneway=F,
        excludelink=(li.RCI=1-5,13,14),   ;no walking on freeway, tollway, and managed links
        cost=(Li.Distance*60/_wlkspd),
        maxcost=4*1,5*10,                 ;set maximum walking time to 10 minutes
        maxntlegs=4*1,5*10,
        ntlegmode=4
       
    ENDPHASE

ENDRUN


; Script for program PUBLIC TRANSPORT in file "C:\ABM\CUBE\TSPTR00H.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=PUBLIC TRANSPORT MSG='Build %TPER% Drive Access Connectors'
FILEO NTLEGO = "%SCENARIO_DIR%\XIT_DRACC_NTL_0_%TPER%.NTL"
FILEO REPORTO = "%SCENARIO_DIR%\XIT_DRACC_RPT_0_%TPER%.RPT"
FILEO NETO = "%SCENARIO_DIR%\XIT_DRACC_NET_0_%TPER%.NET"
FILEI SYSTEMI = "%XIT_SYSTEM%"
FILEI FACTORI[1] = "%CATALOG_DIR%\INPUT\TRANSIT\%TPER%_WK_2010.FAC"
FILEI LINEI[1] = "%XIT_LINES%"
FILEI NETI = "%SCENARIO_DIR%\XIT_NET_0_%TPER%.net"

    REPORT Lines=T
    REREPORT Accesslegs=T, Egresslegs=T, Xferlegs=T, Lines=T, STOPNODES=T
    HDWAYPERIOD=%TOD%

    PHASE=LINKREAD
        _wlkspd = 2.5;mph
        lw.roadtime=(li.distance/li.SPEED) * 60
    ENDPHASE

    PHASE=DATAPREP
        Print List='Build Peak Drive Access Connectors', printo=0

        ;set transit travel time
        TRANTIME[5]=li.loctime       ; local
        TRANTIME[6]=li.loctime       ; local
        TRANTIME[7]=li.exptime       ; express
        TRANTIME[8]=li.lrttime       ; lrt
        TRANTIME[9]=li.exptime       ; commuter bus

        Read FILE = "%XIT_PNRNODES%"
    ENDPHASE

ENDRUN


; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.

*copy "%SCENARIO_DIR%\XIT_WKACC_NTL_0_%TPER%.tmp"+"%CATALOG_DIR%\input\transit\WalkOverrides.txt" "%SCENARIO_DIR%\XIT_WKACC_NTL_0_%TPER%.ntl"
*copy "%SCENARIO_DIR%\XIT_XFER_NTL_0_%TPER%.tmp"+"%CATALOG_DIR%\input\transit\TransferOverrides.txt" "%SCENARIO_DIR%\XIT_XFER_NTL_0_%TPER%.ntl"
*copy "%SCENARIO_DIR%\XIT_DRACC_NTL_0_%TPER%.tmp"+"%CATALOG_DIR%\input\transit\DriveOverrides.txt" "%SCENARIO_DIR%\XIT_DRACC_NTL_0_%TPER%.ntl"
; End of PILOT Script

; Script for program PUBLIC TRANSPORT in file "C:\ABM\CUBE\TSPTR00A.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=PUBLIC TRANSPORT PRNFILE="%SCENARIO_DIR%\XIT_WK_PRN_0_%TPER%.prn" MSG='%TPER% Walk Transit Skim - Step 1'
FILEI FAREI = "%xit_fare%"
FILEO REPORTO = "%SCENARIO_DIR%\XIT_WK_RPT_0_%TPER%.RPT"
FILEO ROUTEO[1] = "%SCENARIO_DIR%\XIT_WK_RTE_0_%TPER%.RTE"
FILEO MATO[1] = "%SCENARIO_DIR%\XIT_WK_SKIM_0_%TPER%.tmp",
 MO=1-12 NAME=IVT_Bus,IVT_LB,IVT_Exp,IVT_LRT,IVT_CRT,WAIT1,WAIT2,XFERS,WALKT,FARE,XBFARE,CRTFare
FILEO NETO = "%SCENARIO_DIR%\XIT_WK_NET_0_%TPER%.NET"
FILEI FACTORI[1] = "%CATALOG_DIR%\input\transit\%TPER%_WK_2010.FAC"
FILEI NTLEGI[3] = "%SCENARIO_DIR%\XIT_XFER_NTL_0_%TPER%.ntl"
FILEI NTLEGI[2] = "%SCENARIO_DIR%\XIT_DRACC_NTL_0_%TPER%.ntl"
FILEI NTLEGI[1] = "%SCENARIO_DIR%\XIT_WKACC_NTL_0_%TPER%.ntl"
FILEI LINEI[1] = "%xit_lines%"
FILEI SYSTEMI = "%xit_system%"
FILEI NETI = "%SCENARIO_DIR%\XIT_NET_0_%TPER%.net"
FILEI FAREMATI[1] = "%xit_faremat%"

    PARAMETERS  HDWAYPERIOD=%TOD%
       
    PROCESS PHASE = DATAPREP
       TRANTIME[5]=li.loctime       ; local
       TRANTIME[6]=li.loctime       ; local
       TRANTIME[7]=li.exptime       ; express
       TRANTIME[8]=li.lrttime       ; lrt
       TRANTIME[9]=li.exptime       ; commuter bus
       GENERATE,
           READNTLEGI=1             ; walk  access link (mode=1)
       ;GENERATE,
        ;   READNTLEGI=2             ; drive access link (mode=2)
       GENERATE,
           READNTLEGI=3             ; transfer link (mode=4)
    ENDPROCESS
    
    PROCESS PHASE = SKIMIJ
        MW[1]=TIMEA(0,5)            ; IVTT for local bus (mode=5) 
        MW[2]=TIMEA(0,6)            ; IVTT local limited stop bus (mode=6)
        MW[3]=TIMEA(0,7)            ; IVTT for Express Bus (mode=7)
        MW[4]=TIMEA(0,8)            ; IVTT for LRT (mode=8)
        MW[5]=TIMEA(0,9)            ; IVTT for CRT (mode=9)
        MW[6]=IWAITA(0)             ; initial wait time
        MW[7]=XWAITA(0)             ; transfer wait time
        MW[8]=BRDINGS(0,5,6,7,8,9)  ; number of boardings
        MW[9]=TIMEA(0,1,4)          ; OVTT for walk access & transfer
        MW[10]=FAREA(0,5,6,8)       ; local, limited and LRT Fares
        MW[11]=FAREA(0,7)           ; Express Fare        
        MW[12]=FAREA(0,9)           ; CRT Fare
    ENDPROCESS

ENDRUN


; Script for program PUBLIC TRANSPORT in file "C:\ABM\CUBE\TSPTR00C.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=PUBLIC TRANSPORT PRNFILE="%SCENARIO_DIR%\XIT_DR_PRN_0_%TPER%.prn" MSG='%TPER% Drive Transit Skim - Step 1'
FILEI FAREI = "%XIT_FARE%"
FILEO REPORTO = "%SCENARIO_DIR%\XIT_DR_RPT_0_%TPER%.RPT"
FILEO ROUTEO[1] = "%SCENARIO_DIR%\XIT_DR_RTE_0_%TPER%.RTE"
FILEO MATO[1] = "%SCENARIO_DIR%\XIT_DR_SKIM_0_%TPER%.TMP",
 MO=1-14 NAME=IVT_Bus,IVT_LB,IVT_Exp,IVT_LRT,IVT_CRT,WAIT1,WAIT2,XFERS,WALKT,FARE,XBFARE,CRTFare,DR_ACCR,DR_ACCD
FILEO NETO = "%SCENARIO_DIR%\XIT_DR_NET_0_%TPER%.NET"
FILEI FACTORI[1] = "%CATALOG_DIR%\INPUT\TRANSIT\%TPER%_DR_2010.FAC"
FILEI NTLEGI[3] = "%SCENARIO_DIR%\XIT_XFER_NTL_0_%TPER%.NTL"
FILEI NTLEGI[2] = "%SCENARIO_DIR%\XIT_DRACC_NTL_0_%TPER%.NTL"
FILEI NTLEGI[1] = "%SCENARIO_DIR%\XIT_WKACC_NTL_0_%TPER%.NTL"
FILEI LINEI[1] = "%XIT_LINES%"
FILEI SYSTEMI = "%XIT_SYSTEM%"
FILEI NETI = "%SCENARIO_DIR%\XIT_NET_0_%TPER%.net"
FILEI FAREMATI[1] = "%XIT_FAREMAT%"

    PARAMETERS  HDWAYPERIOD=%TOD%
   
    PROCESS PHASE = DATAPREP
        TRANTIME[5]=li.loctime       ; local
        TRANTIME[6]=li.loctime       ; local
        TRANTIME[7]=li.exptime       ; express
        TRANTIME[8]=li.lrttime       ; lrt
        TRANTIME[9]=li.exptime       ; commuter bus
        GENERATE,
            READNTLEGI=1             ; walk  access link (mode=1)
        GENERATE,
            READNTLEGI=2             ; drive access link (mode=2)
        GENERATE,
            READNTLEGI=3             ; transfer link (mode=4)
    ENDPROCESS
    
    PROCESS PHASE = SKIMIJ
        MW[1]=TIMEA(0,5)            ; IVTT for local bus (mode=5) 
        MW[2]=TIMEA(0,6)            ; IVTT local limited stop bus (mode=6)
        MW[3]=TIMEA(0,7)            ; IVTT for Express Bus (mode=7)
        MW[4]=TIMEA(0,8)            ; IVTT for LRT (mode=8)
        MW[5]=TIMEA(0,9)            ; IVTT for CRT (mode=9)
        MW[6]=IWAITA(0)             ; initial wait time
        MW[7]=XWAITA(0)             ; transfer wait time
        MW[8]=BRDINGS(0,5,6,7,8,9)  ; number of boardings
        MW[9]=TIMEA(0,1,4)            ; OVTT for walk access & transfer
        MW[10]=FAREA(0,5,6,8)       ; local, limited and LRT Fares
        MW[11]=FAREA(0,7)           ; Express Fare        
        MW[12]=FAREA(0,9)           ; CRT Fare        
        MW[13]=TIMEA(0,2)
        MW[14]=DIST(0,2)
    ENDPROCESS
ENDRUN


; Script for program MATRIX in file "C:\ABM\CUBE\TSMAT00A.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='%TPER% Walk Skim - Step 2'
FILEO MATO[1] = "%SCENARIO_DIR%\XIT_WK_SKIM_0_%TPER%.SKM",
 MO=1-11, NAME=TRNTIME,WLKACC,WLKXFER,WLKEGR,IWAIT,XWAIT,XFERS,FARE,FAREP,FARER,FARES
FILEI MATI[1] = "%SCENARIO_DIR%\XIT_WK_SKIM_0_%TPER%.tmp"


MW[1]=MI.1.1 + MI.1.2 + MI.1.3 + MI.1.4 + MI.1.5 ; Bus, LB, Exp, LRT, CRT - IVT
MW[2]=MI.1.9      ;Walk access, Egress and Transfer Time
MW[3]=0           ; Zeroed out - do not have walk Xfer time seperate
MW[4]=0           ; Zeroed out - do not have walk Egress time seperate
MW[5]=MI.1.6      ; Inital Wait
MW[6]=MI.1.7      ; Transfer Wait
MW[7]=0
MW[8]=(MI.1.10+MI.1.11+MI.1.12)*100 ; Full Fare
MW[9]=(MI.1.10+MI.1.11+MI.1.12)*100*0.90; Reduced Fare (Pass Fare)
MW[10]=(MI.1.10+MI.1.11+MI.1.12)*100*0.90; Senior Fare (Seniors pay full fare in Peak)
MW[11]=(MI.1.10+MI.1.11+MI.1.12)*100*0.90*0.90; Student Fare
JLOOP
  IF (MI.1.8>0)
    MW[7]=MI.1.8-1    ; Transfers equals boards minus one  
  ENDIF
  IF ((I>1312 & I<1342) & (J>1312 & J<1342)) ; Downtown Minneapolis Zone
    MW[8]=50 * MI.1.8 ;Full Fare is $0.50 * boards
    MW[9]=50 * MI.1.8 ;Pass Fare is $0.50 * boards
    MW[10]=50 * MI.1.8;Senior Fare is $0.50 * boards
    MW[11]=50 * MI.1.8;Student Fare is $0.50 * boards
  ENDIF
  IF ((I>1999 & I<2022) & (J>1999 & J<2022)) ; Downtown St. Paul Zone
    MW[8]=50 * MI.1.8 ;Full Fare is $0.50 * boards
    MW[9]=50 * MI.1.8 ;Pass Fare is $0.50 * boards
    MW[10]=50 * MI.1.8;Senior Fare is $0.50 * boards
    MW[11]=50 * MI.1.8;Student Fare is $0.50 * boards
  ENDIF
ENDJLOOP


ENDRUN


; Script for program MATRIX in file "C:\ABM\CUBE\TSMAT00C.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='%TPER% Drive Skim - Step 2'
FILEO MATO[1] = "%SCENARIO_DIR%\XIT_DR_SKIM_0_%TPER%.SKM",
 MO=1-11, NAME=TRNTIME,DRACC,WLKXFER,WLKEGR,IWAIT,XWAIT,XFERS,FARE,FAREP,FARER,FARES
FILEI MATI[1] = "%SCENARIO_DIR%\XIT_DR_SKIM_0_%TPER%.TMP"

MW[1]=MI.1.1 + MI.1.2 + MI.1.3 + MI.1.4 + MI.1.5 ; Bus, LB, Exp, LRT, CRT - IVT
MW[2]=MI.1.13      ;Walk access, Egress and Transfer Time
MW[3]=0           ; Zeroed out - do not have walk Xfer time seperate
MW[4]=MI.1.9      ; Walk transfer and egress
MW[5]=MI.1.6      ; Inital Wait
MW[6]=MI.1.7      ; Transfer Wait
MW[7]=0
MW[8]=(MI.1.10+MI.1.11+MI.1.12)*100 ; Full Fare
MW[9]=(MI.1.10+MI.1.11+MI.1.12)*100*0.90; Reduced Fare (Pass Fare)
MW[10]=(MI.1.10+MI.1.11+MI.1.12)*100*0.90; Senior Fare (Seniors pay full fare in Peak)
MW[11]=(MI.1.10+MI.1.11+MI.1.12)*100*0.90*0.90; Student Fare
JLOOP
  IF (MI.1.8>0)
    MW[7]=MI.1.8-1    ; Transfers equals boards minus one  
  ENDIF
  IF ((I>1312 & I<1342) & (J>1312 & J<1342)) ; Downtown Minneapolis Zone
    MW[8]=50 * MI.1.8 ;Full Fare is $0.50 * boards
    MW[9]=50 * MI.1.8 ;Pass Fare is $0.50 * boards
    MW[10]=50 * MI.1.8;Senior Fare is $0.50 * boards
    MW[11]=50 * MI.1.8;Student Fare is $0.50 * boards
  ENDIF
  IF ((I>1999 & I<2022) & (J>1999 & J<2022)) ; Downtown St. Paul Zone
    MW[8]=50 * MI.1.8 ;Full Fare is $0.50 * boards
    MW[9]=50 * MI.1.8 ;Pass Fare is $0.50 * boards
    MW[10]=50 * MI.1.8;Senior Fare is $0.50 * boards
    MW[11]=50 * MI.1.8;Student Fare is $0.50 * boards
  ENDIF
ENDJLOOP

ENDRUN


; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.

ENDDISTRIBUTEMULTISTEP
ENDLOOP

Wait4Files FILES='transit1.script.end, transit2.script.end' CheckReturnCode=T, DelDistribFiles=T

*cluster transit 1-2 CLOSE EXIT

; End of PILOT Script

goto TransitSkim_END

:TransitSkim_END
; Script for program GENERATION in file "C:\ABM\CUBE\TSGEN00A.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=GENERATION MSG='Quick Response Freight Manual routine'
FILEO PAO[2] = "%SCENARIO_DIR%\TRK_PA.txt",
 FORM=6.0, LIST=Z, P[1],A[1], P[2], A[2]
FILEO PAO[1] = "%SCENARIO_DIR%\TRK_PA.dbf",
 FORM=6.0, DBF=T, LIST=Z, P[1], A[1], P[2], A[2]
FILEO PRINTO[1] = "%SCENARIO_DIR%\TRK_GENERATION.PRN"
FILEI ZDATI[2] = "%ext_sta%"
FILEI ZDATI[1] = "%zone_attribs%"
FILEI LOOKUPI[1] = "%qfrm%"

LOOKUP LOOKUPI=1, NAME=TGRates,      ; Rate Lookup Table
LOOKUP[1]=1,  RESULT=2,   ; Households Coefficient
LOOKUP[2]=1,  RESULT=3,   ; AMC Coefficient
LOOKUP[3]=1,  RESULT=4,   ; Manu Coefficient
LOOKUP[4]=1,  RESULT=5,   ; Retail Coefficient
LOOKUP[5]=1,  RESULT=6    ; Retail Coefficient

process phase = iloop

PARAMETERS ZONES = %ZONES%

    P[1] = (TGRates(1,1)*HOUSEHOLDS) + (TGRates(2,1)* AMC_EMP) + (TGRates(3,1)* MAN_EMP) + (TGRates(4,1)* RET_EMP) + (TGRates(5,1)* OFF_EMP) + ZI.2.HCAADT*0.14 ; 
    P[2] = (TGRates(1,2)*HOUSEHOLDS) + (TGRates(2,2)* AMC_EMP) + (TGRates(3,2)* MAN_EMP) + (TGRates(4,2)* RET_EMP) + (TGRates(5,2)* OFF_EMP) + ZI.2.HCAADT*0.36 ; 

    A[1] = P[1]
    A[2] = P[2]

ENDPROCESS

process phase = adjust
A[1] = P[1]
A[2] = P[2]
    PRINT CSV=F, LIST=' ', PRINTO=1
    PRINT CSV=F, LIST='TRUCK GENERATION OUTPUTS', PRINTO=1
    PRINT CSV=F, LIST='SINGLE-UNIT TRUCK TRIPS  = ',A[1][0], PRINTO=1
    PRINT CSV=F, LIST='COMBINATION TRUCK TRIPS  = ',A[2][0], PRINTO=1
    PRINT CSV=F, LIST=' ', PRINTO=1
ENDPROCESS

ENDRUN


; Script for program MATRIX in file "C:\ABM\CUBE\TSMAT00H.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='External Auto Allocation and Mode Choice'
FILEO PRINTO[2] = "%SCENARIO_DIR%\HWY_EXT_MARGINAL_TARGET.txt"
FILEO RECO[1] = "%SCENARIO_DIR%\HWY_EXT.dbf",
 FIELDS=ZONE,AUTOS,EE,EI_DA,EI_S2,EI_S3,IE_DA,IE_S2,IE_S3
FILEI LOOKUPI[1] = "%LU_external%"
FILEI DBI[1] = "%ext_sta%"

  zones=1
  
  _autos = 0
  _ee = 0
  _ei_da = 0
  _ei_s2 = 0
  _ei_s3 = 0
  _ie_da = 0
  _ie_s2 = 0
  _ie_s3 = 0  
  
  
  LOOKUP LOOKUPI=1, LIST=N,
  NAME=EXT, 
  LOOKUP[1]=1, RESULT=2, ; EE share
  LOOKUP[2]=1, RESULT=5, ; IE_DA share
  LOOKUP[3]=1, RESULT=6, ; IE_S2 share
  LOOKUP[4]=1, RESULT=7, ; IE_S3 share
  LOOKUP[5]=1, RESULT=8, ; EI_DA share  
  LOOKUP[6]=1, RESULT=9, ; EI_S2 share
  LOOKUP[7]=1, RESULT=10 ; EI_S3 share
  
  ;PRINT CSV=T, LIST='ZONE','AUTOS','EE','EI_DA','EI_S2','EI_S3','IE_DA','IE_S2','IE_S3' PRINTO=1

  
; loop through each external zone 
LOOP  k=1,DBI.1.NUMRECORDS
  
  x=DBIReadRecord(1,k)
  
  _autos = DI.1.AADT - DI.1.HCAADT
  
  ; write out externals for each zone
  RO.ZONE = DI.1.ZONE
  RO.AUTOS = _autos
  RO.EE =   _autos * EXT(1, DI.1.ZONE) / 100
  RO.EI_DA =  _autos * EXT(2, DI.1.ZONE) / 100
  RO.EI_S2 =  _autos * EXT(3, DI.1.ZONE) / 100
  RO.EI_S3 =  _autos * EXT(4, DI.1.ZONE) / 100
  RO.IE_DA =  _autos * EXT(5, DI.1.ZONE) / 100
  RO.IE_S2 =  _autos * EXT(6, DI.1.ZONE) / 100
  RO.IE_S3 =  _autos * EXT(7, DI.1.ZONE) / 100
  
  WRITE RECO=1
  
  ; write out external - externals too
  PRINT CSV=F, LIST=DI.1.ZONE, (RO.EE / 2), (RO.EE / 2) PRINTO=2

ENDLOOP

ENDRUN


; Script for program MATRIX in file "C:\ABM\CUBE\TSMAT00I.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Build distribution matrix for Auto EE IPF'
FILEO MATO[1] = "%SCENARIO_DIR%\HWY_EXT_JOINT_TARGET.TRP",
DEC=2, MO=1, NAME=EE_SURVEY

FILEI MATI[1] = "%ee_auto_dist%",
 PATTERN=IJ:V,FIELDS=#1,2,3

    zones = %zones%
    
    MW[1] = MI.1.1

ENDRUN


; Script for program FRATAR in file "C:\ABM\CUBE\TSFRA00A.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=FRATAR MSG='Fratar station targets using distribution from survey'
FILEO MATO[1] = "%SCENARIO_DIR%\HWY_EXT_EETRIP.TRP",
 MO=1, NAME=EE_AUTO
FILEI MATI[1] = "%SCENARIO_DIR%\HWY_EXT_JOINT_TARGET.TRP"
FILEI LOOKUPI[1] = "%SCENARIO_DIR%\HWY_EXT_MARGINAL_TARGET.txt"

  LOOKUP LOOKUPI=1,
  NAME=FRATAR,
  LOOKUP[1]=1, RESULT=2,
  LOOKUP[2]=1, RESULT=3
  
  MAXITERS=20

  SETPA P[1]=FRATAR(1,J), A[1]=FRATAR(2,J) MW[1]=MI.1.1

ENDRUN


; Script for program MATRIX in file "C:\ABM\CUBE\TSMAT00K.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Generate Airport Trips'
FILEO RECO[1] = "%SCENARIO_DIR%\HWY_SPC_PA.dbf",
 FIELDS=ORIG(8.0),DEST(8.0),TRIPS(10.2)
FILEI DBI[1] = "%zone_attribs%",
 SORT=ZONE

ZONES=1
 
LOOP k=1,DBI.1.NUMRECORDS
x=DBIReadRecord(1,k)
RO.ORIG=DBI.1.NFIELD[1]
RO.DEST=1521
RO.TRIPS=DBI.1.NFIELD[4]*0.0199
 
WRITE RECO=1
ENDLOOP

ENDRUN


; Script for program MATRIX in file "C:\ABM\CUBE\TSMAT00L.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Create Special Generator Matrix'
FILEI LOOKUPI[1] = "%LU_spc_tod%"
FILEO MATO[1] = "%SCENARIO_DIR%\HWY_SPC_TRIP.trp",
 MO=1-11, NAME= AM1, AM2, AM3, AM4, MD, PM1, PM2, PM3, PM4, EV, ON
FILEI MATI[1] = "%SCENARIO_DIR%\HWY_SPC_PA.dbf",
 PATTERN=IJ:V, FIELDS=ORIG, DEST, TRIPS


  LOOKUP LOOKUPI=1, NAME=TODL,
  LOOKUP[1]=1, RESULT=2, ; AM1
  LOOKUP[2]=1, RESULT=3, ; AM2
  LOOKUP[3]=1, RESULT=4, ; AM3
  LOOKUP[4]=1, RESULT=5, ; AM4
  LOOKUP[5]=1, RESULT=6, ; MD
  LOOKUP[6]=1, RESULT=7, ; PM1
  LOOKUP[7]=1, RESULT=8, ; PM2
  LOOKUP[8]=1, RESULT=9, ; PM3
  LOOKUP[9]=1, RESULT=10, ; PM4
  LOOKUP[10]=1, RESULT=11,  ; EV
  LOOKUP[11]=1, RESULT=12  ; NT
  
  zones=%zones%
  
  MW[1]= MI.1.1 * TODL(1,1)
  MW[2]= MI.1.1 * TODL(2,1)
  MW[3]= MI.1.1 * TODL(3,1)
  MW[4]= MI.1.1 * TODL(4,1)
  MW[5]= MI.1.1 * TODL(5,1)        
  MW[6]= MI.1.1 * TODL(6,1)
  MW[7]= MI.1.1 * TODL(7,1)
  MW[8]= MI.1.1 * TODL(8,1)
  MW[9]= MI.1.1 * TODL(9,1)
  MW[10]= MI.1.1 * TODL(10,1)   
  MW[11]= MI.1.1 * TODL(11,1)          
        
        
ENDRUN


; Script for program FRATAR in file "C:\ABM\CUBE\TSFRA00B.S"
;;<<Default Template>><<FRATAR>><<Default>>;;
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=FRATAR MSG='Fratar EE truck from FAF'
FILEO MATO[1] = "%SCENARIO_DIR%\EE_FRATAR_TMP.MAT",
 MO=1, DEC=1, NAME=EE_TRK
FILEI LOOKUPI[1] = "%ee_fratar%"
FILEI MATI[1] = "%ee_trk_dist%"
LOOKUP LOOKUPI=1,
 NAME=FRATAR,
  LOOKUP[1]=1, RESULT=2,
  LOOKUP[2]=1, RESULT=3
    MAXRMSE=0.01
  MAXITERS=99
  SETPA P[1]=FRATAR(1,J), A[1]=FRATAR(2,J) MW[1]=MI.1.1

ENDRUN


; Script for program MATRIX in file "C:\ABM\CUBE\TSMAT00M.S"
;;<<Default Template>><<MATRIX>><<Default>>;;
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Split into two types'
FILEO MATO[1] = "%SCENARIO_DIR%\EE_FRATAR_TRK.MAT",
 MO=1-2, DEC=1, NAME=SINGLEUNIT, COMBINATION
FILEI MATI[1] = "%SCENARIO_DIR%\EE_FRATAR_TMP.MAT"

MW[1]=MI.1.1*0.727
MW[2]=MI.1.1*0.273

ENDRUN


LOOP ITER = 1, 20, 1

; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.

PREV_ITER = ITER - 1

IF (ITER==1)
  ;*copy "%CATALOG_DIR%\input\SchoolTAZs.csv" "%SCENARIO_DIR%\SchoolTAZs.csv"
  *copy "%zone_attribs%" "%SCENARIO_DIR%\zones_0.dbf"
ENDIF
; End of PILOT Script

; Script for program MATRIX in file "C:\ABM\CUBE\EVMAT00A.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Highway Accessibility'
FILEI ZDATI[1] = "%SCENARIO_DIR%\zones_%PREV_ITER%.dbf"

FILEO PRINTO[1] = "%SCENARIO_DIR%\highway_accessibility.csv"
FILEI MATI[1] = "%SCENARIO_DIR%\HWY_SKIM_%PREV_ITER%_AM.skm"

; This script creates highway accessibility measures for each TAZ
; Inputs- Highway skim file (HWY_SKIM_4_AM.skm) and Zonal Data File (zones.dbf)
; Output - Highway accessibility measures (highway accessibility.csv)
; Moby Khan 11/2/16

Zones = %int_zones%

mw[100]=mi.1.daptime

; Six different constants are used to calculate six different highway accessibility measures
C_1=1
C_2=2
C_5=5
C_10=10
C_15=15
C_20=20

; The following loop calculates T_bar
if (i=1)
  LOOP a=1,Zones
    LOOP b=1,Zones
      if (matval(1,1,a,b)>0)
        T_sum = T_sum + matval(1,1,a,b)
        NumPairs = NumPairs + 1
      endif
    ENDLOOP
  ENDLOOP
  T_bar = T_sum / NumPairs
endif

; Use a constant value of T_bar if desired
; T_bar=44.2

; Calculate first step of accessibility measure for all ij pair based on the formula emp_j * exp(-C*T_ij/T_bar)
jloop
  mw[1]=zi.1.tot_emp[j]*exp(-1*C_1*mw[100]/T_bar) ;accvalT1
  mw[2]=zi.1.tot_emp[j]*exp(-1*C_2*mw[100]/T_bar) ;accvalT2 
  mw[3]=zi.1.tot_emp[j]*exp(-1*C_5*mw[100]/T_bar) ;accvalT5 
  mw[4]=zi.1.tot_emp[j]*exp(-1*C_10*mw[100]/T_bar) ;accvalT10 
  mw[5]=zi.1.tot_emp[j]*exp(-1*C_15*mw[100]/T_bar) ;accvalT15 
  mw[6]=zi.1.tot_emp[j]*exp(-1*C_20*mw[100]/T_bar) ;accvalT20 
  mw[7]=zi.1.ret_emp[j]*exp(-1*C_1*mw[100]/T_bar) ;accvalR1 
  mw[8]=zi.1.ret_emp[j]*exp(-1*C_2*mw[100]/T_bar) ;accvalR2 
  mw[9]=zi.1.ret_emp[j]*exp(-1*C_5*mw[100]/T_bar) ;accvalR5 
  mw[10]=zi.1.ret_emp[j]*exp(-1*C_10*mw[100]/T_bar) ;accvalR10 
  mw[11]=zi.1.ret_emp[j]*exp(-1*C_15*mw[100]/T_bar) ;accvalR15 
  mw[12]=zi.1.ret_emp[j]*exp(-1*C_20*mw[100]/T_bar) ;accvalR20 
  mw[13]=zi.1.nret_emp[j]*exp(-1*C_1*mw[100]/T_bar) ;accvalN1
  mw[14]=zi.1.nret_emp[j]*exp(-1*C_2*mw[100]/T_bar) ;accvalN2
  mw[15]=zi.1.nret_emp[j]*exp(-1*C_5*mw[100]/T_bar) ;accvalN5
  mw[16]=zi.1.nret_emp[j]*exp(-1*C_10*mw[100]/T_bar) ;accvalN10
  mw[17]=zi.1.nret_emp[j]*exp(-1*C_15*mw[100]/T_bar) ;accvalN15
  mw[18]=zi.1.nret_emp[j]*exp(-1*C_20*mw[100]/T_bar) ;accvalN20
  if(mi.1.daptoll>0)
    mw[19]=zi.1.tot_emp[j]*exp(-1*C_1*mw[100]/T_bar) ;accvalM1
    mw[20]=zi.1.tot_emp[j]*exp(-1*C_2*mw[100]/T_bar) ;accvalM2
    mw[21]=zi.1.tot_emp[j]*exp(-1*C_5*mw[100]/T_bar) ;accvalM5
    mw[22]=zi.1.tot_emp[j]*exp(-1*C_10*mw[100]/T_bar) ;accvalM10
    mw[23]=zi.1.tot_emp[j]*exp(-1*C_15*mw[100]/T_bar) ;accvalM15
    mw[24]=zi.1.tot_emp[j]*exp(-1*C_20*mw[100]/T_bar) ;accvalM20
  endif
endjloop


; Declare arrays(columns) for each of the accesibility measures
ARRAY TEhwyacc1=Zones,TEhwyacc2=Zones,TEhwyacc5=Zones,TEhwyacc10=Zones,TEhwyacc15=Zones,TEhwyacc20=Zones,REhwyacc1=Zones,REhwyacc2=Zones,REhwyacc5=Zones,REhwyacc10=Zones,REhwyacc15=Zones,REhwyacc20=Zones,NEhwyacc1=Zones,NEhwyacc2=Zones,NEhwyacc5=Zones,NEhwyacc10=Zones,NEhwyacc15=Zones,NEhwyacc20=Zones,MEhwyacc1=Zones,MEhwyacc2=Zones,MEhwyacc5=Zones,MEhwyacc10=Zones,MEhwyacc15=Zones,MEhwyacc20=Zones

; Sum across all rows(js), add 1 and take natural log to obtain accessibility measures for all i
; Highway accessibility Measures are calculated for Total Employment, Retail Employment, Non-retail employment and finally for MnPass Connections

; Total Employment Accessibility
TEhwyacc1[i]=ln(1+rowsum(1))
TEhwyacc2[i]=ln(1+rowsum(2))
TEhwyacc5[i]=ln(1+rowsum(3))
TEhwyacc10[i]=ln(1+rowsum(4))
TEhwyacc15[i]=ln(1+rowsum(5))
TEhwyacc20[i]=ln(1+rowsum(6))

; Retail Employment Accessibility
REhwyacc1[i]=ln(1+rowsum(7))
REhwyacc2[i]=ln(1+rowsum(8))
REhwyacc5[i]=ln(1+rowsum(9))
REhwyacc10[i]=ln(1+rowsum(10))
REhwyacc15[i]=ln(1+rowsum(11))
REhwyacc20[i]=ln(1+rowsum(12))

; Non-retail Employment Accessibility
NEhwyacc1[i]=ln(1+rowsum(13))
NEhwyacc2[i]=ln(1+rowsum(14))
NEhwyacc5[i]=ln(1+rowsum(15))
NEhwyacc10[i]=ln(1+rowsum(16))
NEhwyacc15[i]=ln(1+rowsum(17))
NEhwyacc20[i]=ln(1+rowsum(18))

; MnPass Accesibility 
MEhwyacc1[i]=ln(1+rowsum(19))
MEhwyacc2[i]=ln(1+rowsum(20))
MEhwyacc5[i]=ln(1+rowsum(21))
MEhwyacc10[i]=ln(1+rowsum(22))
MEhwyacc15[i]=ln(1+rowsum(23))
MEhwyacc20[i]=ln(1+rowsum(24))


; Create csv headers
if(i=1)
print csv=T,
printo=1,list="Zone","TEhwyacc1","TEhwyacc2","TEhwyacc5","TEhwyacc10","TEhwyacc15","TEhwyacc20",
"REhwyacc1","REhwyacc2","REhwyacc5","REhwyacc10","REhwyacc15","REhwyacc20",
"NEhwyacc1","NEhwyacc2","NEhwyacc5","NEhwyacc10","NEhwyacc15","NEhwyacc20",
"MEhwyacc1","MEhwyacc2","MEhwyacc5","MEhwyacc10","MEhwyacc15","MEhwyacc20"
endif

; Output actual data
print csv=T,
printo=1,list=i,form=10.10,list=TEhwyacc1[i],TEhwyacc2[i],TEhwyacc5[i],TEhwyacc10[i],TEhwyacc15[i],TEhwyacc20[i],
REhwyacc1[i],REhwyacc2[i],REhwyacc5[i],REhwyacc10[i],REhwyacc15[i],REhwyacc20[i],
NEhwyacc1[i],NEhwyacc2[i],NEhwyacc5[i],NEhwyacc10[i],NEhwyacc15[i],NEhwyacc20[i],
MEhwyacc1[i],MEhwyacc2[i],MEhwyacc5[i],MEhwyacc10[i],MEhwyacc15[i],MEhwyacc20[i]

ENDRUN


; Script for program MATRIX in file "C:\ABM\CUBE\EVMAT00B.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Transit Accessibility'
FILEI ZDATI[1] = "%SCENARIO_DIR%\zones_%PREV_ITER%.dbf"

FILEO PRINTO[1] = "%SCENARIO_DIR%\transit_accessibility.csv"
FILEI MATI[1] = "%SCENARIO_DIR%\XIT_WK_SKIM_%PREV_ITER%_PK.SKM"

; This script creates transit accessibility measures for each TAZ
; Inputs- Transit skim file (PK_XIT_WK.SKM) and Zonal Data File (zones.dbf)
; Output - Transit accessibility measures (transit_accessibility.csv)
; Moby Khan 11/2/16

Zones = %int_zones%

; Six different constants are used to calculate six different transit accessibility measures
mw[100]=mi.1.TRNTIME
C_1=1
C_2=2
C_5=5
C_10=10
C_15=15
C_20=20

; The following loop calculates T_bar
if (i=1) ; this if statement makes sure T_bar is calculated only once since it is the same for all i's
  LOOP a=1,Zones
    LOOP b=1,Zones
      if (matval(1,1,a,b)>0)
        T_sum = T_sum + matval(1,1,a,b)
        NumPairs = NumPairs + 1
      endif
    ENDLOOP
  ENDLOOP
  T_bar = T_sum / NumPairs
endif


; Use a constant value of T_bar if desired, otherwise T_bar is calculated in step above
; T_bar=38.65447734

; Calculate first step of accessibility measure for all ij pair based on the formula emp_j * exp(-C*T_ij/T_bar)
jloop
  if(mw[100]>0) ; check that transit skims exist for ij pair, otherwise accessibility is 0
    mw[1]=zi.1.tot_emp[j]*exp(-1*C_1*mw[100]/T_bar) ;accvalT1
    mw[2]=zi.1.tot_emp[j]*exp(-1*C_2*mw[100]/T_bar) ;accvalT2 
    mw[3]=zi.1.tot_emp[j]*exp(-1*C_5*mw[100]/T_bar) ;accvalT5 
    mw[4]=zi.1.tot_emp[j]*exp(-1*C_10*mw[100]/T_bar) ;accvalT10 
    mw[5]=zi.1.tot_emp[j]*exp(-1*C_15*mw[100]/T_bar) ;accvalT15 
    mw[6]=zi.1.tot_emp[j]*exp(-1*C_20*mw[100]/T_bar) ;accvalT20 
    mw[7]=zi.1.ret_emp[j]*exp(-1*C_1*mw[100]/T_bar) ;accvalR1 
    mw[8]=zi.1.ret_emp[j]*exp(-1*C_2*mw[100]/T_bar) ;accvalR2 
    mw[9]=zi.1.ret_emp[j]*exp(-1*C_5*mw[100]/T_bar) ;accvalR5 
    mw[10]=zi.1.ret_emp[j]*exp(-1*C_10*mw[100]/T_bar) ;accvalR10 
    mw[11]=zi.1.ret_emp[j]*exp(-1*C_15*mw[100]/T_bar) ;accvalR15 
    mw[12]=zi.1.ret_emp[j]*exp(-1*C_20*mw[100]/T_bar) ;accvalR20 
    mw[13]=zi.1.nret_emp[j]*exp(-1*C_1*mw[100]/T_bar) ;accvalN1
    mw[14]=zi.1.nret_emp[j]*exp(-1*C_2*mw[100]/T_bar) ;accvalN2
    mw[15]=zi.1.nret_emp[j]*exp(-1*C_5*mw[100]/T_bar) ;accvalN5
    mw[16]=zi.1.nret_emp[j]*exp(-1*C_10*mw[100]/T_bar) ;accvalN10
    mw[17]=zi.1.nret_emp[j]*exp(-1*C_15*mw[100]/T_bar) ;accvalN15
    mw[18]=zi.1.nret_emp[j]*exp(-1*C_20*mw[100]/T_bar) ;accvalN20
  endif
endjloop

; Declare arrays(columns) for each of the accesibility measures
ARRAY TETRacc1=Zones,TETRacc2=Zones,TETRacc5=Zones,TETRacc10=Zones,TETRacc15=Zones,TETRacc20=Zones,RETRacc1=Zones,RETRacc2=Zones,RETRacc5=Zones,RETRacc10=Zones,RETRacc15=Zones,RETRacc20=Zones,NETRacc1=Zones,NETRacc2=Zones,NETRacc5=Zones,NETRacc10=Zones,NETRacc15=Zones,NETRacc20=Zones

; Sum across all rows(js), add 1 and take natural log to obtain accessibility measures

; Total Employment Accessibility
TETRacc1[i]=ln(1+rowsum(1))
TETRacc2[i]=ln(1+rowsum(2))
TETRacc5[i]=ln(1+rowsum(3))
TETRacc10[i]=ln(1+rowsum(4))
TETRacc15[i]=ln(1+rowsum(5))
TETRacc20[i]=ln(1+rowsum(6))

; Retail Employment Accessibility
RETRacc1[i]=ln(1+rowsum(7))
RETRacc2[i]=ln(1+rowsum(8))
RETRacc5[i]=ln(1+rowsum(9))
RETRacc10[i]=ln(1+rowsum(10))
RETRacc15[i]=ln(1+rowsum(11))
RETRacc20[i]=ln(1+rowsum(12))

; Non-retail Employment Accessibility
NETRacc1[i]=ln(1+rowsum(13))
NETRacc2[i]=ln(1+rowsum(14))
NETRacc5[i]=ln(1+rowsum(15))
NETRacc10[i]=ln(1+rowsum(16))
NETRacc15[i]=ln(1+rowsum(17))
NETRacc20[i]=ln(1+rowsum(18))


; Create csv headers
if(i=1)
  print csv=T,
  printo=1,list="Zone","TETRacc1","TETRacc2","TETRacc5","TETRacc10","TETRacc15","TETRacc20",
  "RETRacc1","RETRacc2","RETRacc5","RETRacc10","RETRacc15","RETRacc20",
  "NETRacc1","NETRacc2","NETRacc5","NETRacc10","NETRacc15","NETRacc20"
endif

; Output actual data
print csv=T,
printo=1,list=i,form=10.10,list=TETRacc1[i],TETRacc2[i],TETRacc5[i],TETRacc10[i],TETRacc15[i],TETRacc20[i],
RETRacc1[i],RETRacc2[i],RETRacc5[i],RETRacc10[i],RETRacc15[i],RETRacc20[i],
NETRacc1[i],NETRacc2[i],NETRacc5[i],NETRacc10[i],NETRacc15[i],NETRacc20[i]


ENDRUN


; Script for program MATRIX in file "C:\ABM\CUBE\EVMAT00C.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Distance to External'

FILEO PRINTO[1] = "%SCENARIO_DIR%\distancetoexternal.csv"
FILEI MATI[1] = "%SCENARIO_DIR%\HWY_SKIM_%PREV_ITER%_MD.skm"

; This script calculates the minimum distance to external zone for each TAZ
; Input- Highway skim file (HWY_SKIM_4_AM.skm)
; Output - Distance to closest external TAZ for each TAZ (distancetoexternal.csv)
; Moby Khan 11/2/16

Zones = %int_zones%

; Use drive alone distance for distance measure
mw[100]=mi.1.dapdist

; Initiate with a large MINDIST which will be overwritten subsequently
MINDIST=1000

; Loop through only external zones
jloop
  if (j=2918,2916,2960,2958,2959,2863,2864,2861,2860,2855,3001,3004,2993,2973,2974,2994,
  2995,2987,3021,3022,3019,2527,2554,2553,2558,2557,2556,2555,2573,2572,2601,2603,
  2510,2602,2607,2807,2806,2808,2838,2835,2824,2826,2827,2829,2828,2865,2857,2531,
  2534,2532,2533,2537,2739,2757,2758,2759,2742,2760,2761,2762,2683,2696,2684,2699,
  2775,2776,2777,2779,2599,2600,2591,2569,2571,2570,2559,2707,2708,2712,2713,2714,
  2716,2717,2718,2726,2605,2606,2612,2613,2627,2629)
    if (MINDIST>mw[100]) ; Check if current ij distance is smaller than previous MINDIST
      MINDIST=MW[100] ; Update MINDIST with new distance
    endif
  endif
endjloop

; Create csv headers
if(i=1)
print csv=T,
printo=1,list="Zone","MINDIST"
endif

; Output actual data
print csv=T,
printo=1,list=i,MINDIST



ENDRUN


; Script for program MATRIX in file "C:\ABM\CUBE\EVMAT00D.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='School TAZs'

FILEO PRINTO[1] = "%SCENARIO_DIR%\TAZ_SchoolList.csv"
FILEI ZDATI[1] = "%CATALOG_DIR%\\Input\SchoolTAZs.csv",
Z=#1,District=#2,Sch1TAZs=#3,Sch2TAZs=#4,Sch3TAZs=#5,wSch1=#6,wSch2=#7,wSch3=#8
FILEI MATI[1] = "%SCENARIO_DIR%\HWY_SKIM_%PREV_ITER%_MD.skm"

; This script outputs 10 closest school TAZs for each TAZ
; Inputs- Highway skim file (HWY_SKIM_4_AM.skm) and list of TAZs with school Districts, Number of school TAZs within district and school TAZ indicator
; Output - List of 10 closest TAZs in order for three types of schools, for each TAZ in the model
; Moby Khan 11/2/16

Zones = %int_zones%

; Use SR offpeak distance to identify closest schools
mw[100]=mi.1.a2pdist

; Declare two arrays for-
; SCH1NUM which contains 10 closest elementary school TAZs for each TAZ
; distSch1TAZ which contains the distance to these 10 closest TAZs

ARRAY SCH1NUM=Zones,10, dist_Sch1TAZ=Zones,10

; Calculate SCH1NUM1
dist_Sch1TAZ[i][1]=1000 ; Initiate with a large distance which gets replaced when a shorter distance is encountered
if (wSch1[i]>0) ; if the TAZ itself contains a school, then the closest TAZ is itself
  SCH1NUM[i][1]=i
  dist_Sch1TAZ[i][1]=matval(1,dapdist,i,i)
  else 
    jloop ; otherwise loop through all js to pick the closest school TAZ
      if (District[i]=District[j] & wSch1[j]>0) ; check to make sure that the school districts are same and destination j is a TAZ w/school
        if (dist_Sch1TAZ[i][1] > mw[100]) ; if the distance to the previously selected zone is larger than the distance to current zone
          SCH1NUM[i][1] = j ; replace the TAZ with current zone
          dist_Sch1TAZ[i][1] = mw[100] ; update the distance, loop through remaining js
        endif
      endif
    endjloop 
endif

; Calculate SCH1NUM2 through SCH1NUM10 by initiating a loop SCH1LOOP that corresponds to 2-10
LOOP SCH1LOOP=2,10
  dist_Sch1TAZ[i][SCH1LOOP]=1000 ; Initiate with a large distance which gets replaced when a shorter distance is encountered
  
  ; if the number of schools within the school district is less than the loop number, set school TAZ to 0. For example, the 5th school TAZ for a district that has only 4 schools should be 0
  if (Sch1TAZs[i]<SCH1LOOP) 
    SCH1NUM[i][SCH1LOOP]=0
    else
      jloop ; otherwise loop through all js to pick the next closest school TAZ
        if (District[i]=District[j] & wSch1[j]>0) ; check to make sure that the school districts are same and destination j is a TAZ w/school
          if (dist_Sch1TAZ[i][SCH1LOOP] > mw[100] & mw[100]>=dist_Sch1TAZ[i][SCH1LOOP-1] & j!=SCH1NUM[i][SCH1LOOP-1])
          ; check that the previous distance is larger than the new distance
          ; check that the distance to the current zone is greater than or equal to the previous closest TAZ
          ; check that the current zone is not the same as the previous or (n-1)th TAZ
            if (SCH1LOOP>2) ; check that the current zone is not the same as (n-2)th TAZ
                if (SCH1NUM[i][SCH1LOOP-2]!=j)
                  SCH1NUM[i][SCH1LOOP] = j ; replace the TAZ with current zone
                  dist_Sch1TAZ[i][SCH1LOOP] = mw[100]
                endif
            else
              SCH1NUM[i][SCH1LOOP] = j ; replace the TAZ with current zone
              dist_Sch1TAZ[i][SCH1LOOP] = mw[100] ; update the distance, loop through remaining js
            endif
          endif
        endif
      endjloop 
  endif
ENDLOOP


; Repeat above for School types 2 and 3 (Middle and High School)

ARRAY SCH2NUM=Zones,10, dist_Sch2TAZ=Zones,10

; Calculate SCH2NUM1
dist_Sch2TAZ[i][1]=1000 ; Initiate with a large distance which gets replaced when a shorter distance is encountered
if (wSch2[i]>0) ; if the TAZ itself contains a school, then the closest TAZ is itself
  SCH2NUM[i][1]=i
  dist_Sch2TAZ[i][1]=matval(1,dapdist,i,i)
  else 
    jloop ; otherwise loop through all js to pick the closest school TAZ
      if (District[i]=District[j] & wSch2[j]>0) ; check to make sure that the school districts are same and destination j is a TAZ w/school
        if (dist_Sch2TAZ[i][1] > mw[100]) ; if the distance to the previously selected zone is larger than the distance to current zone
          SCH2NUM[i][1] = j ; replace the TAZ with current zone
          dist_Sch2TAZ[i][1] = mw[100] ; update the distance, loop through remaining js
        endif
      endif
    endjloop 
endif

; Calculate SCH2NUM2 through SCH2NUM10 by initiating a loop SCH2LOOP that corresponds to 2-10
LOOP SCH2LOOP=2,10
  dist_Sch2TAZ[i][SCH2LOOP]=1000 ; Initiate with a large distance which gets replaced when a shorter distance is encountered
  
  ; if the number of schools within the school district is less than the loop number, set school TAZ to 0. For example, the 5th school TAZ for a district that has only 4 schools should be 0
  if (Sch2TAZs[i]<SCH2LOOP) 
    SCH2NUM[i][SCH2LOOP]=0
    else
      jloop ; otherwise loop through all js to pick the next closest school TAZ
        if (District[i]=District[j] & wSch2[j]>0) ; check to make sure that the school districts are same and destination j is a TAZ w/school
          if (dist_Sch2TAZ[i][SCH2LOOP] > mw[100] & mw[100]>=dist_Sch2TAZ[i][SCH2LOOP-1] & j!=SCH2NUM[i][SCH2LOOP-1])
          ; check that the previous distance is larger than the new distance
          ; check that the distance to the current zone is greater than or equal to the previous closest TAZ
          ; check that the current zone is not the same as the previous or (n-1)th TAZ
            if (SCH2LOOP>2) ; check that the current zone is not the same as (n-2)th TAZ
                if (SCH2NUM[i][SCH2LOOP-2]!=j)
                  SCH2NUM[i][SCH2LOOP] = j ; replace the TAZ with current zone
                  dist_Sch2TAZ[i][SCH2LOOP] = mw[100]
                endif
            else
              SCH2NUM[i][SCH2LOOP] = j ; replace the TAZ with current zone
              dist_Sch2TAZ[i][SCH2LOOP] = mw[100] ; update the distance, loop through remaining js
            endif
          endif
        endif
      endjloop 
  endif
ENDLOOP


ARRAY SCH3NUM=Zones,10, dist_Sch3TAZ=Zones,10

; Calculate SCH3NUM1
dist_Sch3TAZ[i][1]=1000 ; Initiate with a large distance which gets replaced when a shorter distance is encountered
if (wSch3[i]>0) ; if the TAZ itself contains a school, then the closest TAZ is itself
  SCH3NUM[i][1]=i
  dist_Sch3TAZ[i][1]=matval(1,dapdist,i,i)
  else 
    jloop ; otherwise loop through all js to pick the closest school TAZ
      if (District[i]=District[j] & wSch3[j]>0) ; check to make sure that the school districts are same and destination j is a TAZ w/school
        if (dist_Sch3TAZ[i][1] > mw[100]) ; if the distance to the previous zone is larger than the distance to current zone
          SCH3NUM[i][1] = j ; replace the TAZ with current zone
          dist_Sch3TAZ[i][1] = mw[100] ; update the distance, loop through remaining js
        endif
      endif
    endjloop 
endif

; Calculate SCH3NUM2 through SCH3NUM10 by initiating a loop SCH3LOOP that corresponds to 2-10
LOOP SCH3LOOP=2,10
  dist_Sch3TAZ[i][SCH3LOOP]=1000 ; Initiate with a large distance which gets replaced when a shorter distance is encountered
  
  ; if the number of schools within the school district is less than the loop number, set school TAZ to 0. For example, the 5th school TAZ for a district that has only 4 schools should be 0
  if (Sch3TAZs[i]<SCH3LOOP) 
    SCH3NUM[i][SCH3LOOP]=0
    else
      jloop ; otherwise loop through all js to pick the next closest school TAZ
        if (District[i]=District[j] & wSch3[j]>0) ; check to make sure that the school districts are same and destination j is a TAZ w/school
          if (dist_Sch3TAZ[i][SCH3LOOP] > mw[100] & mw[100]>=dist_Sch3TAZ[i][SCH3LOOP-1] & j!=SCH3NUM[i][SCH3LOOP-1])
          ; check that the previous distance is larger than the new distance
          ; check that the distance to the current zone is greater than or equal to the previous closest TAZ
          ; check that the current zone is not the same as the previous or (n-1)th TAZ
            if (SCH3LOOP>2) ; check that the current zone is not the same as (n-2)th TAZ
                if (SCH3NUM[i][SCH3LOOP-2]!=j)
                  SCH3NUM[i][SCH3LOOP] = j ; replace the TAZ with current zone
                  dist_Sch3TAZ[i][SCH3LOOP] = mw[100]
                endif
            else
              SCH3NUM[i][SCH3LOOP] = j ; replace the TAZ with current zone
              dist_Sch3TAZ[i][SCH3LOOP] = mw[100] ; update the distance, loop through remaining js
            endif
          endif
        endif
      endjloop 
  endif
ENDLOOP




; Create csv headers
if(i=1)
print csv=T,
printo=1,list="Zone","SCH1NUM1","SCH1NUM2","SCH1NUM3","SCH1NUM4","SCH1NUM5","SCH1NUM6","SCH1NUM7","SCH1NUM8","SCH1NUM9","SCH1NUM10","SCH2NUM1","SCH2NUM2","SCH2NUM3","SCH2NUM4","SCH2NUM5","SCH2NUM6","SCH2NUM7","SCH2NUM8","SCH2NUM9","SCH2NUM10","SCH3NUM1","SCH3NUM2","SCH3NUM3","SCH3NUM4","SCH3NUM5","SCH3NUM6","SCH3NUM7","SCH3NUM8","SCH3NUM9","SCH3NUM10"
endif

; Output actual data
print csv=T,
printo=1,form=10.0,list=i,SCH1NUM[i][1],SCH1NUM[i][2],SCH1NUM[i][3],SCH1NUM[i][4],SCH1NUM[i][5],SCH1NUM[i][6],SCH1NUM[i][7],SCH1NUM[i][8],SCH1NUM[i][9],SCH1NUM[i][10],SCH2NUM[i][1],SCH2NUM[i][2],SCH2NUM[i][3],SCH2NUM[i][4],SCH2NUM[i][5],SCH2NUM[i][6],SCH2NUM[i][7],SCH2NUM[i][8],SCH2NUM[i][9],SCH2NUM[i][10],SCH3NUM[i][1],SCH3NUM[i][2],SCH3NUM[i][3],SCH3NUM[i][4],SCH3NUM[i][5],SCH3NUM[i][6],SCH3NUM[i][7],SCH3NUM[i][8],SCH3NUM[i][9],SCH3NUM[i][10]

ENDRUN


; Script for program MATRIX in file "C:\ABM\CUBE\EVMAT00E.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='University Enrollment'
FILEI ZDATI[1] = "%SCENARIO_DIR%\zones_%PREV_ITER%.dbf"
FILEI MATI[1] = "%SCENARIO_DIR%\HWY_SKIM_%PREV_ITER%_AM.skm"
FILEO PRINTO[1] = "%SCENARIO_DIR%\universityenrollment.csv"

; This script calculated university enrollment based on 1,2,5 and 10 mile buffers around TAZs.
; Inputs- Highway skim file (HWY_SKIM_4_AM.skm) and Zonal Data File (zones.dbf)
; Output - University Enrollment for each TAZ by distance buffers (universityenrollment.csv)
; Moby Khan 11/2/16

Zones = %int_zones%

; Buffer is based on drive-alone distance
mw[100]=mi.1.dapdist

; Create arrays for each buffers - 1,2,5 and 10 miles
ARRAY ENROLLED1=Zones,ENROLLED2=Zones,ENROLLED5=Zones,ENROLLED10=Zones

; Loop through all j's and sum enrollment if destination j is within the buffer
jloop
  if (mw[100]<=1) ; 1 mile
    ENROLLED1[i] = ENROLLED1[i] + zi.1.ENROLLED[j]
  endif
  if (mw[100]<=2) ; 2 miles
    ENROLLED2[i] = ENROLLED2[i] + zi.1.ENROLLED[j]
  endif
  if (mw[100]<=5) ; 5 miles
    ENROLLED5[i] = ENROLLED5[i] + zi.1.ENROLLED[j]
  endif
  if (mw[100]<=10) ; 10 miles
    ENROLLED10[i] = ENROLLED10[i] + zi.1.ENROLLED[j]
  endif
endjloop


; Create csv headers
if(i=1)
print csv=T,
printo=1,list="Zone","ENROLLED1","ENROLLED2","ENROLLED5","ENROLLED10"
endif

; Output actual data
print csv=T,
printo=1,list=i,form=10.0,list=ENROLLED1[i],ENROLLED2[i],ENROLLED5[i],ENROLLED10[i]


ENDRUN


; Script for program MATRIX in file "C:\ABM\CUBE\EVMAT00F.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Update Zonal Database'
FILEI ZDATI[1] = "%SCENARIO_DIR%\zones_%PREV_ITER%.dbf"
FILEO RECO[1] = "%SCENARIO_DIR%\zones_%ITER%.dbf",
form=10.0,FIELDS=ZONE,ZONEID,POPULATION,HOUSEHOLDS,RET_EMP,NRET_EMP,AMC_EMP,MAN_EMP,OFF_EMP,MED1_EMP,MED2_EMP,RST_EMP,K12_EMP,ENT_EMP,TOT_EMP,
form=10.8,FIELDS=AREA,MIX_DENS,
form=10.0,FIELDS=TERM_TIME,
form=10.0,FIELDS=PARK_COST,NONWRKPRK,
form=10.0,FIELDS=ENROLLED,ENROLLED2,ENROLLED5,ENROLLED10,
form=10.8,FIELDS=TETRACC15,TEHWYACC10,REHWYACC10,NEHWYACC10,MEHWYACC10,
form=10.2,FIELDS=EXT_DIST,
form=10.0,FIELDS=CBD,SUBURB3,SUBURB2,RURAL,
form=10.8,FIELDS=HHDENSITY,LOGMXDENS,RETEMPDEN,POPDENS,TOTEMPDEN,TRHWACCRAT,
form=10.0,FIELDS=TW_ACC,SCH1NUM1,SCH1NUM2,SCH1NUM3,SCH1NUM4,SCH1NUM5,SCH1NUM6,SCH1NUM7,SCH1NUM8,SCH1NUM9,SCH1NUM10,SCH2NUM1,SCH2NUM2,SCH2NUM3,SCH2NUM4,SCH2NUM5,SCH2NUM6,SCH2NUM7,SCH2NUM8,SCH2NUM9,SCH2NUM10,SCH3NUM1,SCH3NUM2,SCH3NUM3,SCH3NUM4,SCH3NUM5,SCH3NUM6,SCH3NUM7,SCH3NUM8,SCH3NUM9,SCH3NUM10,DISTRICT
FILEI ZDATI[6] = "%SCENARIO_DIR%\universityenrollment.csv",
 Z=#1,ENROLLED2=#3,ENROLLED5=#4,ENROLLED10=#5
FILEI ZDATI[5] = "%SCENARIO_DIR%\TAZ_SchoolList.csv",
 Z=#1,SCH1NUM1=#2,SCH1NUM2=#3,SCH1NUM3=#4,SCH1NUM4=#5,SCH1NUM5=#6,SCH1NUM6=#7,SCH1NUM7=#8,SCH1NUM8=#9,SCH1NUM9=#10,SCH1NUM10=#11,SCH2NUM1=#12,SCH2NUM2=#13,SCH2NUM3=#14,SCH2NUM4=#15,SCH2NUM5=#16,SCH2NUM6=#17,SCH2NUM7=#18,SCH2NUM8=#19,SCH2NUM9=#20,SCH2NUM10=#21,SCH3NUM1=#22,SCH3NUM2=#23,SCH3NUM3=#24,SCH3NUM4=#25,SCH3NUM5=#26,SCH3NUM6=#27,SCH3NUM7=#28,SCH3NUM8=#29,SCH3NUM9=#30,SCH3NUM10=#31
FILEI ZDATI[4] = "%SCENARIO_DIR%\distancetoexternal.csv",
 Z=#1,EXT_DIST=#2
FILEI ZDATI[3] = "%SCENARIO_DIR%\transit_accessibility.csv",
 Z=#1,TETRACC15=#6
FILEI ZDATI[2] = "%SCENARIO_DIR%\highway_accessibility.csv",
 Z=#1,TEHWYACC10=#5,REHWYACC10=#11,NEHWYACC10=#17,MEHWYACC10=#23


ZONES=%int_zones%

; Update all variables
ro.ZONE=zi.1.ZONE[i]
ro.ZONEID=zi.1.ZONEID[i]
ro.POPULATION=zi.1.POPULATION[i]
ro.HOUSEHOLDS=zi.1.HOUSEHOLDS[i]
ro.RET_EMP=zi.1.RET_EMP[i]
ro.NRET_EMP=zi.1.NRET_EMP[i]
ro.AMC_EMP=zi.1.AMC_EMP[i]
ro.MAN_EMP=zi.1.MAN_EMP[i]
ro.OFF_EMP=zi.1.OFF_EMP[i]
ro.MED1_EMP=zi.1.MED1_EMP[i]
ro.MED2_EMP=zi.1.MED2_EMP[i]
ro.RST_EMP=zi.1.RST_EMP[i]
ro.K12_EMP=zi.1.K12_EMP[i]
ro.ENT_EMP=zi.1.ENT_EMP[i]
ro.TOT_EMP=zi.1.TOT_EMP[i]
ro.AREA=zi.1.AREA[i]
ro.MIX_DENS=zi.1.MIX_DENS[i]
ro.TERM_TIME=zi.1.TERM_TIME[i]
ro.PARK_COST=zi.1.PARK_COST[i]
ro.NONWRKPRK=zi.1.NONWRKPRK[i]
ro.ENROLLED=zi.1.ENROLLED[i]
ro.ENROLLED2=zi.6.ENROLLED2[i]
ro.ENROLLED5=zi.6.ENROLLED5[i]
ro.ENROLLED10=zi.6.ENROLLED10[i]
ro.TETRACC15=zi.3.TETRACC15[i]
ro.TEHWYACC10=zi.2.TEHWYACC10[i]
ro.REHWYACC10=zi.2.REHWYACC10[i]
ro.NEHWYACC10=zi.2.NEHWYACC10[i]
ro.MEHWYACC10=zi.2.MEHWYACC10[i]
ro.EXT_DIST=zi.4.EXT_DIST[i]
ro.CBD=zi.1.CBD[i]
ro.SUBURB3=zi.1.SUBURB3[i]
ro.SUBURB2=zi.1.SUBURB2[i]
ro.RURAL=zi.1.RURAL[i]
ro.HHDENSITY=zi.1.HHDENSITY[i]
ro.LOGMXDENS=zi.1.LOGMXDENS[i]
ro.RETEMPDEN=zi.1.RETEMPDEN[i]
ro.POPDENS=zi.1.POPDENS[i]
ro.TOTEMPDEN=zi.1.TOTEMPDEN[i]
ro.TRHWACCRAT=zi.1.TRHWACCRAT[i]
ro.TW_ACC=zi.1.TW_ACC[i]
ro.SCH1NUM1=zi.5.SCH1NUM1[i]
ro.SCH1NUM2=zi.5.SCH1NUM2[i]
ro.SCH1NUM3=zi.5.SCH1NUM3[i]
ro.SCH1NUM4=zi.5.SCH1NUM4[i]
ro.SCH1NUM5=zi.5.SCH1NUM5[i]
ro.SCH1NUM6=zi.5.SCH1NUM6[i]
ro.SCH1NUM7=zi.5.SCH1NUM7[i]
ro.SCH1NUM8=zi.5.SCH1NUM8[i]
ro.SCH1NUM9=zi.5.SCH1NUM9[i]
ro.SCH1NUM10=zi.5.SCH1NUM10[i]
ro.SCH2NUM1=zi.5.SCH2NUM1[i]
ro.SCH2NUM2=zi.5.SCH2NUM2[i]
ro.SCH2NUM3=zi.5.SCH2NUM3[i]
ro.SCH2NUM4=zi.5.SCH2NUM4[i]
ro.SCH2NUM5=zi.5.SCH2NUM5[i]
ro.SCH2NUM6=zi.5.SCH2NUM6[i]
ro.SCH2NUM7=zi.5.SCH2NUM7[i]
ro.SCH2NUM8=zi.5.SCH2NUM8[i]
ro.SCH2NUM9=zi.5.SCH2NUM9[i]
ro.SCH2NUM10=zi.5.SCH2NUM10[i]
ro.SCH3NUM1=zi.5.SCH3NUM1[i]
ro.SCH3NUM2=zi.5.SCH3NUM2[i]
ro.SCH3NUM3=zi.5.SCH3NUM3[i]
ro.SCH3NUM4=zi.5.SCH3NUM4[i]
ro.SCH3NUM5=zi.5.SCH3NUM5[i]
ro.SCH3NUM6=zi.5.SCH3NUM6[i]
ro.SCH3NUM7=zi.5.SCH3NUM7[i]
ro.SCH3NUM8=zi.5.SCH3NUM8[i]
ro.SCH3NUM9=zi.5.SCH3NUM9[i]
ro.SCH3NUM10=zi.5.SCH3NUM10[i]
ro.DISTRICT=zi.1.DISTRICT[i]

; create output dbf
write reco=1

ENDRUN


; Script for program MATRIX in file "C:\ABM\CUBE\TCMAT00A.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Set Inputs and Intermediate File Names - Part 1'
FILEO PRINTO[1] = "%CATALOG_DIR%\\TourCast\Script\CubeKeyValues.py"

;The python configuration file has variable references like this:
;DataReferences=%"Files":___FILE___% where ___FILE___ is a variable holding the file path
;This Matrix module writes these lines out to a Python file that is imported by the config files.  

; TODO: Add feedback iteration to create unique file from each round
; TODO: depending on first or subsequent iteration, specify the skims

Zones=1    ;a Cube setting required for record file processing

If (_writefiles==0) 
  Print printo=1 List='#These lines are generated by Cube to pass file names from Catalog Keys to Python Configuration'
  Print printo=1 List='cube___HOUSEHOLDS_FILE___ = r"', '%households%"'
  Print printo=1 List='cube___ZONES_FILE___ = r"', '%SCENARIO_DIR%\zones_%ITER%.dbf"'
  Print printo=1 List='cube___PERSONS_FILE___ = r"', '%persons%"'
  Print printo=1 List='cube___DAILY_ACTIVITY_PATTERNS___ = r"', '%SCENARIO_DIR%\TC_OutputDAP_%ITER%.dbf"'
  Print printo=1 List='cube___MODELED_HOUSEHOLDS_FILE___ = r"', '%SCENARIO_DIR%\TC_HouseholdModeledData_%ITER%.dbf"'
  Print printo=1 List='cube___PASS_MODEL___ = r"', '%SCENARIO_DIR%\TC_PassModel_%ITER%.dbf"'
  Print printo=1 List='cube___PASS_MODEL_SUMMARY___ = r"', '%SCENARIO_DIR%\TC_PassModelSummary_%ITER%.dbf"'  
  Print printo=1 List='cube___DAILY_ACTIVITY_PATTERNS_FIRST_TOURS___ = r"', '%SCENARIO_DIR%\TC_OutputDAPFirstTours_%ITER%.dbf"'
  Print printo=1 List='cube___DAILY_ACTIVITY_PATTERNS_SECOND_TOURS___ = r"', '%SCENARIO_DIR%\TC_OutputDAPSecondTours_%ITER%.dbf"'
  Print printo=1 List='cube___DAILY_ACTIVITY_PATTERNS_SUMMARY___ = r"', '%SCENARIO_DIR%\TC_OutputDAPStats_%ITER%.dbf"'
  Print printo=1 List='cube___DAILY_ACTIVITY_PATTERN_PRE_PROCESSED_DATA___ = r"', '%SCENARIO_DIR%\TC_OutputPersonsPreDAP_%ITER%.dbf"'
  Print printo=1 List='cube___FULLY_JOINT_TOURS___ = r"', '%SCENARIO_DIR%\TC_FullyJointTours_%ITER%.dbf"'
  Print printo=1 List='cube___FULLY_JOINT_TOUR_PERSON_LINK_TABLE___ = r"', '%SCENARIO_DIR%\TC_FullyJointPersonTourLinkTable_%ITER%.dbf"'
  Print printo=1 List='cube___FULLY_JOINT_TOUR_SUMMARY___ = r"', '%SCENARIO_DIR%\TC_FullyJointTourSummaryByHousehold_%ITER%.dbf"'
  Print printo=1 List='cube___FULLY_JOINT_TOUR_PARTICIPATION_SUMMARY___ = r"', '%SCENARIO_DIR%\TC_FullyJointTourParticipationSummary_%ITER%.dbf"'
  Print printo=1 List='cube___FULLY_JOINT_TOUR_GENERATION_SUMMARY___ = r"', '%SCENARIO_DIR%\TC_FullyJointTourGenerationSummary_%ITER%.dbf"'
  Print printo=1 List='cube___FULLY_JOINT_TOUR_DESTINATION_CHOICE___ = r"', '%SCENARIO_DIR%\TC_OutputTourDestinationChoiceFullyJoint_%ITER%.dbf"'
  Print printo=1 List='cube___FULLY_JOINT_TOUR_DESTINATION_CHOICE_SUMMARY___ = r"', '%SCENARIO_DIR%\TC_OutputTourDestinationChoiceFullyJointStats_%ITER%.txt"'
  Print printo=1 List='cube___FULLY_JOINT_TOUR_PRE_PROCESSED_DATA___ = r"', '%SCENARIO_DIR%\TC_PreFJTPersonModeledData_%ITER%.dbf"'
  Print printo=1 List='cube___FULLY_JOINT_TOUR_TIME_OF_DAY___ = r"', '%SCENARIO_DIR%\TC_OutputTODToursFullyJoint_%ITER%.dbf"'
  Print printo=1 List='cube___FULLY_JOINT_TOUR_PERSON_SCHEDULES___ = r"', '%SCENARIO_DIR%\TC_OutputPersonTODSchedulesFullyJoint_%ITER%.dbf"'
  Print printo=1 List='cube___INDIVIDUAL_NON_MANDATORY_TOURS___ = r"', '%SCENARIO_DIR%\TC_OutputINMTours_%ITER%.dbf"'
  Print printo=1 List='cube___INDIVIDUAL_NON_MANDATORY_ESCORT_TOUR_DESTINATION_CHOICES___ = r"', '%SCENARIO_DIR%\TC_OutputTourDestinationChoiceINMEscort_%ITER%.dbf"'
  Print printo=1 List='cube___INDIVIDUAL_NON_MANDATORY_ESCORT_TOUR_DESTINATION_CHOICE_SUMMARY___ = r"', '%SCENARIO_DIR%\TC_OutputTourDestinationChoiceINMEscortStats_%ITER%.txt"'
  Print printo=1 List='cube___INDIVIDUAL_NON_MANDATORY_TOUR_PRE_PROCESSED_DATA___ = r"', '%SCENARIO_DIR%\TC_PreINMPersonModeledData_%ITER%.dbf"'
  Print printo=1 List='cube___INDIVIDUAL_NON_MANDATORY_TOUR_DESTINATION_CHOICES___ = r"', '%SCENARIO_DIR%\TC_OutputTourDestinationChoiceINM_%ITER%.dbf"'
  Print printo=1 List='cube___INDIVIDUAL_NON_MANDATORY_TOUR_DESTINATION_CHOICE_SUMMARY___ = r"', '%SCENARIO_DIR%\TC_OutputTourDestinationChoiceINMStats_%ITER%.txt"'
  Print printo=1 List='cube___FIRST_MANDATORY_TOUR_TIME_OF_DAY___ = r"', '%SCENARIO_DIR%\TC_OutputPreTODFirstTours_%ITER%.dbf"'
  Print printo=1 List='cube___SECOND_MANDATORY_TOUR_TIME_OF_DAY___ = r"', '%SCENARIO_DIR%\TC_OutputPreTODSecondTours_%ITER%.dbf"'
  Print printo=1 List='cube___SCHOOL_ESCORT_TOURS___ = r"', '%SCENARIO_DIR%\TC_OutputPostSchoolEscortTours_%ITER%.dbf"'
  Print printo=1 List='cube___SCHOOL_ESCORT_STOPS___ = r"', '%SCENARIO_DIR%\TC_OutputSchoolEscortStops_%ITER%.dbf"'
  Print printo=1 List='cube___SCHOOL_ESCORT_SUMMARY___ = r"', '%SCENARIO_DIR%\TC_OutputSchoolEscortStats_%ITER%.dbf"'
  Print printo=1 List='cube___SCHOOL_LOCATIONS___ = r"', '%SCENARIO_DIR%\TC_OutputSchoolLocationTest_%ITER%.dbf"'
  Print printo=1 List='cube___SCHOOL_LOCATIONS_SUMMARY___ = r"', '%SCENARIO_DIR%\TC_OutputSchoolLocationStatsTest_%ITER%.txt"'
  Print printo=1 List='cube___STOP_DESTINATION_CHOICE___ = r"', '%SCENARIO_DIR%\TC_OutputStopsWithDestinations_%ITER%.dbf"'
  Print printo=1 List='cube___STOP_DESTINATION_CHOICE_SUMMARY___ = r"', '%SCENARIO_DIR%\TC_OutputStopDestinationChoiceStats_%ITER%.txt"'
  Print printo=1 List='cube___STOP_GENERATION_STOPS_HOME_BASED___ = r"', '%SCENARIO_DIR%\TC_OutputStops_%ITER%.dbf"'
  Print printo=1 List='cube___STOP_GENERATION_TOURS_HOME_BASED___ = r"', '%SCENARIO_DIR%\TC_OutputToursAfterStopGen_%ITER%.dbf"'
  Print printo=1 List='cube___TRIP_TIME_OF_DAY___ = r"', '%SCENARIO_DIR%\TC_OutputTrips_%ITER%.dbf"'
  Print printo=1 List='cube___STOPS_WITH_TOUR_OFFSET_TIMES___ = r"', '%SCENARIO_DIR%\TC_OutputStopsWithTourOffsetTimes_%ITER%.dbf"'
  Print printo=1 List='cube___UNIVERSITY_TOUR_DESTINATION_CHOICE_FIRST_TOURS___ = r"', '%SCENARIO_DIR%\TC_OutputTourDestinationChoiceUniversityFirstToursTest_%ITER%.dbf"'
  Print printo=1 List='cube___UNIVERSITY_TOUR_DESTINATION_CHOICE_SECOND_TOURS___ = r"', '%SCENARIO_DIR%\TC_OutputTourDestinationChoiceUniversitySecondToursTest_%ITER%.dbf"'
  Print printo=1 List='cube___UNIVERSITY_TOUR_DESTINATION_CHOICE_SUMMARY___ = r"', '%SCENARIO_DIR%\TC_OutputTourDestinationChoiceUniversityStats_%ITER%.txt"'
  Print printo=1 List='cube___WORK_TOUR_DESTINATION_CHOICE_FIRST_TOURS___ = r"', '%SCENARIO_DIR%\TC_OutputTourDestinationChoiceWorkFirstToursTest_%ITER%.dbf"'
  Print printo=1 List='cube___WORK_TOUR_DESTINATION_CHOICE_SECOND_TOURS___ = r"', '%SCENARIO_DIR%\TC_OutputTourDestinationChoiceWorkSecondToursTest_%ITER%.dbf"'
  Print printo=1 List='cube___WORK_TOUR_DESTINATION_CHOICE_SUMMARY___ = r"', '%SCENARIO_DIR%\TC_OutputTourDestinationChoiceWorkStats_%ITER%.txt"'
  Print printo=1 List='cube___HOME_BASED_TOUR_MODE_CHOICE___ = r"', '%SCENARIO_DIR%\TC_OutputModeChoice_%ITER%.dbf"'
  Print printo=1 List='cube___HOME_BASED_TOUR_MODE_CHOICE_SUMMARY___ = r"', '%SCENARIO_DIR%\TC_OutputModeChoiceForStats_%ITER%.dbf"'
  Print printo=1 List='cube___DAP_TOUR_TIME_OF_DAY_CHOICE_FIRST_TOURS___ = r"', '%SCENARIO_DIR%\TC_OutputTODToursDAPFirst_%ITER%.dbf"'
  Print printo=1 List='cube___DAP_TOUR_TIME_OF_DAY_PERSON_SCHEDULES_FIRST_TOURS___ = r"', '%SCENARIO_DIR%\TC_OutputPersonTODSchedulesDAPFirstTours_%ITER%.dbf"'
  Print printo=1 List='cube___DAP_TOUR_TIME_OF_DAY_FIRST_TOUR_CHOICE_SUMMARY___ = r"', '%SCENARIO_DIR%\TC_OutputTODStatsDAPFirstTours_%ITER%.dbf"'
  Print printo=1 List='cube___DAP_TOUR_TIME_OF_DAY_CHOICE_SECOND_TOURS___ = r"', '%SCENARIO_DIR%\TC_OutputTODToursDAPSecond_%ITER%.dbf"'
  Print printo=1 List='cube___DAP_TOUR_TIME_OF_DAY_PERSON_SCHEDULES_SECOND_TOURS___ = r"', '%SCENARIO_DIR%\TC_OutputPersonTODSchedulesDAPSecondTours_%ITER%.dbf"'
  Print printo=1 List='cube___DAP_TOUR_TIME_OF_DAY_SECOND_TOUR_CHOICE_SUMMARY___ = r"', '%SCENARIO_DIR%\TC_OutputTODStatsDAPSecondTours_%ITER%.dbf"'
  Print printo=1 List='cube___INDIVIDUAL_NON_MANDATORY_ESCORT_TOUR_TIME_OF_DAY_CHOICE___ = r"', '%SCENARIO_DIR%\TC_OutputTODToursIndNonMandEscort_%ITER%.dbf"'
  Print printo=1 List='cube___INDIVIDUAL_NON_MANDATORY_ESCORT_TOUR_TIME_OF_DAY_PERSON_SCHEDULES___ = r"', '%SCENARIO_DIR%\TC_OutputPersonTODSchedulesIndNonMand_%ITER%.dbf"'
  Print printo=1 List='cube___INDIVIDUAL_NON_MANDATORY_TOUR_TIME_OF_DAY_CHOICE___ = r"', '%SCENARIO_DIR%\TC_OutputTODToursIndNonMand_%ITER%.dbf"'
  Print printo=1 List='cube___INDIVIDUAL_NON_MANDATORY_TOUR_TIME_OF_DAY_PERSON_SCHEDULES___ = r"', '%SCENARIO_DIR%\TC_OutputPersonTODSchedulesIndNonMandNonEscort_%ITER%.dbf"'
  Print printo=1 List='cube___INDIVIDUAL_NON_MANDATORY_TOUR_TIME_OF_DAY_SUMMARY___ = r"', '%SCENARIO_DIR%\TC_INDIVIDUAL_NON_MANDATORY_TOUR_TIME_OF_DAY_SUMMARY_%ITER%.dbf"'
  Print printo=1 List='cube___TRIPS_WITH_MODES___ = r"', '%SCENARIO_DIR%\TC_OutputTripModes_%ITER%.dbf"'
  Print printo=1 List='cube___WORKPLACE_LOCATIONS___ = r"', '%SCENARIO_DIR%\TC_OutputPersonsWorkplaceLocationTest_%ITER%.dbf"'
  Print printo=1 List='cube___WORKPLACE_LOCATIONS_SUMMARY___ = r"', '%SCENARIO_DIR%\TC_OutputPersonsWorkplaceLocationStats_%ITER%.txt"'
  Print printo=1 List='cube___NUM_CARS_PER_HOUSEHOLD___ = r"', '%SCENARIO_DIR%\TC_OutputNCars_%ITER%.dbf"'
  Print printo=1 List='cube___VEHICLE_AVAILABILITY_SUMMARY___ = r"', '%SCENARIO_DIR%\TC_OutputAAStats_%ITER%.dbf"'
  Print printo=1 List='cube___PERSONS_ADULTS___ = r"', '%SCENARIO_DIR%\TC_OutputPersonsAdultsAA_%ITER%.dbf"'
  Print printo=1 List='cube___PERSONS_CHILDREN___ = r"', '%SCENARIO_DIR%\TC_OutputPersonsChildrenAA_%ITER%.dbf"'
  Print printo=1 List='cube___WORK_BASED_SUBTOURS___ = r"', '%SCENARIO_DIR%\TC_OutputWBSTGeneration_%ITER%.dbf"'  
  Print printo=1 List='cube___WORK_BASED_STOPS___ = r"', '%SCENARIO_DIR%\TC_OutputStopsWorkBasedStopGen_%ITER%.dbf"'
  Print printo=1 List='cube___WORK_BASED_TOUR_DESTINATION_CHOICE___ = r"', '%SCENARIO_DIR%\TC_OutputTourDestinationChoiceWorkBased_%ITER%.dbf"'
  Print printo=1 List='cube___WORK_BASED_TOUR_DESTINATION_CHOICE_SUMMARY___ = r"', '%SCENARIO_DIR%\TC_OutputTourDestinationChoiceWorkBasedStats_%ITER%.txt"'
  Print printo=1 List='cube___WORK_BASED_TOUR_TIME_OF_DAY_CHOICE___ = r"', '%SCENARIO_DIR%\TC_OutputTODToursWorkBased_%ITER%.dbf"'
  Print printo=1 List='cube___WORK_BASED_TOUR_TIME_OF_DAY_CHOICE_SUMMARY___ = r"', '%SCENARIO_DIR%\TC_OutputTODStatsWorkBased_%ITER%.dbf"'
  Print printo=1 List='cube___WORKPLACE_LOCATIONS_PERSONS___ = r"', '%SCENARIO_DIR%\TC_OutputUsualWorkplaceExistenceTest_%ITER%.dbf"'
  Print printo=1 List='cube___WORKPLACE_LOCATIONS_PERSONS_SUMMARY___ = r"', '%SCENARIO_DIR%\TC_OutputPersonStats_UsualWorkplaceExistence_%ITER%.dbf"'
  Print printo=1 List='cube___WORK_BASED_TOUR_PRE_PROCESSED_DATA___ = r"', '%SCENARIO_DIR%\TC_OutputPreWBST_%ITER%.dbf"'
  Print printo=1 List='cube___WORK_BASED_TOUR_MODE_CHOICE___ = r"', '%SCENARIO_DIR%\TC_OutputModeChoiceWorkBased_%ITER%.dbf"'
  Print printo=1 List='cube___WORK_BASED_TOUR_MODE_CHOICE_SUMMARY___ = r"', '%SCENARIO_DIR%\TC_OutputModeChoiceForStatsWorkBased_%ITER%.dbf"'
  Print printo=1 List='cube___TRIP_TABLE_MATRIX___ = r"', '%SCENARIO_DIR%\TripTable.mat"'
  Print printo=1 List='#End of Cube generated lines'
  _writefiles=1
Endif 

ENDRUN


; Script for program MATRIX in file "C:\ABM\CUBE\TCMAT00B.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Set Inputs and Intermediate File Names - Part 2'
FILEO PRINTO[1] = "%CATALOG_DIR%\TourCast\Script\MatrixKeyValues.py"

;The python configuration file has variable references like this:
;DataReferences=%"Files":___FILE___% where ___FILE___ is a variable holding the file path
;This Matrix module writes these lines out to a Python file that is imported by the config files.  

Zones=1    ;a Cube setting required for record file processing

If (_writefiles==0) 
  Print printo=1 List='#These lines are generated by Cube to pass file names from Catalog Keys to Python Configuration'
  Print printo=1 List='cube___OD_DISTANCE_MATRIX___ = r"', '%SCENARIO_DIR%\HWY_SKIM_%PREV_ITER%_AM.skm', '"'
  Print printo=1 List='cube___AM_PEAK_MATRIX___ = r"', '%SCENARIO_DIR%\HWY_SKIM_%PREV_ITER%_AM.skm', '"'
  Print printo=1 List='cube___MIDDAY_MATRIX___ = r"', '%SCENARIO_DIR%\HWY_SKIM_%PREV_ITER%_MD.skm', '"'
  Print printo=1 List='cube___PM_PEAK_MATRIX___ = r"', '%SCENARIO_DIR%\HWY_SKIM_%PREV_ITER%_PM.skm', '"'
  Print printo=1 List='cube___OVERNIGHT_MATRIX___ = r"', '%SCENARIO_DIR%\HWY_SKIM_%PREV_ITER%_NT.skm', '"'
  Print printo=1 List='cube___NM_MATRIX___ = r"', '%SCENARIO_DIR%\NM_SKIM.skm', '"'  
  Print printo=1 List='cube___PEAK_WALK_TO_TRANSIT_MATRIX___ = r"', '%SCENARIO_DIR%\XIT_WK_SKIM_%PREV_ITER%_PK.skm', '"'
  Print printo=1 List='cube___PEAK_DRIVE_TO_TRANSIT_MATRIX___ = r"', '%SCENARIO_DIR%\XIT_DR_SKIM_%PREV_ITER%_PK.skm', '"'
  Print printo=1 List='cube___OFF_PEAK_WALK_TO_TRANSIT_MATRIX___ = r"', '%SCENARIO_DIR%\XIT_WK_SKIM_%PREV_ITER%_OP.skm', '"'
  Print printo=1 List='cube___OFF_PEAK_DRIVE_TO_TRANSIT_MATRIX___ = r"', '%SCENARIO_DIR%\XIT_DR_SKIM_%PREV_ITER%_OP.skm', '"'
  
  Print printo=1 List='AM1___TRIP_TABLE_MATRIX___ = r"', '%SCENARIO_DIR%\HWY_TRIP_%ITER%_AM1.trp', '"'
  Print printo=1 List='AM2___TRIP_TABLE_MATRIX___ = r"', '%SCENARIO_DIR%\HWY_TRIP_%ITER%_AM2.trp', '"'
  Print printo=1 List='AM3___TRIP_TABLE_MATRIX___ = r"', '%SCENARIO_DIR%\HWY_TRIP_%ITER%_AM3.trp', '"'
  Print printo=1 List='AM4___TRIP_TABLE_MATRIX___ = r"', '%SCENARIO_DIR%\HWY_TRIP_%ITER%_AM4.trp', '"'

  Print printo=1 List='MD___TRIP_TABLE_MATRIX___ = r"', '%SCENARIO_DIR%\HWY_TRIP_%ITER%_MD.trp', '"'  
  
  Print printo=1 List='PM1___TRIP_TABLE_MATRIX___ = r"', '%SCENARIO_DIR%\HWY_TRIP_%ITER%_PM1.trp', '"'
  Print printo=1 List='PM2___TRIP_TABLE_MATRIX___ = r"', '%SCENARIO_DIR%\HWY_TRIP_%ITER%_PM2.trp', '"'
  Print printo=1 List='PM3___TRIP_TABLE_MATRIX___ = r"', '%SCENARIO_DIR%\HWY_TRIP_%ITER%_PM3.trp', '"'
  Print printo=1 List='PM4___TRIP_TABLE_MATRIX___ = r"', '%SCENARIO_DIR%\HWY_TRIP_%ITER%_PM4.trp', '"'

  Print printo=1 List='EV___TRIP_TABLE_MATRIX___ = r"', '%SCENARIO_DIR%\HWY_TRIP_%ITER%_EV.trp', '"'  
  Print printo=1 List='NT___TRIP_TABLE_MATRIX___ = r"', '%SCENARIO_DIR%\HWY_TRIP_%ITER%_ON.trp', '"'    
  
  Print printo=1 List='PeakTransit___TRIP_TABLE_MATRIX___ = r"', '%SCENARIO_DIR%\XIT_TRIP_%ITER%_PK.trp', '"'
  Print printo=1 List='OffPeakTransit___TRIP_TABLE_MATRIX___ = r"', '%SCENARIO_DIR%\XIT_TRIP_%ITER%_OP.trp', '"'
	Print printo=1 List='#End of Cube generated lines'
  _writefiles=1
Endif 

ENDRUN


; PILOT Script
FILEO PRINTO[1] = "%SCENARIO_DIR%\TourCastStatus.prn"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.

; 
; Build a batchfile to drive TourCast and show outputs (calling direct from Cube hides status)
;

* echo %echo on > TourCastRun.bat
* echo %cd ..\TourCast\bin >> TourCastRun.bat
* echo %echo TourCast Aborted ^> ..\..\Cube\TC_error.txt >> TourCastRun.bat
;
; Vehicle Availability Sequence
;
IF (%TC_vehavail% == 1)

  * echo ModelEngine.exe VehicleAvailabilityModel.py >>  TourCastRun.bat
  * echo %IF ERRORLEVEL 2 GOTO TCERROR >> TourCastRun.bat  
  * echo ModelEngine.exe VehicleAvailabilityModelPostProcessor.py  >>  TourCastRun.bat
  * echo %IF ERRORLEVEL 2 GOTO TCERROR >> TourCastRun.bat

ENDIF

;
; School Location
;
IF (%TC_schLocation% == 1)

  * echo ModelEngine.exe SchoolLocationConstrChoice.py  >>  TourCastRun.bat
  * echo %IF ERRORLEVEL 2 GOTO TCERROR >> TourCastRun.bat  
  
ENDIF

;
; Usual Work Location
;
IF (%TC_workLocation% == 1)

  * echo ModelEngine.exe WorkplaceLocationChoiceModelPreProcessor.py  >>  TourCastRun.bat
  * echo %IF ERRORLEVEL 2 GOTO TCERROR >> TourCastRun.bat    
  * echo ModelEngine.exe UsualWorkplaceLocationChoiceModel.py UsualWorkplaceLocationTourModeChoiceLogsumModel.py  >>  TourCastRun.bat
  * echo %IF ERRORLEVEL 2 GOTO TCERROR >> TourCastRun.bat    
  
ENDIF

;
; Pass Models
;
IF (%TC_pass% == 1)
  * echo ModelEngine.exe PassModels.py  >>  TourCastRun.bat
  * echo %IF ERRORLEVEL 2 GOTO TCERROR >> TourCastRun.bat  
    
ENDIF

;
; DAP
;
IF (%TC_DAP% == 1)
  * echo ModelEngine.exe DailyActivityPatternModelPreProcessor.py  >>  TourCastRun.bat
  * echo %IF ERRORLEVEL 2 GOTO TCERROR >> TourCastRun.bat  
  * echo ModelEngine.exe DailyActivityPatternModel.py  >>  TourCastRun.bat
  * echo %IF ERRORLEVEL 2 GOTO TCERROR >> TourCastRun.bat      
ENDIF

;
; Mandatory Tour Destination Choice (Work and University)
;
IF (%TC_mandTourDest% == 1)
  * echo ModelEngine.exe TourDestinationChoiceUniversity.py  TourModeChoiceLogsum_SchoolLocation.py  >>  TourCastRun.bat
  * echo %IF ERRORLEVEL 2 GOTO TCERROR >> TourCastRun.bat  
  * echo ModelEngine.exe TourDestinationChoiceWork.py TourModeChoiceLogsum_Work.py  >>  TourCastRun.bat
  * echo %IF ERRORLEVEL 2 GOTO TCERROR >> TourCastRun.bat  
ENDIF

;
; Mandatory Tour TOD
;
IF (%TC_mandTourTOD% == 1)
  * echo ModelEngine.exe MandatoryTourTimeOfDayChoiceModelPreProcessor.py  >>  TourCastRun.bat
  * echo %IF ERRORLEVEL 2 GOTO TCERROR >> TourCastRun.bat  
  * echo ModelEngine.exe TourTimeOfDayDAPFirstTours.py  >>  TourCastRun.bat
  * echo %IF ERRORLEVEL 2 GOTO TCERROR >> TourCastRun.bat  
  * echo ModelEngine.exe TourTimeOfDayDAPSecondTours.py  >>  TourCastRun.bat
  * echo %IF ERRORLEVEL 2 GOTO TCERROR >> TourCastRun.bat  
  
ENDIF

;
; School Escorting
;
IF (%TC_schEscort% == 1)
  * echo ModelEngine.exe SchoolEscortModel.py  >>  TourCastRun.bat
  * echo %IF ERRORLEVEL 2 GOTO TCERROR >> TourCastRun.bat  
ENDIF

;
; Fully Joint Tours
;
IF (%TC_FJ% == 1)
  * echo ModelEngine.exe FullyJointTourPreProcessor.py  >>  TourCastRun.bat
  * echo %IF ERRORLEVEL 2 GOTO TCERROR >> TourCastRun.bat  
  * echo ModelEngine.exe FullyJointTour.py  >>  TourCastRun.bat
  * echo %IF ERRORLEVEL 2 GOTO TCERROR >> TourCastRun.bat  
  * echo ModelEngine.exe FullyJointTourDestinationChoice.py TourModeChoiceLogsum_FullyJoint.py  >>  TourCastRun.bat
  * echo %IF ERRORLEVEL 2 GOTO TCERROR >> TourCastRun.bat  
  * echo ModelEngine.exe FullyJointTourTimeOfDay.py  >>  TourCastRun.bat
  * echo %IF ERRORLEVEL 2 GOTO TCERROR >> TourCastRun.bat  
ENDIF
  
;
; INM Tours
;
IF (%TC_INM% == 1)
  * echo ModelEngine.exe IndividualNonMandatoryPreProcessor.py  >>  TourCastRun.bat
  * echo %IF ERRORLEVEL 2 GOTO TCERROR >> TourCastRun.bat  
  * echo ModelEngine.exe IndividualNonMandatory.py  >>  TourCastRun.bat
  * echo %IF ERRORLEVEL 2 GOTO TCERROR >> TourCastRun.bat  
  * echo ModelEngine.exe IndividualNonMandatoryEscortTourDestinationChoice.py TourModeChoiceLogsum_IndividualNonMandatory_Escort.py  >>  TourCastRun.bat
  * echo %IF ERRORLEVEL 2 GOTO TCERROR >> TourCastRun.bat  
  * echo ModelEngine.exe IndividualNonMandatoryTourDestinationChoice.py TourModeChoiceLogsum_IndividualNonMandatory.py  >>  TourCastRun.bat
  * echo %IF ERRORLEVEL 2 GOTO TCERROR >> TourCastRun.bat  
  * echo ModelEngine.exe TourTimeOfDayIndNonMandNonEscort.py  >>  TourCastRun.bat
  * echo %IF ERRORLEVEL 2 GOTO TCERROR >> TourCastRun.bat  
  * echo ModelEngine.exe TourTimeOfDayIndNonMandEscort.py  >>  TourCastRun.bat
  * echo %IF ERRORLEVEL 2 GOTO TCERROR >> TourCastRun.bat  
ENDIF

;
; Stop Generation
;
IF (%TC_stopGen% == 1)
  * echo ModelEngine.exe StopGeneration.py  >>  TourCastRun.bat
  * echo %IF ERRORLEVEL 2 GOTO TCERROR >> TourCastRun.bat  
ENDIF

;
; Home-Based Tour Mode Choice
;
IF (%TC_tourMC% == 1)
  * echo ModelEngine.exe TourModeChoiceHomeBased.py  >>  TourCastRun.bat
  * echo %IF ERRORLEVEL 2 GOTO TCERROR >> TourCastRun.bat  
ENDIF

;
; Work-Based Tours
;
IF (%TC_WB% == 1)
  * echo ModelEngine.exe WorkBasedSubTourPreProcessor.py  >>  TourCastRun.bat
  * echo %IF ERRORLEVEL 2 GOTO TCERROR >> TourCastRun.bat  
  * echo ModelEngine.exe WorkBasedSubTour.py  >>  TourCastRun.bat
  * echo %IF ERRORLEVEL 2 GOTO TCERROR >> TourCastRun.bat  
  * echo ModelEngine.exe WorkBasedTourDestinationChoice.py TourModeChoiceLogsum_WorkBased.py  >>  TourCastRun.bat
  * echo %IF ERRORLEVEL 2 GOTO TCERROR >> TourCastRun.bat  
  * echo ModelEngine.exe WorkBasedTourTimeOfDay.py  >>  TourCastRun.bat
  * echo %IF ERRORLEVEL 2 GOTO TCERROR >> TourCastRun.bat  
  * echo ModelEngine.exe WorkBasedStopGeneration.py  >>  TourCastRun.bat
  * echo %IF ERRORLEVEL 2 GOTO TCERROR >> TourCastRun.bat  
  * echo ModelEngine.exe WorkBasedTourModeChoice.py  >>  TourCastRun.bat
  * echo %IF ERRORLEVEL 2 GOTO TCERROR >> TourCastRun.bat  
ENDIF

;
; Stop-Level Models
;
IF (%TC_stopDestTOD% == 1)
  * echo ModelEngine.exe StopDestination.py  >>  TourCastRun.bat
  * echo %IF ERRORLEVEL 2 GOTO TCERROR >> TourCastRun.bat  
  * echo ModelEngine.exe StopTimeOfDay.py  >>  TourCastRun.bat
  * echo %IF ERRORLEVEL 2 GOTO TCERROR >> TourCastRun.bat  
ENDIF

;
; Trip Mode Choice
;
IF (%TC_tripMC% == 1)
  * echo ModelEngine.exe TripModeChoice.py  >>  TourCastRun.bat
  * echo %IF ERRORLEVEL 2 GOTO TCERROR >> TourCastRun.bat  
ENDIF

;
; Write error checking to TourCastRun.bat
;
* echo %del ..\..\Cube\TC_error.txt >> TourCastRun.bat
* echo exit >> TourCastRun.bat
* echo :TCERROR >> TourCastRun.bat
* echo %echo TourCast Component Failed
* echo %echo TourCast Error ^> ..\..\Cube\TC_error.txt >> TourCastRun.bat
* echo %pause >> TourCastRun.bat
* echo exit >> TourCastRun.bat

* start /wait TourCastRun.bat
* dir TC_error.txt
  IF (ReturnCode == 0) 
    PRINT LIST='TourCast Model Error - see log files for more information'
    * type TC_error.txt
    abort
  ENDIF 
; End of PILOT Script

; Script for program MATRIX in file "C:\ABM\CUBE\FTMAT00A.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Create weighted skim times'
FILEO MATO[1] = "%SCENARIO_DIR%\TRK_SKIM_%ITER%.tmp",
 MO=1-2, DEC=D*2, NAME=SNGLTIME, MULTTIME
FILEI LOOKUPI[1] = "%qfrm%"
FILEI MATI[4] = "%SCENARIO_DIR%\HWY_SKIM_%PREV_ITER%_NT.SKM"
FILEI MATI[3] = "%SCENARIO_DIR%\HWY_SKIM_%PREV_ITER%_PM.SKM"
FILEI MATI[2] = "%SCENARIO_DIR%\HWY_SKIM_%PREV_ITER%_MD.SKM"
FILEI MATI[1] = "%SCENARIO_DIR%\HWY_SKIM_%PREV_ITER%_AM.SKM"

  LOOKUP LOOKUPI=1, NAME=TOD,  ;TOD Skim Shares
  LOOKUP[1]=1, RESULT=2, ; AM
  LOOKUP[2]=1, RESULT=3, ; MD
  LOOKUP[3]=1, RESULT=4, ; PM
  LOOKUP[4]=1, RESULT=5  ; NT

  ; Single Unit weighted travel time
  MW[1] = MI.1.DANTIME * TOD(1,3) +  ; AM
          MI.1.DANTIME * TOD(1,3) +  ; MD
          MI.3.DANTIME * TOD(3,3)  + ; PM
          MI.4.DANTIME * TOD(4,3)    ; NT 
          
 ; Multi Unit weighted travel time
  MW[2]=  MI.1.DANTIME * TOD(1,4)  + ; AM
          MI.2.DANTIME * TOD(2,4)  + ; MD
          MI.3.DANTIME * TOD(3,4)  + ; PM
          MI.4.DANTIME * TOD(4,4)    ; NT
        
 ; prevent EI trips from becoming EEs
 JLOOP
  IF (I>%int_zones% & J>%int_zones%)
    MW[1] = 1000
    MW[2] = 1000
    MW[3] = 1000
    MW[4] = 1000
  ENDIF
 ENDJLOOP
 
ENDRUN


; Script for program TRIPDIST in file "C:\ABM\CUBE\FTTRD00A.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=TRIPDIST MSG='Truck gravity model'
FILEO MATO[1] = "%SCENARIO_DIR%\TRK_TRIP_%ITER%.tmp",
 MO=1-3, DEC=D,D,D, NAME=SINGLEUNIT, COMBINATION, HV
FILEI LOOKUPI[1] = "%qrfm_ff%"
FILEI MATI[1] = "%SCENARIO_DIR%\TRK_SKIM_%ITER%.tmp"
FILEI ZDATI[1] = "%SCENARIO_DIR%\TRK_PA.txt",
 Z=#1, P1=#2, A1=#3, P2=#4, A2=#5 ;PA DATA

 MAXITERS=10
 MAXRMSE=10

 LOOKUP LOOKUPI=1, FAIL=120,0,0, LIST=N, 
 NAME=FF,  ;FRICTION FACTOR LOOKUP TABLE
 LOOKUP[1]=1, RESULT=2,
 LOOKUP[2]=1, RESULT=3,
 INTERPOLATE=Y, SETUPPER=N

 SETPA P[1]= P1, P[2] = P2
 SETPA A[1]= A1, A[2] = A2
          
 ;*****
 ;Define Friction Factors for Single Unit and Combination Trucks;
 ;Note: Use these as KFACTOR matrices, because FFACTORS cannot be in matrix form;
 ;*****
 MW[10]= MI.1.1
 MW[11]= MI.1.2

 GRAVITY PURPOSE=1, LOS=MW[10], FFACTORS=FF,  LOSRANGE=0-999   ;SINGLE UNIT GRAVITY MODEL
 FREQUENCY VALUEMW=1, BASEMW=10, RANGE=1-100, TITLE='SINGLE UNIT TRIPS'
  
 GRAVITY PURPOSE=2, LOS=MW[11], FFACTORS=FF,  LOSRANGE=0-999   ;COMBINATION GRAVITY MODEL
 FREQUENCY VALUEMW=1, BASEMW=11, RANGE=1-100, TITLE='COMBINATION TRIPS'

 MW[3] = MW[1]+ MW[2] ; TOTAL TRUCK TRIPS
ENDRUN


; Script for program MATRIX in file "C:\ABM\CUBE\FTMAT00B.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Time period splits'
FILEI MATI[2] = "%SCENARIO_DIR%\EE_FRATAR_TRK.MAT"
FILEO PRINTO[1] = "%SCENARIO_DIR%\TRK_TRIP_PRN_%ITER%.prn"
FILEI LOOKUPI[1] = "%qfrm%"
FILEO MATO[11] = "%SCENARIO_DIR%\TRK_TRIP_%ITER%_ON.trp",
 MO=111,112,113, NAME=Single, Combo, Total
FILEO MATO[10] = "%SCENARIO_DIR%\TRK_TRIP_%ITER%_EV.trp",
 MO=101,102,103, NAME=Single, Combo, Total
FILEO MATO[9] = "%SCENARIO_DIR%\TRK_TRIP_%ITER%_PM4.trp",
 MO=91,92,93, NAME=Single, Combo, Total
FILEO MATO[8] = "%SCENARIO_DIR%\TRK_TRIP_%ITER%_PM3.trp",
 MO=81,82,83, NAME=Single, Combo, Total
FILEO MATO[7] = "%SCENARIO_DIR%\TRK_TRIP_%ITER%_PM2.trp",
 MO=71,72,73, NAME=Single, Combo, Total
FILEO MATO[6] = "%SCENARIO_DIR%\TRK_TRIP_%ITER%_PM1.trp",
 MO=61,62,63, NAME=Single, Combo, Total
FILEO MATO[5] = "%SCENARIO_DIR%\TRK_TRIP_%ITER%_MD.trp",
 MO=51,52,53, NAME=Single, Combo, Total
FILEO MATO[4] = "%SCENARIO_DIR%\TRK_TRIP_%ITER%_AM4.trp",
 MO=41,42,43, NAME=Single, Combo, Total
FILEO MATO[3] = "%SCENARIO_DIR%\TRK_TRIP_%ITER%_AM3.trp",
 MO=31,32,33, NAME=Single, Combo, Total
FILEO MATO[2] = "%SCENARIO_DIR%\TRK_TRIP_%ITER%_AM2.trp",
 MO=21,22,23, NAME=Single, Combo, Total
FILEO MATO[1] = "%SCENARIO_DIR%\TRK_TRIP_%ITER%_AM1.trp",
 MO=11,12,13, NAME=Single, Combo, Total
FILEI MATI[1] = "%SCENARIO_DIR%\TRK_TRIP_%ITER%.tmp"

  
  LOOKUP LOOKUPI=1, NAME=TODL,
  LOOKUP[1]=1, RESULT=2, ; AM1
  LOOKUP[2]=1, RESULT=3, ; AM2
  LOOKUP[3]=1, RESULT=4, ; AM3
  LOOKUP[4]=1, RESULT=5, ; AM4
  LOOKUP[5]=1, RESULT=6, ; MD
  LOOKUP[6]=1, RESULT=7, ; PM1
  LOOKUP[7]=1, RESULT=8, ; PM2
  LOOKUP[8]=1, RESULT=9, ; PM3
  LOOKUP[9]=1, RESULT=10, ; PM4
  LOOKUP[10]=1, RESULT=11,  ; EV
  LOOKUP[11]=1, RESULT=12  ; NT
  
  ; Distribute by TOD
  
  ; AM1
	MW[11] = (MI.1.SINGLEUNIT + MI.2.1) * TODL(1,7)
	MW[12] = (MI.1.COMBINATION + MI.2.2)* TODL(1,8)
	MW[13] = MW[11] + MW[12]
	
  ;AM2
	MW[21] = (MI.1.SINGLEUNIT + MI.2.1) * TODL(2,7)
	MW[22] = (MI.1.COMBINATION + MI.2.2) * TODL(2,8)
	MW[23] = MW[21] + MW[22]
	
  ; AM3
	MW[31] = (MI.1.SINGLEUNIT + MI.2.1) * TODL(3,7)
	MW[32] = (MI.1.COMBINATION + MI.2.2) * TODL(3,8)
	MW[33] = MW[31] + MW[32]
	
  ; AM4
	MW[41] = (MI.1.SINGLEUNIT + MI.2.1) * TODL(4,7)
	MW[42] = (MI.1.COMBINATION + MI.2.2) * TODL(4,8)
	MW[43] = MW[41] + MW[42]
	
  ;MD
	MW[51] = (MI.1.SINGLEUNIT + MI.2.1) * TODL(5,7)
	MW[52] = (MI.1.COMBINATION + MI.2.2) * TODL(5,8)
	MW[53] = MW[51] + MW[52]
	
  ;PM1
	MW[61] = (MI.1.SINGLEUNIT + MI.2.1) * TODL(6,7)
	MW[62] = (MI.1.COMBINATION + MI.2.2) * TODL(6,8)
	MW[63] = MW[61] + MW[62]
	
  ;PM2
	MW[71] = (MI.1.SINGLEUNIT + MI.2.1) * TODL(7,7)
	MW[72] = (MI.1.COMBINATION + MI.2.2) * TODL(7,8)
	MW[73] = MW[71] + MW[72]
	
  ;PM3
	MW[81] = (MI.1.SINGLEUNIT + MI.2.1) * TODL(8,7)
	MW[82] = (MI.1.COMBINATION + MI.2.2) * TODL(8,8)
	MW[83] = MW[81] + MW[82]
	
  ;PM4
	MW[91] = (MI.1.SINGLEUNIT + MI.2.1) * TODL(9,7)
	MW[92] = (MI.1.COMBINATION + MI.2.2) * TODL(9,8)
	MW[93] = MW[91] + MW[92]
	
  ;EV
	MW[101] = (MI.1.SINGLEUNIT + MI.2.1) * TODL(10,7)
	MW[102] = (MI.1.COMBINATION + MI.2.2) * TODL(10,8)
	MW[103] = MW[101] + MW[102]
	
  ;NT
	MW[111] = (MI.1.SINGLEUNIT + MI.2.1) * TODL(11,7)
	MW[112] = (MI.1.COMBINATION + MI.2.2) * TODL(11,8)
	MW[113] = MW[111] + MW[112]

  JLOOP
    AM_SU = AM_SU + MW[11] + MW[21] + MW[31] + MW[41]
    AM_MU = AM_MU + MW[12] + MW[22] + MW[32] + MW[42]
 
    MD_SU = MD_SU + MW[51]
    MD_MU = MD_MU + MW[52]
    
    PM_SU = PM_SU + MW[61] + MW[71] + MW[81] + MW[91]
    PM_MU = PM_MU + MW[62] + MW[72] + MW[82] + MW[92]
    
    OP_SU = OP_SU + MW[101] + MW[111]
    OP_MU = OP_MU + MW[102] + MW[112]
  
  
  ENDJLOOP
    IF (I = %zones%)
      PRINT CSV=T, LIST='Truck,  AM,  MD,  PM,  OP',PRINTO=1
      PRINT CSV=T, LIST='Single,'   AM_SU, MD_SU, PM_SU, OP_SU, PRINTO=1
      PRINT CSV=T, LIST='Combo,'  AM_MU, MD_MU, PM_MU, OP_MU, PRINTO=1
      
    ENDIF


ENDRUN


; Script for program MATRIX in file "C:\ABM\CUBE\EEMAT00A.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Auto EI / IE Destination Choice'
FILEI DBI[2] = "%SCENARIO_DIR%\HWY_EXT.dbf"
FILEI MATI[1] = "%SCENARIO_DIR%\HWY_SKIM_%PREV_ITER%_AM.skm"
FILEO MATO[2] = "%SCENARIO_DIR%\HWY_EXT_IETRIP_%ITER%.trp",
 MO=11-18, NAME=termTime,time,sizeVar, expU, prob, IE_DA, IE_S2, IE_S3
 
FILEO MATO[1] = "%SCENARIO_DIR%\HWY_EXT_EITRIP_%ITER%.trp",
 MO=1-8, NAME=termTime,time,sizeVar, expU, prob, EI_DA,	EI_S2,	EI_S3

FILEI DBI[1] = "%zone_attribs%"

 zones = %zones%
 
  ARRAY destTermT=%int_zones%, destSizeV=%int_zones%, destTrips=(%ext_zones%)
  ARRAY origTermT=%int_zones%, origSizeV=%int_zones%, origTrips=(%ext_zones%)
  
  
  ; read in vectors of zonal data  
  IF (I=1)
    LOOP k=1,%int_zones%
    
      x=DBIReadRecord(1,k)
      
      ; External to Internal (EI) - Destination Choice
      destTermT[k]=DI.1.CBD * 1.32
      destSizeV[k]= MAX(ln(DI.1.AREA + DI.1.TOT_EMP * 52.45),0)
      
      ; Internal to External (IE) - Origin Choice
      origTermT[k]=DI.1.CBD * -0.107 + DI.1.SUBURB2 * 0.489 + DI.1.RURAL * 1.65
      origSizeV[k]= MAX(ln(DI.1.AREA + DI.1.POPULATION * 23.81 + DI.1.TOT_EMP * 18.73),0)      
      
    ENDLOOP
  ENDIF
  
  ; Calculate utility function and probabilities for Extenal-Internal interchanges
  IF (I > %int_zones%)  
  
    ; prepare utility function
    JLOOP J=1,%int_zones%
      ; EI
      mw[1] = destTermT[J] 
      mw[2] = MI.1.1 * -0.116 + 0.00059 * MI.1.1 ^ 2 + -0.00000036 * MI.1.1 ^ 3 
      mw[3] = destSizeV[J]
      mw[4] = exp(mw[1] + mw[2]) * mw[3]

      ; IE
      mw[11] = origTermT[J] 
      mw[12] = MI.1.1 * -0.194 + 0.0020 * MI.1.1 ^ 2 + -0.0000073 * MI.1.1 ^ 3 
      mw[13] = origSizeV[J]
      mw[14] = exp(mw[11] + mw[12]) * mw[13]  
      
    ENDJLOOP  
    
    destRowsum = ROWSUM(4)
    origRowsum = ROWSUM(14)
    
    ; calculate probabilities and apply to EI / IE trips
     JLOOP J=1,%int_zones%
      mw[5] = (mw[4] * 100) / destRowsum   
      mw[15] = (mw[14] * 100) / origRowsum 
      
      ; Read in external trips
      x=DBIReadRecord(2,I - %int_zones%)
      
      mw[6] = mw[5] * DI.2.EI_DA / 2 / 100 
      mw[7] = mw[5] * DI.2.EI_S2 / 2 / 100 
      mw[8] = mw[5] * DI.2.EI_S3 / 2 / 100 
      
      mw[16] = mw[15] * DI.2.IE_DA / 2 / 100 
      mw[17] = mw[15] * DI.2.IE_S2 / 2 / 100 
      mw[18] = mw[15] * DI.2.IE_S3 / 2 / 100       

    ENDJLOOP     
    
    
    
    
  ENDIF 



ENDRUN


; Script for program MATRIX in file "C:\ABM\CUBE\EEMAT00B.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Combine EI / IE trips with transpose and EE'
FILEI MATI[3] = "%SCENARIO_DIR%\HWY_EXT_EETRIP.TRP"
FILEO MATO[1] = "%SCENARIO_DIR%\HWY_EXT_TRIP_%ITER%.trp",
 MO=1-3, NAME=DA, SR2, SR3
FILEI MATI[2] = "%SCENARIO_DIR%\HWY_EXT_IETRIP_%ITER%.trp"
FILEI MATI[1] = "%SCENARIO_DIR%\HWY_EXT_EITRIP_%ITER%.trp"

  MW[1] = MI.1.6 + MI.1.6.T + MI.2.6 + MI.2.6.T + MI.3.1 ; exclude EE trips from MnPass
  MW[2] = MI.1.7 + MI.1.7.T + MI.2.7 + MI.2.7.T
  MW[3] = MI.1.8 + MI.1.8.T + MI.2.8 + MI.2.8.T  

ENDRUN


; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.



LOOP TOD=1,11,1
 IF(TOD=1) PER='AM1'
 IF(TOD=2) PER='AM2'
 IF(TOD=3) PER='AM3'
 IF(TOD=4) PER='AM4'  
 IF(TOD=5) PER='MD' 
 IF(TOD=6) PER='PM1'
 IF(TOD=7) PER='PM2'
 IF(TOD=8) PER='PM3'
 IF(TOD=9) PER='PM4'
 IF(TOD=10) PER='EV' 
 IF(TOD=11) PER='ON'  
; End of PILOT Script

; Script for program MATRIX in file "C:\ABM\CUBE\EEMAT00D.S"
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


; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.


ENDLOOP
; End of PILOT Script

; Script for program MATRIX in file "C:\ABM\CUBE\EEMAT00E.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Split trips by TOD'
FILEO PRINTO[1] = "%SCENARIO_DIR%\HWY_EXT_TRIP_PRN_%ITER%.prn"
FILEO MATO[11] = "%SCENARIO_DIR%\HWY_EXT_TRIP_%ITER%_ON.trp",
 MO=111-113, NAME=DA, SR2, SR3
FILEO MATO[10] = "%SCENARIO_DIR%\HWY_EXT_TRIP_%ITER%_EV.trp",
 MO=101-103, NAME=DA, SR2, SR3
FILEO MATO[9] = "%SCENARIO_DIR%\HWY_EXT_TRIP_%ITER%_PM4.trp",
 MO=91-93, NAME=DA, SR2, SR3
FILEO MATO[8] = "%SCENARIO_DIR%\HWY_EXT_TRIP_%ITER%_PM3.trp",
 MO=81-83, NAME=DA, SR2, SR3
FILEO MATO[7] = "%SCENARIO_DIR%\HWY_EXT_TRIP_%ITER%_PM2.trp",
 MO=71-73, NAME=DA, SR2, SR3
FILEO MATO[6] = "%SCENARIO_DIR%\HWY_EXT_TRIP_%ITER%_PM1.trp",
 MO=61-63, NAME=DA, SR2, SR3
FILEO MATO[5] = "%SCENARIO_DIR%\HWY_EXT_TRIP_%ITER%_MD.trp",
 MO=51-53, NAME=DA, SR2, SR3
FILEO MATO[4] = "%SCENARIO_DIR%\HWY_EXT_TRIP_%ITER%_AM4.trp",
 MO=41-43, NAME=DA, SR2, SR3
FILEO MATO[3] = "%SCENARIO_DIR%\HWY_EXT_TRIP_%ITER%_AM3.trp",
 MO=31-33, NAME=DA, SR2, SR3
FILEO MATO[2] = "%SCENARIO_DIR%\HWY_EXT_TRIP_%ITER%_AM2.trp",
 MO=21-23, NAME=DA, SR2, SR3
FILEI DBI[1] = "%SCENARIO_DIR%\HWY_TRIP_PRN_%ITER%.csv",
DELIMITER[1]=",",
 FIELDS=3
FILEO MATO[1] = "%SCENARIO_DIR%\HWY_EXT_TRIP_%ITER%_AM1.trp",
 MO=11-13, NAME=DA, SR2, SR3
FILEI MATI[1] = "%SCENARIO_DIR%\HWY_EXT_TRIP_%ITER%.trp"

  ; 
  ; Caculate TOD share based on TourCast outputs
  ;
  ARRAY share = 11
  
  IF(I==1)
    _total = 0

    ; First calculate total trips
    LOOP k=1,11
        x=DBIReadRecord(1,k)
        _total = _total + DI.1.FIELD1
        ;PRINT LIST=DI.1.FIELD1, k, _total PRINTO=1
    ENDLOOP
    
     ; Next calculate share per time period
    LOOP k=1,11
        x=DBIReadRecord(1,k)
        share[k] =  DI.1.FIELD1 / _total
        ;PRINT LIST=DI.1.FIELD1, k, _total, share[k] PRINTO=1
    ENDLOOP   
    
    ; Sum up external trips to check
    _totalExt = 0
    _am1Ext = 0 _am2Ext = 0 _am3Ext = 0 _am4Ext = 0 
    _mdExt = 0
    _pm1Ext = 0 _pm2Ext = 0 _pm3Ext = 0 _pm4Ext = 0 
    _evExt = 0 _ntExt = 0
        
  ENDIF
  
  ;
  ; Apply share to create TOD trip tables.
  ;
	MW[11] = MI.1.1 * share[1]	MW[12] = MI.1.2 * share[1]	MW[13] = MI.1.3 * share[1]
	MW[21] = MI.1.1 * share[2]	MW[22] = MI.1.2 * share[2]	MW[23] = MI.1.3 * share[2]
	MW[31] = MI.1.1 * share[3]	MW[32] = MI.1.2 * share[3]	MW[33] = MI.1.3 * share[3]
	MW[41] = MI.1.1 * share[4]	MW[42] = MI.1.2 * share[4]	MW[43] = MI.1.3 * share[4]
	MW[51] = MI.1.1 * share[5]	MW[52] = MI.1.2 * share[5]	MW[53] = MI.1.3 * share[5]
	MW[61] = MI.1.1 * share[6]	MW[62] = MI.1.2 * share[6]	MW[63] = MI.1.3 * share[6]  
	MW[71] = MI.1.1 * share[7]	MW[72] = MI.1.2 * share[7]	MW[73] = MI.1.3 * share[7]
	MW[81] = MI.1.1 * share[8]	MW[82] = MI.1.2 * share[8]	MW[83] = MI.1.3 * share[8]
	MW[91] = MI.1.1 * share[9]	MW[92] = MI.1.2 * share[9]	MW[93] = MI.1.3 * share[9]
	MW[101] = MI.1.1 * share[10]	MW[102] = MI.1.2 * share[10]	MW[103] = MI.1.3 * share[10]
	MW[111] = MI.1.1 * share[11]	MW[112] = MI.1.2 * share[11]	MW[113] = MI.1.3 * share[11]
  
  _am1Ext = ROWSUM(11) + ROWSUM(12) + ROWSUM(13)
  _am1Ext = ROWSUM(21) + ROWSUM(22) + ROWSUM(23)
  _am1Ext = ROWSUM(31) + ROWSUM(32) + ROWSUM(33)
  _am1Ext = ROWSUM(41) + ROWSUM(42) + ROWSUM(43)
  _am1Ext = ROWSUM(51) + ROWSUM(52) + ROWSUM(53)
  _am1Ext = ROWSUM(61) + ROWSUM(62) + ROWSUM(63)
  _am1Ext = ROWSUM(71) + ROWSUM(72) + ROWSUM(73)
  _am1Ext = ROWSUM(81) + ROWSUM(82) + ROWSUM(83)
  _am1Ext = ROWSUM(91) + ROWSUM(92) + ROWSUM(93)
  _am1Ext = ROWSUM(101) + ROWSUM(102) + ROWSUM(103)
  _am1Ext = ROWSUM(111) + ROWSUM(112) + ROWSUM(113)
  _am1Ext = ROWSUM(121) + ROWSUM(122) + ROWSUM(123)
  
  _totalExt = _am1Ext + _am2Ext + _am3Ext + _am4Ext + 
              _mdExt + _pm1Ext + _pm2Ext + _pm3Ext + _pm4Ext + _evExt + _ntExt
    
    IF (I = %zones%)
      PRINT CSV=T, LIST='Total, AM1, AM2, AM3, AM4, MD, PM1, PM2, PM3, PM4, EV, ON',PRINTO=1
      PRINT CSV=T, LIST=_totalExt,_am1Ext,_am2Ext,_am3Ext,_am4Ext,
              _mdExt,_pm1Ext,_pm2Ext,_pm3Ext,_pm4Ext,_evExt,_ntExt, PRINTO=1
      
    ENDIF
    
ENDRUN


; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.

;ITER = 1
;PREV_ITER = 0

READ FILE = "%SPC_MODECHOICE%"

LOOP TOD=1,11,1
 IF(TOD=1) PER='AM1' HPER='AM' TPER = 'PK'
 IF(TOD=2) PER='AM2' HPER='AM' TPER = 'PK' 
 IF(TOD=3) PER='AM3' HPER='AM' TPER = 'PK' 
 IF(TOD=4) PER='AM4' HPER='AM' TPER = 'PK'   
 IF(TOD=5) PER='MD'  HPER='MD' TPER = 'OP'
 IF(TOD=6) PER='PM1' HPER='PM' TPER = 'PK'  
 IF(TOD=7) PER='PM2' HPER='PM' TPER = 'PK' 
 IF(TOD=8) PER='PM3' HPER='PM' TPER = 'PK' 
 IF(TOD=9) PER='PM4' HPER='PM' TPER = 'PK'
 IF(TOD=10) PER='EV' HPER='NT' TPER = 'OP' 
 IF(TOD=11) PER='ON' HPER='NT' TPER = 'OP' 
; End of PILOT Script

; Script for program MATRIX in file "C:\ABM\CUBE\SGMAT00A.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Airport Mode Choice'
FILEO MATO[1] = "%SCENARIO_DIR%\HWY_SPC_TRIP_%ITER%_%PER%.tmp",
 MO=134-138, DEC=3,3,3,3,3, NAME= DA,SR2,SR3,XIT_WK, XIT_DR
FILEI MATI[4] = "%SCENARIO_DIR%\HWY_SPC_TRIP.trp"
FILEI MATI[3] = "%SCENARIO_DIR%\HWY_SKIM_%PREV_ITER%_%HPER%.skm"
FILEI MATI[2] = "%SCENARIO_DIR%\XIT_DR_SKIM_%PREV_ITER%_%TPER%.skm"
FILEI MATI[1] = "%SCENARIO_DIR%\XIT_WK_SKIM_%PREV_ITER%_%TPER%.SKM"


 MW[3]=MI.3.1     ; AUTO IVTT
  MW[4]=MI.3.5     ; AUTO DISTANCE
  MW[5]=MI.3.2	   ; AUTO TOLL
  
  MW[203]=MI.3.6     ; SR2 IVTT
  MW[204]=MI.3.10    ; SR2 DISTANCE
  MW[205]=MI.3.7	 ; SR2 TOLL
  
  MW[303]=MI.3.11    ; SR3 IVTT
  MW[304]=MI.3.15    ; SR3 DISTANCE
  MW[305]=MI.3.12	 ; SR3 TOLL
  
  
  MW[6]= MI.1.2+MI.1.3+MI.1.4+MI.1.5+MI.1.6    ; WALK ACCESS OVTT
  MW[9]= MI.1.1                                ; IVTT, WALK ACCESS
  MW[10]= MI.1.8                               ; WALK ACCESS FARE

  MW[26]= MI.2.2+MI.2.3+MI.2.4+MI.2.5+MI.2.6    ; AUTO ACCESS OVTT
  MW[29]= MI.2.1                                ; IVTT, DRIVE ACCESS
  MW[30]= MI.2.8                                ; DRIVE ACCESS FARE

JLOOP INCLUDE=1521
  MW[41]= %TTIME_AUTO%*%HWTCOEFF% + MW[3]*%HWTCOEFF%   + MW[4]*%AUTOCOST%*%DA_COST%          + MW[5]*%DA_COST%    + 20*%DA_COST%      +%C_DA%    ; DA UTILITY
  MW[51]= %TTIME_SR%*%HWTCOEFF%   + MW[203]*%HWTCOEFF% + MW[204]*%AUTOCOST%*0.5*%SR2_COST%   + MW[205]*%SR2_COST% + 20*0.5*%SR2_COST% +%C_SR2%   ; SR2 UTILITY
  MW[61]= %TTIME_SR%*%HWTCOEFF%   + MW[303]*%HWTCOEFF% + MW[304]*%AUTOCOST%*0.285*%SR3_COST% + MW[305]*%SR3_COST% + 20*%SR3_COST%/3.5 +%C_SR3%   ; SR3 UTILITY
ENDJLOOP

JLOOP INCLUDE=1521
    ; WalkTransit
    IF(MW[9][J]>0)
      MW[71]=2.5*MW[6]*%TCOEFF_WA%+MW[9]*%TCOEFF_WA%+MW[10]*%FARECOST%/100+%C_TR%   ; WALK ACCESS UTILITY
    ELSE
      MW[71]=-9999
    ENDIF
    ; DriveTransit
    ;IF (MW[29][J]>0)
     ; MW[91]=2.5*MW[26]*%TCOEFF_DA%+MW[29]*%TCOEFF_DA%+MW[30]*%FARECOST%/100+%C_TR%   ; DRIVE ACCESS UTILITY
    ;ELSE
      MW[91]=-9999
    ;ENDIF
ENDJLOOP

JLOOP INCLUDE=1521
    IF(MW[9][J]=0) MW[71]=-9999
ENDJLOOP

; DO EXPONENTIAL OF UTILITIES

MW[101] = EXP(MW[41])*100000   ; DA

MW[111] = EXP(MW[51])*100000   ; SR2

MW[121] = EXP(MW[61])*100000   ; SR3

MW[131] = EXP(MW[71])*100000   ; WALK ACCESSS

MW[151] = EXP(MW[91])*100000   ; DRIVE ACCESS

; SHARES
MW[171] = 100*MW[101]/(MW[101]+MW[111]+MW[121]+MW[131]+MW[151])           ; DA SHARE 
MW[172] = 100*MW[111]/(MW[101]+MW[111]+MW[121]+MW[131]+MW[151])           ; SR2 SHARE 
MW[173] = 100*MW[121]/(MW[101]+MW[111]+MW[121]+MW[131]+MW[151])           ; SR3 SHARE 
MW[174] = 100*MW[131]/(MW[101]+MW[111]+MW[121]+MW[131]+MW[151])           ; Walk Access Transit Share
;MW[175] = 100*MW[151]/(MW[101]+MW[111]+MW[121]+MW[131]+MW[151])             ; Drive Access Transit Share

MW[197]=MI.4.%TOD% 

MW[134] = MW[171]*MW[197]/100                ;DA TRIPS 
MW[135] = MW[172]*MW[197]/100                ;SR2 TRIPS 
MW[136] = MW[173]*MW[197]/100                ;SR3+ 
MW[137] = MW[174]*MW[197]/100                ;WALK ACCESS TRANSIT TRIPS
;MW[138] = MW[175]*MW[197]/100               ;DRIVE ACCESS TRANSIT TRIPS


ENDRUN


; Script for program MATRIX in file "C:\ABM\CUBE\SGMAT00B.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Add return trips'
FILEO MATO[1] = "%SCENARIO_DIR%\HWY_SPC_TRIP_%ITER%_%PER%.trp",
 MO=1-5, DEC=3,3,3,3,3, NAME= DA,SR2,SR3,XIT_WK, XIT_DR
FILEI MATI[1] = "%SCENARIO_DIR%\HWY_SPC_TRIP_%ITER%_%PER%.tmp"
 
 MW[1] = MI.1.1 + MI.1.1.T
 MW[2] = MI.1.2 + MI.1.2.T + (MI.1.2 + MI.1.2.T)*0.9391
 MW[3] = MI.1.3 + MI.1.3.T + (MI.1.3 + MI.1.3.T)*0.6308
 MW[4] = MI.1.4 + MI.1.4  ; NOTE: Transit is assigned in PA format
 MW[5] = MI.1.5 + MI.1.5  ; NOTE: Transit is assigned in PA format


ENDRUN


; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.

ENDLOOP
; End of PILOT Script

; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
;ITER = 2
DISTRIBUTE INTRASTEP=T
*Cluster Intrastep 1-%max_threads% START EXIT
; End of PILOT Script

; Script for program MATRIX in file "C:\ABM\CUBE\HAMAT00E.S"
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


; Script for program MATRIX in file "C:\ABM\CUBE\HAMAT00G.S"
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


; Script for program MATRIX in file "C:\ABM\CUBE\HAMAT00I.S"
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


; Script for program MATRIX in file "C:\ABM\CUBE\HAMAT00K.S"
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

; Script for program MATRIX in file "C:\ABM\CUBE\HAMAT00A.S"
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


; Script for program HIGHWAY in file "C:\ABM\CUBE\HAHWY00A.S"
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
    
    PARAMETERS raad=0.0001 gap = 0.0001 RELATIVEGAP = 0.0001 aad = 0.01 MAXITERS = %hwy_assignIters% COMBINE=EQUI
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
    
    ; conical function with variable alpha/beta - 13% low on VMT
    ;FUNCTION TC[99] = T0 * (2+SQRT((ALPHA^2)*(1-(V/C))^2 + BETA^2) - ALPHA*(1-(V/C)) - BETA) 
    
    ;FUNCTION TC[1] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    ;FUNCTION TC[2] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    ;FUNCTION TC[3] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    ;FUNCTION TC[4] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    ;FUNCTION TC[5] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    ;FUNCTION TC[6] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    ;FUNCTION TC[7] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    ;FUNCTION TC[8] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    ;FUNCTION TC[9] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    ;FUNCTION TC[10] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    ;FUNCTION TC[11] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    ;FUNCTION TC[12] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    ;FUNCTION TC[13] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    ;FUNCTION TC[14] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    ;FUNCTION TC[15] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    ;FUNCTION TC[99] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167)    

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

; Group 2: HOV SECTIONS - Rachel Editing groups, adding more
        IF (LI.HOV=1,7,9)    ADDTOGROUP=1  ;I-35W	NB	Dakota County to Downtown 
        IF (LI.HOV=2,8,17)   ADDTOGROUP=2  ;I-35W	SB	Downtown to Dakota County 
        IF (LI.HOV=6)        ADDTOGROUP=3  ;I-394	WB DT to 100
        IF (LI.HOV=61)       ADDTOGROUP=4  ;I-394	EB 100 to DT
        IF (LI.HOV=4)        ADDTOGROUP=5  ;I-394	WB	STH-100	I-494 Outbound
        IF (LI.HOV=5)        ADDTOGROUP=6  ;I-394	EB	I-494	STH-100	Inbound
        IF (LI.HOV=11,25)    ADDTOGROUP=7  ; 35E outbound, DT StP to CRJ
        IF (LI.HOV=12,24)    ADDTOGROUP=8  ; 35w inbound, CRJ to DTstP
        IF (LI.HOV=13)       ADDTOGROUP=9 ; 35W NB, Hwy 36 to Blaine
        IF (LI.HOV=14)       ADDTOGROUP=10 ; 35W SB , Blaine to Hwy 36
        IF (LI.HOV=15)       ADDTOGROUP=11 ; 94 between downtowns EB
        IF (LI.HOV=16)       ADDTOGROUP=12 ; 94 between downtowns WB
        IF (LI.HOV=18)       ADDTOGROUP=13 ; 252 SB
        IF (LI.HOV=19)       ADDTOGROUP=14 ; 252 NB
        IF (LI.HOV=23,21)    ADDTOGROUP=15 ; SB 94 from 694 to DT
        IF (LI.HOV=20,22)    ADDTOGROUP=16  ; NB 94 from DT to 694
        IF (LI.HOV=27,29)    ADDTOGROUP=17  ; NB 35w / Hwy 36
        IF (LI.HOV=26,28)    ADDTOGROUP=18 ; SB hwy 36 / 35W
        IF (LI.HOV=30)    ADDTOGROUP=19 ; 94 rogers to maplegrove
        IF (LI.HOV=31)    ADDTOGROUP=20 ; 94 maplegrove to rogers
        IF (LI.HOV=32)    ADDTOGROUP=21 ; 169 from 694 to 394
        IF (LI.HOV=33)    ADDTOGROUP=22  ; 169 from 394 to 694
        IF (LI.HOV=34)    ADDTOGROUP=23 ; 169 from shakopee to 394
        IF (LI.HOV=35)    ADDTOGROUP=24 ; 169 from 394 to shakopee
        IF (LI.HOV=36)    ADDTOGROUP=25 ; 494 EB from 212 to Minnesota River, congested both directions 
        IF (LI.HOV=37)    ADDTOGROUP=26 ; 494 WB from Minnesota River to 212, congested both directions 
        IF (LI.HOV=38,39)    ADDTOGROUP=27 ; 94/694 from maple grove to 94 south into DT, partial lane converstion
        IF (LI.HOV=40,41)    ADDTOGROUP=28 ; 94/694 from 94 to maplegrove, partial lane converstion 
        IF (LI.HOV=42)    ADDTOGROUP=29 ; 694 EB from 94 to 35W
        IF (LI.HOV=43)    ADDTOGROUP=31 ; 694 WB from 35W to 94 ; SKIPPING GROUP 30 because it is exclusion group above . ugh 
        IF (LI.HOV=44,45)    ADDTOGROUP=32 ; 77 NB and SB because i cna't have 33 groups WHICH IS STUPID
      
        
        
        
        ; rachel adding toll groups 6 - 32
        _toll1 = 25
        _toll2 = 25
        _toll3 = 25
        _toll4 = 25
        _toll5 = 25
        _toll6 = 25
        _toll7 = 25
        _toll8 = 25
        _toll9 = 25
        _toll10 = 25
        _toll11 = 25
        _toll12 = 25
        _toll13 = 25
        _toll14 = 25
        _toll15 = 25
        _toll16 = 25
        _toll17 = 25
        _toll18 = 25
        _toll19 = 25
        _toll20 = 25
        _toll21 = 25
        _toll22 = 25
        _toll23 = 25
        _toll24 = 25
        _toll25 = 25
        _toll26 = 25
        _toll27 = 25
        _toll28 = 25
        _toll29 = 25
        _toll31 = 25
        _toll32 = 25
        
        
        
   
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
                MW[85]=_toll5, selectgroup=5 ; Rachel add in new working maxtrix starting at 200
                MW[200]=_toll6, selectgroup=6
                MW[201]=_toll7, selectgroup=7
                MW[202]=_toll8, selectgroup=8
                MW[203]=_toll9, selectgroup=9
                MW[204]=_toll10, selectgroup=10
                MW[205]=_toll11, selectgroup=11
                MW[206]=_toll12, selectgroup=12
                MW[207]=_toll13, selectgroup=13
                MW[208]=_toll14, selectgroup=14
                MW[209]=_toll15, selectgroup=15
                MW[210]=_toll16, selectgroup=16
                MW[211]=_toll17, selectgroup=17
                MW[212]=_toll18, selectgroup=18
                MW[213]=_toll19, selectgroup=19
                MW[214]=_toll20, selectgroup=20
                MW[215]=_toll21, selectgroup=21
                MW[216]=_toll22, selectgroup=22
                MW[217]=_toll23, selectgroup=23
                MW[218]=_toll24, selectgroup=24
                MW[219]=_toll25, selectgroup=25
                MW[220]=_toll26, selectgroup=26
                MW[221]=_toll27, selectgroup=27
                MW[222]=_toll28, selectgroup=28
                MW[223]=_toll29, selectgroup=29
                MW[224]=_toll31, selectgroup=31
                MW[225]=_toll32, selectgroup=32
                



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
      ; rachel add new working maxtrix here MW[200 - 226]
       MW[35] =  MW[81]+MW[82]+MW[83]+MW[84]+MW[85]+MW[200]+MW[201]+MW[202]+MW[203]+MW[204]+MW[205]+MW[206]+MW[207]+MW[208]+MW[209]+MW[210]+MW[211]+MW[212]+MW[213]+MW[214]+MW[215]+MW[216]+MW[217]+MW[218]+MW[219]+MW[220]+MW[221]+MW[222]+MW[223]+MW[224]+MW[225]
 
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
          MW[95] = MW[85] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80])   ; toll5 revenue  rachel keep adding here from MW[200] to MW[225]
          MW[300] = MW[200] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll6 revenue 
          MW[301] = MW[201] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll7 revenue 
          MW[302] = MW[202] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll8 revenue 
          MW[303] = MW[203] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll9 revenue 
          MW[304] = MW[204] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll10 revenue 
          MW[305] = MW[205] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll11 revenue 
          MW[306] = MW[206] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll12 revenue 
          MW[307] = MW[207] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll13 revenue 
          MW[308] = MW[208] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll14 revenue 
          MW[309] = MW[209] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll15 revenue 
          MW[310] = MW[210] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll16 revenue 
          MW[311] = MW[211] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll17 revenue 
          MW[312] = MW[212] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll18 revenue 
          MW[313] = MW[213] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll19 revenue 
          MW[314] = MW[214] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll20 revenue 
          MW[315] = MW[215] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll21 revenue 
          MW[316] = MW[216] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll22 revenue 
          MW[317] = MW[217] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll23 revenue 
          MW[318] = MW[218] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll24 revenue 
          MW[319] = MW[219] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll25 revenue
          MW[320] = MW[220] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll26 revenue
          MW[321] = MW[221] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll27 revenue
          MW[322] = MW[222] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll28 revenue
          MW[323] = MW[223] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll29 revenue
          MW[324] = MW[224] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll31 revenue
          MW[325] = MW[225] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll32 revenue
         

                   

        
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
          _maxVC5 = 0 ; Rachel keep adding here, maxVCs to group 32
          _maxVC6 = 0
          _maxVC7 = 0
          _maxVC8 = 0
          _maxVC9 = 0
          _maxVC10 = 0
          _maxVC11 = 0
          _maxVC12 = 0
          _maxVC13 = 0
          _maxVC14 = 0
          _maxVC15 = 0
          _maxVC16 = 0
          _maxVC17 = 0
          _maxVC18 = 0
          _maxVC19 = 0
          _maxVC20 = 0
          _maxVC21 = 0
          _maxVC22 = 0
          _maxVC23 = 0
          _maxVC24 = 0
          _maxVC25 = 0
          _maxVC26 = 0
          _maxVC27 = 0
          _maxVC28 = 0
          _maxVC29 = 0
          _maxVC31 = 0
          _maxVC32 = 0
          
    
                          
          IF (Iteration =1)
            PRINT CSV=T LIST='Iteration,ANode,BNode,HOV,Volume,VC,TIME,DISTANCE, VHT, VMT, Toll1, Toll2, Toll3, Toll4, Toll5, Toll6, Toll7, Toll8, Toll9, Toll10, Toll11, Toll12, Toll13, Toll14, Toll15, Toll16, Toll17, Toll18, Toll19, Toll20, Toll21, Toll22, Toll23, Toll24, Toll25, Toll26, Toll27, Toll28, Toll29, Toll31, Toll32' PRINTO=1          ; adding new toll groups here to try to fix intrastep issues 
          ENDIF
         ENDIF

; *** COMPUTE MAXIMUM V/C RATIO AND TOLL RATES FOR NEXT ITERATION ON TOLLED SEGMENTS ***
;HOT Lanes
     
        IF (LW.HOV=1,7,9 & C>0)
          IF ((V/C) > _maxVC1) _maxVC1 = (V/C)
        ENDIF
        IF (LW.HOV=2,8,17 & C>0)
          IF ((V/C) > _maxVC2) _maxVC2 = (V/C)          
        ENDIF
        IF (LW.HOV=6 & C>0)
          IF ((V/C) > _maxVC3) _maxVC3 = (V/C)
        ENDIF
        IF (LW.HOV=61 & C>0)
          IF ((V/C) > _maxVC4) _maxVC4 = (V/C)
        ENDIF
        IF (LW.HOV=4 & C>0)
          IF ((V/C) > _maxVC5) _maxVC5 = (V/C)
        ENDIF ; Rachel keep adding here too
        
        IF (LW.HOV=5 & C>0)
          IF ((V/C) > _maxVC6) _maxVC6 = (V/C)
        ENDIF
        IF (LW.HOV=11,25 & C>0)
          IF ((V/C) > _maxVC7) _maxVC7 = (V/C)          
        ENDIF
        IF (LW.HOV=12,24 & C>0)
          IF ((V/C) > _maxVC8) _maxVC8 = (V/C)
        ENDIF
        IF (LW.HOV=13 & C>0)
          IF ((V/C) > _maxVC9) _maxVC9 = (V/C)
        ENDIF
        IF (LW.HOV=14 & C>0)
          IF ((V/C) > _maxVC10) _maxVC10 = (V/C)
        ENDIF 
        
         IF (LW.HOV=15 & C>0)
          IF ((V/C) > _maxVC11) _maxVC11 = (V/C)
        ENDIF
        IF (LW.HOV=16 & C>0)
          IF ((V/C) > _maxVC12) _maxVC12 = (V/C)          
        ENDIF
        IF (LW.HOV=18 & C>0)
          IF ((V/C) > _maxVC13) _maxVC13 = (V/C)
        ENDIF
        IF (LW.HOV=19 & C>0)
          IF ((V/C) > _maxVC14) _maxVC14 = (V/C)
        ENDIF
        IF (LW.HOV=23,21 & C>0)
          IF ((V/C) > _maxVC15) _maxVC15 = (V/C)
        ENDIF 
        
         IF (LW.HOV=20,22 & C>0)
          IF ((V/C) > _maxVC16) _maxVC16 = (V/C)
        ENDIF
        IF (LW.HOV=27,29 & C>0)
          IF ((V/C) > _maxVC17) _maxVC17 = (V/C)          
        ENDIF
        IF (LW.HOV=26,28 & C>0)
          IF ((V/C) > _maxVC18) _maxVC18 = (V/C)
        ENDIF
        IF (LW.HOV=30 & C>0)
          IF ((V/C) > _maxVC19) _maxVC19 = (V/C)
        ENDIF
        IF (LW.HOV=31 & C>0)
          IF ((V/C) > _maxVC20) _maxVC20 = (V/C)
        ENDIF 
        
         IF (LW.HOV=32 & C>0)
          IF ((V/C) > _maxVC21) _maxVC21 = (V/C)
        ENDIF
        IF (LW.HOV=33 & C>0)
          IF ((V/C) > _maxVC22) _maxVC22 = (V/C)          
        ENDIF
        IF (LW.HOV=34 & C>0)
          IF ((V/C) > _maxVC23) _maxVC23 = (V/C)
        ENDIF
        IF (LW.HOV=35 & C>0)
          IF ((V/C) > _maxVC24) _maxVC24 = (V/C)
        ENDIF
        
        IF (LW.HOV=36 & C>0)
            IF ((V/C) > _maxVC25) _maxVC25 = (V/C)
          ENDIF
          
        IF (LW.HOV=37 & C>0)
          IF ((V/C) > _maxVC26) _maxVC26 = (V/C)
        ENDIF
        
        IF (LW.HOV=38,39 & C>0)
          IF ((V/C) > _maxVC27) _maxVC27 = (V/C)
        ENDIF
        
        IF (LW.HOV=40,41 & C>0)
          IF ((V/C) > _maxVC28) _maxVC28 = (V/C)
        ENDIF
        
        IF (LW.HOV=42 & C>0)
          IF ((V/C) > _maxVC29) _maxVC29 = (V/C)
        ENDIF
        
        IF (LW.HOV=43 & C>0)
          IF ((V/C) > _maxVC31) _maxVC31 = (V/C)
        ENDIF
        
        IF (LW.HOV=44,45 & C>0)
          IF ((V/C) > _maxVC32) _maxVC32 = (V/C)
        ENDIF
        
      
        
         
        ;Tolls for Next Assignment Iteration
        _toll1 = TOLL(1,_maxVC1)
        _toll2 = TOLL(1,_maxVC2)
        _toll3 = TOLL(1,_maxVC3)
        _toll4 = TOLL(1,_maxVC4)
        _toll5 = TOLL(1,_maxVC5) ; rachel keep adding up to toll32, maxvc32
        _toll5 = TOLL(1,_maxVC5)
        _toll6 = TOLL(1,_maxVC6)
        _toll7 = TOLL(1,_maxVC7)
        _toll8 = TOLL(1,_maxVC8)
        _toll9 = TOLL(1,_maxVC9)
        _toll10 = TOLL(1,_maxVC10)
        _toll11 = TOLL(1,_maxVC11)
        _toll12 = TOLL(1,_maxVC12)
        _toll13 = TOLL(1,_maxVC13)
        _toll14 = TOLL(1,_maxVC14)
        _toll15 = TOLL(1,_maxVC15)
        _toll16 = TOLL(1,_maxVC16)
        _toll17 = TOLL(1,_maxVC17)
        _toll18 = TOLL(1,_maxVC18)
        _toll19 = TOLL(1,_maxVC19)
        _toll20 = TOLL(1,_maxVC20)
        _toll21 = TOLL(1,_maxVC21)
        _toll22 = TOLL(1,_maxVC22)
        _toll23 = TOLL(1,_maxVC23)
        _toll24 = TOLL(1,_maxVC24)
        _toll25 = TOLL(1,_maxVC25)
        _toll26 = TOLL(1,_maxVC26)
        _toll27 = TOLL(1,_maxVC27)
        _toll28 = TOLL(1,_maxVC28)
        _toll29 = TOLL(1,_maxVC29)
        _toll31 = TOLL(1,_maxVC31)
        _toll32 = TOLL(1,_maxVC32)
       
        
        

        IF (LW.HOV>0 & V>0)
          PRINT CSV=T LIST=iteration(2.0),A(6.0),B(6.0),LW.HOV(4.0),V(8.2),V/C(8.42),TIME(5.2), DISTANCE(5.2), V*TIME(15.2), V*DISTANCE(15.2), _toll1(5.2), _toll2(5.2), _toll3(5.2), _toll4(5.2), _toll5(5.2), _toll6(5.2), _toll7(5.2), _toll8(5.2), _toll9(5.2), _toll10(5.2), _toll11(5.2), _toll12(5.2), _toll13(5.2), _toll14(5.2), _toll15(5.2), _toll16(5.2), _toll17(5.2), _toll18(5.2), _toll19(5.2), _toll20(5.2), _toll21(5.2), _toll22(5.2), _toll23(5.2), _toll24(5.2), _toll25(5.2), _toll26(5.2), _toll27(5.2), _toll28(5.2), _toll29(5.2), _toll31(5.2), _toll32(5.2) PRINTO=1
        ENDIF
    ENDPHASE

ENDRUN


; Script for program MATRIX in file "C:\ABM\CUBE\HAMAT00C.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Create Highway Skims: %ASSIGNNAME%'
FILEI MATI[2] = "%SCENARIO_DIR%\HWY_SKIM_%PREV_ITER%_%PER%.skm"
FILEO MATO[1] = "%SCENARIO_DIR%\HWY_SKIM_%ITER%_%PER%.skm",
 MO=1-16, 
  NAME=daptime, daptoll, dantime, dantoll, dapdist, a2ptime, a2ptoll, a2ntime, a2ntoll, a2pdist, 
  a3ptime, a3ptoll, a3ntime, a3ntoll, a3pdist, lnrtdist
FILEI MATI[1] = "%SCENARIO_DIR%\HWY_SKIM_%ITER%_%PER%.tmp"

DISTRIBUTEINTRASTEP ProcessID='Intrastep', ProcessList=1-%max_threads%
  zones = %zones%
  
    ; calculate weighted skims - initial skims do not factor in here
      
    ; Drive alone
    mw[1] = MI.1.33 * (1/(%ITER%)) + MI.2.1 * ((%ITER%-1)/(%ITER%))
    mw[2] = MI.1.35 * (1/(%ITER%)) + MI.2.2 * ((%ITER%-1)/(%ITER%))  
    mw[3] = MI.1.31 * (1/(%ITER%)) + MI.2.3 * ((%ITER%-1)/(%ITER%))
    mw[4] = 0
    mw[5] = MI.1.40 * (1/(%ITER%)) + MI.2.5 * ((%ITER%-1)/(%ITER%))

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

; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.


;ITER = 4
;iter = 1
; End of PILOT Script

; Script for program NETWORK in file "C:\ABM\CUBE\CANET00A.S"
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
 VMT_DIFF, VMT_DIFFSQ, VOL_DIFFSQ, HOV
  
 FF_SPD  = LI.1.SPEED
 FF_TIME = LI.1.TIME ; edit made 3/30/18 from TIME_1 to TIME  , TIME is Freeflow, TIME_1 is congested, per call with cambridge 
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


; Script for program NETWORK in file "C:\ABM\CUBE\CANET00B.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK MSG='Export link dbf'
FILEO LINKO = "%SCENARIO_DIR%\HWY_LDNET_%ITER%_DAILY.dbf"
FILEI LINKI[1] = "%SCENARIO_DIR%\HWY_LDNET_%ITER%_DAILY.NET"


ENDRUN


; Script for program MATRIX in file "C:\ABM\CUBE\CAMAT00A.S"
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


; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
;ITER = 4
;NEXTITER = ITER + 1
*cluster transit 1-2 START EXIT

LOOP TOD=1,2,1
 IF(TOD=1) TPER='PK' ASSIGNNAME='Peak Period'  PER ='AM' 
 IF(TOD=2) TPER='OP' ASSIGNNAME='OffPeak Period'  PER ='MD' 

 DISTRIBUTEMULTISTEP PROCESSID='transit' PROCESSNUM=%TOD%
; End of PILOT Script

; Script for program NETWORK in file "C:\ABM\CUBE\TSNET00F.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK MSG='Calculate Transit Speeds for %TPER%'
FILEI NODEI[1] = "%SCENARIO_DIR%\node.dbf"
FILEI LINKI[2] = "%SCENARIO_DIR%\ALL_NET.net"
FILEO NETO = "%SCENARIO_DIR%\XIT_NET_%ITER%_%TPER%.NET"
FILEI LOOKUPI[2] = "%CATALOG_DIR%\INPUT\TRANSIT\%TPER%EXPRESSDELAYS.TXT"
FILEI LOOKUPI[1] = "%CATALOG_DIR%\INPUT\TRANSIT\%TPER%LOCALDELAYS.TXT"
FILEI LINKI[1] = "%SCENARIO_DIR%\HWY_LDNET_%ITER%_%PER%.net"

    ;  transit time = congested time +  distance * link delay
    ;   Delays are calibrated by AREA and facility type and time period.
    LOOKUP NAME=locdelay, LOOKUP[1]=1, RESULT=2,
                            LOOKUP[2]=1, RESULT=3,
                            LOOKUP[3]=1, RESULT=4,
                            LOOKUP[4]=1, RESULT=5,
                            LOOKUP[5]=1, RESULT=6,
                            LOOKUP[6]=1, RESULT=7,
                            LOOKUP[7]=1, RESULT=7,
                            LOOKUP[8]=1, RESULT=7,
                            LOOKUP[9]=1, RESULT=7,
                            LOOKUP[10]=1, RESULT=7,
                            FAIL=0,0,0, INTERPOLATE=N,
                            LOOKUPI=1, LIST=Y

    LOOKUP NAME=expdelay, LOOKUP[1]=1, RESULT=2,
                            LOOKUP[2]=1, RESULT=3,
                            LOOKUP[3]=1, RESULT=4,
                            LOOKUP[4]=1, RESULT=5,
                            LOOKUP[5]=1, RESULT=6,
                            LOOKUP[6]=1, RESULT=7,
                            LOOKUP[7]=1, RESULT=7,
                            LOOKUP[8]=1, RESULT=7,
                            LOOKUP[9]=1, RESULT=7,
                            LOOKUP[10]=1, RESULT=2,         ; 1 and 10 are rural area types
                            FAIL=0,0,0, INTERPOLATE=N,
                            LOOKUPI=2, LIST=Y


    ; TODO: Move this into the GeoDB
    PHASE=NODEMERGE FILEI=NI.1 
      IF (N=17502)
        FAREZONE=1
      ENDIF
      IF (N=19759)
        FAREZONE=2
      ENDIF
      IF (N=19761)
        FAREZONE=3
      ENDIF
      IF (N=19762)
        FAREZONE=4
      ENDIF
      IF (N=19763)
        FAREZONE=5
      ENDIF
      IF (N=19764)
        FAREZONE=6
      ENDIF
      
    ENDPROCESS                            
                            
;;--------------------------------------------------------------------------

    ; Set transit speeds - same for PK/OP
    IF(LI.1.CSPD_1=0)
      SPEED=0.1
    ELSE
      SPEED = LI.1.CSPD_1
    ENDIF
    
;;--------------------------------------------------------------------------

    ; Code free flow speed for all links
    LOCTIME = (DISTANCE * 60 / SPEED)
    EXPTIME = (DISTANCE * 60 / SPEED)
    
;;--------------------------------------------------------------------------    

    ; Override manually coded speed for transit only links
    IF (LI.2.T_MANTIME>0)
        LOCTIME = T_MANTIME
        EXPTIME = T_MANTIME
        LRTTIME = T_MANTIME
    ENDIF    

;;--------------------------------------------------------------------------

    ;Calculate Local Bus Transit Travel Time
    IF (LOCTIME=0)
         _DELAY = locdelay(LI.1.AREA,LI.1.RCI)
         IF (T_Priority=2)
            IF ((SPEED+15)<50)
                _tspeed = MIN(SPEED+15,35)
            ELSE
                _tspeed=MAX(SPEED,35)
            ENDIF
            LOCTIME = (DISTANCE * 60 / _tspeed) + (DISTANCE * _DELAY)
         ELSE
            LOCTIME = (DISTANCE * 60 / SPEED) + (DISTANCE * _DELAY)
         ENDIF
    
        IF (LOCTIME=0) 
            PRINT LIST='LOCAL BUS TIME IS ZERO FOR - ', A(6), B(6)
        ENDIF        
    ENDIF
;;--------------------------------------------------------------------------
    
    ;Calculate Express Bus Transit Travel Time
    IF (EXPTIME=0)
        _DELAY = expdelay(LI.1.AREA,LI.1.RCI)
         IF (T_Priority=2)
            IF ((SPEED+15)<50)
                _tspeed = MIN(SPEED+15,35)
            ELSE
                _tspeed=MAX(SPEED,35)
            ENDIF
            EXPTIME = (DISTANCE * 60 / _tspeed) + (DISTANCE * _DELAY)
         ELSE
            EXPTIME = (DISTANCE * 60 / SPEED) + (DISTANCE * _DELAY)
         ENDIF
    
        IF (EXPTIME=0) 
            PRINT LIST='EXPRESS BUS TIME IS ZERO FOR - ', A(6), B(6)
        ENDIF
    ENDIF       

ENDRUN


; Script for program PUBLIC TRANSPORT in file "C:\ABM\CUBE\TSPTR00N.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=PUBLIC TRANSPORT MSG='Build %TPER% Walk Access Connectors'
FILEO NTLEGO = "%SCENARIO_DIR%\XIT_WKACC_NTL_%ITER%_%TPER%.TMP"
FILEO REPORTO = "%SCENARIO_DIR%\XIT_WKACC_RPT_%ITER%_%TPER%.RPT"
FILEO NETO = "%SCENARIO_DIR%\XIT_WKACC_NET_%ITER%_%TPER%.NET"
FILEI SYSTEMI = "%XIT_SYSTEM%"
FILEI FACTORI[1] = "%CATALOG_DIR%\INPUT\TRANSIT\%TPER%_WK_%xit_fac_year%.FAC"
FILEI LINEI[1] = "%XIT_LINES%"
FILEI NETI = "%SCENARIO_DIR%\XIT_NET_%ITER%_%TPER%.NET"

    REPORT Lines=T
    REREPORT Accesslegs=T, Egresslegs=T, Xferlegs=T, Lines=T, STOPNODES=T
    HDWAYPERIOD=%TOD%

    PHASE=LINKREAD
        _wlkspd = 2.5   ;mph
    ENDPHASE

    PHASE=DATAPREP
        Print List='Build Peak Walk Access Connectors', printo=0

        ;set transit travel time
        TRANTIME[5]=li.loctime       ; local
        TRANTIME[6]=li.loctime       ; local
        TRANTIME[7]=li.exptime       ; express
        TRANTIME[8]=li.lrttime       ; lrt
        TRANTIME[9]=li.exptime       ; commuter bus

        generate,
        fromnode=1-3061,
        tonode=3100-99999,
        direction=3,
        oneway=F,
        cost=li.Distance,
        extractcost=(Li.Distance*60/_wlkspd),
        excludelink=(li.RCI=1-5,13,14),   ;no walking on freeway, tollway,ramps and managed links
        maxcost=4*0,5*2,                 ;set maximum walking distance to 2 Miles
        maxntlegs=4*1,5*99,
        ntlegmode=1
    ENDPHASE


ENDRUN


; Script for program PUBLIC TRANSPORT in file "C:\ABM\CUBE\TSPTR00S.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=PUBLIC TRANSPORT MSG='Build %TPER% Transfer Access Connectors'
FILEO NTLEGO = "%SCENARIO_DIR%\XIT_XFER_NTL_%ITER%_%TPER%.TMP"
FILEO REPORTO = "%SCENARIO_DIR%\XIT_XFER_RPT_%ITER%_%TPER%.RPT"
FILEO NETO = "%SCENARIO_DIR%\XIT_XFER_NET_%ITER%_%TPER%.NET"
FILEI SYSTEMI = "%XIT_SYSTEM%"
FILEI FACTORI[1] = "%CATALOG_DIR%\INPUT\TRANSIT\%TPER%_WK_%xit_fac_year%.FAC"
FILEI LINEI[1] = "%XIT_LINES%"
FILEI NETI = "%SCENARIO_DIR%\XIT_NET_%ITER%_%TPER%.NET"

    REPORT Lines=T
    REREPORT Accesslegs=T, Egresslegs=T, Xferlegs=T, Lines=T, STOPNODES=T
    HDWAYPERIOD=%TOD%

 
    PHASE=LINKREAD
        _wlkspd = 2.5   ;mph
    ENDPHASE

    PHASE=DATAPREP
        Print List='Build Peak Transfer Connectors', printo=0
        ;set transit travel time
        TRANTIME[5]=li.loctime       ; local
        TRANTIME[6]=li.loctime       ; local
        TRANTIME[7]=li.exptime       ; express
        TRANTIME[8]=li.lrttime       ; lrt
        TRANTIME[9]=li.exptime       ; commuter bus

        ;*************************************
        ;    TRANSFER CONNECTORS
        ;*************************************
        ;generate the transfer legs based on transfer links
        generate,
        fromnode=3100-99999,
        tonode=3100-99999,
        direction=3,
        oneway=F,
        excludelink=(li.RCI=1-5,13,14),   ;no walking on freeway, tollway, and managed links
        cost=(Li.Distance*60/_wlkspd),
        maxcost=4*1,5*10,                 ;set maximum walking time to 10 minutes
        maxntlegs=4*1,5*10,
        ntlegmode=4
    ENDPHASE

ENDRUN


; Script for program PUBLIC TRANSPORT in file "C:\ABM\CUBE\TSPTR00U.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=PUBLIC TRANSPORT MSG='Build %TPER% Drive Access Connectors'
FILEO NTLEGO = "%SCENARIO_DIR%\XIT_DRACC_NTL_%ITER%_%TPER%.TMP"
FILEO REPORTO = "%SCENARIO_DIR%\XIT_DRACC_RPT_%ITER%_%TPER%.RPT"
FILEO NETO = "%SCENARIO_DIR%\XIT_DRACC_NET_%ITER%_%TPER%.NET"
FILEI SYSTEMI = "%XIT_SYSTEM%"
FILEI FACTORI[1] = "%CATALOG_DIR%\INPUT\TRANSIT\%TPER%_WK_%xit_fac_year%.FAC"
FILEI LINEI[1] = "%XIT_LINES%"
FILEI NETI = "%SCENARIO_DIR%\XIT_NET_%ITER%_%TPER%.NET"

    REPORT Lines=T
    REREPORT Accesslegs=T, Egresslegs=T, Xferlegs=T, Lines=T, STOPNODES=T
    HDWAYPERIOD=%TOD%

    PHASE=LINKREAD
        _wlkspd = 2.5;mph
        if (li.CSPD_1=0) 
            lw.roadtime=(li.distance/li.SPEED)*60
        else
            lw.roadtime=(li.distance/li.CSPD_1)*60
        ENDIF
    ENDPHASE

    PHASE=DATAPREP
        Print List='Build Peak Drive Access Connectors', printo=0

        ;set transit travel time
        TRANTIME[5]=li.loctime       ; local
        TRANTIME[6]=li.loctime       ; local
        TRANTIME[7]=li.exptime       ; express
        TRANTIME[8]=li.lrttime       ; lrt
        TRANTIME[9]=li.exptime       ; commuter bus

        Read FILE = "%XIT_PNRNODES%"
    ENDPHASE

ENDRUN


; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.

*copy "%SCENARIO_DIR%\XIT_WKACC_NTL_%ITER%_%TPER%.tmp"+"%CATALOG_DIR%\input\transit\WalkOverrides.txt" "%SCENARIO_DIR%\XIT_WKACC_NTL_%ITER%_%TPER%.ntl"
*copy "%SCENARIO_DIR%\XIT_XFER_NTL_%ITER%_%TPER%.tmp"+"%CATALOG_DIR%\input\transit\TransferOverrides.txt" "%SCENARIO_DIR%\XIT_XFER_NTL_%ITER%_%TPER%.ntl"
*copy "%SCENARIO_DIR%\XIT_DRACC_NTL_%ITER%_%TPER%.tmp"+"%CATALOG_DIR%\input\transit\DriveOverrides.txt" "%SCENARIO_DIR%\XIT_DRACC_NTL_%ITER%_%TPER%.ntl"
; End of PILOT Script

; Script for program PUBLIC TRANSPORT in file "C:\ABM\CUBE\TSPTR00J.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=PUBLIC TRANSPORT PRNFILE="%SCENARIO_DIR%\XIT_WK_PRN_%ITER%_%TPER%.prn" MSG='%TPER% Walk Transit Skim - Step 1'
FILEI FAREI = "%XIT_FARE%"
FILEO REPORTO = "%SCENARIO_DIR%\XIT_WK_RPT_%ITER%_%TPER%.RPT"
FILEO ROUTEO[1] = "%SCENARIO_DIR%\XIT_WK_RTE_%ITER%_%TPER%.RTE",
 TRACEI=164, TRACEJ=2578
FILEO MATO[1] = "%SCENARIO_DIR%\XIT_WK_SKIM_%ITER%_%TPER%.TMP",
 MO=1-12 NAME=IVT_Bus,IVT_LB,IVT_Exp,IVT_LRT,IVT_CRT,WAIT1,WAIT2,XFERS,WALKT,FARE,XBFARE,CRTFare
FILEO NETO = "%SCENARIO_DIR%\XIT_WK_NET_%ITER%_%TPER%.NET"
FILEI FACTORI[1] = "%CATALOG_DIR%\INPUT\TRANSIT\%TPER%_WK_%xit_fac_year%.FAC"
FILEI NTLEGI[3] = "%SCENARIO_DIR%\XIT_XFER_NTL_%ITER%_%TPER%.NTL"
FILEI NTLEGI[2] = "%SCENARIO_DIR%\XIT_DRACC_NTL_%ITER%_%TPER%.NTL"
FILEI NTLEGI[1] = "%SCENARIO_DIR%\XIT_WKACC_NTL_%ITER%_%TPER%.NTL"
FILEI LINEI[1] = "%XIT_LINES%"
FILEI SYSTEMI = "%XIT_SYSTEM%"
FILEI NETI = "%SCENARIO_DIR%\XIT_NET_%ITER%_%TPER%.NET"
FILEI FAREMATI[1] = "%XIT_FAREMAT%"

    PARAMETERS  HDWAYPERIOD=%TOD%
       
    PROCESS PHASE = DATAPREP
       TRANTIME[5]=li.loctime       ; local
       TRANTIME[6]=li.loctime       ; local
       TRANTIME[7]=li.exptime       ; express
       TRANTIME[8]=li.lrttime       ; lrt
       TRANTIME[9]=li.exptime       ; commuter bus
       GENERATE,
           READNTLEGI=1             ; walk  access link (mode=1)
       GENERATE,
           READNTLEGI=2             ; drive access link (mode=2)
       GENERATE,
           READNTLEGI=3             ; transfer link (mode=4)
    ENDPROCESS
    
    PROCESS PHASE = SKIMIJ
        MW[1]=TIMEA(0,5)            ; IVTT for local bus (mode=5) 
        MW[2]=TIMEA(0,6)            ; IVTT local limited stop bus (mode=6)
        MW[3]=TIMEA(0,7)            ; IVTT for Express Bus (mode=7)
        MW[4]=TIMEA(0,8)            ; IVTT for LRT (mode=8)
        MW[5]=TIMEA(0,9)            ; IVTT for CRT (mode=9)
        MW[6]=IWAITA(0)             ; initial wait time
        MW[7]=XWAITA(0)             ; transfer wait time
        MW[8]=BRDINGS(0,5,6,7,8,9)  ; number of boardings
        MW[9]=TIMEA(0,1,4)          ; OVTT for walk access & transfer
        MW[10]=FAREA(0,5,6,8)       ; local, limited and LRT Fares
        MW[11]=FAREA(0,7)           ; Express Fare        
        MW[12]=FAREA(0,9)           ; CRT Fare
    ENDPROCESS

ENDRUN


; Script for program PUBLIC TRANSPORT in file "C:\ABM\CUBE\TSPTR00L.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=PUBLIC TRANSPORT PRNFILE="%SCENARIO_DIR%\XIT_DR_PRN_%ITER%_%TPER%.prn" MSG='%TPER% Drive Transit Skim - Step 1'
FILEI FAREI = "%XIT_FARE%"
FILEO REPORTO = "%SCENARIO_DIR%\XIT_DR_RPT_%ITER%_%TPER%.RPT"
FILEO ROUTEO[1] = "%SCENARIO_DIR%\XIT_DR_RTE_%ITER%_%TPER%.RTE",
 TRACEI=164, TRACEJ=2578
FILEO MATO[1] = "%SCENARIO_DIR%\XIT_DR_SKIM_%ITER%_%TPER%.TMP",
 MO=1-14 NAME=IVT_Bus,IVT_LB,IVT_Exp,IVT_LRT,IVT_CRT,WAIT1,WAIT2,XFERS,WALKT,FARE,XBFARE,CRTFare,DR_ACCR,DR_ACCD
FILEO NETO = "%SCENARIO_DIR%\XIT_DR_NET_%ITER%_%TPER%.NET"
FILEI FACTORI[1] = "%CATALOG_DIR%\INPUT\TRANSIT\%TPER%_DR_%xit_fac_year%.FAC"
FILEI NTLEGI[3] = "%SCENARIO_DIR%\XIT_XFER_NTL_%ITER%_%TPER%.NTL"
FILEI NTLEGI[2] = "%SCENARIO_DIR%\XIT_DRACC_NTL_%ITER%_%TPER%.NTL"
FILEI NTLEGI[1] = "%SCENARIO_DIR%\XIT_WKACC_NTL_%ITER%_%TPER%.NTL"
FILEI LINEI[1] = "%XIT_LINES%"
FILEI SYSTEMI = "%XIT_SYSTEM%"
FILEI NETI = "%SCENARIO_DIR%\XIT_NET_%ITER%_%TPER%.NET"
FILEI FAREMATI[1] = "%XIT_FAREMAT%"

    PARAMETERS  HDWAYPERIOD=%TOD%
   
    PROCESS PHASE = DATAPREP
        TRANTIME[5]=li.loctime       ; local
        TRANTIME[6]=li.loctime       ; local
        TRANTIME[7]=li.exptime       ; express
        TRANTIME[8]=li.lrttime       ; lrt
        TRANTIME[9]=li.exptime       ; commuter bus
        GENERATE,
            READNTLEGI=1             ; walk  access link (mode=1)
        GENERATE,
            READNTLEGI=2             ; drive access link (mode=2)
        GENERATE,
            READNTLEGI=3             ; transfer link (mode=4)
    ENDPROCESS
    
    PROCESS PHASE = SKIMIJ
        MW[1]=TIMEA(0,5)            ; IVTT for local bus (mode=5) 
        MW[2]=TIMEA(0,6)            ; IVTT local limited stop bus (mode=6)
        MW[3]=TIMEA(0,7)            ; IVTT for Express Bus (mode=7)
        MW[4]=TIMEA(0,8)            ; IVTT for LRT (mode=8)
        MW[5]=TIMEA(0,9)            ; IVTT for CRT (mode=9)
        MW[6]=IWAITA(0)             ; initial wait time
        MW[7]=XWAITA(0)             ; transfer wait time
        MW[8]=BRDINGS(0,5,6,7,8,9)  ; number of boardings
        MW[9]=TIMEA(0,1,4)            ; OVTT for walk access & transfer
        MW[10]=FAREA(0,5,6,8)       ; local, limited and LRT Fares
        MW[11]=FAREA(0,7)           ; Express Fare        
        MW[12]=FAREA(0,9)           ; CRT Fare        
        MW[13]=TIMEA(0,2)
        MW[14]=DIST(0,2)
    ENDPROCESS
ENDRUN


; Script for program MATRIX in file "C:\ABM\CUBE\TSMAT00E.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='%TPER% Walk Skim - Step 2'
FILEO MATO[1] = "%SCENARIO_DIR%\XIT_WK_SKIM_%ITER%_%TPER%.SKM",
 MO=1-11, NAME=TRNTIME,WLKACC,WLKXFER,WLKEGR,IWAIT,XWAIT,XFERS,FARE,FAREP,FARER,FARES
FILEI MATI[1] = "%SCENARIO_DIR%\XIT_WK_SKIM_%ITER%_%TPER%.TMP"


MW[1]=MI.1.1 + MI.1.2 + MI.1.3 + MI.1.4 + MI.1.5 ; Bus, LB, Exp, LRT, CRT - IVT
MW[2]=MI.1.9      ;Walk access, Egress and Transfer Time
MW[3]=0           ; Zeroed out - do not have walk Xfer time seperate
MW[4]=0           ; Zeroed out - do not have walk Egress time seperate
MW[5]=MI.1.6      ; Inital Wait
MW[6]=MI.1.7      ; Transfer Wait
MW[7]=0
MW[8]=(MI.1.10+MI.1.11+MI.1.12)*100 ; Full Fare
MW[9]=(MI.1.10+MI.1.11+MI.1.12)*100*0.90; Reduced Fare (Pass Fare)
MW[10]=(MI.1.10+MI.1.11+MI.1.12)*100*0.90; Senior Fare (Seniors pay full fare in Peak)
MW[11]=(MI.1.10+MI.1.11+MI.1.12)*100*0.90*0.90; Student Fare
JLOOP
  IF (MI.1.8>0)
    MW[7]=MI.1.8-1    ; Transfers equals boards minus one  
  ENDIF
  IF ((I>1312 & I<1342) & (J>1312 & J<1342)) ; Downtown Minneapolis Zone
    MW[8]=50 * MI.1.8 ;Full Fare is $0.50 * boards
    MW[9]=50 * MI.1.8 ;Pass Fare is $0.50 * boards
    MW[10]=50 * MI.1.8;Senior Fare is $0.50 * boards
    MW[11]=50 * MI.1.8;Student Fare is $0.50 * boards
  ENDIF
  IF ((I>1999 & I<2022) & (J>1999 & J<2022)) ; Downtown St. Paul Zone
    MW[8]=50 * MI.1.8 ;Full Fare is $0.50 * boards
    MW[9]=50 * MI.1.8 ;Pass Fare is $0.50 * boards
    MW[10]=50 * MI.1.8;Senior Fare is $0.50 * boards
    MW[11]=50 * MI.1.8;Student Fare is $0.50 * boards
  ENDIF
ENDJLOOP


ENDRUN


; Script for program MATRIX in file "C:\ABM\CUBE\TSMAT00G.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='%TPER% Drive Skim - Step 2'
FILEO MATO[1] = "%SCENARIO_DIR%\XIT_DR_SKIM_%ITER%_%TPER%.SKM",
 MO=1-11, NAME=TRNTIME,DRACC,WLKXFER,WLKEGR,IWAIT,XWAIT,XFERS,FARE,FAREP,FARER,FARES
FILEI MATI[1] = "%SCENARIO_DIR%\XIT_DR_SKIM_%ITER%_%TPER%.TMP"

MW[1]=MI.1.1 + MI.1.2 + MI.1.3 + MI.1.4 + MI.1.5 ; Bus, LB, Exp, LRT, CRT - IVT
MW[2]=MI.1.13      ;Walk access, Egress and Transfer Time
MW[3]=0           ; Zeroed out - do not have walk Xfer time seperate
MW[4]=MI.1.9      ; Walk transfer and egress
MW[5]=MI.1.6      ; Inital Wait
MW[6]=MI.1.7      ; Transfer Wait
MW[7]=0
MW[8]=(MI.1.10+MI.1.11+MI.1.12)*100 ; Full Fare
MW[9]=(MI.1.10+MI.1.11+MI.1.12)*100*0.90; Reduced Fare (Pass Fare)
MW[10]=(MI.1.10+MI.1.11+MI.1.12)*100*0.90; Senior Fare (Seniors pay full fare in Peak)
MW[11]=(MI.1.10+MI.1.11+MI.1.12)*100*0.90*0.90; Student Fare
JLOOP
  IF (MI.1.8>0)
    MW[7]=MI.1.8-1    ; Transfers equals boards minus one  
  ENDIF
  IF ((I>1312 & I<1342) & (J>1312 & J<1342)) ; Downtown Minneapolis Zone
    MW[8]=50 * MI.1.8 ;Full Fare is $0.50 * boards
    MW[9]=50 * MI.1.8 ;Pass Fare is $0.50 * boards
    MW[10]=50 * MI.1.8;Senior Fare is $0.50 * boards
    MW[11]=50 * MI.1.8;Student Fare is $0.50 * boards
  ENDIF
  IF ((I>1999 & I<2022) & (J>1999 & J<2022)) ; Downtown St. Paul Zone
    MW[8]=50 * MI.1.8 ;Full Fare is $0.50 * boards
    MW[9]=50 * MI.1.8 ;Pass Fare is $0.50 * boards
    MW[10]=50 * MI.1.8;Senior Fare is $0.50 * boards
    MW[11]=50 * MI.1.8;Student Fare is $0.50 * boards
  ENDIF
ENDJLOOP

ENDRUN


; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.

ENDDISTRIBUTEMULTISTEP
ENDLOOP

Wait4Files FILES='transit1.script.end, transit2.script.end' CheckReturnCode=T, DelDistribFiles=T

*cluster transit 1-2 CLOSE EXIT
; End of PILOT Script

; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.

if (ITER == 1)
  ConvergeCheck = 1
else
  ConvergeCheck = 2
endif
; End of PILOT Script

  If (ConvergeCheck=2)
    goto ConvergeCheck_2
  Elseif (ConvergeCheck=1)
    goto ConvergeCheck_1
  Else
    PRINT LIST='Application Error: No Branch Selected from Branch Control "ConvergeCheck"'
    ABORT
  Endif

:ConvergeCheck_2
; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
;ITER = 2
PREV_ITER = ITER - 1
;PER='NT' 

; tag the iteration time and date
*echo.  >> "%SCENARIO_DIR%\converge.txt"
*echo.  >> "%SCENARIO_DIR%\converge.txt"
*echo 'Checking convergence for iteration %ITER%'  >> "%SCENARIO_DIR%\converge.txt"
*echo %date% %time%  >> "%SCENARIO_DIR%\converge.txt"

LOOP TOD=1,4,1
 IF(TOD=1) PER='NT' 
 IF(TOD=2) PER='AM' 
 IF(TOD=3) PER='MD' 
 IF(TOD=4) PER='PM' 
 
 
; End of PILOT Script

; Script for program NETWORK in file "C:\ABM\CUBE\CCNET00D.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK MSG='Unbuild network'
FILEO NETO = "%SCENARIO_DIR%\HWY_ITERCOMP_%PREV_ITER%_%ITER%_%PER%.NET",
     INCLUDE=A B LINKCLASS DISTANCE LOAD1 LOAD2 LOADCHG ABSLOADCHG PRCLOADCHG, 
            CSPD1 CSPD2 CSPDCHG ABSCSPDCHG PRCCSPDCHG,
            TIME1 TIME2 TIMECHG ABSTIMECHG PRCTIMECHG,
            VC1 VC2 VCCHG ABSVCCHG PRCVCCHG
FILEI LINKI[2] = "%SCENARIO_DIR%\HWY_LDNET_%ITER%_%PER%.NET"
FILEO LINKO = "%SCENARIO_DIR%\HWY_ITERCOMP_%PREV_ITER%_%ITER%_%PER%.dbf"
FILEI LINKI[1] = "%SCENARIO_DIR%\HWY_LDNET_%PREV_ITER%_%PER%.NET"

   LOAD1=LI.1.V_1

   LOAD2=LI.2.V_1

   LOADCHG=(LOAD2-LOAD1)

   ABSLOADCHG=ABS(LOAD2-LOAD1)

if (load1>0) PRCLOADCHG=LOADCHG/LOAD1

   CSPD1=LI.1.CSPD_1

   CSPD2=LI.2.CSPD_1

   CSPDCHG=(CSPD1-CSPD2)

   ABSCSPDCHG=ABS(CSPD1-CSPD2)

if (CSPD1>0) PRCCSPDCHG=CSPDCHG/CSPD1

   TIME1=LI.1.TIME_1

   TIME2=LI.2.TIME_1

   TIMECHG=(TIME1-TIME2)

   ABSTIMECHG=ABS(TIME1-TIME2)

if (TIME1>0) PRCTIMECHG=TIMECHG/TIME1

   VC1=LI.1.VC_1

   VC2=LI.2.VC_1

   VCCHG=(VC1-VC2)

   ABSVCCHG=ABS(VC1-VC2)

if (VC1>0) PRCVCCHG=VCCHG/VC1

ENDRUN


; Script for program MATRIX in file "C:\ABM\CUBE\CCMAT00A.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Calculate convergence stats'
FILEO PRINTO[1] = "%SCENARIO_DIR%\CONVERGE_%ITER%_%PER%.txt"
FILEI DBI[1] = "%SCENARIO_DIR%\HWY_ITERCOMP_%PREV_ITER%_%ITER%_%PER%.dbf",
 SORT=A,B 

  zones = 1
  
  _totLinks = 0
  _chgLinks = 0
  _prevVMT = 0
  _curVMT = 0
  _sumSE = 0
  
 ; First loop through each records and calculate differences
 LOOP k=1,DBI.1.NUMRECORDS
  
  x=DBIReadRecord(1,k)
  
  ; only check for non-centroid connectors
  IF (DI.1.LINKCLASS <> 99)
 
    _totLinks = _totLinks + 1
    
    IF (ABS(DI.1.PRCLOADCHG) > (%conv_LinkVol%/100))
      
        _chgLinks = _chgLinks + 1
        
    ENDIF
      
    _prevVMT = _prevVMT + DI.1.LOAD1*DI.1.DISTANCE
    _curVMT  = _curVMT  + DI.1.LOAD2*DI.1.DISTANCE
    _sumSE   = _sumSE   + ((DI.1.LOAD1 - DI.1.LOAD2)*DI.1.DISTANCE)^2

  ENDIF ; centroid connector

  
 ENDLOOP

 ; Next, calculate overall PRMSE 
 _MSE = _sumSE / _totLinks
 _PRMSE = 100*SQRT(_MSE)/(_curVMT/_totLinks)
 _errLinks = (_chgLinks / _totLinks) * 100
 
 LOG PREFIX=%PER%, VAR=_errLinks
 LOG VAR = _errLinks
 
 PRINT CSV=F LIST='Convergence check for period %PER% iteration %ITER%' PRINTO=1 
 PRINT CSV=F LIST='Previous %PER% VMT was ', _prevVMT PRINTO=1
 PRINT CSV=F LIST='Current %PER% VMT is ', _curVMT PRINTO=1
 PRINT CSV=F LIST='The percent of %PER% link volumes exceeding ', %conv_LinkVol%, '% change is ', _errLinks, '%' PRINTO=1
 PRINT CSV=F LIST='%PER% PRMSE is ', _PRMSE, '%' PRINTO=1

ENDRUN


; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.

*echo.  >> "%SCENARIO_DIR%\converge.txt"
*type "%SCENARIO_DIR%\converge_%ITER%_%PER%.txt" >> "%SCENARIO_DIR%\converge.txt"
*echo.  >> "%SCENARIO_DIR%\converge.txt"

endloop

; check if converged

if ((OP._ERRLINKS > %conv_LinkPerc%) |
    (MD._ERRLINKS > %conv_LinkPerc%) |
    (AM._ERRLINKS > %conv_LinkPerc%) |
    (PM._ERRLINKS > %conv_LinkPerc%))
    
  *echo Iteration %ITER% Not Converged >> "%SCENARIO_DIR%\converge.txt"
  
else
 
  *echo Iteration %ITER% Converged! >> "%SCENARIO_DIR%\converge.txt"
  
   CONV = 1
   LOG VAR=CONV
   ;LOG PREFIX=CONVCHECK, VAR=CONV ; It appears that Cube does not write a prefix if logged from a Pilot program
   
endif

if (ITER == %max_feedback%)
  *echo.  >> "%SCENARIO_DIR%\converge.txt"
  *echo Maximum Iterations Hit >> "%SCENARIO_DIR%\converge.txt"
  *echo.  >> "%SCENARIO_DIR%\converge.txt"
  
    CONV = 1
   LOG VAR=CONV
endif
; End of PILOT Script

  goto ConvergeCheck_END

:ConvergeCheck_1
; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.


;ITER = 1
;PER='NT' 

LOOP TOD=1,4,1
 IF(TOD=1) PER='NT' 
 IF(TOD=2) PER='AM' 
 IF(TOD=3) PER='MD' 
 IF(TOD=4) PER='PM' 
; End of PILOT Script

; Script for program NETWORK in file "C:\ABM\CUBE\IINET00C.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK MSG='Unbuild network'
FILEO LINKO = "%SCENARIO_DIR%\HWY_LDNET_%ITER%_%PER%.dbf"
FILEI LINKI[1] = "%SCENARIO_DIR%\HWY_LDNET_%ITER%_%PER%.NET"


ENDRUN


; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.


ENDLOOP
; End of PILOT Script

  goto ConvergeCheck_END

:ConvergeCheck_END
; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.

if(CONV ==1)
  FinalAssign = 2
else
  FinalAssign = 1
endif
; End of PILOT Script

  If (FinalAssign=2)
    goto FinalAssign_2
  Elseif (FinalAssign=1)
    goto FinalAssign_1
  Else
    PRINT LIST='Application Error: No Branch Selected from Branch Control "FinalAssign"'
    ABORT
  Endif

:FinalAssign_2
; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.

;NEXTITER = ITER + 1
*Cluster Intrastep 1-%max_threads% START EXIT

LOOP TOD=1,11,1
 IF(TOD=1) PER='AM1' ASSIGNNAME='AM1 Peak Period'    HWY_NET ='HWY_NET_3.net'    NETNAME='AM Peak Period 6:00 AM to 7:00 AM'  CAPFAC = 1
 IF(TOD=2) PER='AM2' ASSIGNNAME='AM2 Peak Period'    HWY_NET ='HWY_NET_3.net'    NETNAME='AM Peak Period 7:00 AM to 8:00 AM'  CAPFAC = 1 
 IF(TOD=3) PER='AM3' ASSIGNNAME='AM3 Peak Period'    HWY_NET ='HWY_NET_3.net'    NETNAME='AM Peak Period 8:00 AM to 9:00 AM'  CAPFAC = 1
 IF(TOD=4) PER='AM4' ASSIGNNAME='AM4 Peak Period'    HWY_NET ='HWY_NET_3.net'    NETNAME='AM Peak Period 9:00 AM to 10:00 AM'  CAPFAC = 1 
  
 IF(TOD=5) PER='MD' ASSIGNNAME='Mid Day Period'    HWY_NET ='HWY_NET_4.net'    NETNAME='Mid Day Period 10:00 AM to 3:00 PM'  CAPFAC = 4.48

 IF(TOD=6) PER='PM1' ASSIGNNAME='PM1 Peak Period'    HWY_NET ='HWY_NET_6.net'    NETNAME='PM Peak Period 3:00 PM to 4:00 PM'  CAPFAC = 1
 IF(TOD=7) PER='PM2' ASSIGNNAME='PM2 Peak Period'    HWY_NET ='HWY_NET_6.net'    NETNAME='PM Peak Period 4:00 PM to 5:00 PM'  CAPFAC = 1
 IF(TOD=8) PER='PM3' ASSIGNNAME='PM3 Peak Period'    HWY_NET ='HWY_NET_6.net'    NETNAME='PM Peak Period 5:00 PM to 6:00 PM'  CAPFAC = 1 
 IF(TOD=9) PER='PM4' ASSIGNNAME='PM4 Peak Period'    HWY_NET ='HWY_NET_6.net'    NETNAME='PM Peak Period 6:00 PM to 7:00 PM'  CAPFAC = 1

 IF(TOD=10) PER='EV' ASSIGNNAME='Evening Period'  HWY_NET ='HWY_NET_1.net'    NETNAME='Evening 7:00 PM to 12:00 AM'  CAPFAC = 3.32 
 IF(TOD=11) PER='ON' ASSIGNNAME='Overnight Period'  HWY_NET ='HWY_NET_1.net'    NETNAME='Overnight 12:00 AM to 6:00 AM'  CAPFAC = 2.59
  


; End of PILOT Script

; Script for program MATRIX in file "C:\ABM\CUBE\HTMAT00B.S"
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


; Script for program HIGHWAY in file "C:\ABM\CUBE\HTHWY00B.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=HIGHWAY MSG='Assignment Period: %ASSIGNNAME%'
FILEI MATI[4] = "%SCENARIO_DIR%\HWY_SPC_AUTO_TRIP_%ITER%_%PER%.trp"
FILEI MATI[3] = "%SCENARIO_DIR%\HWY_EXT_TRIP_%ITER%_%PER%.trp"
FILEI MATI[2] = "%SCENARIO_DIR%\TRK_TRIP_%ITER%_%PER%.trp"
FILEO PRINTO[1] = "%SCENARIO_DIR%\HWY_LDNET_PRN_%ITER%_%PER%.txt"
DISTRIBUTEINTRASTEP ProcessID="Intrastep", ProcessList=1-%max_threads%
FILEO MATO[1] = "%SCENARIO_DIR%\HWY_SKIM_%ITER%_%PER%.tmp",
                 MO=1-120, DEC[1]=5*120, COMBINE=T
FILEO NETO = "%SCENARIO_DIR%\HWY_LDNET_%ITER%_%PER%.NET"
FILEI NETI = "%SCENARIO_DIR%\%HWY_NET%"
FILEI LOOKUPI[1] = "%LU_WILL2PAY%"
FILEI MATI[1] = "%SCENARIO_DIR%\HWY_AUTO_TRIP_%ITER%_%PER%.trp"


 ; **********   Define Assignment Parameters    ************
    
    PARAMETERS raad=0.0001 gap = 0.0001 RELATIVEGAP = 0.0001 aad = 0.01  MAXITERS = %hwy_assignIters% COMBINE=EQUI
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
    
    ; conical function with variable alpha/beta - 13% low on VMT
    ;FUNCTION TC[99] = T0 * (2+SQRT((ALPHA^2)*(1-(V/C))^2 + BETA^2) - ALPHA*(1-(V/C)) - BETA) 
    
    ;FUNCTION TC[1] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    ;FUNCTION TC[2] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    ;FUNCTION TC[3] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    ;FUNCTION TC[4] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    ;FUNCTION TC[5] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    ;FUNCTION TC[6] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    ;FUNCTION TC[7] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    ;FUNCTION TC[8] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    ;FUNCTION TC[9] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    ;FUNCTION TC[10] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    ;FUNCTION TC[11] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    ;FUNCTION TC[12] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    ;FUNCTION TC[13] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    ;FUNCTION TC[14] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    ;FUNCTION TC[15] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    ;FUNCTION TC[99] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167)  

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

; Group 2: HOV SECTIONS - Rachel Editing groups, adding more
        IF (LI.HOV=1,7,9)    ADDTOGROUP=1  ;I-35W	NB	Dakota County to Downtown 
        IF (LI.HOV=2,8,17)   ADDTOGROUP=2  ;I-35W	SB	Downtown to Dakota County 
        IF (LI.HOV=6)        ADDTOGROUP=3  ;I-394	WB DT to 100
        IF (LI.HOV=61)       ADDTOGROUP=4  ;I-394	EB 100 to DT
        IF (LI.HOV=4)        ADDTOGROUP=5  ;I-394	WB	STH-100	I-494 Outbound
        IF (LI.HOV=5)        ADDTOGROUP=6  ;I-394	EB	I-494	STH-100	Inbound
        IF (LI.HOV=11,25)    ADDTOGROUP=7  ; 35E outbound, DT StP to CRJ
        IF (LI.HOV=12,24)    ADDTOGROUP=8  ; 35w inbound, CRJ to DTstP
        IF (LI.HOV=13)       ADDTOGROUP=9 ; 35W NB, Hwy 36 to Blaine
        IF (LI.HOV=14)       ADDTOGROUP=10 ; 35W SB , Blaine to Hwy 36
        IF (LI.HOV=15)       ADDTOGROUP=11 ; 94 between downtowns EB
        IF (LI.HOV=16)       ADDTOGROUP=12 ; 94 between downtowns WB
        IF (LI.HOV=18)       ADDTOGROUP=13 ; 252 SB
        IF (LI.HOV=19)       ADDTOGROUP=14 ; 252 NB
        IF (LI.HOV=23,21)    ADDTOGROUP=15 ; SB 94 from 694 to DT
        IF (LI.HOV=20,22)    ADDTOGROUP=16  ; NB 94 from DT to 694
        IF (LI.HOV=27,29)    ADDTOGROUP=17  ; NB 35w / Hwy 36
        IF (LI.HOV=26,28)    ADDTOGROUP=18 ; SB hwy 36 / 35W
        IF (LI.HOV=30)    ADDTOGROUP=19 ; 94 rogers to maplegrove
        IF (LI.HOV=31)    ADDTOGROUP=20 ; 94 maplegrove to rogers
        IF (LI.HOV=32)    ADDTOGROUP=21 ; 169 from 694 to 394
        IF (LI.HOV=33)    ADDTOGROUP=22  ; 169 from 394 to 694
        IF (LI.HOV=34)    ADDTOGROUP=23 ; 169 from shakopee to 394
        IF (LI.HOV=35)    ADDTOGROUP=24 ; 169 from 394 to shakopee
        IF (LI.HOV=36)    ADDTOGROUP=25 ; 494 EB from 212 to Minnesota River, congested both directions 
        IF (LI.HOV=37)    ADDTOGROUP=26 ; 494 WB from Minnesota River to 212, congested both directions 
        IF (LI.HOV=38,39)    ADDTOGROUP=27 ; 94/694 from maple grove to 94 south into DT, partial lane converstion
        IF (LI.HOV=40,41)    ADDTOGROUP=28 ; 94/694 from 94 to maplegrove, partial lane converstion 
        IF (LI.HOV=42)    ADDTOGROUP=29 ; 694 EB from 94 to 35W
        IF (LI.HOV=43)    ADDTOGROUP=31 ; 694 WB from 35W to 94  SKIPPING GROUP 30 because used above 
        IF (LI.HOV=44,45)    ADDTOGROUP=32 ; 77 NB and SB combinging these groups because i can't have 33 groups
        
        
        
       ; rachel adding toll groups 6 - 24
        _toll1 = 25
        _toll2 = 25
        _toll3 = 25
        _toll4 = 25
        _toll5 = 25
        _toll6 = 25
        _toll7 = 25
        _toll8 = 25
        _toll9 = 25
        _toll10 = 25
        _toll11 = 25
        _toll12 = 25
        _toll13 = 25
        _toll14 = 25
        _toll15 = 25
        _toll16 = 25
        _toll17 = 25
        _toll18 = 25
        _toll19 = 25
        _toll20 = 25
        _toll21 = 25
        _toll22 = 25
        _toll23 = 25
        _toll24 = 25
        _toll25 = 25
        _toll26 = 25
        _toll27 = 25
        _toll28 = 25
        _toll29 = 25
        _toll31 = 25 ; SKIPPING GROUP 30 because used above 
        _toll32 = 25
        
    ENDPHASE 

    PHASE=ILOOP           

      MW[1] = MI.1.1    MW[2] = MI.1.2    MW[3] = MI.1.3    MW[4] = MI.1.4    MW[5] = MI.1.5 ; SOV Work
      MW[6] = MI.1.6    MW[7] = MI.1.7    MW[8] = MI.1.8    MW[9] = MI.1.9    MW[10]= MI.1.10 ; HOV2 Work
      MW[11]= MI.1.11   MW[12]= MI.1.12   MW[13]= MI.1.13   MW[14]= MI.1.14   MW[15]= MI.1.15 ; HOV3 Work
      MW[16]= MI.1.16   MW[17]= MI.1.17   MW[18]= MI.1.18   MW[19]= MI.1.19   MW[20]= MI.1.20 ; SOV NON Work
      MW[21]= MI.1.21   MW[22]= MI.1.22   MW[23]= MI.1.23   MW[24]= MI.1.24   MW[25]= MI.1.25 ; HOV2 NON Work
      MW[26]= MI.1.26   MW[27]= MI.1.27   MW[28]= MI.1.28   MW[29]= MI.1.29   MW[30]= MI.1.30 ; HOV3 NON Work
      MW[119] = MI.1.31    MW[120] = MI.1.32 + MI.3.1 + MI.3.2 + MI.3.3 + MI.4.1 + MI.4.2 + MI.4.3    ; SOVInc1, SOVInc25 - No Transponder / Externals / Spec Gen in with SOVInc25

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
                MW[85]=_toll5, selectgroup=5 ; Rachel add in new working maxtrix starting at 200
                MW[200]=_toll6, selectgroup=6
                MW[201]=_toll7, selectgroup=7
                MW[202]=_toll8, selectgroup=8
                MW[203]=_toll9, selectgroup=9
                MW[204]=_toll10, selectgroup=10
                MW[205]=_toll11, selectgroup=11
                MW[206]=_toll12, selectgroup=12
                MW[207]=_toll13, selectgroup=13
                MW[208]=_toll14, selectgroup=14
                MW[209]=_toll15, selectgroup=15
                MW[210]=_toll16, selectgroup=16
                MW[211]=_toll17, selectgroup=17
                MW[212]=_toll18, selectgroup=18
                MW[213]=_toll19, selectgroup=19
                MW[214]=_toll20, selectgroup=20
                MW[215]=_toll21, selectgroup=21
                MW[216]=_toll22, selectgroup=22
                MW[217]=_toll23, selectgroup=23
                MW[218]=_toll24, selectgroup=24
                MW[219]=_toll25, selectgroup=25
                MW[220]=_toll26, selectgroup=26
                MW[221]=_toll27, selectgroup=27
                MW[222]=_toll28, selectgroup=28
                MW[223]=_toll29, selectgroup=29
                MW[224]=_toll31, selectgroup=31
                MW[225]=_toll32, selectgroup=32
                


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
      ; rachel add new working maxtrix here MW[200 - 225]
       MW[35] =  MW[81]+MW[82]+MW[83]+MW[84]+MW[85]+MW[200]+MW[201]+MW[202]+MW[203]+MW[204]+MW[205]+MW[206]+MW[207]+MW[208]+MW[209]+MW[210]+MW[211]+MW[212]+MW[213]+MW[214]+MW[215]+MW[216]+MW[217]+MW[218]+MW[219]+MW[220]+MW[221]+MW[222]+MW[223]+MW[224]+MW[225]
       
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
          MW[95] = MW[85] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80])   ; toll5 revenue  rachel keep adding here from MW[200] to MW[218]
          MW[300] = MW[200] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll6 revenue 
          MW[301] = MW[201] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll7 revenue 
          MW[302] = MW[202] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll8 revenue 
          MW[303] = MW[203] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll9 revenue 
          MW[304] = MW[204] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll10 revenue 
          MW[305] = MW[205] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll11 revenue 
          MW[306] = MW[206] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll12 revenue 
          MW[307] = MW[207] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll13 revenue 
          MW[308] = MW[208] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll14 revenue 
          MW[309] = MW[209] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll15 revenue 
          MW[310] = MW[210] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll16 revenue 
          MW[311] = MW[211] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll17 revenue 
          MW[312] = MW[212] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll18 revenue 
          MW[313] = MW[213] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll19 revenue 
          MW[314] = MW[214] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll20 revenue 
          MW[315] = MW[215] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll21 revenue 
          MW[316] = MW[216] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll22 revenue 
          MW[317] = MW[217] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll23 revenue 
          MW[318] = MW[218] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll24 revenue 
          MW[319] = MW[219] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll25 revenue
          MW[320] = MW[220] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll26 revenue
          MW[321] = MW[221] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll27 revenue
          MW[322] = MW[222] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll28 revenue
          MW[323] = MW[223] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll29 revenue
          MW[324] = MW[224] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll31 revenue
          MW[325] = MW[225] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll32 revenue
        
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
          _maxVC5 = 0 ; Rachel keep adding here, maxVCs to group 32
          _maxVC6 = 0
          _maxVC7 = 0
          _maxVC8 = 0
          _maxVC9 = 0
          _maxVC10 = 0
          _maxVC11 = 0
          _maxVC12 = 0
          _maxVC13 = 0
          _maxVC14 = 0
          _maxVC15 = 0
          _maxVC16 = 0
          _maxVC17 = 0
          _maxVC18 = 0
          _maxVC19 = 0
          _maxVC20 = 0
          _maxVC21 = 0
          _maxVC22 = 0
          _maxVC23 = 0
          _maxVC24 = 0
          _maxVC25 = 0
          _maxVC26 = 0
          _maxVC27 = 0
          _maxVC28 = 0
          _maxVC29 = 0
          _maxVC31 = 0
          _maxVC32 = 0
          
          
          
          
         
          IF (Iteration =1)
            PRINT CSV=T LIST='Iteration,ANode,BNode,HOV,Volume,VC,TIME,DISTANCE, VHT, VMT, Toll1, Toll2, Toll3, Toll4, Toll5, Toll6, Toll7, Toll8, Toll9, Toll10, Toll11, Toll12, Toll13, Toll14, Toll15, Toll16, Toll17, Toll18, Toll19, Toll20, Toll21, Toll22, Toll23, Toll24, Toll25, Toll26, Toll27, Toll28, Toll29, Toll31, Toll32' PRINTO=1          ; adding new toll groups here to try to fix intrastep issues PRINTO=1          
          ENDIF
         ENDIF

; *** COMPUTE MAXIMUM V/C RATIO AND TOLL RATES FOR NEXT ITERATION ON TOLLED SEGMENTS ***
;HOT Lanes
          IF (LW.HOV=1,7,9 & C>0)
          IF ((V/C) > _maxVC1) _maxVC1 = (V/C)
        ENDIF
        IF (LW.HOV=2,8,17 & C>0)
          IF ((V/C) > _maxVC2) _maxVC2 = (V/C)          
        ENDIF
        IF (LW.HOV=6 & C>0)
          IF ((V/C) > _maxVC3) _maxVC3 = (V/C)
        ENDIF
        IF (LW.HOV=61 & C>0)
          IF ((V/C) > _maxVC4) _maxVC4 = (V/C)
        ENDIF
        IF (LW.HOV=4 & C>0)
          IF ((V/C) > _maxVC5) _maxVC5 = (V/C)
        ENDIF ; Rachel keep adding here too
        
        IF (LW.HOV=5 & C>0)
          IF ((V/C) > _maxVC6) _maxVC6 = (V/C)
        ENDIF
        IF (LW.HOV=11,25 & C>0)
          IF ((V/C) > _maxVC7) _maxVC7 = (V/C)          
        ENDIF
        IF (LW.HOV=12,24 & C>0)
          IF ((V/C) > _maxVC8) _maxVC8 = (V/C)
        ENDIF
        IF (LW.HOV=13 & C>0)
          IF ((V/C) > _maxVC9) _maxVC9 = (V/C)
        ENDIF
        IF (LW.HOV=14 & C>0)
          IF ((V/C) > _maxVC10) _maxVC10 = (V/C)
        ENDIF 
        
         IF (LW.HOV=15 & C>0)
          IF ((V/C) > _maxVC11) _maxVC11 = (V/C)
        ENDIF
        IF (LW.HOV=16 & C>0)
          IF ((V/C) > _maxVC12) _maxVC12 = (V/C)          
        ENDIF
        IF (LW.HOV=18 & C>0)
          IF ((V/C) > _maxVC13) _maxVC13 = (V/C)
        ENDIF
        IF (LW.HOV=19 & C>0)
          IF ((V/C) > _maxVC14) _maxVC14 = (V/C)
        ENDIF
        IF (LW.HOV=23,21 & C>0)
          IF ((V/C) > _maxVC15) _maxVC15 = (V/C)
        ENDIF 
        
         IF (LW.HOV=20,22 & C>0)
          IF ((V/C) > _maxVC16) _maxVC16 = (V/C)
        ENDIF
        IF (LW.HOV=27,29 & C>0)
          IF ((V/C) > _maxVC17) _maxVC17 = (V/C)          
        ENDIF
        IF (LW.HOV=26,28 & C>0)
          IF ((V/C) > _maxVC18) _maxVC18 = (V/C)
        ENDIF
        IF (LW.HOV=30 & C>0)
          IF ((V/C) > _maxVC19) _maxVC19 = (V/C)
        ENDIF
        IF (LW.HOV=31 & C>0)
          IF ((V/C) > _maxVC20) _maxVC20 = (V/C)
        ENDIF 
        
         IF (LW.HOV=32 & C>0)
          IF ((V/C) > _maxVC21) _maxVC21 = (V/C)
        ENDIF
        IF (LW.HOV=33 & C>0)
          IF ((V/C) > _maxVC22) _maxVC22 = (V/C)          
        ENDIF
        IF (LW.HOV=34 & C>0)
          IF ((V/C) > _maxVC23) _maxVC23 = (V/C)
        ENDIF
        IF (LW.HOV=35 & C>0)
          IF ((V/C) > _maxVC24) _maxVC24 = (V/C)
        ENDIF
        
         IF (LW.HOV=36 & C>0)
            IF ((V/C) > _maxVC25) _maxVC25 = (V/C)
          ENDIF
          
        IF (LW.HOV=37 & C>0)
          IF ((V/C) > _maxVC26) _maxVC26 = (V/C)
        ENDIF
        
        IF (LW.HOV=38,39 & C>0)
          IF ((V/C) > _maxVC27) _maxVC27 = (V/C)
        ENDIF
        
        IF (LW.HOV=40,41 & C>0)
          IF ((V/C) > _maxVC28) _maxVC28 = (V/C)
        ENDIF
        
        IF (LW.HOV=42 & C>0)
          IF ((V/C) > _maxVC29) _maxVC29 = (V/C)
        ENDIF
        
        IF (LW.HOV=43 & C>0)
          IF ((V/C) > _maxVC31) _maxVC31 = (V/C)   ; skipping 30 again because of excluded group, see line 96
        ENDIF
        
        IF (LW.HOV=44,45 & C>0)
          IF ((V/C) > _maxVC32) _maxVC32 = (V/C)
        ENDIF
        
      
        
        
        
        
         
        ;Tolls for Next Assignment Iteration
       _toll1 = TOLL(1,_maxVC1)
        _toll2 = TOLL(1,_maxVC2)
        _toll3 = TOLL(1,_maxVC3)
        _toll4 = TOLL(1,_maxVC4)
        _toll5 = TOLL(1,_maxVC5) ; rachel keep adding up to toll24, maxvc24
        _toll5 = TOLL(1,_maxVC5)
        _toll6 = TOLL(1,_maxVC6)
        _toll7 = TOLL(1,_maxVC7)
        _toll8 = TOLL(1,_maxVC8)
        _toll9 = TOLL(1,_maxVC9)
        _toll10 = TOLL(1,_maxVC10)
        _toll11 = TOLL(1,_maxVC11)
        _toll12 = TOLL(1,_maxVC12)
        _toll13 = TOLL(1,_maxVC13)
        _toll14 = TOLL(1,_maxVC14)
        _toll15 = TOLL(1,_maxVC15)
        _toll16 = TOLL(1,_maxVC16)
        _toll17 = TOLL(1,_maxVC17)
        _toll18 = TOLL(1,_maxVC18)
        _toll19 = TOLL(1,_maxVC19)
        _toll20 = TOLL(1,_maxVC20)
        _toll21 = TOLL(1,_maxVC21)
        _toll22 = TOLL(1,_maxVC22)
        _toll23 = TOLL(1,_maxVC23)
        _toll24 = TOLL(1,_maxVC24)
        _toll25 = TOLL(1,_maxVC25)
        _toll26 = TOLL(1,_maxVC26)
        _toll27 = TOLL(1,_maxVC27)
        _toll28 = TOLL(1,_maxVC28)
        _toll29 = TOLL(1,_maxVC29)
        _toll31 = TOLL(1,_maxVC31)
        _toll32 = TOLL(1,_maxVC32)
       

        
        
        IF (LW.HOV>0 & V>0)
                    
          PRINT CSV=T LIST=iteration(2.0),A(6.0),B(6.0),LW.HOV(4.0),V(8.2),V/C(8.42),TIME(5.2), DISTANCE(5.2), V*TIME(15.2), V*DISTANCE(15.2), _toll1(5.2), _toll2(5.2), _toll3(5.2), _toll4(5.2), _toll5(5.2), _toll6(5.2), _toll7(5.2), _toll8(5.2), _toll9(5.2), _toll10(5.2), _toll11(5.2), _toll12(5.2), _toll13(5.2), _toll14(5.2), _toll15(5.2), _toll16(5.2), _toll17(5.2), _toll18(5.2), _toll19(5.2), _toll20(5.2), _toll21(5.2), _toll22(5.2), _toll23(5.2), _toll24(5.2), _toll25(5.2), _toll26(5.2), _toll27(5.2), _toll28(5.2), _toll29(5.2), _toll31(5.2), _toll32(5.2) PRINTO=1
        ENDIF
    ENDPHASE

ENDRUN


; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.


ENDLOOP
*Cluster Intrastep 1-%max_threads% CLOSE EXIT
; End of PILOT Script

; Script for program MATRIX in file "C:\ABM\CUBE\PAMAT00C.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Combine Special Generator Trips into Peak/Off-Peak'
FILEO MATO[2] = "%SCENARIO_DIR%\XIT_SPC_TRIP_%ITER%_OP.trp",
 MO=11-12, NAME=WK, DR
FILEO MATO[1] = "%SCENARIO_DIR%\XIT_SPC_TRIP_%ITER%_PK.trp",
 MO=1-2, NAME=WK, DR
FILEI MATI[11] = "%SCENARIO_DIR%\HWY_SPC_TRIP_%ITER%_ON.trp"
FILEI MATI[10] = "%SCENARIO_DIR%\HWY_SPC_TRIP_%ITER%_EV.trp"
FILEI MATI[9] = "%SCENARIO_DIR%\HWY_SPC_TRIP_%ITER%_MD.trp"
FILEI MATI[8] = "%SCENARIO_DIR%\HWY_SPC_TRIP_%ITER%_PM4.trp"
FILEI MATI[7] = "%SCENARIO_DIR%\HWY_SPC_TRIP_%ITER%_PM3.trp"
FILEI MATI[6] = "%SCENARIO_DIR%\HWY_SPC_TRIP_%ITER%_PM2.trp"
FILEI MATI[5] = "%SCENARIO_DIR%\HWY_SPC_TRIP_%ITER%_PM1.trp"
FILEI MATI[4] = "%SCENARIO_DIR%\HWY_SPC_TRIP_%ITER%_AM4.trp"
FILEI MATI[3] = "%SCENARIO_DIR%\HWY_SPC_TRIP_%ITER%_AM3.trp"
FILEI MATI[2] = "%SCENARIO_DIR%\HWY_SPC_TRIP_%ITER%_AM2.trp"
FILEI MATI[1] = "%SCENARIO_DIR%\HWY_SPC_TRIP_%ITER%_AM1.trp"

  ; peak
  MW[1] = MI.1.4 + MI.2.4 + MI.3.4 + MI.4.4 + MI.5.4 + MI.6.4 + MI.7.4 + MI.8.4
  MW[2] = MI.1.5 + MI.2.5 + MI.3.5 + MI.4.5 + MI.5.5 + MI.6.5 + MI.7.5 + MI.8.5
  
  ; off-peak
  MW[11] = MI.9.4 + MI.10.4 + MI.11.4
  MW[12] = MI.9.5 + MI.10.5 + MI.11.5
  
ENDRUN


; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.

;NEXTITER = ITER + 1

*cluster transit 1-2 START EXIT

LOOP TOD=1,2,1
 IF(TOD=1) TPER='PK' ASSIGNNAME='Peak Period'  PER ='AM' 
 IF(TOD=2) TPER='OP' ASSIGNNAME='OffPeak Period'  PER ='MD' 

 DISTRIBUTEMULTISTEP PROCESSID='transit' PROCESSNUM=%TOD%
; End of PILOT Script

; Script for program MATRIX in file "C:\ABM\CUBE\PAMAT00A.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Expand trip table to full zones'
FILEI MATI[4] = "%SCENARIO_DIR%\XIT_SPC_TRIP_%ITER%_%TPER%.trp"
FILEO PRINTO[1] = "%SCENARIO_DIR%\XIT_TRIP_PRN_%ITER%_%TPER%.trp"
FILEI MATI[3] = "%SCENARIO_DIR%\XIT_DR_SKIM_%ITER%_%TPER%.SKM"
FILEI MATI[2] = "%SCENARIO_DIR%\XIT_WK_SKIM_%ITER%_%TPER%.SKM"
FILEO MATO[1] = "%SCENARIO_DIR%\XIT_TRIP_%ITER%_%TPER%_CLEAN.trp",
 MO=1-2, NAME=WalkToTransit, DriveToTransit
FILEI MATI[1] = "%SCENARIO_DIR%\XIT_TRIP_%ITER%_%TPER%.trp"

  zones = %zones%
  mw[1] = MI.1.1 + MI.4.1; Walk to Transit
  mw[2] = MI.1.2 + MI.4.2; Drive to Transit
  
  MW[3] = MI.2.1
  MW[4] = MI.3.1

  ; Remove trips where no path is found, add 0.1 trips to at least one path 
  ; to avoid Cube crash when assigning empty trip tables
  ARRAY _pathFound = 6
  IF (I==1)
    _WBUS = 0
    _DBUS = 0   
    _DROPPED_WBUS = 0
    _DROPPED_DBUS = 0 
  ENDIF
  
  IF (I <= %int_zones%)
   JLOOP
      _WBUS = _WBUS + MW[1][J]
      _DBUS = _DBUS + MW[2][J]
      
      IF (MW[1][J]>0 && MW[3][J]=0) 
        _DROPPED_WBUS = _DROPPED_WBUS + MW[1][J]
        MW[1][J]=0
      ENDIF
      IF (MW[2][J]>0 && MW[4][J]=0)
        _DROPPED_DBUS = _DROPPED_DBUS + MW[2][J]
        MW[2][J]=0
      ENDIF        
       
      ; Add a 0.1 trip to the first path found just in case trips are empty
      IF (_pathFound[1]=0 && MW[3][J]>0)
        MW[1][J]=MW[1][J] + 0.1
        _pathFound[1] = 1
      ENDIF
      IF (_pathFound[2]=0 && MW[4][J]>0)
        MW[2][J]=MW[2][J] + 0.1
        _pathFound[2] = 1
      ENDIF
   ENDJLOOP
  ENDIF
  
   IF (I = %zones%)
    PRINT CSV=T, LIST = 'Trips', 'WBUS', 'DBUS', PRINTO=1
    PRINT CSV=T, LIST = 'Initial Trips', _WBUS, _DBUS, PRINTO=1    
    PRINT CSV=T, LIST = 'Dropped Trips', _DROPPED_WBUS, _DROPPED_DBUS, PRINTO=1
   ENDIF
   
   LOOP _p = 1,2
      IF(_pathFound[_p] = 0)
          LOG PREFIX=TransitAssignment, VAR=_p
      ENDIF
   ENDLOOP  
  
  
ENDRUN


; Script for program PUBLIC TRANSPORT in file "C:\ABM\CUBE\PAPTR00B.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=PUBLIC TRANSPORT PRNFILE="%SCENARIO_DIR%\XIT_WK_LD_PRN_%ITER%_%TPER%.prn" MSG='%TPER% Walk Transit Assignment'
FILEO ROUTEO[1] = "%SCENARIO_DIR%\XIT_WK_LD_RTE_%ITER%_%TPER%.RTE"
FILEO LINKO[1] = "%SCENARIO_DIR%\XIT_WK_LD_%ITER%_%TPER%.DBF",
ONOFFS=Y, NTLEGS=Y, SKIP0=Y
FILEI MATI[1] = "%SCENARIO_DIR%\XIT_TRIP_%ITER%_%TPER%_CLEAN.trp"
FILEI FAREI = "%XIT_FARE%"
FILEO REPORTO = "%SCENARIO_DIR%\XIT_WK_LD_RPT_%ITER%_%TPER%.RPT"
FILEI FACTORI[1] = "%CATALOG_DIR%\INPUT\TRANSIT\%TPER%_WK_%xit_fac_year%.FAC"
FILEI NTLEGI[3] = "%SCENARIO_DIR%\XIT_XFER_NTL_%ITER%_%TPER%.NTL"
FILEI NTLEGI[2] = "%SCENARIO_DIR%\XIT_DRACC_NTL_%ITER%_%TPER%.NTL"
FILEI NTLEGI[1] = "%SCENARIO_DIR%\XIT_WKACC_NTL_%ITER%_%TPER%.NTL"
FILEI LINEI[1] = "%XIT_LINES%"
FILEI SYSTEMI = "%XIT_SYSTEM%"
FILEI NETI = "%SCENARIO_DIR%\XIT_NET_%ITER%_%TPER%.net"
FILEI FAREMATI[1] = "%XIT_FAREMAT%"

    PARAMETERS  HDWAYPERIOD=%TOD%
       
    PROCESS PHASE = DATAPREP
       TRANTIME[5]=li.loctime       ; local
       TRANTIME[6]=li.loctime       ; local
       TRANTIME[7]=li.exptime       ; express
       TRANTIME[8]=li.lrttime       ; lrt
       TRANTIME[9]=li.exptime       ; commuter bus
       GENERATE,
           READNTLEGI=1             ; walk  access link (mode=1)
       ;GENERATE,
        ;   READNTLEGI=2             ; drive access link (mode=2)
       GENERATE,
           READNTLEGI=3             ; transfer link (mode=4)
    ENDPROCESS
    
 PARAMETERS TRIPSIJ[1] = MI.1.1         ; ASSIGN WALK TO Transit TRIPS

 REPORT LINES=T, SORT=MODE, LINEVOLS=T, STOPSONLY=T, SKIP0=T, XFERSUM=MODE


ENDRUN


; Script for program PUBLIC TRANSPORT in file "C:\ABM\CUBE\PAPTR00D.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=PUBLIC TRANSPORT PRNFILE="%SCENARIO_DIR%\XIT_DR_LD_PRN_%ITER%_%TPER%.prn" MSG='%TPER% Drive Transit Assignment'
FILEO ROUTEO[1] = "%SCENARIO_DIR%\XIT_DR_LD_RTE_%ITER%_%TPER%.RTE"
FILEO LINKO[1] = "%SCENARIO_DIR%\XIT_DR_LD_%ITER%_%TPER%.DBF",
ONOFFS=Y, NTLEGS=Y, SKIP0=Y
FILEI MATI[1] = "%SCENARIO_DIR%\XIT_TRIP_%ITER%_%TPER%_CLEAN.trp"
FILEI FAREI = "%XIT_FARE%"
FILEO REPORTO = "%SCENARIO_DIR%\XIT_DR_LD_RPT_%ITER%_%TPER%.RPT"
FILEI FACTORI[1] = "%CATALOG_DIR%\INPUT\TRANSIT\%TPER%_DR_%xit_fac_year%.FAC"
FILEI NTLEGI[3] = "%SCENARIO_DIR%\XIT_XFER_NTL_%ITER%_%TPER%.NTL"
FILEI NTLEGI[2] = "%SCENARIO_DIR%\XIT_DRACC_NTL_%ITER%_%TPER%.NTL"
FILEI NTLEGI[1] = "%SCENARIO_DIR%\XIT_WKACC_NTL_%ITER%_%TPER%.NTL"
FILEI LINEI[1] = "%XIT_LINES%"
FILEI SYSTEMI = "%XIT_SYSTEM%"
FILEI NETI = "%SCENARIO_DIR%\XIT_NET_%ITER%_%TPER%.net"
FILEI FAREMATI[1] = "%XIT_FAREMAT%"

    PARAMETERS  HDWAYPERIOD=%TOD%
   
    PROCESS PHASE = DATAPREP
        TRANTIME[5]=li.loctime       ; local
        TRANTIME[6]=li.loctime       ; local
        TRANTIME[7]=li.exptime       ; express
        TRANTIME[8]=li.lrttime       ; lrt
        TRANTIME[9]=li.exptime       ; commuter bus
        GENERATE,
            READNTLEGI=1             ; walk  access link (mode=1)
        GENERATE,
            READNTLEGI=2             ; drive access link (mode=2)
        GENERATE,
            READNTLEGI=3             ; transfer link (mode=4)
    ENDPROCESS
    
 PARAMETERS TRIPSIJ[1] = MI.1.2         ; ASSIGN Drive TO Transit TRIPS

 REPORT LINES=T, SORT=MODE, LINEVOLS=T, STOPSONLY=T, SKIP0=T, XFERSUM=MODE

ENDRUN


; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.


LOOP T=1,2,1

  IF (T==1) ACC='WK'
  IF (T==2) ACC='DR'
; End of PILOT Script

; Script for program MATRIX in file "C:\ABM\CUBE\PAMAT00B.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Combine Transit Boarding Data'
FILEI DBI[1] = "%SCENARIO_DIR%\XIT_%ACC%_LD_%ITER%_%TPER%.dbf"
FILEO PRINTO[1] = "%SCENARIO_DIR%\XIT_%ACC%_LD_%ITER%_%TPER%_SUMM.csv"
zones = 1

ons = 0 name = 0 mode = 0 op = 0

 PRINT CSV=T, LIST='Route, Mode, Operator, Boardings', PRINTO=1

; Read first record to get name reference
x=DBIReadREcord(1,k)
name = val(DI.1.NAME)
strname = DI.1.NAME
mode = DI.1.MODE
op   = DI.1.OPERATOR

; Walk-Transit
  LOOP k=1,DBI.1.NUMRECORDS
    x=DBIReadREcord(1,k)
    
    IF (strname == DI.1.NAME)
      ons = ons + DI.1.ONA
    ELSE
      PRINT CSV=T, LIST=strname, mode, op, ons PRINTO=1
      name = val(DI.1.NAME)
      strname = DI.1.NAME
      mode = DI.1.MODE
      op   = DI.1.OPERATOR
      ons  = DI.1.ONA
    ENDIF

  ENDLOOP

ENDRUN


; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.

ENDLOOP ; Transit access summaries

ENDDISTRIBUTEMULTISTEP
ENDLOOP

Wait4Files FILES='transit1.script.end, transit2.script.end' CheckReturnCode=T, DelDistribFiles=T

*cluster transit 1-2 CLOSE EXIT
; End of PILOT Script

; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.


LOOP TOD=1,2,1

  IF(TOD==1) PER='AM'
  IF(TOD==2) PER='PM'
; End of PILOT Script

; Script for program NETWORK in file "C:\ABM\CUBE\PPNET00A.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK MSG='Combine 11 and 4 time period networks'
FILEO NETO = "%SCENARIO_DIR%\HWY_LDNET_%ITER%_%PER%_COMP.NET",
 INCLUDE = A, B, NC_NAME(20), AREA, COUNTY, RCI, DISTANCE, 
 VOL_TRK_HR, VOL_AUTO_HR, VOL_TOT_HR, 
 VOL_TRK_PD, VOL_AUTO_PD, VOL_TOT_PD, 
 VHT_HR, VHT_PD,
 CSPD_HR, CSPD_PD, 
 VOL_DIFF, VMT_DIFF, VMT_DIFFSQ
 
FILEI LINKI[5] = "%SCENARIO_DIR%\HWY_LDNET_%ITER%_%PER%.NET"
FILEI LINKI[4] = "%SCENARIO_DIR%\HWY_LDNET_%ITER%_%PER%4.NET"
FILEI LINKI[3] = "%SCENARIO_DIR%\HWY_LDNET_%ITER%_%PER%3.NET"
FILEI LINKI[2] = "%SCENARIO_DIR%\HWY_LDNET_%ITER%_%PER%2.NET"
FILEI LINKI[1] = "%SCENARIO_DIR%\HWY_LDNET_%ITER%_%PER%1.NET"


 VOL_TOT_HR   = LI.1.V_1 + LI.2.V_1 + LI.3.V_1 + LI.4.V_1
 VOL_TRK_HR   = LI.1.V13_1 + LI.2.V13_1 + LI.3.V13_1 + LI.4.V13_1 
 VOL_AUTO_HR  = VOL_TOT_HR - VOL_TRK_HR
 VMT_TOT_HR   = VOL_TOT_HR * DISTANCE
 
 VOL_TOT_PD   = LI.5.V_1
 VOL_TRK_PD   = LI.5.V13_1
 VOL_AUTO_PD  = VOL_TOT_PD - VOL_TRK_PD
 VMT_TOT_PD   = VOL_TOT_PD * DISTANCE
 
 VOL_DIFF = VOL_TOT_HR - VOL_TOT_PD
 VMT_DIFF = VMT_TOT_HR - VMT_TOT_PD
 VMT_DIFFSQ = VMT_DIFF ^ 2
 
 CSPD_PD = LI.5.CSPD_1
  
 IF (VOL_TOT_HR > 0) 
  CSPD_HR = (LI.1.V_1 * LI.1.CSPD_1 + LI.2.V_1 * LI.2.CSPD_1 + LI.3.V_1 * LI.3.CSPD_1 + LI.4.V_1 * LI.4.CSPD_1)/VOL_TOT_HR
 ELSE 
  CSPD_HR = LI.1.CSPD_1
 ENDIF 
 
 VHT_HR = VOL_TOT_HR * (DISTANCE / CSPD_HR)
 VHT_PD = VOL_TOT_PD * (DISTANCE / CSPD_PD) 
 
 VHT_DIFF = VHT_HR - VHT_PD
 VHT_DIFFSQ = VHT_DIFF ^ 2 
 
 CSPD_DIFF = CSPD_HR - CSPD_PD
 CSPD_PER_DIFF = ABS(CSPD_DIFF / CSPD_HR)
 
ENDRUN


; Script for program NETWORK in file "C:\ABM\CUBE\PPNET00B.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK
FILEO LINKO = "%SCENARIO_DIR%\HWY_LDNET_%ITER%_%PER%_COMP.DBF"
FILEI LINKI[1] = "%SCENARIO_DIR%\HWY_LDNET_%ITER%_%PER%_COMP.NET"


ENDRUN


; Script for program MATRIX in file "C:\ABM\CUBE\PPMAT00A.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Export to CSV'
FILEO PRINTO[1] = "%SCENARIO_DIR%\HWY_LDNET_%ITER%_%PER%_COMP.CSV"
FILEI DBI[1] = "%SCENARIO_DIR%\HWY_LDNET_%ITER%_%PER%_COMP.DBF"

zones = 1
 LOOP k=1,DBI.1.NUMRECORDS
  x=DBIReadRecord(1,k)


PRINT CSV=T, LIST=DI.1.A(6), DI.1.B(6), DI.1.NC_NAME(20), DI.1.RCI(2), DI.1.AREA(2), DI.1.COUNTY(2),  
                  DI.1.DISTANCE(9.6), DI.1.VOL_TOT_HR(9.4), DI.1.VOL_TOT_PD(9.4), 
                  DI.1.VHT_HR(10.4), DI.1.VHT_PD(10.4), 
                  DI.1.CSPD_HR(10.4), DI.1.CSPD_PD(10.4), DI.1.CSPD_PER_DI(10.4), DI.1.VHT_DIFFSQ(10.4) PRINTO=1
                  ;,(DI.1.VOL_DIFF - _volErrAve)^2(10.4) 
                  
 ENDLOOP

ENDRUN


; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.


ENDLOOP


; End of PILOT Script

  goto FinalAssign_END

:FinalAssign_1
  goto FinalAssign_END

:FinalAssign_END
; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.


  ; TODO: add temp file delete
  
IF (CONV==1)
  break
ENDIF
; End of PILOT Script

ENDLOOP

