; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK MSG='Export Bike Network from Geodatabase'
FILEO NETO = "%SCENARIO_DIR%\NM_NET.net"
FILEI LINKI[1] = "%SCENARIO_DIR%\ALL_NET.tmp"

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
