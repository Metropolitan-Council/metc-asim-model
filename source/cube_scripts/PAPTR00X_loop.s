; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.

*cluster transit 1-5 START EXIT
LOOP TOD=1,5,1

 IF(TOD=1) TPER='EA' ASSIGNNAME='EA Period'  PER ='EA' TPER2='NT' TPER3='OP'
 IF(TOD=2) TPER='AM' ASSIGNNAME='AM Period'  PER ='AM' TPER2='AM' TPER3='PK'
 IF(TOD=3) TPER='MD' ASSIGNNAME='MD Period'  PER ='MD' TPER2='MD' TPER3='OP'
 IF(TOD=4) TPER='PM' ASSIGNNAME='PM Period'  PER ='PM' TPER2='PM' TPER3='PK'
 IF(TOD=5) TPER='NT' ASSIGNNAME='NT Period'  PER ='NT' TPER2='NT' TPER3='OP'

 DISTRIBUTEMULTISTEP PROCESSID='transit' PROCESSNUM=@TOD@

RUN PGM=PUBLIC TRANSPORT PRNFILE="%SCENARIO_DIR%\transit\XIT_DRE_LD_PRN_%ITER%_@TPER@.prn" MSG='@TPER@ Drive Transit Assignment'
FILEO ROUTEO[1] = "%SCENARIO_DIR%\transit\XIT_DRE_LD_RTE_%ITER%_@TPER@.RTE"
FILEO LINKO[1] = "%SCENARIO_DIR%\transit\XIT_DRE_LD_%ITER%_@TPER@.DBF",
ONOFFS=Y, NTLEGS=Y, SKIP0=Y
FILEI MATI[1] = "%SCENARIO_DIR%\transit\XIT_TRIP_%ITER%_@TPER@.trp"
FILEI FAREI = "%XIT_FARE%"
FILEO REPORTO = "%SCENARIO_DIR%\transit\XIT_DRE_LD_RPT_%ITER%_@TPER@.RPT"
FILEI FACTORI[1] = "%TRANSIT_FOLDER%\@TPER3@_DRE_%xit_fac_year%.FAC"
FILEI NTLEGI[3] = "%SCENARIO_DIR%\transit\XIT_XFER_NTL_@TPER@.NTL"
FILEI NTLEGI[2] = "%SCENARIO_DIR%\transit\XIT_DRACC_NTL_%ITER%_@TPER@.NTL"
FILEI NTLEGI[1] = "%SCENARIO_DIR%\transit\XIT_WKACC_NTL_@TPER@.NTL"
FILEI LINEI[1] = "%XIT_LINES%"
FILEI SYSTEMI = "%XIT_SYSTEM%"
FILEI NETI = "%SCENARIO_DIR%\transit\XIT_NET_%ITER%_@TPER2@.net"
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
    
 PARAMETERS TRIPSIJ[1] = MI.1.2, NOROUTEERRS=9999999         ; ASSIGN Drive TO Transit TRIPS

 REPORT LINES=T, SORT=MODE, LINEVOLS=T, STOPSONLY=T, SKIP0=T, XFERSUM=MODE

ENDRUN


ENDDISTRIBUTEMULTISTEP
ENDLOOP

Wait4Files FILES='transit1.script.end, transit2.script.end, transit3.script.end, transit4.script.end, transit5.script.end' CheckReturnCode=T, DelDistribFiles=T

*cluster transit 1-5 CLOSE EXIT