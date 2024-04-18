; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.

*cluster transit 1-5 START EXIT
LOOP TOD=1,5,1

 IF(TOD=1) TPER='EA' ASSIGNNAME='EA Period'  PER ='NT' TPER2 = 'OP'
 IF(TOD=2) TPER='AM' ASSIGNNAME='AM Period'  PER ='AM' TPER2 = 'PK'
 IF(TOD=3) TPER='MD' ASSIGNNAME='MD Period'  PER ='MD' TPER2 = 'OP'
 IF(TOD=4) TPER='PM' ASSIGNNAME='PM Period'  PER ='PM' TPER2 = 'PK'
 IF(TOD=5) TPER='NT' ASSIGNNAME='NT Period'  PER ='NT' TPER2 = 'OP'
 
  DISTRIBUTEMULTISTEP PROCESSID='transit' PROCESSNUM=@TOD@

RUN PGM=PUBLIC TRANSPORT MSG='Build @TPER@ Drive Access Connectors'
FILEO NTLEGO = "%SCENARIO_DIR%\transit\XIT_DRACC_NTL_%ITER%_@TPER@.TMP"
FILEO REPORTO = "%SCENARIO_DIR%\transit\XIT_DRACC_RPT_%ITER%_@TPER@.RPT"
FILEO NETO = "%SCENARIO_DIR%\transit\XIT_DRACC_NET_%ITER%_@TPER@.NET"
FILEI SYSTEMI = "%XIT_SYSTEM%"
FILEI FACTORI[1] = "%TRANSIT_FOLDER%\@TPER2@_WK_%xit_fac_year%.FAC"
FILEI LINEI[1] = "%XIT_LINES%"
FILEI NETI = "%SCENARIO_DIR%\transit\XIT_NET_%ITER%_@TPER@.NET"


    REPORT Lines=T
    REREPORT Accesslegs=T, Egresslegs=T, Xferlegs=T, Lines=T, STOPNODES=T
    HDWAYPERIOD=@TOD@

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

ENDDISTRIBUTEMULTISTEP



ENDLOOP
Wait4Files FILES='transit1.script.end, transit2.script.end, transit3.script.end, transit4.script.end, transit5.script.end' CheckReturnCode=T, DelDistribFiles=T

*cluster transit 1-5 CLOSE EXIT