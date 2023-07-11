HighwaySkimBranch=-1
; Script for program NETWORK in file "D:\8296\TourCast\CUBE\HNNET00B.S"
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
		time=60*(distance/speed)

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

; Script for program NETWORK in file "D:\8296\TourCast\CUBE\HNNET00C.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK MSG='Set Managed Lanes for: %NETNAME%'
FILEI LINKI[1] = "%SCENARIO_DIR%\ALL_NET.net"
FILEO NETO = "%SCENARIO_DIR%\HWY_NET_%TOD%.net"


  IF (RCI=100) DELETE ; Remove Rail
  IF (Bike=1) DELETE ;Remove Bike paths


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
  ENDIF ; End of PILOT Script

goto HighwaySkimBranch_END

:HighwaySkimBranch_2
; Script for program HIGHWAY in file "D:\8296\TourCast\CUBE\FFHWY00A.S"
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
