; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
*cluster transit 1-2 START EXIT
LOOP TOD=1,2,1



 IF(TOD=1) TPER='PK' ASSIGNNAME='Peak Period'  PER ='AM' 
 IF(TOD=2) TPER='OP' ASSIGNNAME='OffPeak Period'  PER ='MD' 



  DISTRIBUTEMULTISTEP PROCESSID='transit' PROCESSNUM=@TOD@

RUN PGM=PUBLIC TRANSPORT MSG='Build @TPER@ Walk Access Connectors'
FILEO NTLEGO = "%SCENARIO_DIR%\XIT_WKACC_NTL_%ITER%_@TPER@.TMP"
FILEO REPORTO = "%SCENARIO_DIR%\XIT_WKACC_RPT_%ITER%_@TPER@.RPT"
FILEO NETO = "%SCENARIO_DIR%\XIT_WKACC_NET_%ITER%_@TPER@.NET"
FILEI SYSTEMI = "%XIT_SYSTEM%"
FILEI FACTORI[1] = "%CATALOG_DIR%\INPUT\TRANSIT\@TPER@_WK_%xit_fac_year%.FAC"
FILEI LINEI[1] = "%XIT_LINES%"
FILEI NETI = "%SCENARIO_DIR%\XIT_NET_%ITER%_@TPER@.NET"


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
ENDDISTRIBUTEMULTISTEP



ENDLOOP

Wait4Files FILES='transit1.script.end, transit2.script.end' CheckReturnCode=T, DelDistribFiles=T
*cluster transit 1-2 CLOSE EXIT
