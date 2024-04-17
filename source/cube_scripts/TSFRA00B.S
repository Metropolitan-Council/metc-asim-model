;;<<Default Template>><<FRATAR>><<Default>>;;
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=FRATAR MSG='Fratar EE truck from FAF'
FILEO MATO[1] = "%SCENARIO_DIR%\truck\EE_FRATAR_TMP.MAT",
 MO=1, DEC=1, NAME=EE_TRK
FILEI LOOKUPI[1] = "%ee_fratar%"
FILEI MATI[1] = "%ee_trk_dist%"
LOOKUP LOOKUPI=1,
 NAME=FRATAR,
  LOOKUP[1]=1, RESULT=2,
  LOOKUP[2]=1, RESULT=3
    MAXRMSE=0.01
  MAXITERS=99
  SETPA P[1]=FRATAR(1,J), A[1]=FRATAR(2,J) MW[1]=MI.1.1

ENDRUN
