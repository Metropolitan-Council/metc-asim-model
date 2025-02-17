; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK MSG='Set highway link speeds, capacities, and AB'
FILEI LOOKUPI[3] = "%LU_AlphaBeta%"
FILEI LOOKUPI[2] = "%LU_capacity%"
FILEI LOOKUPI[1] = "%LU_speed%"
FILEI LINKI[1] = "%SCENARIO_DIR%\highway\ALL_NET.tmp"
FILEO NETO = "%SCENARIO_DIR%\highway\ALL_NET.net"
 
;Length corrections
  ;DISTANCE = SHAPE_Length/1609.344 ; Adds distance to any new link that was not coded with a distance
/*
  LOOKUP LOOKUPI=1, NAME=Spd,
    LOOKUP[1]=1, RESULT=2,
    LOOKUP[2]=1, RESULT=3,
    LOOKUP[3]=1, RESULT=4,
    LOOKUP[4]=1, RESULT=5,
		LOOKUP[5]=1, RESULT=6,
		LOOKUP[6]=1, RESULT=7,
		LOOKUP[7]=1, RESULT=8,
		LOOKUP[8]=1, RESULT=9,
		LOOKUP[9]=1, RESULT=10,
		LOOKUP[10]=1, RESULT=11,
		LOOKUP[11]=1, RESULT=12,
		LOOKUP[12]=1, RESULT=13,
		LOOKUP[13]=1, RESULT=14,
		LOOKUP[14]=1, RESULT=15
    Speed = Spd(AREA,RCI)
		if(speed > 0) time=60*(distance/speed)

  LOOKUP LOOKUPI=2, NAME=Cap,
    LOOKUP[1]=1, RESULT=2,
    LOOKUP[2]=1, RESULT=3,
    LOOKUP[3]=1, RESULT=4,
    LOOKUP[4]=1, RESULT=5,
		LOOKUP[5]=1, RESULT=6,
		LOOKUP[6]=1, RESULT=7,
		LOOKUP[7]=1, RESULT=8,
		LOOKUP[8]=1, RESULT=9,
		LOOKUP[9]=1, RESULT=10,
		LOOKUP[10]=1, RESULT=11,
		LOOKUP[11]=1, RESULT=12,
		LOOKUP[12]=1, RESULT=13,
		LOOKUP[13]=1, RESULT=14,
		LOOKUP[14]=1, RESULT=15,
	  LOOKUP[15]=1, RESULT=16
    Capacity = Cap(AREA,RCI) * lanes
  */  
  LOOKUP LOOKUPI=3, NAME=AB,
    LOOKUP[1]=1, RESULT=2,
    LOOKUP[2]=1, RESULT=3,
    LOOKUP[3]=1, RESULT=4,
    LOOKUP[4]=1, RESULT=5,
		LOOKUP[5]=1, RESULT=6,
		LOOKUP[6]=1, RESULT=7,
		LOOKUP[7]=1, RESULT=8,
		LOOKUP[8]=1, RESULT=9,
		LOOKUP[9]=1, RESULT=10,
		LOOKUP[10]=1, RESULT=11,
		LOOKUP[11]=1, RESULT=12,
		LOOKUP[12]=1, RESULT=13,
		LOOKUP[13]=1, RESULT=14,
		LOOKUP[14]=1, RESULT=15,
	  LOOKUP[15]=1, RESULT=16
    ALPHA = AB(1,RCI)
    BETA = AB(2,RCI)


ENDRUN
