; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.

*copy "%SCENARIO_DIR%\XIT_WKACC_NTL_%ITER%_%TPER%.tmp"+"%CATALOG_DIR%\input\transit\WalkOverrides.txt" "%SCENARIO_DIR%\XIT_WKACC_NTL_%ITER%_%TPER%.ntl"
*copy "%SCENARIO_DIR%\XIT_XFER_NTL_%ITER%_%TPER%.tmp"+"%CATALOG_DIR%\input\transit\TransferOverrides.txt" "%SCENARIO_DIR%\XIT_XFER_NTL_%ITER%_%TPER%.ntl"
*copy "%SCENARIO_DIR%\XIT_DRACC_NTL_%ITER%_%TPER%.tmp"+"%CATALOG_DIR%\input\transit\DriveOverrides.txt" "%SCENARIO_DIR%\XIT_DRACC_NTL_%ITER%_%TPER%.ntl"
