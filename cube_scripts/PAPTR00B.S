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
    
 PARAMETERS TRIPSIJ[1] = MI.1.WalkToTransit         ; ASSIGN WALK TO Transit TRIPS

 REPORT LINES=T, SORT=MODE, LINEVOLS=T, STOPSONLY=T, SKIP0=T, XFERSUM=MODE


ENDRUN
