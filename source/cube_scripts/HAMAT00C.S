; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Create Highway Skims: %ASSIGNNAME%'
FILEI MATI[2] = "%SCENARIO_DIR%\highway\HWY_SKIM_%PREV_ITER%_%PER%_%IC%.skm"
FILEO MATO[1] = "%SCENARIO_DIR%\highway\HWY_SKIM_%ITER%_%PER%_%IC%.skm",
 MO=1-15, 
  NAME=daptime, daptoll, dantime, dantoll, dapdist, a2ptime, a2ptoll, a2ntime, a2ntoll, a2pdist, 
  a3ptime, a3ptoll, a3ntime, a3ntoll, a3pdist
FILEI MATI[1] = "%SCENARIO_DIR%\highway\HWY_SKIM_%ITER%_%PER%_%IC%.tmp"

DISTRIBUTEINTRASTEP ProcessID='Intrastep', ProcessList=1-%max_threads%
  zones = %zones%
  
    ; calculate weighted skims - initial skims do not factor in here
      
    ; Drive alone
    mw[1] = MI.1.UTIME * (1/(%ITER%)) + MI.2.daptime * ((%ITER%-1)/(%ITER%))
    mw[2] = MI.1.TOLL * (1/(%ITER%)) + MI.2.daptoll * ((%ITER%-1)/(%ITER%))  
    mw[3] = MI.1.CTIME * (1/(%ITER%)) + MI.2.dantime * ((%ITER%-1)/(%ITER%))
    mw[4] = 0
    mw[5] = MI.1.DIST * (1/(%ITER%)) + MI.2.dapdist * ((%ITER%-1)/(%ITER%))

    mw[1][I] = LOWEST(1,1,0.1,999,I)/2  
    mw[3][I] = LOWEST(3,1,0.1,999,I)/2      
    mw[5][I] = LOWEST(5,1,0.1,999,I)/2 
    
    ; TODO: add switch here to set toll values if HOVPay
    
    ; SR2
    mw[6] = mw[1]
    mw[7] = 0
    mw[8] = mw[1]
    mw[9] = 0
    mw[10] = mw[5]
    
    ; SR3
    mw[11] = mw[1]
    mw[12] = 0
    mw[13] = mw[1]
    mw[14] = 0
    mw[15] = mw[5]       

ENDRUN
