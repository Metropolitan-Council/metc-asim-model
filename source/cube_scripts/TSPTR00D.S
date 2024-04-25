; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=PUBLIC TRANSPORT MSG='Build %TPER% Walk Access Connectors'
FILEO NTLEGO = "%SCENARIO_DIR%\transit\XIT_WKACC_NTL_%TPER%.tmp"
FILEO REPORTO = "%SCENARIO_DIR%\transit\XIT_WKACC_RPT_%TPER%.rpt"
FILEO NETO = "%SCENARIO_DIR%\transit\XIT_WKACC_NET_%TPER%.NET"
FILEI SYSTEMI = "%xit_system%"
FILEI FACTORI[1] = "%TRANSIT_FOLDER%\%TPER2%_WK_2010.FAC"
FILEI LINEI[1] = "%xit_lines%"
FILEI NETI = "%SCENARIO_DIR%\transit\XIT_NET_0_%TPER%.net"

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
