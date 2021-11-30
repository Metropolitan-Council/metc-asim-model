; Script for program NETWORK in file "C:\Projects\TourCast\MetCouncilCodeBase\Cube\Catalog\CUBE\NMNET00A.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK MSG='Export Bike Network from Geodatabase'
FILEO NETO = "%SCENARIO_DIR%\NMNetwork.tmp"
FILEI LINKI[1] = "%SCENARIO_DIR%\RawNetwork.tmp"


;Length corrections
;DISTANCE = SHAPE_Length/1609.344 ; Adds distance to any new link that was not coded with a distance

BIKESPEED=0
IF (BIKE=0) DELETE
IF (BIKE=1) BIKESPEED=%bikeSpeed1%
IF (BIKE=2) BIKESPEED=%bikeSpeed2%
IF (BIKE=3) BIKESPEED=%bikeSpeed3%

BIKETIME=60*(DISTANCE/BIKESPEED)
PTIME=BIKETIME
B1DIST=0
B2DIST=0
B3DIST=0

IF (BIKE=3)
  B3DIST=DISTANCE
ENDIF
IF (BIKE=2)
  B2DIST=DISTANCE
ENDIF
IF (BIKE=1)
  B1DIST=DISTANCE
  PTIME=BIKETIME*%bikeFact1%
ENDIF

ENDRUN


; Script for program HIGHWAY in file "C:\Projects\TourCast\MetCouncilCodeBase\Cube\Catalog\CUBE\NMHWY00A.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=HIGHWAY MSG='Skim Bike Path Times'
FILEO MATO[1] = "%SCENARIO_DIR%\BIKE_DAILY.skm",
 MO=1-6, NAME=PERCTIME, BIKETIME, DISTANCE, B3DIST, B2DIST, B1DIST
FILEI NETI = "%SCENARIO_DIR%\NMNetwork.tmp"

PROCESS PHASE=ILOOP

  PATHLOAD PATH=LI.PTIME, MW[1]=pathtrace(LI.PTIME), MW[2]=pathtrace(LI.BIKETIME),
                          MW[3]=pathtrace(LI.DISTANCE), MW[4]=pathtrace(LI.B3DIST),
                          MW[5]=pathtrace(LI.B2DIST), MW[6]=pathtrace(LI.B1DIST)  
      MW[1][I] = ROWMIN(1) * 0.5  ; Intrazonal time
      MW[2][I] = ROWMIN(2) * 0.5
      MW[3][I] = ROWMIN(3) * 0.5
      MW[4][I] = ROWMIN(3) ; use total distance intrazonal, not just dist on this facility type
      MW[5][I] = 0 ; assume no bike paths on the intrazonal
      MW[6][I] = 0 ; assume no bike paths on the intrazonal
ENDPROCESS


ENDRUN


; Script for program HIGHWAY in file "C:\Projects\TourCast\MetCouncilCodeBase\Cube\Catalog\CUBE\NMHWY00B.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=HIGHWAY MSG='Skim Walk Path Distance'
FILEO MATO[1] = "%SCENARIO_DIR%\WALK_DAILY.skm",
 MO=1-4, NAME=DISTANCE, B3DIST, B2DIST, B1DIST
FILEI NETI = "%SCENARIO_DIR%\NMNetwork.tmp"
PROCESS PHASE=ILOOP

  PATHLOAD PATH=LI.DISTANCE, MW[1]=pathtrace(LI.DISTANCE), MW[2]=pathtrace(LI.B3DIST),
                          MW[3]=pathtrace(LI.B2DIST), MW[4]=pathtrace(LI.B1DIST)  
      MW[1][I] = ROWMIN(1) * 0.5  ; Intrazonal time
      MW[2][I] = ROWMIN(2) * 0.5
      MW[3][I] = ROWMIN(3) * 0.5
      MW[4][I] = ROWMIN(4) * 0.5
ENDPROCESS

ENDRUN


; Script for program MATRIX in file "C:\Projects\TourCast\MetCouncilCodeBase\Cube\Catalog\CUBE\NMMAT00A.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Calculate Bike and Walk Distances'
FILEI MATI[2] = "%SCENARIO_DIR%\WALK_DAILY.skm"
FILEI MATI[1] = "%SCENARIO_DIR%\BIKE_DAILY.skm"
FILEO MATO[1] = "%SCENARIO_DIR%\NM_DAILY.SKM",
 MO=1-2, NAME=BIKEDIST, WALKDIST

  MW[1] = MI.1.4 + (%bikeSpeed3%/%bikeSpeed2%) * MI.1.5 + (%bikeSpeed3%/%bikeSpeed1%) * %bikeFact1% * MI.1.6
  MW[2] = MI.2.1  



ENDRUN


