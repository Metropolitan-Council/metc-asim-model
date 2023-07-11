; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.

*cluster transit 1-2 START EXIT
LOOP TOD=1,2,1



 IF(TOD=1) TPER='PK' ASSIGNNAME='Peak Period'  PER ='AM' 
 IF(TOD=2) TPER='OP' ASSIGNNAME='OffPeak Period'  PER ='MD' 



  DISTRIBUTEMULTISTEP PROCESSID='transit' PROCESSNUM=@TOD@


RUN PGM=NETWORK MSG='Calculate Transit Speeds for %TPER%'



FILEI NODEI[1] = "%SCENARIO_DIR%\node.dbf"
FILEI LINKI[2] = "%SCENARIO_DIR%\ALL_NET.net"
FILEO NETO = "%SCENARIO_DIR%\XIT_NET_%ITER%_@TPER@.NET"
FILEI LOOKUPI[2] = "%CATALOG_DIR%\INPUT\TRANSIT\@TPER@EXPRESSDELAYS.TXT"
FILEI LOOKUPI[1] = "%CATALOG_DIR%\INPUT\TRANSIT\@TPER@LOCALDELAYS.TXT"
FILEI LINKI[1] = "%SCENARIO_DIR%\HWY_LDNET_%ITER%_@PER@.net"



    ;  transit time = congested time +  distance * link delay
    ;   Delays are calibrated by AREA and facility type and time period.
    LOOKUP NAME=locdelay, LOOKUP[1]=1, RESULT=2,
                            LOOKUP[2]=1, RESULT=3,
                            LOOKUP[3]=1, RESULT=4,
                            LOOKUP[4]=1, RESULT=5,
                            LOOKUP[5]=1, RESULT=6,
                            LOOKUP[6]=1, RESULT=7,
                            LOOKUP[7]=1, RESULT=7,
                            LOOKUP[8]=1, RESULT=7,
                            LOOKUP[9]=1, RESULT=7,
                            LOOKUP[10]=1, RESULT=7,
                            FAIL=0,0,0, INTERPOLATE=N,
                            LOOKUPI=1, LIST=Y

    LOOKUP NAME=expdelay, LOOKUP[1]=1, RESULT=2,
                            LOOKUP[2]=1, RESULT=3,
                            LOOKUP[3]=1, RESULT=4,
                            LOOKUP[4]=1, RESULT=5,
                            LOOKUP[5]=1, RESULT=6,
                            LOOKUP[6]=1, RESULT=7,
                            LOOKUP[7]=1, RESULT=7,
                            LOOKUP[8]=1, RESULT=7,
                            LOOKUP[9]=1, RESULT=7,
                            LOOKUP[10]=1, RESULT=2,         ; 1 and 10 are rural area types
                            FAIL=0,0,0, INTERPOLATE=N,
                            LOOKUPI=2, LIST=Y


    ; TODO: Move this into the GeoDB
    PHASE=NODEMERGE FILEI=NI.1 
      IF (N=17502)
        FAREZONE=1
      ENDIF
      IF (N=19759)
        FAREZONE=2
      ENDIF
      IF (N=19761)
        FAREZONE=3
      ENDIF
      IF (N=19762)
        FAREZONE=4
      ENDIF
      IF (N=19763)
        FAREZONE=5
      ENDIF
      IF (N=19764)
        FAREZONE=6
      ENDIF
      
    ENDPHASE                          
                            
;;--------------------------------------------------------------------------

    ; Set transit speeds - same for PK/OP
    IF(LI.1.CSPD_1=0)
      SPEED=0.1
    ELSE
      SPEED = LI.1.CSPD_1
    ENDIF
    
;;--------------------------------------------------------------------------

    ; Code free flow speed for all links
    LOCTIME = (DISTANCE * 60 / SPEED)
    EXPTIME = (DISTANCE * 60 / SPEED)
    
;;--------------------------------------------------------------------------    

    ; Override manually coded speed for transit only links
    IF (LI.2.T_MANTIME>0)
        LOCTIME = T_MANTIME
        EXPTIME = T_MANTIME
        LRTTIME = T_MANTIME
    ENDIF    

;;--------------------------------------------------------------------------

    ;Calculate Local Bus Transit Travel Time
    IF (LOCTIME=0)
         _DELAY = locdelay(LI.1.AREA,LI.1.RCI)
         IF (T_Priority=2)
            IF ((SPEED+15)<50)
                _tspeed = MIN(SPEED+15,35)
            ELSE
                _tspeed=MAX(SPEED,35)
            ENDIF
            LOCTIME = (DISTANCE * 60 / _tspeed) + (DISTANCE * _DELAY)
         ELSE
            LOCTIME = (DISTANCE * 60 / SPEED) + (DISTANCE * _DELAY)
         ENDIF
    
        IF (LOCTIME=0) 
            PRINT LIST='LOCAL BUS TIME IS ZERO FOR - ', A(6), B(6)
        ENDIF        
    ENDIF
;;--------------------------------------------------------------------------
    
    ;Calculate Express Bus Transit Travel Time
    IF (EXPTIME=0)
        _DELAY = expdelay(LI.1.AREA,LI.1.RCI)
         IF (T_Priority=2)
            IF ((SPEED+15)<50)
                _tspeed = MIN(SPEED+15,35)
            ELSE
                _tspeed=MAX(SPEED,35)
            ENDIF
            EXPTIME = (DISTANCE * 60 / _tspeed) + (DISTANCE * _DELAY)
         ELSE
            EXPTIME = (DISTANCE * 60 / SPEED) + (DISTANCE * _DELAY)
         ENDIF
    
        IF (EXPTIME=0) 
            PRINT LIST='EXPRESS BUS TIME IS ZERO FOR - ', A(6), B(6)
        ENDIF
    ENDIF       

 ENDRUN   

ENDDISTRIBUTEMULTISTEP
ENDLOOP
Wait4Files FILES='transit1.script.end, transit2.script.end' CheckReturnCode=T, DelDistribFiles=T

*cluster transit 1-2 CLOSE EXIT





    

