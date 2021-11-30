; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Build distribution matrix for Auto EE IPF'
FILEO MATO[1] = "%SCENARIO_DIR%\HWY_EXT_JOINT_TARGET.TRP",
DEC=2, MO=1, NAME=EE_SURVEY

FILEI MATI[1] = "%ee_auto_dist%",
 PATTERN=IJ:V,FIELDS=#1,2,3

    zones = %zones%
    
    MW[1] = MI.1.1

ENDRUN
