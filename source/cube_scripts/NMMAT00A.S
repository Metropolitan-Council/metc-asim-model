; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Calculate Bike and Walk Distances'
FILEI MATI[2] = "%SCENARIO_DIR%\nonmotorized\NM_SKIM_WALK.skm"
FILEI MATI[1] = "%SCENARIO_DIR%\nonmotorized\NM_SKIM_BIKE.skm"
FILEO MATO[1] = "%SCENARIO_DIR%\nonmotorized\NM_SKIM.SKM",
 MO=1-3, NAME=BIKEDIST, WALKDIST, RATIO  ; add ratio to check calcs

  MW[1] = MI.1.B3DIST + (%bikeSpeed3%/%bikeSpeed2%) * MI.1.B2DIST + (%bikeSpeed3%/%bikeSpeed1%) * %bikeFact1% * MI.1.B1DIST
  MW[2] = MI.2.DISTANCE  
  MW[2][I] = MW[1][I]  ; intrazonal distances should be the same.
  MW[3] = MW[1] / MW[2]



ENDRUN
