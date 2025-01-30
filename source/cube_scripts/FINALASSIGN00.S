ConvergeCheck=-1
FinalAssign=-1
; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.

if (ITER == 1)
  ConvergeBranch = 1
else
  ConvergeBranch = 2
endif
; End of PILOT Script

If (ConvergeCheck=2)
  goto ConvergeCheck_2
Elseif (ConvergeCheck=1)
  goto ConvergeCheck_1
Else
  PRINT LIST='Application Error: No Branch Selected from Branch Control "ConvergeCheck"'
  ABORT
Endif

:ConvergeCheck_2
; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
;ITER = 2
PREV_ITER = ITER - 1
;PER='NT' 

LOOP TOD=1,1,1
 IF(TOD=1) PER='NT' 
 IF(TOD=2) PER='AM' 
 IF(TOD=3) PER='MD' 
 IF(TOD=4) PER='PM' 
 
 
; End of PILOT Script

; Script for program NETWORK in file "D:\TourCast\CATALOG\CUBE\CCNET00D.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK MSG='Unbuild network'
FILEO LINKO = "%SCENARIO_DIR%\%ITER%_%PER%_LDLINK.dbf"
FILEI LINKI[1] = "%SCENARIO_DIR%\%ITER%_%PER%_LDNET.net"


ENDRUN


; Script for program MATRIX in file "D:\TourCast\CATALOG\CUBE\CCMAT00A.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Calculate convergence stats'
FILEO PRINTO[1] = "%SCENARIO_DIR%\%ITER%_%PER%_converge.txt"
FILEI DBI[2] = "%SCENARIO_DIR%\%PREV_ITER%_%PER%_LDLINK.dbf",
 SORT=A,B JOINTODBI=1 JOINTOFIELDS=A,B
FILEI DBI[1] = "%SCENARIO_DIR%\%ITER%_%PER%_LDLINK.dbf",
 SORT=A,B 

  zones = 1
  
  _totLinks = 0
  _chgLinks = 0
  _prevVMT = 0
  _curVMT = 0
  _sumSE = 0
  
 ; First loop through each records and calculate differences
 LOOP k=1,DBI.1.NUMRECORDS
  
  x=DBIReadRecord(1,k)
  IF(DI.2.V_1 > 0 & DI.1.V_1 > 0)
    _totLinks = _totLinks + 1
  
    IF (((DI.2.V_1 - DI.1.V_1) / DI.1.V_1) > (%conv_LinkVol%/100))
    
      _chgLinks = _chgLinks + 1
      
    ENDIF
    
    _prevVMT = _prevVMT + DI.2.V_1*DI.2.DISTANCE
    _curVMT  = _curVMT  + DI.1.V_1*DI.1.DISTANCE
    _sumSE   = _sumSE   + ((DI.2.V_1 - DI.1.V_1)*DI.2.DISTANCE)^2

  ENDIF
  
 ENDLOOP

 ; Next, calculate overall PRMSE 
 _MSE = _sumSE / _totLinks
 _PRMSE = 100*SQRT(_MSE)/(_curVMT/_totLinks)
 _errLinks = (_chgLinks / _totLinks) * 100
 
 LOG PREFIX=%PER%, VAR=_errLinks
 LOG VAR = _errLinks
 
 PRINT CSV=F LIST='Convergence check for period %PER% iteration ITER' PRINTO=1 
 PRINT CSV=F LIST='Previous %PER% VMT was ', _prevVMT PRINTO=1
 PRINT CSV=F LIST='Current %PER% VMT is ', _curVMT PRINTO=1
 PRINT CSV=F LIST='The percent of %PER% link volumes within ', %conv_LinkVol%, '% is ', _errLinks, '%' PRINTO=1
 PRINT CSV=F LIST='%PER% PRMSE is ', _PRMSE, '%' PRINTO=1

ENDRUN


; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.

*echo  >> "%SCENARIO_DIR%\converge.txt"
*type "%SCENARIO_DIR%\%ITER%_%PER%_converge.txt" >> "%SCENARIO_DIR%\converge.txt"
*echo  >> "%SCENARIO_DIR%\converge.txt"

endloop

; check if converged

if ((NT._ERRLINKS > %conv_LinkPerc%) |
    (MD._ERRLINKS > %conv_LinkPerc%) |
    (AM._ERRLINKS > %conv_LinkPerc%) |
    (PM._ERRLINKS > %conv_LinkPerc%))
    
  *echo 'Iteration %ITER% Not Converged' >> "%SCENARIO_DIR%\converge.txt"
  
else
 
  *echo 'Iteration %ITER% Converged!' >> "%SCENARIO_DIR%\converge.txt"
  
   CONV = 1
   LOG PREFIX=CONVCHECK, VAR=CONV
   
endif
; End of PILOT Script

goto ConvergeCheck_END

:ConvergeCheck_1
; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.


;ITER = 1
;PER='NT' 
; End of PILOT Script

; Script for program NETWORK in file "D:\TourCast\CATALOG\CUBE\IINET00C.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK MSG='Unbuild network'
FILEO LINKO = "%SCENARIO_DIR%\%ITER%_%PER%_LDLINK.DBF"
FILEI LINKI[1] = "%SCENARIO_DIR%\%ITER%_%PER%_LDNET.NET"


ENDRUN


goto ConvergeCheck_END

:ConvergeCheck_END
; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.

if(CONVCHECK.CONV ==1)
  FinalAssign = 2
else
  FinalAssign = 1
endif
; End of PILOT Script

If (FinalAssign=2)
  goto FinalAssign_2
Elseif (FinalAssign=1)
  goto FinalAssign_1
Else
  PRINT LIST='Application Error: No Branch Selected from Branch Control "FinalAssign"'
  ABORT
Endif

:FinalAssign_2
; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.

;NEXTITER = ITER + 1

LOOP TOD=1,11,1
 IF(TOD=1) PER='NT' ASSIGNNAME='Overnight Period'  HNET ='HNET_1.net'    NETNAME='Overnight 12:00 AM to 6:00 AM'  CAPFAC = 2.5
 
 IF(TOD=2) PER='AM1' ASSIGNNAME='AM1 Peak Period'    HNET ='HNET_3.net'    NETNAME='AM Peak Period 6:00 AM to 7:00 AM'  CAPFAC = 1
 IF(TOD=3) PER='AM2' ASSIGNNAME='AM2 Peak Period'    HNET ='HNET_3.net'    NETNAME='AM Peak Period 7:00 AM to 8:00 AM'  CAPFAC = 1 
 IF(TOD=4) PER='AM3' ASSIGNNAME='AM3 Peak Period'    HNET ='HNET_3.net'    NETNAME='AM Peak Period 8:00 AM to 9:00 AM'  CAPFAC = 1
 IF(TOD=5) PER='AM4' ASSIGNNAME='AM4 Peak Period'    HNET ='HNET_3.net'    NETNAME='AM Peak Period 9:00 AM to 10:00 AM'  CAPFAC = 1 
  
 IF(TOD=6) PER='MD' ASSIGNNAME='Mid Day Period'    HNET ='HNET_4.net'    NETNAME='Mid Day Period 10:00 AM to 3:00 PM'  CAPFAC = 2.5

 IF(TOD=7) PER='PM1' ASSIGNNAME='PM1 Peak Period'    HNET ='HNET_6.net'    NETNAME='PM Peak Period 3:00 PM to 4:00 PM'  CAPFAC = 1
 IF(TOD=8) PER='PM2' ASSIGNNAME='PM2 Peak Period'    HNET ='HNET_6.net'    NETNAME='PM Peak Period 4:00 PM to 5:00 PM'  CAPFAC = 1
 IF(TOD=9) PER='PM3' ASSIGNNAME='PM3 Peak Period'    HNET ='HNET_6.net'    NETNAME='PM Peak Period 5:00 PM to 6:00 PM'  CAPFAC = 1 
 IF(TOD=10) PER='PM4' ASSIGNNAME='PM4 Peak Period'    HNET ='HNET_6.net'    NETNAME='PM Peak Period 6:00 PM to 7:00 PM'  CAPFAC = 1

 IF(TOD=11) PER='EV' ASSIGNNAME='Evening Period'  HNET ='HNET_1.net'    NETNAME='Evening 7:00 PM to 12:00 AM'  CAPFAC = 2.5 
 
;*Cluster 'Intrastep' 1-%NUMBER_OF_PROCESSORS% START EXIT

; End of PILOT Script

; Script for program MATRIX in file "D:\TourCast\CATALOG\CUBE\HTMAT00B.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Convert to Vehicle Trip Tables %ASSIGNNAME%'
; DISTRIBUTEINTRASTEP ProcessID="Intrastep", ProcessList=1-%NUMBER_OF_PROCESSORS%
FILEO MATO[1] = "%SCENARIO_DIR%\%ITER%_%PER%_AUTO.TRP",
                 MO=1-32, DEC[1]=30*2, NAME = SOVW1, SOVW2, SOVW3, SOVW4, SOVW5,  HOV2W1, HOV2W2, HOV2W3, HOV2W4, HOV2W5,  HOV3W1, HOV3W2, HOV3W3, HOV3W4, HOV3W5,
                                              SOVNW1,SOVNW2,SOVNW3,SOVNW4,SOVNW5, HOV2NW1,HOV2NW2,HOV2NW3,HOV2NW4,HOV2NW5, HOV3NW1,HOV3NW2,HOV3NW3,HOV3NW4,HOV3NW5,SOVNO1,SOVNO25
FILEI MATI[1] = "%SCENARIO_DIR%\%ITER%_%PER%_HWY.TRP"

          MW[1] = MI.1.1
          MW[2] = MI.1.2
          MW[3] = MI.1.3
          MW[4] = MI.1.4
          MW[5] = MI.1.5
          MW[6] = MI.1.6/%hwy_HOV2OCC%
          MW[7] = MI.1.7/%hwy_HOV2OCC%
          MW[8] = MI.1.8/%hwy_HOV2OCC%
          MW[9] = MI.1.9/%hwy_HOV2OCC%
          MW[10]= MI.1.10/%hwy_HOV2OCC%
          MW[11]= MI.1.11/%hwy_HOV3OCC%
          MW[12]= MI.1.12/%hwy_HOV3OCC%
          MW[13]= MI.1.13/%hwy_HOV3OCC%
          MW[14]= MI.1.14/%hwy_HOV3OCC%
          MW[15]= MI.1.15/%hwy_HOV3OCC%
          MW[16]= MI.1.16
          MW[17]= MI.1.17
          MW[18]= MI.1.18
          MW[19]= MI.1.19
          MW[20]= MI.1.20
          MW[21]= MI.1.21/%hwy_HOV2OCC%
          MW[22]= MI.1.22/%hwy_HOV2OCC%
          MW[23]= MI.1.23/%hwy_HOV2OCC%
          MW[24]= MI.1.24/%hwy_HOV2OCC%
          MW[25]= MI.1.25/%hwy_HOV2OCC%
          MW[26]= MI.1.26/%hwy_HOV3OCC%
          MW[27]= MI.1.27/%hwy_HOV3OCC%
          MW[28]= MI.1.28/%hwy_HOV3OCC%
          MW[29]= MI.1.29/%hwy_HOV3OCC%
          MW[30]= MI.1.30/%hwy_HOV3OCC%
          MW[31]= MI.1.31
          MW[32]= MI.1.32

ENDRUN


; Script for program MATRIX in file "D:\TourCast\CATALOG\CUBE\HTMAT00D.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='TEMP: truck trip tables'
FILEO MATO[1] = "%SCENARIO_DIR%\%ITER%_%PER%_TRK.TRP",
                 MO=1, DEC[1]=5*2, NAME = Truck
FILEI MATI[1] = "%SCENARIO_DIR%\%ITER%_%PER%_HWY.TRP"

          MW[1] = MI.1.1 ; *****DUMMY******
          
ENDRUN


; Script for program HIGHWAY in file "D:\TourCast\CATALOG\CUBE\HTHWY00B.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=HIGHWAY MSG='Assignment Period: %ASSIGNNAME%'
FILEO PRINTO[1] = "%SCENARIO_DIR%\%ITER%_%PER%_VOL.TXT"
;DISTRIBUTEINTRASTEP ProcessID="Intrastep", ProcessList=1-%NUMBER_OF_PROCESSORS%
FILEO MATO[1] = "%SCENARIO_DIR%\%ITER%_%PER%_HWY.MAT",
                 MO=1-120, DEC[1]=5*120, COMBINE=T
FILEO NETO = "%SCENARIO_DIR%\%ITER%_%PER%_LDNET.NET"
FILEI NETI = "%SCENARIO_DIR%\%HNET%"
FILEI LOOKUPI[1] = "%LU_WILL2PAY%"
FILEI MATI[2] = "%SCENARIO_DIR%\%ITER%_%PER%_TRK.TRP"
FILEI MATI[1] = "%SCENARIO_DIR%\%ITER%_%PER%_AUTO.TRP"


 ; **********   Define Assignment Parameters    ************
    
    PARAMETERS raad=0 gap = 0.0001 MAXITERS = %hwy_assignIter,EditBox-INTEGER,"","20"% COMBINE=EQUI
    FUNCTION TC[1] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    FUNCTION TC[2] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    FUNCTION TC[3] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    FUNCTION TC[4] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    FUNCTION TC[5] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    FUNCTION TC[6] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    FUNCTION TC[7] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    FUNCTION TC[8] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    FUNCTION TC[9] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    FUNCTION TC[10] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    FUNCTION TC[11] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    FUNCTION TC[12] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    FUNCTION TC[13] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    FUNCTION TC[14] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    FUNCTION TC[15] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    FUNCTION TC[99] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167)    

   FUNCTION V=VOL[1] + VOL[2] + VOL[3] + VOL[4] + VOL[5] + VOL[6] + VOL[7] + VOL[8] + VOL[9] + VOL[10] + VOL[11] + VOL[12] + VOL[13]*%hwy_TrkFac%

    LOOKUP NAME=TOLL, 
           LOOKUP[1]=1, RESULT=2,
           INTERPOLATE=Y,
           FAIL=25,800,
           R = '0.00 25',                  ; LOS-Toll table reported by MnDOT
               '0.35 50',
               '0.54 150',
               '0.77 250',
               '0.93 350',
               '1.00 600'
    LOOKUP LOOKUPI=1,INTERPOLATE=Y, FAIL = 5,100,
    NAME=DIVERT,
           LOOKUP[1]=1, RESULT=2,
           LOOKUP[2]=1, RESULT=3,
           LOOKUP[3]=1, RESULT=4,
           LOOKUP[4]=1, RESULT=5,
           LOOKUP[5]=1, RESULT=6,
           LOOKUP[6]=1, RESULT=7,
           LOOKUP[7]=1, RESULT=8,
           LOOKUP[8]=1, RESULT=9,
           LOOKUP[9]=1, RESULT=10,
           LOOKUP[10]=1,RESULT=11
           
    PHASE=LINKREAD

        T0      = LI.TIME
        IF (LI.CAPACITY=0)
            T0  = 99999
        ENDIF
        LW.HOV  = LI.HOV
        C       = LI.CAPACITY * %CAPFAC%
        Alpha   = LI.Alpha
        Beta    = LI.Beta
        LINKCLASS = LI.RCI


; **********   Create Link Groups    ************
; Group 1: All HOV Lanes
        IF (LI.HOV>0 && LI.HOV<99) ADDTOGROUP=30  ;Used as exclusion group on path building

; Group 2: HOV SECTIONS
        IF (LI.HOV=1,7,9)   ADDTOGROUP=1  ;I-35W	NB	STH-13 to I-494, I-494 to 48th St., and 48th St	to Downtown	Inbound
        IF (LI.HOV=2,8)     ADDTOGROUP=2  ;I-35W	SB	I-494	to STH-13, and 48th St to I-494	Outbound
        IF (LI.HOV=3,6,10)  ADDTOGROUP=3  ;I-394	WB/EB	Reversable Lane Ramp, I-94	to STH-100, and EB	Reversable Lane Ramp
        IF (LI.HOV=4)       ADDTOGROUP=4  ;I-394	WB	STH-100	I-494 Outbound
        IF (LI.HOV=5)       ADDTOGROUP=5  ;I-394	EB	I-494	STH-100	Inbound
        
        _toll1 = 25
        _toll2 = 25
        _toll3 = 25
        _toll4 = 25
        _toll5 = 25
   
    ENDPHASE 

    PHASE=ILOOP           

      MW[1] = MI.1.1    MW[2] = MI.1.2    MW[3] = MI.1.3    MW[4] = MI.1.4    MW[5] = MI.1.5 ; SOV Work
      MW[6] = MI.1.6    MW[7] = MI.1.7    MW[8] = MI.1.8    MW[9] = MI.1.9    MW[10]= MI.1.10 ; HOV2 Work
      MW[11]= MI.1.11   MW[12]= MI.1.12   MW[13]= MI.1.13   MW[14]= MI.1.14   MW[15]= MI.1.15 ; HOV3 Work
      MW[16]= MI.1.16   MW[17]= MI.1.17   MW[18]= MI.1.18   MW[19]= MI.1.19   MW[20]= MI.1.20 ; SOV NON Work
      MW[21]= MI.1.21   MW[22]= MI.1.22   MW[23]= MI.1.23   MW[24]= MI.1.24   MW[25]= MI.1.25 ; SOV NON Work
      MW[26]= MI.1.26   MW[27]= MI.1.27   MW[28]= MI.1.28   MW[29]= MI.1.29   MW[30]= MI.1.30 ; SOV NON Work
      MW[119] = MI.1.31    MW[120] = MI.1.32    ; SOVInc1, SOVInc25 - No Transponder

    ; *** SKIMS ***
      ; Build SOV Truck Paths
      PATHLOAD PATH=TIME,                 
                EXCLUDEGRP=30,
                MW[31]=PATHCOST, MW[39]=PATHTRACE(LI.DISTANCE)
          
      ; Build HOV Paths 
       PATHLOAD PATH=TIME,                 
                MW[32]=PATHCOST, MW[40]=PATHTRACE(LI.DISTANCE)

      ; Build Unconstrained Paths That Use Any Lanes
       PATHLOAD PATH=TIME,
                MW[33] =PATHCOST,
                MW[81]=_toll1, selectgroup=1,
                MW[82]=_toll2, selectgroup=2,
                MW[83]=_toll3, selectgroup=3,
                MW[84]=_toll4, selectgroup=4,
                MW[85]=_toll5, selectgroup=5

    ; *** SOV Toll and Revenue Calculations ***
      ; Sum of tolls charged on each O-D path
        _HOV2PAY = 0
        _HOV3PAY = 0
        IF (%hwy_TollSetting%=2)
          _HOV2PAY = 1
        ENDIF
        IF (%hwy_TollSetting%=3)
          _HOV2PAY = 1
          _HOV3PAY = 1          
        ENDIF             
      
       MW[35] =  MW[81]+MW[82]+MW[83]+MW[84]+MW[85]
      ; Non-Pay Time - Pay Time
       MW[34] =  MW[31]-MW[33]
      ; Calculate %Diversion and Revenue
       JLOOP
        IF (I==J)
         MW[37] = 0 ; Percent willing to pay
        ELSE
         IF (MW[34]>0) ; If HOT Lanes save time
          MW[36] = MW[35]/MW[34]                                     ; SOV toll cost (cents) per minute saved (Toll/Time Saved)
          MW[37] = (MW[35]/%hwy_HOV2OCC%)/MW[34]*_HOV2PAY               ; HOV2 toll cost (cents) per minute saved (Toll/Time Saved)
          MW[38] = (MW[35]/%hwy_HOV3OCC%)/MW[34]*_HOV3PAY               ; HOV3 toll cost (cents) per minute saved (Toll/Time Saved)
          
          MW[41] = MW[1] * DIVERT(1,MW[36])/100     ; SOVW1 willing to pay at this level
          MW[42] = MW[2] * DIVERT(2,MW[36])/100     ; SOVW2 willing to pay at this level
          MW[43] = MW[3] * DIVERT(3,MW[36])/100     ; SOVW3 willing to pay at this level
          MW[44] = MW[4] * DIVERT(4,MW[36])/100     ; SOVW4 willing to pay at this level
          MW[45] = MW[5] * DIVERT(5,MW[36])/100     ; SOVW5 willing to pay at this level
          
          MW[46] = MW[6] * DIVERT(1,MW[37])/100     ; HOV2W1 willing to pay at this level
          MW[47] = MW[7] * DIVERT(2,MW[37])/100     ; HOV2W2 willing to pay at this level
          MW[48] = MW[8] * DIVERT(3,MW[37])/100     ; HOV2W3 willing to pay at this level
          MW[49] = MW[9] * DIVERT(4,MW[37])/100     ; HOV2W4 willing to pay at this level
          MW[50] = MW[10]* DIVERT(5,MW[37])/100     ; HOV2W5 willing to pay at this level
          
          MW[51] = MW[11]* DIVERT(1,MW[38])/100     ; HOV3W1 willing to pay at this level
          MW[52] = MW[12]* DIVERT(2,MW[38])/100     ; HOV3W2 willing to pay at this level
          MW[53] = MW[13]* DIVERT(3,MW[38])/100     ; HOV3W3 willing to pay at this level
          MW[54] = MW[14]* DIVERT(4,MW[38])/100     ; HOV3W4 willing to pay at this level
          MW[55] = MW[15]* DIVERT(5,MW[38])/100     ; HOV3W5 willing to pay at this level          
          
          MW[56] = MW[16]* DIVERT(6,MW[36])/100     ; SOVNW1 willing to pay at this level
          MW[57] = MW[17]* DIVERT(7,MW[36])/100     ; SOVNW2 willing to pay at this level
          MW[58] = MW[18]* DIVERT(8,MW[36])/100     ; SOVNW3 willing to pay at this level
          MW[59] = MW[19]* DIVERT(9,MW[36])/100     ; SOVNW4 willing to pay at this level
          MW[60] = MW[20]* DIVERT(10,MW[36])/100    ; SOVNW5 willing to pay at this level          

          MW[61] = MW[21]* DIVERT(6,MW[37])/100     ; HOV2NW1 willing to pay at this level
          MW[62] = MW[22]* DIVERT(7,MW[37])/100     ; HOV2NW2 willing to pay at this level
          MW[63] = MW[23]* DIVERT(8,MW[37])/100     ; HOV2NW3 willing to pay at this level
          MW[64] = MW[24]* DIVERT(9,MW[37])/100     ; HOV2NW4 willing to pay at this level
          MW[65] = MW[25]* DIVERT(10,MW[37])/100    ; HOV2NW5 willing to pay at this level          
          
          MW[66] = MW[26]* DIVERT(6,MW[38])/100     ; HOV3NW1 willing to pay at this level
          MW[67] = MW[27]* DIVERT(7,MW[38])/100     ; HOV3NW2 willing to pay at this level
          MW[68] = MW[28]* DIVERT(8,MW[38])/100     ; HOV3NW3 willing to pay at this level
          MW[69] = MW[29]* DIVERT(9,MW[38])/100     ; HOV3NW4 willing to pay at this level
          MW[70] = MW[30]* DIVERT(10,MW[38])/100    ; HOV3NW5 willing to pay at this level          
         
         ELSE
          MW[36]  = 0                         ; SOV toll cost (cents) per minute saved (Toll/Time Saved)
          MW[37]  = 0                         ; HOV2 toll cost (cents) per minute saved (Toll/Time Saved)
          MW[38]  = 0                         ; HOV3 toll cost (cents) per minute saved (Toll/Time Saved)


          MW[41] = 0
          MW[42] = 0
          MW[43] = 0
          MW[44] = 0
          MW[45] = 0
          
          MW[46] = 0
          MW[47] = 0
          MW[48] = 0
          MW[49] = 0
          MW[50] = 0
          
          MW[51] = 0
          MW[52] = 0
          MW[53] = 0
          MW[54] = 0
          MW[55] = 0
          
          MW[56] = 0
          MW[57] = 0
          MW[58] = 0
          MW[59] = 0
          MW[60] = 0

          MW[61] = 0
          MW[62] = 0
          MW[63] = 0
          MW[64] = 0
          MW[65] = 0
          
          MW[66] = 0
          MW[67] = 0
          MW[68] = 0
          MW[69] = 0
          MW[70] = 0
         ENDIF
        ENDIF
 
        ;Paying trips
          MW[71] = MW[41] + MW[46]*_HOV2PAY + MW[51]*_HOV3PAY                ; WORK INC 1 WILL PAY
          MW[72] = MW[42] + MW[47]*_HOV2PAY + MW[52]*_HOV3PAY                ; WORK INC 2 WILL PAY
          MW[73] = MW[43] + MW[48]*_HOV2PAY + MW[53]*_HOV3PAY                ; WORK INC 3 WILL PAY
          MW[74] = MW[44] + MW[49]*_HOV2PAY + MW[54]*_HOV3PAY                ; WORK INC 4 WILL PAY
          MW[75] = MW[45] + MW[50]*_HOV2PAY + MW[55]*_HOV3PAY                ; WORK INC 5 WILL PAY
          MW[76] = MW[56] + MW[61]*_HOV2PAY + MW[66]*_HOV3PAY                ; NON WORK INC 1 WILL PAY
          MW[77] = MW[57] + MW[62]*_HOV2PAY + MW[67]*_HOV3PAY                ; NON WORK INC 2 WILL PAY
          MW[78] = MW[58] + MW[63]*_HOV2PAY + MW[68]*_HOV3PAY                ; NON WORK INC 3 WILL PAY
          MW[79] = MW[59] + MW[64]*_HOV2PAY + MW[69]*_HOV3PAY                ; NON WORK INC 4 WILL PAY
          MW[80] = MW[60] + MW[65]*_HOV2PAY + MW[70]*_HOV3PAY                ; NON WORK INC 5 WILL PAY
          
        ;Income Groups 2-5
          MW[101] = MW[2] + MW[3] + MW[4] + MW[5] + MW[17] + MW[18] + MW[19] + MW[20] - MW[42] - MW[43] - MW[44] - MW[45] - MW[57] - MW[58] - MW[59] - MW[60] ; SOV INC25 Will NotPay
          MW[102] = MW[7] + MW[8] + MW[9] + MW[10]+ MW[22] + MW[23] + MW[24] + MW[25] - MW[47] - MW[48] - MW[49] - MW[50] - MW[62] - MW[63] - MW[64] - MW[65] ; HOV2 INC25 Will NotPay
          MW[103] = MW[12]+ MW[13]+ MW[14]+ MW[15] +MW[27] + MW[28] + MW[29] + MW[30] - MW[52] - MW[53] - MW[54] - MW[55] - MW[67] - MW[68] - MW[69] - MW[70] ; HOV3 INC25 Will NotPay
          MW[104] = MW[42] + MW[43] + MW[44] + MW[45] + MW[57] + MW[58] + MW[59] + MW[60] ; SOV  INC25 Will Pay
          MW[105] = MW[47] + MW[48] + MW[49] + MW[50] + MW[62] + MW[63] + MW[64] + MW[65] ; HOV2 INC25 Will Pay
          MW[106] = MW[52] + MW[53] + MW[54] + MW[55] + MW[67] + MW[68] + MW[69] + MW[70] ; HOV3 INC25 Will Pay
        ;Income Group 1
          MW[111] = MW[1] + MW[16] - MW[41] - MW[56] ; SOV  INC1 Will NotPay
          MW[112] = MW[6] + MW[21] - MW[46] - MW[61] ; HOV2 INC1 Will NotPay
          MW[113] = MW[11]+ MW[21] - MW[51] - MW[66] ; HOV3 INC1 Will NotPay
          MW[114] = MW[41]+ MW[56]                   ; SOV  INC1 Will Pay
          MW[115] = MW[46]+ MW[61]                   ; HOV2 INC1 Will Pay
          MW[116] = MW[51]+ MW[66]                   ; HOV3 INC1 Will Pay

        ; Revenue from Paying Vehicles based on "average" toll (average from one assignment to the next)
          MW[90] = MW[35] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80])   ; TOTAL revenue (Willing to Pay * Toll)
          MW[91] = MW[81] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80])   ; toll1 revenue
          MW[92] = MW[82] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80])   ; toll2 revenue
          MW[93] = MW[83] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80])   ; toll3 revenue
          MW[94] = MW[84] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80])   ; toll4 revenue
          MW[95] = MW[85] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80])   ; toll5 revenue
        
       ENDJLOOP
 
    ; *** ASSIGNMENT: LOAD VEHICLES ***

;  The following classes are used in the 7-class assignment:
;INCOME         2-5      2-5      2-5      2-5     2-5      2-5      1        1       1        1         1         1
;PAY OR NO      NO       NO       NO       PAY     PAY      PAY      NO       NO      NO       PAY       PAY       PAY
;OCCUPANCY      SOV      HOV2     HOV3     SOV     SOV2     HOV3     SOV      HOV2    HOV3     SOV       HOV2      HOV3     
   ;FUNCTION V=VOL[1] + VOL[2] + VOL[3] + VOL[4]  VOL[5] + VOL[6] + VOL[7] + VOL[8] +VOL[9] + VOL[10] + VOL[11] + VOL[12] + VOL[13]
   
       ; INCOME GROUPS 2-5
       ; SOV-No MNPASS
       ; Exclude SOV from HOT lanes
       PATHLOAD PATH=TIME, 
                EXCLUDEGRP=30,
                VOL[1]=MW[101] + MW[120]; SOV  INC2-5 NO MNPASS
       ; HOV2-No MNPASS              
       PATHLOAD PATH=TIME,
                EXCLUDEGRP=30,
                VOL[2]=MW[102]; HOV2  INC2-5 NO MNPASS
       ; HOV3-No MNPASS             
       PATHLOAD PATH=TIME,
                EXCLUDEGRP=30,
                VOL[3]=MW[103]; HOV3  INC2-5 NO MNPASS
                
       ; SOV-MNPASS
       ; Build Paths That Use Peak HOT Lanes
       PATHLOAD PATH=TIME, 
                VOL[4]=MW[104]; SOV  INC2-5 MNPASS
       ; HOV2-MNPASS
       PATHLOAD PATH=TIME,
                VOL[5]=MW[105]; HOV2  INC2-5 MNPASS
       ; HOV3-MNPASS                
       PATHLOAD PATH=TIME,
                VOL[6]=MW[106]; HOV3  INC2-5 MNPASS

       ; INCOME GROUP 1
       ; SOV-No MNPASS
       ; Exclude SOV from HOT lanes
       PATHLOAD PATH=TIME, 
                EXCLUDEGRP=30,
                VOL[7]=MW[111] + MW[119]; SOV  INC1 NO MNPASS
       ; HOV2-No MNPASS              
       PATHLOAD PATH=TIME,
                EXCLUDEGRP=30,
                VOL[8]=MW[112]; HOV2  INC1 NO MNPASS
       ; HOV3-No MNPASS             
       PATHLOAD PATH=TIME,
                EXCLUDEGRP=30,
                VOL[9]=MW[113]; HOV3  INC1 NO MNPASS
                
       ; SOV-MNPASS
       ; Build Paths That Use Peak HOT Lanes
       PATHLOAD PATH=TIME, 
                VOL[10]=MW[114]; SOV  INC1 MNPASS
       ; HOV2-MNPASS
       PATHLOAD PATH=TIME,
                VOL[11]=MW[115]; HOV2  INC1 MNPASS
       ; HOV3-MNPASS                
       PATHLOAD PATH=TIME,
                VOL[12]=MW[116]; HOV3  INC1 MNPASS
                
       ; Truck
       ; Exclude Trucks from HOT lanes
       PATHLOAD PATH=TIME, 
                EXCLUDEGRP=30,
                VOL[13]=MI.2.1               ; Trucks  *****TEST TABLE********

    ENDPHASE
    PHASE=ADJUST
         IF (LINKNO=1)
          _maxVC1 = 0
          _maxVC2 = 0
          _maxVC3 = 0
          _maxVC4 = 0
          _maxVC5 = 0
          IF (Iteration =1)
            PRINT CSV=T LIST='Iteration,ANode,BNode,HOV,Volume,VC,TIME,DISTANCE, VHT, VMT, Toll1, Toll2, Toll3, Toll4, Toll5' PRINTO=1          
          ENDIF
         ENDIF

; *** COMPUTE MAXIMUM V/C RATIO AND TOLL RATES FOR NEXT ITERATION ON TOLLED SEGMENTS ***
;HOT Lanes
        IF (LW.HOV=1,7,9 & C>0)
          IF ((V/C) > _maxVC1) _maxVC1 = (V/C)
        ENDIF
        IF (LW.HOV=2,8 & C>0)
          IF ((V/C) > _maxVC2) _maxVC2 = (V/C)          
        ENDIF
        IF (LW.HOV=3,6,10 & C>0)
          IF ((V/C) > _maxVC3) _maxVC3 = (V/C)
        ENDIF
        IF (LW.HOV=4 & C>0)
          IF ((V/C) > _maxVC4) _maxVC4 = (V/C)
        ENDIF
        IF (LW.HOV=5 & C>0)
          IF ((V/C) > _maxVC5) _maxVC5 = (V/C)
        ENDIF        
         
        ;Tolls for Next Assignment Iteration
        _toll1 = TOLL(1,_maxVC1)
        _toll2 = TOLL(1,_maxVC2)
        _toll3 = TOLL(1,_maxVC3)
        _toll4 = TOLL(1,_maxVC4)
        _toll5 = TOLL(1,_maxVC5)

        IF (LW.HOV>0 & V>0)
          PRINT CSV=T LIST=iteration(2.0),A(6.0),B(6.0),LW.HOV(4.0),V(8.2),V/C(8.42),TIME(5.2), DISTANCE(5.2), V*TIME(15.2), V*DISTANCE(15.2), _toll1(5.2), _toll2(5.2), _toll3(5.2), _toll4(5.2), _toll5(5.2) PRINTO=1
        ENDIF
    ENDPHASE

ENDRUN


; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.


ENDLOOP
; End of PILOT Script

; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.

NEXTITER = ITER + 1

LOOP TOD=1,2,1
 IF(TOD=1) TPER='PK' ASSIGNNAME='Peak Period'  HPER ='AM' 
 IF(TOD=2) TPER='OP' ASSIGNNAME='OffPeak Period'  HPER ='MD' 
; End of PILOT Script

; Script for program PUBLIC TRANSPORT in file "D:\TourCast\CATALOG\CUBE\PAPTR00B.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=PUBLIC TRANSPORT PRNFILE="%SCENARIO_DIR%\%ITER%_%TPER%_Walk_Assignmnet.prn" MSG='%TPER% Walk Transit Assignment'
FILEO LINKO[1] = "%SCENARIO_DIR%\%ITER%_%TPER%_XIT_WK.dbf"
FILEI MATI[1] = "%SCENARIO_DIR%\%ITER%_%TPER%_XIT.trp"
FILEI FAREI = "%XIT_FARE%"
FILEO REPORTO = "%SCENARIO_DIR%\%ITER%_%TPER%_WK.RPT"
FILEO ROUTEO[1] = "%SCENARIO_DIR%\%ITER%_%TPER%_WK.RTE",
 TRACEI=164, TRACEJ=2578
FILEO NETO = "%SCENARIO_DIR%\%ITER%_%TPER%_WK.NET"
FILEI FACTORI[1] = "%CATALOG_DIR%\INPUT\TRANSIT\%TPER%_WK_2010.FAC"
FILEI NTLEGI[3] = "%SCENARIO_DIR%\%ITER%_%TPER%_TRANSFERACCESS.NTL"
FILEI NTLEGI[2] = "%SCENARIO_DIR%\%ITER%_%TPER%_DRIVEACCESS.NTL"
FILEI NTLEGI[1] = "%SCENARIO_DIR%\%ITER%_%TPER%_WALKACCESS.NTL"
FILEI LINEI[1] = "%XIT_LINES%"
FILEI SYSTEMI = "%XIT_SYSTEM%"
FILEI NETI = "%SCENARIO_DIR%\%ITER%_%TPER%_TRANSITSPD.TMP"
FILEI FAREMATI[1] = "%XIT_FAREMAT%"

    PARAMETERS  HDWAYPERIOD=%TOD%
       
    PROCESS PHASE = DATAPREP
       TRANTIME[5]=li.loctime       ; local
       TRANTIME[6]=li.loctime       ; local
       TRANTIME[7]=li.exptime       ; express
       TRANTIME[8]=li.lrttime       ; lrt
       TRANTIME[9]=li.exptime       ; commuter bus
       GENERATE,
           READNTLEGI=1             ; walk  access link (mode=1)
       ;GENERATE,
        ;   READNTLEGI=2             ; drive access link (mode=2)
       GENERATE,
           READNTLEGI=3             ; transfer link (mode=4)
    ENDPROCESS
    
 PARAMETERS TRIPSIJ[1] = MI.1.1         ; ASSIGN WALK TO Transit TRIPS

 REPORT LINES=T, SORT=MODE, LINEVOLS=T, STOPSONLY=T, SKIP0=T, XFERSUM=MODE


ENDRUN


; Script for program PUBLIC TRANSPORT in file "D:\TourCast\CATALOG\CUBE\PAPTR00D.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=PUBLIC TRANSPORT PRNFILE="%SCENARIO_DIR%\%ITER%_%TPER%_Drive_Skim.prn" MSG='%TPER% Drive Transit Assignment'
FILEO LINKO[1] = "%SCENARIO_DIR%\%ITER%_%TPER%_XIT_WK.dbf"
FILEI MATI[1] = "%SCENARIO_DIR%\%ITER%_%TPER%_XIT.trp"
FILEI FAREI = "%XIT_FARE%"
FILEO REPORTO = "%SCENARIO_DIR%\%ITER%_%TPER%_DR.RPT"
FILEO ROUTEO[1] = "%SCENARIO_DIR%\%ITER%_%TPER%_DR.RTE",
 TRACEI=164, TRACEJ=2578
FILEO NETO = "%SCENARIO_DIR%\%ITER%_%TPER%_DR.NET"
FILEI FACTORI[1] = "%CATALOG_DIR%\INPUT\TRANSIT\%TPER%_DR_2010.FAC"
FILEI NTLEGI[3] = "%SCENARIO_DIR%\%ITER%_%TPER%_TRANSFERACCESS.NTL"
FILEI NTLEGI[2] = "%SCENARIO_DIR%\%ITER%_%TPER%_DRIVEACCESS.NTL"
FILEI NTLEGI[1] = "%SCENARIO_DIR%\%ITER%_%TPER%_WALKACCESS.NTL"
FILEI LINEI[1] = "%XIT_LINES%"
FILEI SYSTEMI = "%XIT_SYSTEM%"
FILEI NETI = "%SCENARIO_DIR%\%ITER%_%TPER%_TRANSITSPD.TMP"
FILEI FAREMATI[1] = "%XIT_FAREMAT%"

    PARAMETERS  HDWAYPERIOD=%TOD%
   
    PROCESS PHASE = DATAPREP
        TRANTIME[5]=li.loctime       ; local
        TRANTIME[6]=li.loctime       ; local
        TRANTIME[7]=li.exptime       ; express
        TRANTIME[8]=li.lrttime       ; lrt
        TRANTIME[9]=li.exptime       ; commuter bus
        GENERATE,
            READNTLEGI=1             ; walk  access link (mode=1)
        GENERATE,
            READNTLEGI=2             ; drive access link (mode=2)
        GENERATE,
            READNTLEGI=3             ; transfer link (mode=4)
    ENDPROCESS
    
 PARAMETERS TRIPSIJ[1] = MI.1.2         ; ASSIGN Drive TO Transit TRIPS

 REPORT LINES=T, SORT=MODE, LINEVOLS=T, STOPSONLY=T, SKIP0=T, XFERSUM=MODE

ENDRUN


; PILOT Script
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.


ENDLOOP
; End of PILOT Script

goto FinalAssign_END

:FinalAssign_1
goto FinalAssign_END

:FinalAssign_END
