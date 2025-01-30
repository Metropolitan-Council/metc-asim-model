; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.


*copy "%hwy_AM_L_skims%" "%SCENARIO_DIR%\highway\HWY_SKIM_0_AM_L.skm"
*copy "%hwy_MD_L_skims%" "%SCENARIO_DIR%\highway\HWY_SKIM_0_MD_L.skm"
*copy "%hwy_PM_L_skims%" "%SCENARIO_DIR%\highway\HWY_SKIM_0_PM_L.skm"
*copy "%hwy_NT_L_skims%" "%SCENARIO_DIR%\highway\HWY_SKIM_0_NT_L.skm"

*copy "%hwy_AM_M_skims%" "%SCENARIO_DIR%\highway\HWY_SKIM_0_AM_M.skm"
*copy "%hwy_MD_M_skims%" "%SCENARIO_DIR%\highway\HWY_SKIM_0_MD_M.skm"
*copy "%hwy_PM_M_skims%" "%SCENARIO_DIR%\highway\HWY_SKIM_0_PM_M.skm"
*copy "%hwy_NT_M_skims%" "%SCENARIO_DIR%\highway\HWY_SKIM_0_NT_M.skm"

*copy "%hwy_AM_H_skims%" "%SCENARIO_DIR%\highway\HWY_SKIM_0_AM_H.skm"
*copy "%hwy_MD_H_skims%" "%SCENARIO_DIR%\highway\HWY_SKIM_0_MD_H.skm"
*copy "%hwy_PM_H_skims%" "%SCENARIO_DIR%\highway\HWY_SKIM_0_PM_H.skm"
*copy "%hwy_NT_H_skims%" "%SCENARIO_DIR%\highway\HWY_SKIM_0_NT_H.skm"


  IF (ReturnCode == 1) 
    PRINT LIST='Missing Highway Initial Skim file - check scenario key settings in the Scenario Manager'
    abort
  ENDIF 
