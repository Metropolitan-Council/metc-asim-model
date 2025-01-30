; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.


ITER = 4
; End of PILOT Script

; Script for program MATRIX in file "D:\8296\TestAssignment\CUBE\PAMAT00C.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Combine Special Generator Trips into Peak/Off-Peak'
FILEO MATO[2] = "%SCENARIO_DIR%\XIT_SPC_TRIP_%ITER%_OP.trp",
 MO=11-12, NAME=WK, DR
FILEO MATO[1] = "%SCENARIO_DIR%\XIT_SPC_TRIP_%ITER%_PK.trp",
 MO=1-2, NAME=WK, DR
FILEI MATI[11] = "%SCENARIO_DIR%\HWY_SPC_TRIP_%ITER%_ON.trp"
FILEI MATI[10] = "%SCENARIO_DIR%\HWY_SPC_TRIP_%ITER%_EV.trp"
FILEI MATI[9] = "%SCENARIO_DIR%\HWY_SPC_TRIP_%ITER%_MD.trp"
FILEI MATI[8] = "%SCENARIO_DIR%\HWY_SPC_TRIP_%ITER%_PM4.trp"
FILEI MATI[7] = "%SCENARIO_DIR%\HWY_SPC_TRIP_%ITER%_PM3.trp"
FILEI MATI[6] = "%SCENARIO_DIR%\HWY_SPC_TRIP_%ITER%_PM2.trp"
FILEI MATI[5] = "%SCENARIO_DIR%\HWY_SPC_TRIP_%ITER%_PM1.trp"
FILEI MATI[4] = "%SCENARIO_DIR%\HWY_SPC_TRIP_%ITER%_AM4.trp"
FILEI MATI[3] = "%SCENARIO_DIR%\HWY_SPC_TRIP_%ITER%_AM3.trp"
FILEI MATI[2] = "%SCENARIO_DIR%\HWY_SPC_TRIP_%ITER%_AM2.trp"
FILEI MATI[1] = "%SCENARIO_DIR%\HWY_SPC_TRIP_%ITER%_AM1.trp"

  ; peak
  MW[1] = MI.1.4 + MI.2.4 + MI.3.4 + MI.4.4 + MI.5.4 + MI.6.4 + MI.7.4 + MI.8.4
  MW[2] = MI.1.5 + MI.2.5 + MI.3.5 + MI.4.5 + MI.5.5 + MI.6.5 + MI.7.5 + MI.8.5
  
  ; off-peak
  MW[11] = MI.9.4 + MI.10.4 + MI.11.4
  MW[12] = MI.9.5 + MI.10.5 + MI.11.5
  
ENDRUN


; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.

;NEXTITER = ITER + 1

*cluster transit 1-2 START EXIT

LOOP TOD=1,2,1
 IF(TOD=1) TPER='PK' ASSIGNNAME='Peak Period'  PER ='AM' 
 IF(TOD=2) TPER='OP' ASSIGNNAME='OffPeak Period'  PER ='MD' 

 DISTRIBUTEMULTISTEP PROCESSID='transit' PROCESSNUM=%TOD%
; End of PILOT Script

; Script for program MATRIX in file "D:\8296\TestAssignment\CUBE\PAMAT00A.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Expand trip table to full zones'
FILEI MATI[4] = "%SCENARIO_DIR%\XIT_SPC_TRIP_%ITER%_%TPER%.trp"
FILEO PRINTO[1] = "%SCENARIO_DIR%\XIT_TRIP_PRN_%ITER%_%TPER%.trp"
FILEI MATI[3] = "%SCENARIO_DIR%\XIT_DR_SKIM_%ITER%_%TPER%.SKM"
FILEI MATI[2] = "%SCENARIO_DIR%\XIT_WK_SKIM_%ITER%_%TPER%.SKM"
FILEO MATO[1] = "%SCENARIO_DIR%\XIT_TRIP_%ITER%_%TPER%_CLEAN.trp",
 MO=1-2, NAME=WalkToTransit, DriveToTransit
FILEI MATI[1] = "%SCENARIO_DIR%\XIT_TRIP_%ITER%_%TPER%.trp"

  zones = %zones%
  mw[1] = MI.1.1 + MI.4.1; Walk to Transit
  mw[2] = MI.1.2 + MI.4.2; Drive to Transit
  
  MW[3] = MI.2.1
  MW[4] = MI.3.1

  ; Remove trips where no path is found, add 0.1 trips to at least one path 
  ; to avoid Cube crash when assigning empty trip tables
  ARRAY _pathFound = 6
  IF (I==1)
    _WBUS = 0
    _DBUS = 0   
    _DROPPED_WBUS = 0
    _DROPPED_DBUS = 0 
  ENDIF
  
  IF (I <= %int_zones%)
   JLOOP
      _WBUS = _WBUS + MW[1][J]
      _DBUS = _DBUS + MW[2][J]
      
      IF (MW[1][J]>0 && MW[3][J]=0) 
        _DROPPED_WBUS = _DROPPED_WBUS + MW[1][J]
        MW[1][J]=0
      ENDIF
      IF (MW[2][J]>0 && MW[4][J]=0)
        _DROPPED_DBUS = _DROPPED_DBUS + MW[2][J]
        MW[2][J]=0
      ENDIF        
       
      ; Add a 0.1 trip to the first path found just in case trips are empty
      IF (_pathFound[1]=0 && MW[3][J]>0)
        MW[1][J]=MW[1][J] + 0.1
        _pathFound[1] = 1
      ENDIF
      IF (_pathFound[2]=0 && MW[4][J]>0)
        MW[2][J]=MW[2][J] + 0.1
        _pathFound[2] = 1
      ENDIF
   ENDJLOOP
  ENDIF
  
   IF (I = %zones%)
    PRINT CSV=T, LIST = 'Trips', 'WBUS', 'DBUS', PRINTO=1
    PRINT CSV=T, LIST = 'Initial Trips', _WBUS, _DBUS, PRINTO=1    
    PRINT CSV=T, LIST = 'Dropped Trips', _DROPPED_WBUS, _DROPPED_DBUS, PRINTO=1
   ENDIF
   
   LOOP _p = 1,2
      IF(_pathFound[_p] = 0)
          LOG PREFIX=TransitAssignment, VAR=_p
      ENDIF
   ENDLOOP  
  
  
ENDRUN


; Script for program PUBLIC TRANSPORT in file "D:\8296\TestAssignment\CUBE\PAPTR00B.S"
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
    
 PARAMETERS TRIPSIJ[1] = MI.1.1         ; ASSIGN WALK TO Transit TRIPS

 REPORT LINES=T, SORT=MODE, LINEVOLS=T, STOPSONLY=T, SKIP0=T, XFERSUM=MODE


ENDRUN


; Script for program PUBLIC TRANSPORT in file "D:\8296\TestAssignment\CUBE\PAPTR00D.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=PUBLIC TRANSPORT PRNFILE="%SCENARIO_DIR%\XIT_DR_LD_PRN_%ITER%_%TPER%.prn" MSG='%TPER% Drive Transit Assignment'
FILEO ROUTEO[1] = "%SCENARIO_DIR%\XIT_DR_LD_RTE_%ITER%_%TPER%.RTE"
FILEO LINKO[1] = "%SCENARIO_DIR%\XIT_DR_LD_%ITER%_%TPER%.DBF",
ONOFFS=Y, NTLEGS=Y, SKIP0=Y
FILEI MATI[1] = "%SCENARIO_DIR%\XIT_TRIP_%ITER%_%TPER%_CLEAN.trp"
FILEI FAREI = "%XIT_FARE%"
FILEO REPORTO = "%SCENARIO_DIR%\XIT_DR_LD_RPT_%ITER%_%TPER%.RPT"
FILEI FACTORI[1] = "%CATALOG_DIR%\INPUT\TRANSIT\%TPER%_DR_%xit_fac_year%.FAC"
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
        GENERATE,
            READNTLEGI=2             ; drive access link (mode=2)
        GENERATE,
            READNTLEGI=3             ; transfer link (mode=4)
    ENDPROCESS
    
 PARAMETERS TRIPSIJ[1] = MI.1.2         ; ASSIGN Drive TO Transit TRIPS

 REPORT LINES=T, SORT=MODE, LINEVOLS=T, STOPSONLY=T, SKIP0=T, XFERSUM=MODE

ENDRUN


; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.


LOOP T=1,2,1

  IF (T==1) ACC='WK'
  IF (T==2) ACC='DR'
; End of PILOT Script

; Script for program MATRIX in file "D:\8296\TestAssignment\CUBE\PAMAT00B.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Combine Transit Boarding Data'
FILEI DBI[1] = "%SCENARIO_DIR%\XIT_%ACC%_LD_%ITER%_%TPER%.dbf"
FILEO PRINTO[1] = "%SCENARIO_DIR%\XIT_%ACC%_LD_%ITER%_%TPER%_SUMM.csv"
zones = 1

ons = 0 name = 0 mode = 0 op = 0

 PRINT CSV=T, LIST='Route, Mode, Operator, Boardings', PRINTO=1

; Read first record to get name reference
x=DBIReadREcord(1,k)
name = val(DI.1.NAME)
strname = DI.1.NAME
mode = DI.1.MODE
op   = DI.1.OPERATOR

; Walk-Transit
  LOOP k=1,DBI.1.NUMRECORDS
    x=DBIReadREcord(1,k)
    
    IF (strname == DI.1.NAME)
      ons = ons + DI.1.ONA
    ELSE
      PRINT CSV=T, LIST=strname, mode, op, ons PRINTO=1
      name = val(DI.1.NAME)
      strname = DI.1.NAME
      mode = DI.1.MODE
      op   = DI.1.OPERATOR
      ons  = DI.1.ONA
    ENDIF

  ENDLOOP

ENDRUN


; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.

ENDLOOP ; Transit access summaries

ENDDISTRIBUTEMULTISTEP
ENDLOOP

Wait4Files FILES='transit1.script.end, transit2.script.end' CheckReturnCode=T, DelDistribFiles=T

*cluster transit 1-2 CLOSE EXIT
; End of PILOT Script

