; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
*cluster transit 1-2 START EXIT
LOOP TOD=1,2,1



 IF(TOD=1) TPER='PK' ASSIGNNAME='Peak Period'  PER ='AM' 
 IF(TOD=2) TPER='OP' ASSIGNNAME='OffPeak Period'  PER ='MD' 



DISTRIBUTEMULTISTEP PROCESSID='transit' PROCESSNUM=@TOD@

RUN PGM=MATRIX MSG='@TPER@ Walk Skim - Step 2'
FILEO MATO[1] = "%SCENARIO_DIR%\XIT_WK_SKIM_%ITER%_@TPER@.SKM",
 MO=1-11, NAME=TRNTIME,WLKACC,WLKXFER,WLKEGR,IWAIT,XWAIT,XFERS,FARE,FAREP,FARER,FARES
FILEI MATI[1] = "%SCENARIO_DIR%\XIT_WK_SKIM_%ITER%_@TPER@.TMP"


MW[1]=MI.1.1 + MI.1.2 + MI.1.3 + MI.1.4 + MI.1.5 ; Bus, LB, Exp, LRT, CRT - IVT
MW[2]=MI.1.9      ;Walk access, Egress and Transfer Time
MW[3]=0           ; Zeroed out - do not have walk Xfer time seperate
MW[4]=0           ; Zeroed out - do not have walk Egress time seperate
MW[5]=MI.1.6      ; Inital Wait
MW[6]=MI.1.7      ; Transfer Wait
MW[7]=0
MW[8]=(MI.1.10+MI.1.11+MI.1.12)*100 ; Full Fare
MW[9]=(MI.1.10+MI.1.11+MI.1.12)*100*0.90; Reduced Fare (Pass Fare)
MW[10]=(MI.1.10+MI.1.11+MI.1.12)*100*0.90; Senior Fare (Seniors pay full fare in Peak)
MW[11]=(MI.1.10+MI.1.11+MI.1.12)*100*0.90*0.90; Student Fare
JLOOP
  IF (MI.1.8>0)
    MW[7]=MI.1.8-1    ; Transfers equals boards minus one  
  ENDIF
  IF ((I>1312 & I<1342) & (J>1312 & J<1342)) ; Downtown Minneapolis Zone
    MW[8]=50 * MI.1.8 ;Full Fare is $0.50 * boards
    MW[9]=50 * MI.1.8 ;Pass Fare is $0.50 * boards
    MW[10]=50 * MI.1.8;Senior Fare is $0.50 * boards
    MW[11]=50 * MI.1.8;Student Fare is $0.50 * boards
  ENDIF
  IF ((I>1999 & I<2022) & (J>1999 & J<2022)) ; Downtown St. Paul Zone
    MW[8]=50 * MI.1.8 ;Full Fare is $0.50 * boards
    MW[9]=50 * MI.1.8 ;Pass Fare is $0.50 * boards
    MW[10]=50 * MI.1.8;Senior Fare is $0.50 * boards
    MW[11]=50 * MI.1.8;Student Fare is $0.50 * boards
  ENDIF
ENDJLOOP


ENDRUN


ENDDISTRIBUTEMULTISTEP


ENDLOOP
Wait4Files FILES='transit1.script.end, transit2.script.end' CheckReturnCode=T, DelDistribFiles=T

*cluster transit 1-2 CLOSE EXIT
