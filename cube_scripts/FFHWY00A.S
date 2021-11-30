; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=HIGHWAY MSG='Skim Free Flow Network'
FILEI NETI = "%SCENARIO_DIR%\ALL_NET.net"
;FILEO MATO[1] = "%SCENARIO_DIR%\HWY_SKIM.tmp",  changed by Dennis Farmer; this should have extenstion .skm to work and get copied in next script
FILEO MATO[1] = "%SCENARIO_DIR%\HWY_SKIM.skm",
 MO=1-16, 
  NAME=daptime, daptoll, dantime, dantoll, dapdist, a2ptime, a2ptoll, a2ntime, a2ntoll, a2pdist, 
  a3ptime, a3ptoll, a3ntime, a3ntoll, a3pdist, lnrtdist

PROCESS PHASE=ILOOP
    PATHLOAD PATH = TIME,  
    mw[1] = PATHTRACE(TIME) NOACCESS=1000,
    mw[5] = PATHTRACE(li.DISTANCE) NOACCESS=1000 

    ; Intrazonal time / distance is half that to nearest zone
    mw[1][I] = LOWEST(1,1,0.1,999,I)/2 
    mw[5][I] = LOWEST(5,1,0.1,999,I)/2 

    mw[2] = 0
    mw[3] = mw[1]
    mw[4] = mw[2]
    
    ; SR2
    mw[6] = mw[1]
    mw[7] = mw[2]
    mw[8] = mw[3]
    mw[9] = mw[4]
    mw[10] = mw[5]
    
    ; SR3
    mw[11] = mw[1]
    mw[12] = mw[2]
    mw[13] = mw[3]
    mw[14] = mw[4]
    mw[15] = mw[5]   
    
    ; ln(RT Dist + 1)
    mw[16] = LN(2 * mw[5]+1)
    
ENDPROCESS



ENDRUN
