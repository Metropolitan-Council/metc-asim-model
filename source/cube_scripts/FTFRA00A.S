; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=FRATAR
FILEO MATO[1] = "%SCENARIO_DIR%\EE_Fratar_Trk_tmp", MO=1,DEC=D, NAME=EE_TRK
FILEI MATI[1] = "D:\TourCast\MetCouncil_ABM02092015\Input\EE_SEED_TRK_4.MAT"
FILEI LOOKUPI[1] = "D:\TourCast\MetCouncil_ABM02092015\Input\EE_FRATAR.txt"
LOOKUP LOOKUPI=1,
 NAME=FRATAR,
  LOOKUP[1]=1, RESULT=2,
  LOOKUP[2]=1, RESULT=3
    MAXRMSE=0.01
  MAXITERS=99
  SETPA P[1]=FRATAR(1,J), A[1]=FRATAR(2,J) MW[1]=MI.1.1

ENDRUN
