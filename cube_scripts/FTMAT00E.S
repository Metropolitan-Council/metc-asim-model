;;<<Default Template>><<MATRIX>><<Default>>;;
RUN PGM=MATRIX
FILEI MATI[1]=EE_FRATAR_TRK.TMP 
  FILEO MATO[1]=EE_FRATAR_TRK.MAT, MO=1-2, NAME=SINGLEUNIT, COMBINATION
  MW[1]=MI.1.1*0.727
  MW[2]=MI.1.1*0.273

ENDRUN


