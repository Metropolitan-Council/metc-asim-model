; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.

*cluster transit 1-2 START EXIT

LOOP TOD=1,2,1 ; Loop through peak and off-peak
  IF(TOD=1) TPER='PK'
  IF(TOD=2) TPER='OP'
  
 DISTRIBUTEMULTISTEP PROCESSID='transit' PROCESSNUM=%TOD%
