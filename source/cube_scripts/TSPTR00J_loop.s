; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
*cluster transit 1-5 START EXIT
LOOP TOD=1,5,1

 IF(TOD=1) TPER='EA' ASSIGNNAME='EA Period'  PER ='NT' TPER2 = 'OP'
 IF(TOD=2) TPER='AM' ASSIGNNAME='AM Period'  PER ='AM' TPER2 = 'PK'
 IF(TOD=3) TPER='MD' ASSIGNNAME='MD Period'  PER ='MD' TPER2 = 'OP'
 IF(TOD=4) TPER='PM' ASSIGNNAME='PM Period'  PER ='PM' TPER2 = 'PK'
 IF(TOD=5) TPER='NT' ASSIGNNAME='NT Period'  PER ='NT' TPER2 = 'OP'
 
DISTRIBUTEMULTISTEP PROCESSID='transit' PROCESSNUM=@TOD@

RUN PGM=PUBLIC TRANSPORT PRNFILE="%SCENARIO_DIR%\transit\XIT_WK_SKIM_PRN_%ITER%_@TPER@.prn" MSG='@TPER@ Walk Transit Skims'
FILEI FAREI = "%XIT_FARE%"
FILEO REPORTO = "%SCENARIO_DIR%\transit\XIT_WK_RPT_%ITER%_@TPER@.RPT"
FILEO ROUTEO[1] = "%SCENARIO_DIR%\transit\XIT_WK_RTE_%ITER%_@TPER@.RTE"
FILEO MATO[1] = "%SCENARIO_DIR%\transit\XIT_WK_SKIM_%ITER%_@TPER@.SKM",
 MO=1-13 NAME=IVT_Bus,IVT_LB,IVT_Exp,IVT_LRT,IVT_CRT,WAIT1,WAIT2,XFERS,AWALKT,XWALKT,FARE,XBFARE,CRTFare
FILEO NETO = "%SCENARIO_DIR%\transit\XIT_WK_NET_%ITER%_@TPER@.NET"
FILEI FACTORI[1] = "%TRANSIT_FOLDER%\@TPER2@_WK_%xit_fac_year%.FAC"
FILEI NTLEGI[3] = "%SCENARIO_DIR%\transit\XIT_XFER_NTL_@TPER@.NTL"
FILEI NTLEGI[2] = "%SCENARIO_DIR%\transit\XIT_DRACC_NTL_%ITER%_@TPER@.NTL"
FILEI NTLEGI[1] = "%SCENARIO_DIR%\transit\XIT_WKACC_NTL_@TPER@.NTL"
FILEI LINEI[1] = "%XIT_LINES%"
FILEI SYSTEMI = "%XIT_SYSTEM%"
FILEI NETI = "%SCENARIO_DIR%\transit\XIT_NET_%PREV_ITER%_@TPER@.NET"
FILEI FAREMATI[1] = "%XIT_FAREMAT%"



    PARAMETERS  HDWAYPERIOD=@TOD@
       
    PROCESS PHASE = DATAPREP
       TRANTIME[5]=li.loctime       ; local
       TRANTIME[6]=li.loctime       ; local
       TRANTIME[7]=li.exptime       ; express
       TRANTIME[8]=li.lrttime       ; lrt
       TRANTIME[9]=li.crttime       ; commuter bus
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

	REPORT LINES=T
ENDRUN


ENDDISTRIBUTEMULTISTEP



ENDLOOP
Wait4Files FILES='transit1.script.end, transit2.script.end, transit3.script.end, transit4.script.end, transit5.script.end' CheckReturnCode=T, DelDistribFiles=T

*cluster transit 1-5 CLOSE EXIT
