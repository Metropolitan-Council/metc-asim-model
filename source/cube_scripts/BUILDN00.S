HighwaySkimBranch=-1
TransitSkim=-1
; Script for program NETWORK in file "C:\Users\ehrlicjn\Desktop\MetCouncilABMPreRelease0.1\CUBE\BNNET00B.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK MSG='Export Raw Network From Scenario Highway Network'
FILEO NETO = "%SCENARIO_DIR%\ALL_NET.tmp"
FILEI LINKI[1] = "%iHwyNet%"


ENDRUN


; Script for program NETWORK in file "C:\Users\ehrlicjn\Desktop\MetCouncilABMPreRelease0.1\CUBE\NMNET00A.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK MSG='Export Bike Network from MultiModal Network'
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


; Script for program HIGHWAY in file "C:\Users\ehrlicjn\Desktop\MetCouncilABMPreRelease0.1\CUBE\NMHWY00A.S"
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


; Script for program HIGHWAY in file "C:\Users\ehrlicjn\Desktop\MetCouncilABMPreRelease0.1\CUBE\NMHWY00B.S"
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


; Script for program MATRIX in file "C:\Users\ehrlicjn\Desktop\MetCouncilABMPreRelease0.1\CUBE\NMMAT00A.S"
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


; Script for program NETWORK in file "C:\Users\ehrlicjn\Desktop\MetCouncilABMPreRelease0.1\CUBE\HNNET00B.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK MSG='Set highway link speeds, capacities, and AB'
FILEI LOOKUPI[3] = "%LU_AlphaBeta%"
FILEI LOOKUPI[2] = "%LU_capacity%"
FILEI LOOKUPI[1] = "%LU_speed%"
FILEI LINKI[1] = "%SCENARIO_DIR%\ALL_NET.tmp"
FILEO NETO = "%SCENARIO_DIR%\ALL_NET.net"
 
;Length corrections
  ;DISTANCE = SHAPE_Length/1609.344 ; Adds distance to any new link that was not coded with a distance

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

; Script for program NETWORK in file "C:\Users\ehrlicjn\Desktop\MetCouncilABMPreRelease0.1\CUBE\HNNET00C.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK MSG='Set Managed Lanes for: %NETNAME%'
FILEI LINKI[1] = "%SCENARIO_DIR%\ALL_NET.net"
FILEO NETO = "%SCENARIO_DIR%\HWY_NET_%TOD%.net"


  IF (RCI=100) DELETE ; Remove Rail
  IF (Bike=1) DELETE ;Remove Bike paths
  
  IF (RCI=98 || RCI=101 | RCI=150) DELETE

  ;ENDIF


  IF (HOV > 0)
  ;HOV Lane Configurations
  ;MnPass On is the default condition
   _ON=1
  ;For Mainline Lane ADD and MINUS the default condition is Zero
   _ADD=0

  IF (%TOD%=1) ; Overnight 7:00 PM to 5:00 AM
    IF (HOV=1,2,4,5,7,8,9,10,11,12) ;MnPass Off
      _ON=0
    ENDIF
  ENDIF
  IF (%TOD%=2)  ; Reverse Lane Change over 5:00 AM to 6:00 AM  and 1:00 PM to 2:00 PM
    IF (HOV=1,2,3,4,5,6,7,8,9,10,11,12) ;MnPass Off
      _ON=0
    ENDIF
  ENDIF  
  IF (%TOD%=3)  ; AM Peak Period 6:00 AM to 10:00 AM
    IF (HOV=2,3,4) ;MnPass Off
      _ON=0
    ENDIF
    IF (HOV=101,105,107,108) ;Mainline Lane Decrease
      _ADD=-1
    ENDIF
    IF (HOV>999) ;Mainline Lane Increase
      _ADD=1
    ENDIF
  ENDIF  
  IF (%TOD%=4)  ; Mid Day Period 10:00 AM to 1:00 PM
    IF (HOV=1,2,3,4,5,7,8,9,11,12) ;MnPass Off
      _ON=0
    ENDIF
  ENDIF
  IF (%TOD%=5)  ; Pre PM Peak Period 2:00 PM to 3:00 PM
    IF (HOV=1,2,4,5,7,8,9,10,11,12) ;MnPass Off
      _ON=0
    ENDIF
  ENDIF
  IF (%TOD%=6)  ; PM Peak Period 3:00 PM to 7:00 PM
    IF (HOV=1,5,10) ;MnPass Off
      _ON=0
    ENDIF
    IF (HOV=102,104,107,108) ;Mainline Lane Decrease
      _ADD=-1
    ENDIF
    IF (HOV>999) ;Mainline Lane Increase
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
; Script for program HIGHWAY in file "C:\Users\ehrlicjn\Desktop\MetCouncilABMPreRelease0.1\CUBE\FFHWY00A.S"
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

; Script for program NETWORK in file "C:\Users\ehrlicjn\Desktop\MetCouncilABMPreRelease0.1\CUBE\TCNET00B.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK MSG='TEMP: extract link and node dbfs'
FILEO NODEO = "%SCENARIO_DIR%\NODE.DBF"
FILEO LINKO = "%SCENARIO_DIR%\LINK.DBF"
FILEI LINKI[1] = "%SCENARIO_DIR%\ALL_NET.NET"


ENDRUN


goto TransitSkim_END

:TransitSkim_2
; Script for program NETWORK in file "C:\Users\ehrlicjn\Desktop\MetCouncilABMPreRelease0.1\CUBE\TSNET00A.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK MSG='TEMP: extract link and node dbfs'
FILEO NODEO = "%SCENARIO_DIR%\node.dbf"
FILEO LINKO = "%SCENARIO_DIR%\link.dbf"
FILEI LINKI[1] = "%SCENARIO_DIR%\ALL_NET.net"


ENDRUN


; Script for program NETWORK in file "C:\Users\ehrlicjn\Desktop\MetCouncilABMPreRelease0.1\CUBE\TSNET00B.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK MSG='TEMP: set rail zone node field'
FILEI LINKI[4] = "C:\Users\ehrlicjn\Desktop\MetCouncilABMPreRelease0.1\Input\network\T_Priority.dbf"
FILEI LINKI[3] = "C:\Users\ehrlicjn\Desktop\MetCouncilABMPreRelease0.1\Input\network\T_MANTIME.dbf"
FILEI LINKI[2] = "C:\Users\ehrlicjn\Desktop\MetCouncilABMPreRelease0.1\Input\network\Distances.dbf"
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

; Script for program NETWORK in file "C:\Users\ehrlicjn\Desktop\MetCouncilABMPreRelease0.1\CUBE\TSNET00C.S"
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


; Script for program PUBLIC TRANSPORT in file "C:\Users\ehrlicjn\Desktop\MetCouncilABMPreRelease0.1\CUBE\TSPTR00D.S"
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


; Script for program PUBLIC TRANSPORT in file "C:\Users\ehrlicjn\Desktop\MetCouncilABMPreRelease0.1\CUBE\TSPTR00F.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=PUBLIC TRANSPORT MSG='Build %TPER% Transfer Access Connectors'
FILEO NTLEGO = "%SCENARIO_DIR%\XIT_XFER_NTL_0_%TPER%.TMP"
FILEO REPORTO = "%SCENARIO_DIR%\XIT_XFER_RPT_0_%TPER%.RPT"
FILEO NETO = "%SCENARIO_DIR%\XIT_XFER_NET_0_%TPER%.NET"
FILEI SYSTEMI = "%XIT_SYSTEM%"
FILEI FACTORI[1] = "%CATALOG_DIR%\INPUT\TRANSIT\%TPER%_WK_2010.FAC"
FILEI LINEI[1] = "%XIT_LINES%"
FILEI NETI = "%SCENARIO_DIR%\XIT_NET_0_%TPER%.net"

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


; Script for program PUBLIC TRANSPORT in file "C:\Users\ehrlicjn\Desktop\MetCouncilABMPreRelease0.1\CUBE\TSPTR00H.S"
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

; Script for program PUBLIC TRANSPORT in file "C:\Users\ehrlicjn\Desktop\MetCouncilABMPreRelease0.1\CUBE\TSPTR00A.S"
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


; Script for program PUBLIC TRANSPORT in file "C:\Users\ehrlicjn\Desktop\MetCouncilABMPreRelease0.1\CUBE\TSPTR00C.S"
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


; Script for program MATRIX in file "C:\Users\ehrlicjn\Desktop\MetCouncilABMPreRelease0.1\CUBE\TSMAT00A.S"
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


; Script for program MATRIX in file "C:\Users\ehrlicjn\Desktop\MetCouncilABMPreRelease0.1\CUBE\TSMAT00C.S"
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
