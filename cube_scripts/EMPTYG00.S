; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.


ITER = 1
;PER='NT' 

LOOP TOD=1,4,1
 IF(TOD=1) PER='NT' 
 IF(TOD=2) PER='AM' 
 IF(TOD=3) PER='MD' 
 IF(TOD=4) PER='PM' 
; End of PILOT Script

; Script for program NETWORK in file "D:\TourCast\MetCouncil_ABM02092015\CUBE\IINET00C.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK MSG='Unbuild network'
FILEO LINKO = "%SCENARIO_DIR%\HWY_LDNET_%ITER%_%PER%.dbf"
FILEI LINKI[1] = "%SCENARIO_DIR%\HWY_LDNET_%ITER%_%PER%.NET"


ENDRUN


; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.


ENDLOOP
; End of PILOT Script

