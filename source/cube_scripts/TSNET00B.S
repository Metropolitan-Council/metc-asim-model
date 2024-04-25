; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK MSG='TEMP: set rail zone node field'
;FILEI LINKI[4] = "C:\ABM_BatchTest\Input\network\T_Priority.dbf"
;FILEI LINKI[3] = "C:\ABM_BatchTest\Input\network\T_MANTIME.dbf"
;FILEI LINKI[2] = "C:\ABM_BatchTest\Input\network\Distances.dbf"
FILEO NETO = "%SCENARIO_DIR%\transit\TransitBase.NET"
FILEI NODEI[1] = "%SCENARIO_DIR%\transit\node.dbf"
FILEI LINKI[1] = "%SCENARIO_DIR%\transit\link.dbf"

    ZONES=%zones%
    
    ; TODO: Move this into the GeoDB
    ; PHASE=NODEMERGE FILEI=NI.1 
      ; IF (N=17502)
        ; FAREZONE=1
      ; ENDIF
      ; IF (N=19759)
        ; FAREZONE=2
      ; ENDIF
      ; IF (N=19761)
        ; FAREZONE=3
      ; ENDIF
      ; IF (N=19762)
        ; FAREZONE=4
      ; ENDIF
      ; IF (N=19763)
        ; FAREZONE=5
      ; ENDIF
      ; IF (N=19764)
        ; FAREZONE=6
      ; ENDIF
      
    ; ENDPROCESS

	PHASE=NODEMERGE FILEI=NI.1 
       IF (N=417232)
         FAREZONE=1
       ENDIF
       IF (N=417233)
         FAREZONE=2
       ENDIF
       IF (N=417234)
         FAREZONE=3
       ENDIF
       IF (N=417235)
         FAREZONE=4
       ENDIF
       IF (N=417236)
         FAREZONE=5
       ENDIF
       IF (N=417237)
         FAREZONE=6
       ENDIF
      
    ENDPROCESS
      
ENDRUN
