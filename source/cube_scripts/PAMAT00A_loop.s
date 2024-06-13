; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.

*cluster transit 1-5 START EXIT

LOOP TOD=1,5,1

 IF(TOD=1) TPER='EA' ASSIGNNAME='EA Period'  PER ='EA' 
 IF(TOD=2) TPER='AM' ASSIGNNAME='AM Period'  PER ='AM' 
 IF(TOD=3) TPER='MD' ASSIGNNAME='MD Period'  PER ='MD' 
 IF(TOD=4) TPER='PM' ASSIGNNAME='PM Period'  PER ='PM' 
 IF(TOD=5) TPER='NT' ASSIGNNAME='NT Period'  PER ='NT' 

 DISTRIBUTEMULTISTEP PROCESSID='transit' PROCESSNUM=@TOD@

RUN PGM=MATRIX MSG='Adding Asim Transit and Special Generator Transit'
FILEI MATI[2] = "%SCENARIO_DIR%\transit\XIT_SPC_TRIP_%PREV_ITER%_@TPER@.trp"
FILEO PRINTO[1] = "%SCENARIO_DIR%\transit\XIT_TRIP_PRN_%PREV_ITER%_@TPER@.trp"
FILEO MATO[1] = "%SCENARIO_DIR%\transit\XIT_TRIP_%PREV_ITER%_@TPER@_CLEAN.trp",
 MO=1-3, NAME=WalkToTransit, DriveToTransit, TrnDriveEgress
FILEI MATI[1] = "%SCENARIO_DIR%\transit\XIT_TRIP_%PREV_ITER%_@TPER@.trp"

  mw[1] = MI.1.WalkToTransit + MI.2.WK; Walk to Transit
  mw[2] = MI.1.DriveToTransit  + MI.2.DR; Drive to Transit
  mw[3] = MI.1.TrnDriveEgress
  
ENDRUN

ENDDISTRIBUTEMULTISTEP
ENDLOOP

Wait4Files FILES='transit1.script.end, transit2.script.end, transit3.script.end, transit4.script.end, transit5.script.end' CheckReturnCode=T, DelDistribFiles=T

*cluster transit 1-5 CLOSE EXIT