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
