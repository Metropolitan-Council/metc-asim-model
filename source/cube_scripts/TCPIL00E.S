; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.

*copy "%xit_WK_EAskims%" "%SCENARIO_DIR%\transit\XIT_WK_SKIM_0_EA.skm"
*copy "%xit_WK_AMskims%" "%SCENARIO_DIR%\transit\XIT_WK_SKIM_0_AM.skm"
*copy "%xit_WK_MDskims%" "%SCENARIO_DIR%\transit\XIT_WK_SKIM_0_MD.skm"
*copy "%xit_WK_PMskims%" "%SCENARIO_DIR%\transit\XIT_WK_SKIM_0_PM.skm"
*copy "%xit_WK_NTskims%" "%SCENARIO_DIR%\transit\XIT_WK_SKIM_0_NT.skm"

*copy "%xit_DR_EAskims%" "%SCENARIO_DIR%\transit\XIT_DR_SKIM_0_EA.skm"
*copy "%xit_DR_AMskims%" "%SCENARIO_DIR%\transit\XIT_DR_SKIM_0_AM.skm"
*copy "%xit_DR_MDskims%" "%SCENARIO_DIR%\transit\XIT_DR_SKIM_0_MD.skm"
*copy "%xit_DR_PMskims%" "%SCENARIO_DIR%\transit\XIT_DR_SKIM_0_PM.skm"
*copy "%xit_DR_NTskims%" "%SCENARIO_DIR%\transit\XIT_DR_SKIM_0_NT.skm"

  IF (ReturnCode == 1) 
    PRINT LIST='Missing Highway Initial Skim file - check scenario key settings in the Scenario Manager'
    abort
  ENDIF 
