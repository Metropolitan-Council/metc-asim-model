; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
;ITER = 4
;NEXTITER = ITER + 1
*cluster transit 1-2 START EXIT

;LOOP TOD=1,2,1
; IF(TOD=1) TPER='PK' ASSIGNNAME='Peak Period'  PER ='AM' 
; IF(TOD=2) TPER='OP' ASSIGNNAME='OffPeak Period'  PER ='MD' 

; DISTRIBUTEMULTISTEP PROCESSID='transit' PROCESSNUM=%TOD%


