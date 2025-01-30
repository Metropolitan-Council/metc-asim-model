; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
ITER = 4
;NEXTITER = ITER + 1
*cluster transit 1-2 START EXIT

LOOP TOD=1,2,1
 IF(TOD=1) TPER='PK' ASSIGNNAME='Peak Period'  PER ='AM' 
 IF(TOD=2) TPER='OP' ASSIGNNAME='OffPeak Period'  PER ='MD' 

 DISTRIBUTEMULTISTEP PROCESSID='transit' PROCESSNUM=%TOD%
; End of PILOT Script

; Script for program NETWORK in file "D:\8296\TestAssignment\CUBE\TSNET00F.S"
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


; Script for program PUBLIC TRANSPORT in file "D:\8296\TestAssignment\CUBE\TSPTR00N.S"
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


; Script for program PUBLIC TRANSPORT in file "D:\8296\TestAssignment\CUBE\TSPTR00S.S"
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


; Script for program PUBLIC TRANSPORT in file "D:\8296\TestAssignment\CUBE\TSPTR00U.S"
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

; Script for program PUBLIC TRANSPORT in file "D:\8296\TestAssignment\CUBE\TSPTR00J.S"
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


; Script for program PUBLIC TRANSPORT in file "D:\8296\TestAssignment\CUBE\TSPTR00L.S"
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


; Script for program MATRIX in file "D:\8296\TestAssignment\CUBE\TSMAT00E.S"
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


; Script for program MATRIX in file "D:\8296\TestAssignment\CUBE\TSMAT00G.S"
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

