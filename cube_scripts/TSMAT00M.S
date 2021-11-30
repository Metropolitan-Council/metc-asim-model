;;<<Default Template>><<MATRIX>><<Default>>;;
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Split into two types'
FILEO MATO[1] = "%SCENARIO_DIR%\EE_FRATAR_TRK.MAT",
 MO=1-2, DEC=1, NAME=SINGLEUNIT, COMBINATION
FILEI MATI[1] = "%SCENARIO_DIR%\EE_FRATAR_TMP.MAT"

MW[1]=MI.1.1*0.727
MW[2]=MI.1.1*0.273

ENDRUN
