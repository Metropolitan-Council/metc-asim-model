; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.

;ITER = 1
;PREV_ITER = 0

READ FILE = "%SPC_MODECHOICE%"

LOOP TOD=1,11,1
 IF(TOD=1) PER='AM1' HPER='AM' TPER = 'PK'
 IF(TOD=2) PER='AM2' HPER='AM' TPER = 'PK' 
 IF(TOD=3) PER='AM3' HPER='AM' TPER = 'PK' 
 IF(TOD=4) PER='AM4' HPER='AM' TPER = 'PK'   
 IF(TOD=5) PER='MD'  HPER='MD' TPER = 'OP'
 IF(TOD=6) PER='PM1' HPER='PM' TPER = 'PK'  
 IF(TOD=7) PER='PM2' HPER='PM' TPER = 'PK' 
 IF(TOD=8) PER='PM3' HPER='PM' TPER = 'PK' 
 IF(TOD=9) PER='PM4' HPER='PM' TPER = 'PK'
 IF(TOD=10) PER='EV' HPER='NT' TPER = 'OP' 
 IF(TOD=11) PER='ON' HPER='NT' TPER = 'OP' 
