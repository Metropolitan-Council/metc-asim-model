; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.

*cluster transit 1-5 START EXIT
LOOP TOD=1,5,1

 IF(TOD=1) TPER='EA' ASSIGNNAME='EA Period'  PER ='NT' TPER2 = 'OP'
 IF(TOD=2) TPER='AM' ASSIGNNAME='AM Period'  PER ='AM' TPER2 = 'PK'
 IF(TOD=3) TPER='MD' ASSIGNNAME='MD Period'  PER ='MD' TPER2 = 'OP'
 IF(TOD=4) TPER='PM' ASSIGNNAME='PM Period'  PER ='PM' TPER2 = 'PK'
 IF(TOD=5) TPER='NT' ASSIGNNAME='NT Period'  PER ='NT' TPER2 = 'OP'

  DISTRIBUTEMULTISTEP PROCESSID='transit' PROCESSNUM=@TOD@


RUN PGM=NETWORK MSG='Calculate Transit Speeds for @TPER@' PRNFILE="%SCENARIO_DIR%\transit\XIT_TSPEEDS_%ITER%_@TPER@.prn"
FILEI NODEI[1] = "%SCENARIO_DIR%\transit\TransitBase.NET"
FILEI LINKI[1] = "%SCENARIO_DIR%\transit\TransitBase.NET"
FILEO NETO = "%SCENARIO_DIR%\transit\XIT_NET_%ITER%_@TPER@.NET"
FILEI LOOKUPI[2] = "%TRANSIT_FOLDER%\@TPER2@EXPRESSDELAYS.TXT"
FILEI LOOKUPI[1] = "%TRANSIT_FOLDER%\@TPER2@LOCALDELAYS.TXT"
FILEI LINKI[2] = "%SCENARIO_DIR%\highway\HWY_LDNET_%ITER%_@PER@.net";, RENAME=TTIME_ASSERT_AM-TTA_AM, TTIME_ASSERT_MD-TTA_MD,
	;TTIME_ASSERT_PM-TTA_PM, TTIME_ASSERT_NT-TTA_NT



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
    ;PHASE=NODEMERGE FILEI=NI.1 
      ;IF (N=17502)
      ;  FAREZONE=1
      ;ENDIF
      ;IF (N=19759)
      ;  FAREZONE=2
      ;ENDIF
      ;IF (N=19761)
      ;  FAREZONE=3
      ;ENDIF
      ;IF (N=19762)
      ;  FAREZONE=4
      ;ENDIF
      ;IF (N=19763)
      ;  FAREZONE=5
      ;ENDIF
      ;IF (N=19764)
      ;  FAREZONE=6
      ;ENDIF
      
    ;ENDPHASE       

	;LRTTIME = (DISTANCE * 60) / SPEED
    LW.LRT_SPEED = 15
    ;IF(LI.1.RAIL_ONLY=1)
    ;    LW.LRT_SPEED = 45
    ;ENDIF
    LRTTIME = (DISTANCE * 60) / LW.LRT_SPEED
	CRTTIME = (DISTANCE * 60) / 45 ; Per Northstar timetables - 45 MPH effective speed
                            
;;--------------------------------------------------------------------------

    ; Set transit speeds - same for PK/OP
    IF(LI.2.CSPD_1=0)
      SPEED=0.1
    ELSE
      SPEED = LI.2.CSPD_1
    ENDIF
    
;;--------------------------------------------------------------------------

    ; Code free flow speed for all links
    LOCTIME = (DISTANCE * 60 / SPEED)
	IF(LI.1.RCI > 3)
	  LOCTIME = LOCTIME * 1.5
	ENDIF
    EXPTIME = (DISTANCE * 60 / SPEED)
    
;;--------------------------------------------------------------------------    

    ; Override manually coded speed for transit only links
    IF (LI.2.TTIME_ASSERT_@PER@>0)
        LOCTIME = TTIME_ASSERT_@PER@
        EXPTIME = TTIME_ASSERT_@PER@
        LRTTIME = TTIME_ASSERT_@PER@
    ENDIF    

;;--------------------------------------------------------------------------

    ;Calculate Local Bus Transit Travel Time
    IF (LOCTIME=0)
         _DELAY = locdelay(LI.2.AREA_TYPE,LI.2.RCI)
         IF (TRN_PRIORITY_@PER@=2)
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
        _DELAY = expdelay(LI.2.AREA_TYPE,LI.2.RCI)
         IF (TRN_PRIORITY_@PER@=2)
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
	; Local time fix (see TSNET00C_Loop.S)
	IF(LI.1.RCI > 3)
	  LOCTIME = LOCTIME * 0.5
	ENDIF

 ENDRUN   

ENDDISTRIBUTEMULTISTEP
ENDLOOP
Wait4Files FILES='transit1.script.end, transit2.script.end, transit3.script.end, transit4.script.end, transit5.script.end' CheckReturnCode=T, DelDistribFiles=T

*cluster transit 1-5 CLOSE EXIT





    

