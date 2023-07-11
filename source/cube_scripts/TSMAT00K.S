; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Generate Airport Trips'
FILEO RECO[1] = "%SCENARIO_DIR%\HWY_SPC_PA.dbf",
 FIELDS=ORIG(8.0),DEST(8.0),TRIPS(10.2)
FILEI DBI[1] = "%zone_attribs%",
 SORT=ZONE

ZONES=1
 
LOOP k=1,DBI.1.NUMRECORDS
x=DBIReadRecord(1,k)
RO.ORIG=DBI.1.NFIELD[1]
RO.DEST=1521
RO.TRIPS=DBI.1.NFIELD[4]*0.0199
 
WRITE RECO=1
ENDLOOP

ENDRUN
