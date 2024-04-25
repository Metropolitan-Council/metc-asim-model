; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
PER='%PER%'
RUN PGM=PUBLIC TRANSPORT MSG='Build %TPER% Drive Access Connectors'
FILEO NTLEGO = "%SCENARIO_DIR%\transit\XIT_DRACC_NTL_0_%TPER%.NTL"
FILEO REPORTO = "%SCENARIO_DIR%\transit\XIT_DRACC_RPT_0_%TPER%.RPT"
FILEO NETO = "%SCENARIO_DIR%\transit\XIT_DRACC_NET_0_%TPER%.NET"
FILEI SYSTEMI = "%XIT_SYSTEM%"
FILEI FACTORI[1] = "%TRANSIT_FOLDER%\%TPER2%_WK_2010.FAC"
FILEI LINEI[1] = "%XIT_LINES%"
FILEI NETI = "%SCENARIO_DIR%\transit\XIT_NET_0_%TPER%.net"

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
