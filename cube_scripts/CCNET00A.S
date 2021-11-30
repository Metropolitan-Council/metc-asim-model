; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK MSG='Calculate Differences'
FILEO NETO = "%SCENARIO_DIR%\%ITER%_%PER%_CONVCHK.TMP",
  INCLUDE = A,B,LINKCLASS, AREA, DISTANCE, VOL_DIFF, VMT_DIFF, PER_DIFF, VOL_SQR_ERR, VMT_SQR_ERR, DIFF_FLAG
FILEI LINKI[2] = "%SCENARIO_DIR%\%PREV_ITER%_%PER%_LDNET.net"
FILEI LINKI[1] = "%SCENARIO_DIR%\%ITER%_%PER%_LDNET.net"

  PHASE=LINKMERGE
  
  IF (LI.2.V_1 > 0 & LI.1.V_1 > 0)
  
    VOL_DIFF = LI.2.V_1 - LI.1.V_1
    VMT_DIFF = (LI.2.V_1 - LI.1.V_1)*DISTANCE  
    PER_DIFF = (LI.2.V_1 - LI.1.V_1) / LI.1.V_1
    VOL_SQR_ERR = (LI.2.V_1 - LI.1.V_1)^2
    VMT_SQR_ERR = ((LI.2.V_1 - LI.1.V_1)*DISTANCE)^2

    DIFF_FLAG = 0
  
    IF(ABS(PER_DIFF) > 0.05)
      DIFF_FLAG = 1
    ENDIF
  ENDIF
  

  
  ENDPHASE
  
ENDRUN
