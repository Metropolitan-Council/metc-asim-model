; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Record stats and Convert to Vehicle Trip Tables %ASSIGNNAME%'
FILEO MATO[1] = "%SCENARIO_DIR%\specialgen\HWY_SPC_AUTO_TRIP_%ITER%_%PER%.trp",
 MO=41-43, DEC[1]=3*2, NAME=DA, SR2, SR3
FILEI MATI[1] = "%SCENARIO_DIR%\specialgen\HWY_SPC_TRIP_%ITER%_%PER%.TRP"
      
          MW[41] = MI.1.1
          MW[42] = MI.1.2/%hwy_HOV2OCC%
          MW[43] = MI.1.3/%hwy_HOV3OCC%   
		  
ENDRUN
