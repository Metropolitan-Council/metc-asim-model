; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='External Auto Allocation and Mode Choice'
FILEO PRINTO[2] = "%SCENARIO_DIR%\external\HWY_EXT_MARGINAL_TARGET.txt"
FILEO RECO[1] = "%SCENARIO_DIR%\external\HWY_EXT.dbf",
 FIELDS=ZONE,AUTOS,EE,EI_DA,EI_S2,EI_S3,IE_DA,IE_S2,IE_S3
FILEI LOOKUPI[1] = "%LU_external%"
FILEI DBI[1] = "%ext_sta%"

  zones=1
  
  _autos = 0
  _ee = 0
  _ei_da = 0
  _ei_s2 = 0
  _ei_s3 = 0
  _ie_da = 0
  _ie_s2 = 0
  _ie_s3 = 0  
  
  
  LOOKUP LOOKUPI=1, LIST=N,
  NAME=EXT, 
  LOOKUP[1]=1, RESULT=2, ; EE share
  LOOKUP[2]=1, RESULT=5, ; IE_DA share
  LOOKUP[3]=1, RESULT=6, ; IE_S2 share
  LOOKUP[4]=1, RESULT=7, ; IE_S3 share
  LOOKUP[5]=1, RESULT=8, ; EI_DA share  
  LOOKUP[6]=1, RESULT=9, ; EI_S2 share
  LOOKUP[7]=1, RESULT=10 ; EI_S3 share
  
  ;PRINT CSV=T, LIST='ZONE','AUTOS','EE','EI_DA','EI_S2','EI_S3','IE_DA','IE_S2','IE_S3' PRINTO=1

  
; loop through each external zone 
LOOP  k=1,DBI.1.NUMRECORDS
  
  x=DBIReadRecord(1,k)
  
  _autos = DI.1.AADT - DI.1.HCAADT
  
  ; write out externals for each zone
  RO.ZONE = DI.1.ZONE
  RO.AUTOS = _autos
  RO.EE =   _autos * EXT(1, DI.1.ZONE) / 100
  RO.EI_DA =  _autos * EXT(2, DI.1.ZONE) / 100
  RO.EI_S2 =  _autos * EXT(3, DI.1.ZONE) / 100
  RO.EI_S3 =  _autos * EXT(4, DI.1.ZONE) / 100
  RO.IE_DA =  _autos * EXT(5, DI.1.ZONE) / 100
  RO.IE_S2 =  _autos * EXT(6, DI.1.ZONE) / 100
  RO.IE_S3 =  _autos * EXT(7, DI.1.ZONE) / 100
  
  WRITE RECO=1
  
  ; write out external - externals too
  PRINT CSV=F, LIST=DI.1.ZONE, (RO.EE / 2), (RO.EE / 2) PRINTO=2

ENDLOOP

ENDRUN
