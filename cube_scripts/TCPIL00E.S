; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.


*copy "%xit_WK_PKskims%" "%SCENARIO_DIR%\XIT_WK_SKIM_0_PK.skm"
*copy "%xit_WK_OPskims%" "%SCENARIO_DIR%\XIT_WK_SKIM_0_OP.skm"
*copy "%xit_DR_PKskims%" "%SCENARIO_DIR%\XIT_DR_SKIM_0_PK.skm"
*copy "%xit_DR_OPskims%" "%SCENARIO_DIR%\XIT_DR_SKIM_0_OP.skm"

  IF (ReturnCode == 1) 
    PRINT LIST='Missing Highway Initial Skim file - check scenario key settings in the Scenario Manager'
    abort
  ENDIF 
