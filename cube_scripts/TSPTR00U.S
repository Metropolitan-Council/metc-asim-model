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
