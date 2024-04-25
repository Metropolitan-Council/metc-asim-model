; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Generate Airport Trips'
FILEO RECO[1] = "%SCENARIO_DIR%\specialgen\HWY_SPC_PA.dbf",
 FIELDS=ORIG(8.0),DEST(8.0),TRIPS(10.2)
FILEI DBI[1] = "%zone_attribs%",
 SORT=ZONE

ZONES=1
 
LOOP k=1,DBI.1.NUMRECORDS
x=DBIReadRecord(1,k)
RO.ORIG=k
RO.DEST=1521
RO.TRIPS=DI.1.HOUSEHOLDS
WRITE RECO=1
ENDLOOP

ENDRUN
