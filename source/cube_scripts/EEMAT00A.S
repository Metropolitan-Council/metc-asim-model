; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Auto EI / IE Destination Choice'
FILEI DBI[2] = "%SCENARIO_DIR%\external\HWY_EXT.dbf"
FILEI MATI[1] = "%SCENARIO_DIR%\highway\HWY_SKIM_%PREV_ITER%_AM.skm"
FILEO MATO[2] = "%SCENARIO_DIR%\external\HWY_EXT_IETRIP_%ITER%.trp",
 MO=11-18, NAME=termTime,time,sizeVar, expU, prob, IE_DA, IE_S2, IE_S3
 
FILEO MATO[1] = "%SCENARIO_DIR%\external\HWY_EXT_EITRIP_%ITER%.trp",
 MO=1-8, NAME=termTime,time,sizeVar, expU, prob, EI_DA,	EI_S2,	EI_S3

FILEI DBI[1] = "%zone_attribs%"

 zones = %zones%
 
  ARRAY destTermT=%int_zones%, destSizeV=%int_zones%, destTrips=(%ext_zones%)
  ARRAY origTermT=%int_zones%, origSizeV=%int_zones%, origTrips=(%ext_zones%)
  
  
  ; read in vectors of zonal data  
  IF (I=1)
    LOOP k=1,%int_zones%
    
      x=DBIReadRecord(1,k)
      
      ; External to Internal (EI) - Destination Choice
      destTermT[k]=DI.1.CBD * 1.32
      destSizeV[k]= MAX(ln(DI.1.AREA + DI.1.TOT_EMP * 52.45),0)
      
      ; Internal to External (IE) - Origin Choice
      origTermT[k]=DI.1.CBD * -0.107 + DI.1.SUBURB2 * 0.489 + DI.1.RURAL * 1.65
      origSizeV[k]= MAX(ln(DI.1.AREA + DI.1.POPULATION * 23.81 + DI.1.TOT_EMP * 18.73),0)      
      
    ENDLOOP
  ENDIF
  
  ; Calculate utility function and probabilities for Extenal-Internal interchanges
  IF (I > %int_zones%)  
  
    ; prepare utility function
    JLOOP J=1,%int_zones%
      ; EI
      mw[1] = destTermT[J] 
      mw[2] = MI.1.1 * -0.116 + 0.00059 * MI.1.1 ^ 2 + -0.00000036 * MI.1.1 ^ 3 
      mw[3] = destSizeV[J]
      mw[4] = exp(mw[1] + mw[2]) * mw[3]

      ; IE
      mw[11] = origTermT[J] 
      mw[12] = MI.1.1 * -0.194 + 0.0020 * MI.1.1 ^ 2 + -0.0000073 * MI.1.1 ^ 3 
      mw[13] = origSizeV[J]
      mw[14] = exp(mw[11] + mw[12]) * mw[13]  
      
    ENDJLOOP  
    
    destRowsum = ROWSUM(4)
    origRowsum = ROWSUM(14)
    
    ; calculate probabilities and apply to EI / IE trips
     JLOOP J=1,%int_zones%
      mw[5] = (mw[4] * 100) / destRowsum   
      mw[15] = (mw[14] * 100) / origRowsum 
      
      ; Read in external trips
      x=DBIReadRecord(2,I - %int_zones%)
      
      mw[6] = mw[5] * DI.2.EI_DA / 2 / 100 
      mw[7] = mw[5] * DI.2.EI_S2 / 2 / 100 
      mw[8] = mw[5] * DI.2.EI_S3 / 2 / 100 
      
      mw[16] = mw[15] * DI.2.IE_DA / 2 / 100 
      mw[17] = mw[15] * DI.2.IE_S2 / 2 / 100 
      mw[18] = mw[15] * DI.2.IE_S3 / 2 / 100       

    ENDJLOOP     
    
    
    
    
  ENDIF 



ENDRUN
