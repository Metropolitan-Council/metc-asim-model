; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=HIGHWAY

FILEI NETI = %NETI.Q%
FILEO MATO[1] = %MATO.Q%,
MO=1-2, NAME=TIME,DISTANCE
PROCESS PHASE=ILOOP
  PATHLOAD PATH=COST, MW[1]=pathtrace(TIME), MW[2]=pathtrace(LI.DISTANCE)
      MW[1][I] = ROWMIN(1) * 0.5  ; Intrazonal time
      MW[2][I] = 0                ; Set Intrazonal Dist = 0

ENDPROCESS

ENDRUN
