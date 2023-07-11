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
