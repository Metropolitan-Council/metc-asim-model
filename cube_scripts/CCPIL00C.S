; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
;ITER = 2
PREV_ITER = ITER - 1
;PER='NT' 

; tag the iteration time and date
*echo.  >> "%SCENARIO_DIR%\converge.txt"
*echo.  >> "%SCENARIO_DIR%\converge.txt"
*echo 'Checking convergence for iteration %ITER%'  >> "%SCENARIO_DIR%\converge.txt"
*echo %date% %time%  >> "%SCENARIO_DIR%\converge.txt"

LOOP TOD=1,4,1
 IF(TOD=1) PER='NT' 
 IF(TOD=2) PER='AM' 
 IF(TOD=3) PER='MD' 
 IF(TOD=4) PER='PM' 
 
 
