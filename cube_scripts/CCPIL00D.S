; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.

*echo.  >> "%SCENARIO_DIR%\converge.txt"
*type "%SCENARIO_DIR%\converge_%ITER%_%PER%.txt" >> "%SCENARIO_DIR%\converge.txt"
*echo.  >> "%SCENARIO_DIR%\converge.txt"

endloop

; check if converged

if ((OP._ERRLINKS > %conv_LinkPerc%) |
    (MD._ERRLINKS > %conv_LinkPerc%) |
    (AM._ERRLINKS > %conv_LinkPerc%) |
    (PM._ERRLINKS > %conv_LinkPerc%))
    
  *echo Iteration %ITER% Not Converged >> "%SCENARIO_DIR%\converge.txt"
  
else
 
  *echo Iteration %ITER% Converged! >> "%SCENARIO_DIR%\converge.txt"
  
   CONV = 1
   LOG VAR=CONV
   ;LOG PREFIX=CONVCHECK, VAR=CONV ; It appears that Cube does not write a prefix if logged from a Pilot program
   
endif

if (ITER == %max_feedback%)
  *echo.  >> "%SCENARIO_DIR%\converge.txt"
  *echo Maximum Iterations Hit >> "%SCENARIO_DIR%\converge.txt"
  *echo.  >> "%SCENARIO_DIR%\converge.txt"
  
    CONV = 1
   LOG VAR=CONV
endif
