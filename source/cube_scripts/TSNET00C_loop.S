; Andrew got mad and impatient. 
;
; The steps (in order) are:
;
; Network processing: TSNET00C.s
; Build walk access connectors: TSPTR00D.s
; Build transfer connectors: TSPTR00F.s
; Build Drive Access Connectors: TSPTR00H.s
; Copy connector files: TSPIL00C.s
; Build and Skim Walk Transit Network: TSPTR00A.s
; Build and Skim Drive Access Network: TSPTR00C.s
; Build and Skim Drive Egress Network: TSPTR00Z.s

*cluster transit 1-5 START EXIT

LOOP TOD=1,5,1

 IF(TOD=1) TPER='EA' ASSIGNNAME='EA Period' PER ='EA' TPER2 = 'OP' TPER3 = 'NT'
 IF(TOD=2) TPER='AM' ASSIGNNAME='AM Period' PER ='AM' TPER2 = 'PK' TPER3 = 'AM' 
 IF(TOD=3) TPER='MD' ASSIGNNAME='MD Period' PER ='MD' TPER2 = 'OP' TPER3 = 'MD'
 IF(TOD=4) TPER='PM' ASSIGNNAME='PM Period' PER ='PM' TPER2 = 'PK' TPER3 = 'PM'
 IF(TOD=5) TPER='NT' ASSIGNNAME='NT Period' PER ='NT' TPER2 = 'OP' TPER3 = 'NT'

 DISTRIBUTEMULTISTEP PROCESSID='transit' PROCESSNUM=@TOD@
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
;
; Former TSNET00C.S
RUN PGM=NETWORK MSG='Calculate Transit Speeds for @TPER@'
FILEO NETO = "%SCENARIO_DIR%\transit\XIT_NET_0_@TPER@.net"
FILEI LOOKUPI[2] = "%TRANSIT_FOLDER%\@TPER2@ExpressDelays.txt"
FILEI LOOKUPI[1] = "%TRANSIT_FOLDER%\@TPER2@LocalDelays.txt"
FILEI LINKI[1] = "%SCENARIO_DIR%\transit\TransitBase.NET"

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
    LOCTIME = (DISTANCE * 60) / SPEED
    EXPTIME = (DISTANCE * 60) / SPEED
	LRTTIME = (DISTANCE * 60) / SPEED
    
;;--------------------------------------------------------------------------    

    ; Override manually coded speed for transit only links
    IF (LI.1.TTA_@TPER3@>0)
        LOCTIME = TTA_@TPER3@
        EXPTIME = TTA_@TPER3@
        LRTTIME = TTA_@TPER3@
    ENDIF    

;;--------------------------------------------------------------------------

    ;Calculate Local Bus Transit Travel Time
    IF (LOCTIME=0)
         _DELAY = locdelay(LI.1.AREA_TYPE,LI.1.RCI)
         IF (TPri_@TPER3@=2)
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
        _DELAY = expdelay(LI.1.AREA_TYPE,LI.1.RCI)
         IF (TPri_@TPER3@=2)
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

; Former TSPTR00D.S
RUN PGM=PUBLIC TRANSPORT MSG='Build %TPER% Walk Access Connectors'
FILEO NTLEGO = "%SCENARIO_DIR%\transit\XIT_WKACC_NTL_@TPER@.tmp"
FILEO REPORTO = "%SCENARIO_DIR%\transit\XIT_WKACC_RPT_@TPER@.rpt"
FILEO NETO = "%SCENARIO_DIR%\transit\XIT_WKACC_NET_@TPER@.NET"
FILEI SYSTEMI = "%xit_system%"
FILEI FACTORI[1] = "%TRANSIT_FOLDER%\@TPER2@_WK_2010.FAC"
FILEI LINEI[1] = "%xit_lines%"
FILEI NETI = "%SCENARIO_DIR%\transit\XIT_NET_0_@TPER@.net"

    REPORT Lines=T
    REREPORT Accesslegs=T, Egresslegs=T, Xferlegs=T, Lines=T, STOPNODES=T
    HDWAYPERIOD=@TOD@

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
        tonode=3100-999999,
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

; Former TSPTR00F.s
RUN PGM=PUBLIC TRANSPORT MSG='Build @TPER@ Transfer Access Connectors'
FILEO NTLEGO = "%SCENARIO_DIR%\transit\XIT_XFER_NTL_@TPER@.TMP"
FILEO REPORTO = "%SCENARIO_DIR%\transit\XIT_XFER_RPT_@TPER@.RPT"
FILEO NETO = "%SCENARIO_DIR%\transit\XIT_XFER_NET_@TPER@.NET"
FILEI SYSTEMI = "%XIT_SYSTEM%"
FILEI FACTORI[1] = "%TRANSIT_FOLDER%\@TPER2@_WK_2010.FAC"
FILEI LINEI[1] = "%XIT_LINES%"
FILEI NETI = "%SCENARIO_DIR%\transit\XIT_NET_0_@TPER@.net"
 
    SKIPBADLINES = Y
    REPORT Lines=T
    REREPORT Accesslegs=T, Egresslegs=T, Xferlegs=T, Lines=T, STOPNODES=T
    HDWAYPERIOD=@TOD@

 
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

; Former TSPTR00H.s
RUN PGM=PUBLIC TRANSPORT MSG='Build %TPER% Drive Access Connectors'
FILEO NTLEGO = "%SCENARIO_DIR%\transit\XIT_DRACC_NTL_0_@TPER@.NTL"
FILEO REPORTO = "%SCENARIO_DIR%\transit\XIT_DRACC_RPT_0_@TPER@.RPT"
FILEO NETO = "%SCENARIO_DIR%\transit\XIT_DRACC_NET_0_@TPER@.NET"
FILEI SYSTEMI = "%XIT_SYSTEM%"
FILEI FACTORI[1] = "%TRANSIT_FOLDER%\@TPER2@_WK_2010.FAC"
FILEI LINEI[1] = "%XIT_LINES%"
FILEI NETI = "%SCENARIO_DIR%\transit\XIT_NET_0_@TPER@.net"

    REPORT Lines=T
    REREPORT Accesslegs=T, Egresslegs=T, Xferlegs=T, Lines=T, STOPNODES=T
    HDWAYPERIOD=@TOD@

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

; Former TSPIL00C.S
*copy "%SCENARIO_DIR%\transit\XIT_WKACC_NTL_%TPER%.tmp"+"%TRANSIT_FOLDER%\WalkOverrides.txt" "%SCENARIO_DIR%\transit\XIT_WKACC_NTL_%TPER%.ntl"
*copy "%SCENARIO_DIR%\transit\XIT_XFER_NTL_%TPER%.tmp"+"%TRANSIT_FOLDER%\TransferOverrides.txt" "%SCENARIO_DIR%\transit\XIT_XFER_NTL_%TPER%.ntl"
*copy "%SCENARIO_DIR%\transit\XIT_DRACC_NTL_0_%TPER%.tmp"+"%TRANSIT_FOLDER%\DriveOverrides.txt" "%SCENARIO_DIR%\transit\XIT_DRACC_NTL_0_%TPER%.ntl"

; Former TSPTR00A.S
RUN PGM=PUBLIC TRANSPORT PRNFILE="%SCENARIO_DIR%\transit\XIT_WK_PRN_0_@TPER@.prn" MSG='@TPER@ Walk Transit Skim'
FILEI FAREI = "%xit_fare%"
FILEO REPORTO = "%SCENARIO_DIR%\transit\XIT_WK_RPT_0_@TPER@.RPT"
FILEO ROUTEO[1] = "%SCENARIO_DIR%\transit\XIT_WK_RTE_0_@TPER@.RTE" REPORTI=2297
FILEO MATO[1] = "%SCENARIO_DIR%\transit\XIT_WK_SKIM_0_@TPER@.skm",
 MO=1-13 NAME=IVT_Bus,IVT_LB,IVT_Exp,IVT_LRT,IVT_CRT,WAIT1,WAIT2,XFERS,AWALKT,XWALKT,FARE,XBFARE,CRTFare
FILEO NETO = "%SCENARIO_DIR%\transit\XIT_WK_NET_0_@TPER@.NET"
FILEI FACTORI[1] = "%TRANSIT_FOLDER%\@TPER2@_WK_2010.FAC"
FILEI NTLEGI[3] = "%SCENARIO_DIR%\transit\XIT_XFER_NTL_@TPER@.ntl"
FILEI NTLEGI[2] = "%SCENARIO_DIR%\transit\XIT_DRACC_NTL_@TPER@.ntl"
FILEI NTLEGI[1] = "%SCENARIO_DIR%\transit\XIT_WKACC_NTL_@TPER@.ntl"
FILEI LINEI[1] = "%xit_lines%"
FILEI SYSTEMI = "%xit_system%"
FILEI NETI = "%SCENARIO_DIR%\transit\XIT_NET_0_@TPER@.net"
FILEI FAREMATI[1] = "%xit_faremat%"

    PARAMETERS  HDWAYPERIOD=@TOD@
       
    PROCESS PHASE = DATAPREP
       TRANTIME[5]=li.loctime       ; local
       TRANTIME[6]=li.loctime       ; local
       TRANTIME[7]=li.exptime       ; express
       TRANTIME[8]=li.lrttime       ; lrt
       TRANTIME[9]=li.exptime       ; commuter bus
       GENERATE,
           READNTLEGI=1             ; walk  access link (mode=1)
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
        MW[9]=TIMEA(0,1)            ; OVTT for walk access & egress
		MW[10]=TIMEA(0,4)           ; OVTT for transfer
        MW[11]=FAREA(0,5,6,8)       ; local, limited and LRT Fares
        MW[12]=FAREA(0,7)           ; Express Fare        
        MW[13]=FAREA(0,9)           ; CRT Fare
    ENDPROCESS

ENDRUN

; Former TSPTR00C.S
RUN PGM=PUBLIC TRANSPORT PRNFILE="%SCENARIO_DIR%\transit\XIT_DR_PRN_0_@TPER@.prn" MSG='@TPER@ Drive Transit Access Skim'
FILEI FAREI = "%XIT_FARE%"
FILEO REPORTO = "%SCENARIO_DIR%\transit\XIT_DR_RPT_0_@TPER@.RPT"
FILEO ROUTEO[1] = "%SCENARIO_DIR%\transit\XIT_DR_RTE_0_@TPER@.RTE"
FILEO MATO[1] = "%SCENARIO_DIR%\transit\XIT_DR_SKIM_0_@TPER@.skm",
 MO=1-15 NAME=IVT_Bus,IVT_LB,IVT_Exp,IVT_LRT,IVT_CRT,WAIT1,WAIT2,XFERS,AWALKT,XWALKT,FARE,XBFARE,CRTFare,DR_ACCR,DR_ACCD
FILEO NETO = "%SCENARIO_DIR%\transit\XIT_DR_NET_0_@TPER@.NET"
FILEI FACTORI[1] = "%TRANSIT_FOLDER%\@TPER2@_DR_2010.FAC"
FILEI NTLEGI[3] = "%SCENARIO_DIR%\transit\XIT_XFER_NTL_@TPER@.NTL"
FILEI NTLEGI[2] = "%SCENARIO_DIR%\transit\XIT_DRACC_NTL_0_@TPER@.NTL"
FILEI NTLEGI[1] = "%SCENARIO_DIR%\transit\XIT_WKACC_NTL_@TPER@.NTL"
FILEI LINEI[1] = "%XIT_LINES%"
FILEI SYSTEMI = "%XIT_SYSTEM%"
FILEI NETI = "%SCENARIO_DIR%\transit\XIT_NET_0_@TPER@.net"
FILEI FAREMATI[1] = "%XIT_FAREMAT%"

    PARAMETERS  HDWAYPERIOD=@TOD@
   
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
        MW[9]=TIMEA(0,1)            ; OVTT for walk access & egress
		MW[10]=TIMEA(0,4)           ; OVTT for transfer
        MW[11]=FAREA(0,5,6,8)       ; local, limited and LRT Fares
        MW[12]=FAREA(0,7)           ; Express Fare        
        MW[13]=FAREA(0,9)           ; CRT Fare        
        MW[14]=TIMEA(0,2)           ; Drive access time
        MW[15]=DIST(0,2)            ; Drive access dist
    ENDPROCESS
ENDRUN

; Former TSPTR00Z.S
RUN PGM=PUBLIC TRANSPORT PRNFILE="%SCENARIO_DIR%\transit\XIT_DRE_PRN_0_@TPER@.prn" MSG='@TPER@ Drive Transit Egress Skim'
FILEI FAREI = "%XIT_FARE%"
FILEO REPORTO = "%SCENARIO_DIR%\transit\XIT_DRE_RPT_0_@TPER@.RPT"
FILEO ROUTEO[1] = "%SCENARIO_DIR%\transit\XIT_DRE_RTE_0_@TPER@.RTE" 
FILEO MATO[1] = "%SCENARIO_DIR%\transit\XIT_DRE_SKIM_0_@TPER@.skm",
 MO=1-15 NAME=IVT_Bus,IVT_LB,IVT_Exp,IVT_LRT,IVT_CRT,WAIT1,WAIT2,XFERS,AWALKT,XWALKT,FARE,XBFARE,CRTFare,DR_ACCR,DR_ACCD
FILEO NETO = "%SCENARIO_DIR%\transit\XIT_DRE_NET_0_@TPER@.NET"
FILEI FACTORI[1] = "%TRANSIT_FOLDER%\@TPER2@_DRE_2010.FAC"
FILEI NTLEGI[3] = "%SCENARIO_DIR%\transit\XIT_XFER_NTL_@TPER@.NTL"
FILEI NTLEGI[2] = "%SCENARIO_DIR%\transit\XIT_DRACC_NTL_0_@TPER@.NTL"
FILEI NTLEGI[1] = "%SCENARIO_DIR%\transit\XIT_WKACC_NTL_@TPER@.NTL"
FILEI LINEI[1] = "%XIT_LINES%"
FILEI SYSTEMI = "%XIT_SYSTEM%"
FILEI NETI = "%SCENARIO_DIR%\transit\XIT_NET_0_@TPER@.net"
FILEI FAREMATI[1] = "%XIT_FAREMAT%"

    PARAMETERS  HDWAYPERIOD=@TOD@
   
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
        MW[9]=TIMEA(0,1)            ; OVTT for walk access & egress
		MW[10]=TIMEA(0,4)           ; OVTT for transfer
        MW[11]=FAREA(0,5,6,8)       ; local, limited and LRT Fares
        MW[12]=FAREA(0,7)           ; Express Fare        
        MW[13]=FAREA(0,9)           ; CRT Fare        
        MW[14]=TIMEA(0,2)
        MW[15]=DIST(0,2)
    ENDPROCESS
ENDRUN


ENDDISTRIBUTEMULTISTEP
ENDLOOP

Wait4Files FILES='transit1.script.end, transit2.script.end, transit3.script.end, transit4.script.end, transit5.script.end' CheckReturnCode=T, DelDistribFiles=T

*cluster transit 1-5 CLOSE EXIT