; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.

ITER = 1
PREV_ITER = 0

READ FILE = %spc_modechoice%

LOOP TOD=1,11,1
 IF(TOD=1) PER='AM1' HPER='AM' TPER = 'PK'
 IF(TOD=2) PER='AM2' HPER='AM' TPER = 'PK' 
 IF(TOD=3) PER='AM3' HPER='AM' TPER = 'PK' 
 IF(TOD=4) PER='AM4' HPER='AM' TPER = 'PK'   
 IF(TOD=5) PER='MD'  HPER='MD' TPER = 'OP'
 IF(TOD=6) PER='PM1' HPER='PM' TPER = 'PK'  
 IF(TOD=7) PER='PM2' HPER='PM' TPER = 'PK' 
 IF(TOD=8) PER='PM3' HPER='PM' TPER = 'PK' 
 IF(TOD=9) PER='PM4' HPER='PM' TPER = 'PK'
 IF(TOD=10) PER='EV' HPER='NT' TPER = 'OP' 
 IF(TOD=11) PER='ON' HPER='NT' TPER = 'OP' ; End of PILOT Script

; Script for program MATRIX in file "C:\PROJECTS\TOURCAST\METCOUNCILCODEBASE\CUBE\CATALOG\CUBE\SGMAT00A.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Airport Mode Choice '
FILEO MATO[1] = "%SCENARIO_DIR%\HWY_SPC_TRIP_%ITER%_%PER%.tmp",
 MO=134-138, DEC=3,3,3,3,3, NAME= DA,SR2,SR3,XIT_WK, XIT_DR
FILEI MATI[4] = "%SCENARIO_DIR%\HWY_SPC_TRIP.trp"
FILEI MATI[3] = "%SCENARIO_DIR%\HWY_SKIM_%PREV_ITER%_%HPER%.skm"
FILEI MATI[2] = "%SCENARIO_DIR%\XIT_DR_SKIM_%PREV_ITER%_%TPER%.skm"
FILEI MATI[1] = "%SCENARIO_DIR%\XIT_WK_SKIM_%PREV_ITER%_%TPER%.SKM"


 MW[3]=MI.3.1     ; AUTO IVTT
  MW[4]=MI.3.5     ; AUTO DISTANCE
  MW[5]=MI.3.2	   ; AUTO TOLL
  
  MW[203]=MI.3.6     ; SR2 IVTT
  MW[204]=MI.3.10    ; SR2 DISTANCE
  MW[205]=MI.3.7	 ; SR2 TOLL
  
  MW[303]=MI.3.11    ; SR3 IVTT
  MW[304]=MI.3.15    ; SR3 DISTANCE
  MW[305]=MI.3.12	 ; SR3 TOLL
  
  
  MW[6]= MI.1.2+MI.1.3+MI.1.4+MI.1.5+MI.1.6    ; WALK ACCESS OVTT
  MW[9]= MI.1.1                                ; IVTT, WALK ACCESS
  MW[10]= MI.1.8                               ; WALK ACCESS FARE

  MW[26]= MI.2.2+MI.2.3+MI.2.4+MI.2.5+MI.2.6    ; AUTO ACCESS OVTT
  MW[29]= MI.2.1                                ; IVTT, DRIVE ACCESS
  MW[30]= MI.2.8                                ; DRIVE ACCESS FARE

JLOOP INCLUDE=1521
  MW[41]= %TTIME_AUTO%*%HWTCOEFF% + MW[3]*%HWTCOEFF%   + MW[4]*%AUTOCOST%*%DA_COST%          + MW[5]*%DA_COST%    + 20*%DA_COST%      +%C_DA%    ; DA UTILITY
  MW[51]= %TTIME_SR%*%HWTCOEFF%   + MW[203]*%HWTCOEFF% + MW[204]*%AUTOCOST%*0.5*%SR2_COST%   + MW[205]*%SR2_COST% + 20*0.5*%SR2_COST% +%C_SR2%   ; SR2 UTILITY
  MW[61]= %TTIME_SR%*%HWTCOEFF%   + MW[303]*%HWTCOEFF% + MW[304]*%AUTOCOST%*0.285*%SR3_COST% + MW[305]*%SR3_COST% + 20*%SR3_COST%/3.5 +%C_SR3%   ; SR3 UTILITY
ENDJLOOP

JLOOP INCLUDE=1521
    ; WalkTransit
    IF(MW[9][J]>0)
      MW[71]=2.5*MW[6]*%TCOEFF_WA%+MW[9]*%TCOEFF_WA%+MW[10]*%FARECOST%/100+%C_TR%   ; WALK ACCESS UTILITY
    ELSE
      MW[71]=-9999
    ENDIF
    ; DriveTransit
    IF (MW[29][J]>0)
      MW[91]=2.5*MW[26]*%TCOEFF_DA%+MW[29]*%TCOEFF_DA%+MW[30]*%FARECOST%/100+%C_TR%   ; DRIVE ACCESS UTILITY
    ELSE
      MW[91]=-9999
    ENDIF
ENDJLOOP

JLOOP INCLUDE=1521
    IF(MW[9][J]=0) MW[71]=-9999
ENDJLOOP

; DO EXPONENTIAL OF UTILITIES

MW[101] = EXP(MW[41])*100000   ; DA

MW[111] = EXP(MW[51])*100000   ; SR2

MW[121] = EXP(MW[61])*100000   ; SR3

MW[131] = EXP(MW[71])*100000   ; WALK ACCESSS

MW[151] = EXP(MW[91])*100000   ; DRIVE ACCESS

; SHARES
MW[171] = 100*MW[101]/(MW[101]+MW[111]+MW[121]+MW[131]+MW[151])           ; DA SHARE 
MW[172] = 100*MW[111]/(MW[101]+MW[111]+MW[121]+MW[131]+MW[151])           ; SR2 SHARE 
MW[173] = 100*MW[121]/(MW[101]+MW[111]+MW[121]+MW[131]+MW[151])           ; SR3 SHARE 
MW[174] = 100*MW[131]/(MW[101]+MW[111]+MW[121]+MW[131]+MW[151])           ; Walk Access Transit Share
MW[175] = 100*MW[151]/(MW[101]+MW[111]+MW[121]+MW[131]+MW[151])             ; Drive Access Transit Share

MW[197]=MI.4.%TOD% 

MW[134] = MW[171]*MW[197]/100                ;DA TRIPS 
MW[135] = MW[172]*MW[197]/100                ;SR2 TRIPS 
MW[136] = MW[173]*MW[197]/100                ;SR3+ 
MW[137] = MW[174]*MW[197]/100                ;WALK ACCESS TRANSIT TRIPS
MW[138] = MW[175]*MW[197]/100               ;DRIVE ACCESS TRANSIT TRIPS


ENDRUN


; Script for program MATRIX in file "C:\PROJECTS\TOURCAST\METCOUNCILCODEBASE\CUBE\CATALOG\CUBE\SGMAT00B.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Add return trips'
FILEO MATO[1] = "%SCENARIO_DIR%\HWY_SPC_TRIP_%ITER%_%PER%.trp",
 MO=1-5, DEC=3,3,3,3,3, NAME= DA,SR2,SR3,XIT_WK, XIT_DR
FILEI MATI[1] = "%SCENARIO_DIR%\HWY_SPC_TRIP_%ITER%_%PER%.tmp"
 
 MW[1] = MI.1.1 + MI.1.1.T
 MW[2] = MI.1.2 + MI.1.2.T
 MW[3] = MI.1.3 + MI.1.3.T
 MW[4] = MI.1.4 + MI.1.4  ; NOTE: Transit is assigned in PA format
 MW[5] = MI.1.5 + MI.1.5  ; NOTE: Transit is assigned in PA format


ENDRUN


; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.

ENDLOOP
; End of PILOT Script

