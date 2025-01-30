; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.


;ITER = 1
;PER='NT' 

LOOP TOD=1,4,1
 IF(TOD=1) PER='NT' 
 IF(TOD=2) PER='AM' 
 IF(TOD=3) PER='MD' 
 IF(TOD=4) PER='PM' 
