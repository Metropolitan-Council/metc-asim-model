; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Split trips by TOD'
FILEO PRINTO[1] = "%SCENARIO_DIR%\external\HWY_EXT_TRIP_PRN_%ITER%.prn"
FILEO MATO[11] = "%SCENARIO_DIR%\external\HWY_EXT_TRIP_%ITER%_ON.trp",
 MO=111-113, NAME=DA, SR2, SR3
FILEO MATO[10] = "%SCENARIO_DIR%\external\HWY_EXT_TRIP_%ITER%_EV.trp",
 MO=101-103, NAME=DA, SR2, SR3
FILEO MATO[9] = "%SCENARIO_DIR%\external\HWY_EXT_TRIP_%ITER%_PM4.trp",
 MO=91-93, NAME=DA, SR2, SR3
FILEO MATO[8] = "%SCENARIO_DIR%\external\HWY_EXT_TRIP_%ITER%_PM3.trp",
 MO=81-83, NAME=DA, SR2, SR3
FILEO MATO[7] = "%SCENARIO_DIR%\external\HWY_EXT_TRIP_%ITER%_PM2.trp",
 MO=71-73, NAME=DA, SR2, SR3
FILEO MATO[6] = "%SCENARIO_DIR%\external\HWY_EXT_TRIP_%ITER%_PM1.trp",
 MO=61-63, NAME=DA, SR2, SR3
FILEO MATO[5] = "%SCENARIO_DIR%\external\HWY_EXT_TRIP_%ITER%_MD.trp",
 MO=51-53, NAME=DA, SR2, SR3
FILEO MATO[4] = "%SCENARIO_DIR%\external\HWY_EXT_TRIP_%ITER%_AM4.trp",
 MO=41-43, NAME=DA, SR2, SR3
FILEO MATO[3] = "%SCENARIO_DIR%\external\HWY_EXT_TRIP_%ITER%_AM3.trp",
 MO=31-33, NAME=DA, SR2, SR3
FILEO MATO[2] = "%SCENARIO_DIR%\external\HWY_EXT_TRIP_%ITER%_AM2.trp",
 MO=21-23, NAME=DA, SR2, SR3
FILEI DBI[1] = "%SCENARIO_DIR%\external\HWY_TRIP_PRN_%ITER%.csv",
DELIMITER[1]=",",
 FIELDS=3
FILEO MATO[1] = "%SCENARIO_DIR%\external\HWY_EXT_TRIP_%ITER%_AM1.trp",
 MO=11-13, NAME=DA, SR2, SR3
FILEI MATI[1] = "%SCENARIO_DIR%\external\HWY_EXT_TRIP_%ITER%.trp"

  ; 
  ; Caculate TOD share based on TourCast outputs
  ;
  ARRAY share = 11
  
  IF(I==1)
    _total = 0

    ; First calculate total trips
    LOOP k=1,11
        x=DBIReadRecord(1,k)
        _total = _total + DI.1.FIELD1
        ;PRINT LIST=DI.1.FIELD1, k, _total PRINTO=1
    ENDLOOP
    
     ; Next calculate share per time period
    LOOP k=1,11
        x=DBIReadRecord(1,k)
        share[k] =  DI.1.FIELD1 / _total
        ;PRINT LIST=DI.1.FIELD1, k, _total, share[k] PRINTO=1
    ENDLOOP   
    
    ; Sum up external trips to check
    _totalExt = 0
    _am1Ext = 0 _am2Ext = 0 _am3Ext = 0 _am4Ext = 0 
    _mdExt = 0
    _pm1Ext = 0 _pm2Ext = 0 _pm3Ext = 0 _pm4Ext = 0 
    _evExt = 0 _ntExt = 0
        
  ENDIF
  
  ;
  ; Apply share to create TOD trip tables.
  ;
	MW[11] = MI.1.1 * share[1]	MW[12] = MI.1.2 * share[1]	MW[13] = MI.1.3 * share[1]
	MW[21] = MI.1.1 * share[2]	MW[22] = MI.1.2 * share[2]	MW[23] = MI.1.3 * share[2]
	MW[31] = MI.1.1 * share[3]	MW[32] = MI.1.2 * share[3]	MW[33] = MI.1.3 * share[3]
	MW[41] = MI.1.1 * share[4]	MW[42] = MI.1.2 * share[4]	MW[43] = MI.1.3 * share[4]
	MW[51] = MI.1.1 * share[5]	MW[52] = MI.1.2 * share[5]	MW[53] = MI.1.3 * share[5]
	MW[61] = MI.1.1 * share[6]	MW[62] = MI.1.2 * share[6]	MW[63] = MI.1.3 * share[6]  
	MW[71] = MI.1.1 * share[7]	MW[72] = MI.1.2 * share[7]	MW[73] = MI.1.3 * share[7]
	MW[81] = MI.1.1 * share[8]	MW[82] = MI.1.2 * share[8]	MW[83] = MI.1.3 * share[8]
	MW[91] = MI.1.1 * share[9]	MW[92] = MI.1.2 * share[9]	MW[93] = MI.1.3 * share[9]
	MW[101] = MI.1.1 * share[10]	MW[102] = MI.1.2 * share[10]	MW[103] = MI.1.3 * share[10]
	MW[111] = MI.1.1 * share[11]	MW[112] = MI.1.2 * share[11]	MW[113] = MI.1.3 * share[11]
  
  _am1Ext = ROWSUM(11) + ROWSUM(12) + ROWSUM(13)
  _am1Ext = ROWSUM(21) + ROWSUM(22) + ROWSUM(23)
  _am1Ext = ROWSUM(31) + ROWSUM(32) + ROWSUM(33)
  _am1Ext = ROWSUM(41) + ROWSUM(42) + ROWSUM(43)
  _am1Ext = ROWSUM(51) + ROWSUM(52) + ROWSUM(53)
  _am1Ext = ROWSUM(61) + ROWSUM(62) + ROWSUM(63)
  _am1Ext = ROWSUM(71) + ROWSUM(72) + ROWSUM(73)
  _am1Ext = ROWSUM(81) + ROWSUM(82) + ROWSUM(83)
  _am1Ext = ROWSUM(91) + ROWSUM(92) + ROWSUM(93)
  _am1Ext = ROWSUM(101) + ROWSUM(102) + ROWSUM(103)
  _am1Ext = ROWSUM(111) + ROWSUM(112) + ROWSUM(113)
  _am1Ext = ROWSUM(121) + ROWSUM(122) + ROWSUM(123)
  
  _totalExt = _am1Ext + _am2Ext + _am3Ext + _am4Ext + 
              _mdExt + _pm1Ext + _pm2Ext + _pm3Ext + _pm4Ext + _evExt + _ntExt
    
    IF (I = %zones%)
      PRINT CSV=T, LIST='Total, AM1, AM2, AM3, AM4, MD, PM1, PM2, PM3, PM4, EV, ON',PRINTO=1
      PRINT CSV=T, LIST=_totalExt,_am1Ext,_am2Ext,_am3Ext,_am4Ext,
              _mdExt,_pm1Ext,_pm2Ext,_pm3Ext,_pm4Ext,_evExt,_ntExt, PRINTO=1
      
    ENDIF
    
ENDRUN
