; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=HIGHWAY MSG='Assignment Period: %ASSIGNNAME%'
FILEI MATI[4] = "%SCENARIO_DIR%\HWY_SPC_AUTO_TRIP_%ITER%_%PER%.trp"
FILEI MATI[3] = "%SCENARIO_DIR%\HWY_EXT_TRIP_%ITER%_%PER%.trp"
FILEI MATI[2] = "%SCENARIO_DIR%\TRK_TRIP_%ITER%_%PER%.trp"
FILEO PRINTO[1] = "%SCENARIO_DIR%\HWY_LDNET_PRN_%ITER%_%PER%.txt"
DISTRIBUTEINTRASTEP ProcessID="Intrastep", ProcessList=1-%max_threads%
FILEO MATO[1] = "%SCENARIO_DIR%\HWY_SKIM_%ITER%_%PER%.tmp",
                 MO=1-120, 200-225, DEC[1]=5*120, COMBINE=T
FILEO NETO = "%SCENARIO_DIR%\HWY_LDNET_%ITER%_%PER%.NET"
FILEI NETI = "%SCENARIO_DIR%\%HWY_NET%"
FILEI LOOKUPI[1] = "%LU_WILL2PAY%"
FILEI MATI[1] = "%SCENARIO_DIR%\HWY_AUTO_TRIP_%ITER%_%PER%.trp"


 ; **********   Define Assignment Parameters    ************
    
    PARAMETERS raad=0.0001 gap = 0.0001 RELATIVEGAP = 0.0001 aad = 0.01  MAXITERS = %hwy_assignIters% COMBINE=EQUI
    FUNCTION TC[1] = T0 * (1 + ALPHA*(V/C)^(BETA)) 
    FUNCTION TC[2] = T0 * (1 + ALPHA*(V/C)^(BETA)) 
    FUNCTION TC[3] = T0 * (1 + ALPHA*(V/C)^(BETA)) 
    FUNCTION TC[4] = T0 * (1 + ALPHA*(V/C)^(BETA)) 
    FUNCTION TC[5] = T0 * (1 + ALPHA*(V/C)^(BETA)) 
    FUNCTION TC[6] = T0 * (1 + ALPHA*(V/C)^(BETA)) 
    FUNCTION TC[7] = T0 * (1 + ALPHA*(V/C)^(BETA)) 
    FUNCTION TC[8] = T0 * (1 + ALPHA*(V/C)^(BETA)) 
    FUNCTION TC[9] = T0 * (1 + ALPHA*(V/C)^(BETA)) 
    FUNCTION TC[10] = T0 * (1 + ALPHA*(V/C)^(BETA)) 
    FUNCTION TC[11] = T0 * (1 + ALPHA*(V/C)^(BETA)) 
    FUNCTION TC[12] = T0 * (1 + ALPHA*(V/C)^(BETA)) 
    FUNCTION TC[13] = T0 * (1 + ALPHA*(V/C)^(BETA)) 
    FUNCTION TC[14] = T0 * (1 + ALPHA*(V/C)^(BETA)) 
    FUNCTION TC[15] = T0 * (1 + ALPHA*(V/C)^(BETA)) 
    FUNCTION TC[99] = T0 * (1 + ALPHA*(V/C)^(BETA)) 
    
    ; conical function with variable alpha/beta - 13% low on VMT
    ;FUNCTION TC[99] = T0 * (2+SQRT((ALPHA^2)*(1-(V/C))^2 + BETA^2) - ALPHA*(1-(V/C)) - BETA) 
    
    ;FUNCTION TC[1] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    ;FUNCTION TC[2] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    ;FUNCTION TC[3] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    ;FUNCTION TC[4] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    ;FUNCTION TC[5] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    ;FUNCTION TC[6] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    ;FUNCTION TC[7] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    ;FUNCTION TC[8] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    ;FUNCTION TC[9] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    ;FUNCTION TC[10] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    ;FUNCTION TC[11] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    ;FUNCTION TC[12] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    ;FUNCTION TC[13] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    ;FUNCTION TC[14] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    ;FUNCTION TC[15] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167) 
    ;FUNCTION TC[99] = T0 * (2+SQRT(16*(1-(V/C))^2 + 1.361) - 4*(1-(V/C)) - 1.167)  

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

; Group 2: HOV SECTIONS - Rachel Editing groups, adding more
        IF (LI.HOV=1,7,9)    ADDTOGROUP=1  ;I-35W	NB	Dakota County to Downtown 
        IF (LI.HOV=2,8,17)   ADDTOGROUP=2  ;I-35W	SB	Downtown to Dakota County 
        IF (LI.HOV=6)        ADDTOGROUP=3  ;I-394	WB DT to 100
        IF (LI.HOV=61)       ADDTOGROUP=4  ;I-394	EB 100 to DT
        IF (LI.HOV=4)        ADDTOGROUP=5  ;I-394	WB	STH-100	I-494 Outbound
        IF (LI.HOV=5)        ADDTOGROUP=6  ;I-394	EB	I-494	STH-100	Inbound
        IF (LI.HOV=11,25)    ADDTOGROUP=7  ; 35E outbound, DT StP to CRJ
        IF (LI.HOV=12,24)    ADDTOGROUP=8  ; 35w inbound, CRJ to DTstP
        IF (LI.HOV=13)       ADDTOGROUP=9 ; 35W NB, Hwy 36 to Blaine
        IF (LI.HOV=14)       ADDTOGROUP=10 ; 35W SB , Blaine to Hwy 36
        IF (LI.HOV=15)       ADDTOGROUP=11 ; 94 between downtowns EB
        IF (LI.HOV=16)       ADDTOGROUP=12 ; 94 between downtowns WB
        IF (LI.HOV=18)       ADDTOGROUP=13 ; 252 SB
        IF (LI.HOV=19)       ADDTOGROUP=14 ; 252 NB
        IF (LI.HOV=23,21)    ADDTOGROUP=15 ; SB 94 from 694 to DT
        IF (LI.HOV=20,22)    ADDTOGROUP=16  ; NB 94 from DT to 694
        IF (LI.HOV=27,29)    ADDTOGROUP=17  ; NB 35w / Hwy 36
        IF (LI.HOV=26,28)    ADDTOGROUP=18 ; SB hwy 36 / 35W
        IF (LI.HOV=30)    ADDTOGROUP=19 ; 94 rogers to maplegrove
        IF (LI.HOV=31)    ADDTOGROUP=20 ; 94 maplegrove to rogers
        IF (LI.HOV=32)    ADDTOGROUP=21 ; 169 from 694 to 394
        IF (LI.HOV=33)    ADDTOGROUP=22  ; 169 from 394 to 694
        IF (LI.HOV=34)    ADDTOGROUP=23 ; 169 from shakopee to 394
        IF (LI.HOV=35)    ADDTOGROUP=24 ; 169 from 394 to shakopee
        IF (LI.HOV=36)    ADDTOGROUP=25 ; 494 EB from 212 to Minnesota River, congested both directions 
        IF (LI.HOV=37)    ADDTOGROUP=26 ; 494 WB from Minnesota River to 212, congested both directions 
        IF (LI.HOV=38,39)    ADDTOGROUP=27 ; 94/694 from maple grove to 94 south into DT, partial lane converstion
        IF (LI.HOV=40,41)    ADDTOGROUP=28 ; 94/694 from 94 to maplegrove, partial lane converstion 
        IF (LI.HOV=42)    ADDTOGROUP=29 ; 694 EB from 94 to 35W
        IF (LI.HOV=43)    ADDTOGROUP=31 ; 694 WB from 35W to 94  SKIPPING GROUP 30 because used above 
        IF (LI.HOV=44,45)    ADDTOGROUP=32 ; 77 NB and SB combinging these groups because i can't have 33 groups
        
        
        
       ; rachel adding toll groups 6 - 24
        _toll1 = 25
        _toll2 = 25
        _toll3 = 25
        _toll4 = 25
        _toll5 = 25
        _toll6 = 25
        _toll7 = 25
        _toll8 = 25
        _toll9 = 25
        _toll10 = 25
        _toll11 = 25
        _toll12 = 25
        _toll13 = 25
        _toll14 = 25
        _toll15 = 25
        _toll16 = 25
        _toll17 = 25
        _toll18 = 25
        _toll19 = 25
        _toll20 = 25
        _toll21 = 25
        _toll22 = 25
        _toll23 = 25
        _toll24 = 25
        _toll25 = 25
        _toll26 = 25
        _toll27 = 25
        _toll28 = 25
        _toll29 = 25
        _toll31 = 25 ; SKIPPING GROUP 30 because used above 
        _toll32 = 25
        
    ENDPHASE 

    PHASE=ILOOP           

      MW[1] = MI.1.1    MW[2] = MI.1.2    MW[3] = MI.1.3    MW[4] = MI.1.4    MW[5] = MI.1.5 ; SOV Work
      MW[6] = MI.1.6    MW[7] = MI.1.7    MW[8] = MI.1.8    MW[9] = MI.1.9    MW[10]= MI.1.10 ; HOV2 Work
      MW[11]= MI.1.11   MW[12]= MI.1.12   MW[13]= MI.1.13   MW[14]= MI.1.14   MW[15]= MI.1.15 ; HOV3 Work
      MW[16]= MI.1.16   MW[17]= MI.1.17   MW[18]= MI.1.18   MW[19]= MI.1.19   MW[20]= MI.1.20 ; SOV NON Work
      MW[21]= MI.1.21   MW[22]= MI.1.22   MW[23]= MI.1.23   MW[24]= MI.1.24   MW[25]= MI.1.25 ; HOV2 NON Work
      MW[26]= MI.1.26   MW[27]= MI.1.27   MW[28]= MI.1.28   MW[29]= MI.1.29   MW[30]= MI.1.30 ; HOV3 NON Work
      MW[119] = MI.1.31    MW[120] = MI.1.32 + MI.3.1 + MI.3.2 + MI.3.3 + MI.4.1 + MI.4.2 + MI.4.3    ; SOVInc1, SOVInc25 - No Transponder / Externals / Spec Gen in with SOVInc25

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
                MW[85]=_toll5, selectgroup=5, ; Rachel add in new working maxtrix starting at 200
                MW[200]=_toll6, selectgroup=6,
                MW[201]=_toll7, selectgroup=7,
                MW[202]=_toll8, selectgroup=8,
                MW[203]=_toll9, selectgroup=9,
                MW[204]=_toll10, selectgroup=10,
                MW[205]=_toll11, selectgroup=11,
                MW[206]=_toll12, selectgroup=12,
                MW[207]=_toll13, selectgroup=13,
                MW[208]=_toll14, selectgroup=14,
                MW[209]=_toll15, selectgroup=15,
                MW[210]=_toll16, selectgroup=16,
                MW[211]=_toll17, selectgroup=17,
                MW[212]=_toll18, selectgroup=18,
                MW[213]=_toll19, selectgroup=19,
                MW[214]=_toll20, selectgroup=20,
                MW[215]=_toll21, selectgroup=21,
                MW[216]=_toll22, selectgroup=22,
                MW[217]=_toll23, selectgroup=23,
                MW[218]=_toll24, selectgroup=24,
                MW[219]=_toll25, selectgroup=25,
                MW[220]=_toll26, selectgroup=26,
                MW[221]=_toll27, selectgroup=27,
                MW[222]=_toll28, selectgroup=28,
                MW[223]=_toll29, selectgroup=29,
                MW[224]=_toll31, selectgroup=31,
                MW[225]=_toll32, selectgroup=32
                


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
      ; rachel add new working maxtrix here MW[200 - 225]
       MW[35] =  MW[81]+MW[82]+MW[83]+MW[84]+MW[85]+MW[200]+MW[201]+MW[202]+MW[203]+MW[204]+MW[205]+MW[206]+MW[207]+MW[208]+MW[209]+MW[210]+MW[211]+MW[212]+MW[213]+MW[214]+MW[215]+MW[216]+MW[217]+MW[218]+MW[219]+MW[220]+MW[221]+MW[222]+MW[223]+MW[224]+MW[225]
       
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
          MW[113] = MW[11]+ MW[26] - MW[51] - MW[66] ; HOV3 INC1 Will NotPay this line changed by Rachel Wiken 2-26-19 , MW26 was MW21, which is an error  
          MW[114] = MW[41]+ MW[56]                   ; SOV  INC1 Will Pay
          MW[115] = MW[46]+ MW[61]                   ; HOV2 INC1 Will Pay
          MW[116] = MW[51]+ MW[66]                   ; HOV3 INC1 Will Pay

         ; Revenue from Paying Vehicles based on "average" toll (average from one assignment to the next)
          MW[90] = MW[35] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80])   ; TOTAL revenue (Willing to Pay * Toll)
          MW[91] = MW[81] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80])   ; toll1 revenue
          MW[92] = MW[82] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80])   ; toll2 revenue
          MW[93] = MW[83] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80])   ; toll3 revenue
          MW[94] = MW[84] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80])   ; toll4 revenue
          MW[95] = MW[85] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80])   ; toll5 revenue  rachel keep adding here from MW[200] to MW[218]
          MW[300] = MW[200] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll6 revenue 
          MW[301] = MW[201] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll7 revenue 
          MW[302] = MW[202] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll8 revenue 
          MW[303] = MW[203] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll9 revenue 
          MW[304] = MW[204] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll10 revenue 
          MW[305] = MW[205] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll11 revenue 
          MW[306] = MW[206] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll12 revenue 
          MW[307] = MW[207] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll13 revenue 
          MW[308] = MW[208] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll14 revenue 
          MW[309] = MW[209] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll15 revenue 
          MW[310] = MW[210] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll16 revenue 
          MW[311] = MW[211] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll17 revenue 
          MW[312] = MW[212] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll18 revenue 
          MW[313] = MW[213] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll19 revenue 
          MW[314] = MW[214] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll20 revenue 
          MW[315] = MW[215] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll21 revenue 
          MW[316] = MW[216] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll22 revenue 
          MW[317] = MW[217] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll23 revenue 
          MW[318] = MW[218] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll24 revenue 
          MW[319] = MW[219] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll25 revenue
          MW[320] = MW[220] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll26 revenue
          MW[321] = MW[221] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll27 revenue
          MW[322] = MW[222] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll28 revenue
          MW[323] = MW[223] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll29 revenue
          MW[324] = MW[224] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll31 revenue
          MW[325] = MW[225] * (MW[71]+MW[72]+MW[73]+MW[74]+MW[75]+MW[76]+MW[77]+MW[78]+MW[79]+MW[80]) ; toll32 revenue
        
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
                VOL[13]=MI.2.3               ; Trucks 

    ENDPHASE
    PHASE=ADJUST
         IF (LINKNO=1)
          _maxVC1 = 0
          _maxVC2 = 0
          _maxVC3 = 0
          _maxVC4 = 0
          _maxVC5 = 0 ; Rachel keep adding here, maxVCs to group 32
          _maxVC6 = 0
          _maxVC7 = 0
          _maxVC8 = 0
          _maxVC9 = 0
          _maxVC10 = 0
          _maxVC11 = 0
          _maxVC12 = 0
          _maxVC13 = 0
          _maxVC14 = 0
          _maxVC15 = 0
          _maxVC16 = 0
          _maxVC17 = 0
          _maxVC18 = 0
          _maxVC19 = 0
          _maxVC20 = 0
          _maxVC21 = 0
          _maxVC22 = 0
          _maxVC23 = 0
          _maxVC24 = 0
          _maxVC25 = 0
          _maxVC26 = 0
          _maxVC27 = 0
          _maxVC28 = 0
          _maxVC29 = 0
          _maxVC31 = 0
          _maxVC32 = 0
          
          
          
          
         
          IF (Iteration =1)
            PRINT CSV=T LIST='Iteration,ANode,BNode,HOV,Volume,VC,TIME,DISTANCE, VHT, VMT, Toll1, Toll2, Toll3, Toll4, Toll5, Toll6, Toll7, Toll8, Toll9, Toll10, Toll11, Toll12, Toll13, Toll14, Toll15, Toll16, Toll17, Toll18, Toll19, Toll20, Toll21, Toll22, Toll23, Toll24, Toll25, Toll26, Toll27, Toll28, Toll29, Toll31, Toll32' PRINTO=1          ; adding new toll groups here to try to fix intrastep issues PRINTO=1          
          ENDIF
         ENDIF

; *** COMPUTE MAXIMUM V/C RATIO AND TOLL RATES FOR NEXT ITERATION ON TOLLED SEGMENTS ***
;HOT Lanes
          IF (LW.HOV=1,7,9 & C>0)
          IF ((V/C) > _maxVC1) _maxVC1 = (V/C)
        ENDIF
        IF (LW.HOV=2,8,17 & C>0)
          IF ((V/C) > _maxVC2) _maxVC2 = (V/C)          
        ENDIF
        IF (LW.HOV=6 & C>0)
          IF ((V/C) > _maxVC3) _maxVC3 = (V/C)
        ENDIF
        IF (LW.HOV=61 & C>0)
          IF ((V/C) > _maxVC4) _maxVC4 = (V/C)
        ENDIF
        IF (LW.HOV=4 & C>0)
          IF ((V/C) > _maxVC5) _maxVC5 = (V/C)
        ENDIF ; Rachel keep adding here too
        
        IF (LW.HOV=5 & C>0)
          IF ((V/C) > _maxVC6) _maxVC6 = (V/C)
        ENDIF
        IF (LW.HOV=11,25 & C>0)
          IF ((V/C) > _maxVC7) _maxVC7 = (V/C)          
        ENDIF
        IF (LW.HOV=12,24 & C>0)
          IF ((V/C) > _maxVC8) _maxVC8 = (V/C)
        ENDIF
        IF (LW.HOV=13 & C>0)
          IF ((V/C) > _maxVC9) _maxVC9 = (V/C)
        ENDIF
        IF (LW.HOV=14 & C>0)
          IF ((V/C) > _maxVC10) _maxVC10 = (V/C)
        ENDIF 
        
         IF (LW.HOV=15 & C>0)
          IF ((V/C) > _maxVC11) _maxVC11 = (V/C)
        ENDIF
        IF (LW.HOV=16 & C>0)
          IF ((V/C) > _maxVC12) _maxVC12 = (V/C)          
        ENDIF
        IF (LW.HOV=18 & C>0)
          IF ((V/C) > _maxVC13) _maxVC13 = (V/C)
        ENDIF
        IF (LW.HOV=19 & C>0)
          IF ((V/C) > _maxVC14) _maxVC14 = (V/C)
        ENDIF
        IF (LW.HOV=23,21 & C>0)
          IF ((V/C) > _maxVC15) _maxVC15 = (V/C)
        ENDIF 
        
         IF (LW.HOV=20,22 & C>0)
          IF ((V/C) > _maxVC16) _maxVC16 = (V/C)
        ENDIF
        IF (LW.HOV=27,29 & C>0)
          IF ((V/C) > _maxVC17) _maxVC17 = (V/C)          
        ENDIF
        IF (LW.HOV=26,28 & C>0)
          IF ((V/C) > _maxVC18) _maxVC18 = (V/C)
        ENDIF
        IF (LW.HOV=30 & C>0)
          IF ((V/C) > _maxVC19) _maxVC19 = (V/C)
        ENDIF
        IF (LW.HOV=31 & C>0)
          IF ((V/C) > _maxVC20) _maxVC20 = (V/C)
        ENDIF 
        
         IF (LW.HOV=32 & C>0)
          IF ((V/C) > _maxVC21) _maxVC21 = (V/C)
        ENDIF
        IF (LW.HOV=33 & C>0)
          IF ((V/C) > _maxVC22) _maxVC22 = (V/C)          
        ENDIF
        IF (LW.HOV=34 & C>0)
          IF ((V/C) > _maxVC23) _maxVC23 = (V/C)
        ENDIF
        IF (LW.HOV=35 & C>0)
          IF ((V/C) > _maxVC24) _maxVC24 = (V/C)
        ENDIF
        
         IF (LW.HOV=36 & C>0)
            IF ((V/C) > _maxVC25) _maxVC25 = (V/C)
          ENDIF
          
        IF (LW.HOV=37 & C>0)
          IF ((V/C) > _maxVC26) _maxVC26 = (V/C)
        ENDIF
        
        IF (LW.HOV=38,39 & C>0)
          IF ((V/C) > _maxVC27) _maxVC27 = (V/C)
        ENDIF
        
        IF (LW.HOV=40,41 & C>0)
          IF ((V/C) > _maxVC28) _maxVC28 = (V/C)
        ENDIF
        
        IF (LW.HOV=42 & C>0)
          IF ((V/C) > _maxVC29) _maxVC29 = (V/C)
        ENDIF
        
        IF (LW.HOV=43 & C>0)
          IF ((V/C) > _maxVC31) _maxVC31 = (V/C)   ; skipping 30 again because of excluded group, see line 96
        ENDIF
        
        IF (LW.HOV=44,45 & C>0)
          IF ((V/C) > _maxVC32) _maxVC32 = (V/C)
        ENDIF
        
      
        
        
        
        
         
        ;Tolls for Next Assignment Iteration
       _toll1 = TOLL(1,_maxVC1)
        _toll2 = TOLL(1,_maxVC2)
        _toll3 = TOLL(1,_maxVC3)
        _toll4 = TOLL(1,_maxVC4)
        _toll5 = TOLL(1,_maxVC5) ; rachel keep adding up to toll24, maxvc24
        _toll5 = TOLL(1,_maxVC5)
        _toll6 = TOLL(1,_maxVC6)
        _toll7 = TOLL(1,_maxVC7)
        _toll8 = TOLL(1,_maxVC8)
        _toll9 = TOLL(1,_maxVC9)
        _toll10 = TOLL(1,_maxVC10)
        _toll11 = TOLL(1,_maxVC11)
        _toll12 = TOLL(1,_maxVC12)
        _toll13 = TOLL(1,_maxVC13)
        _toll14 = TOLL(1,_maxVC14)
        _toll15 = TOLL(1,_maxVC15)
        _toll16 = TOLL(1,_maxVC16)
        _toll17 = TOLL(1,_maxVC17)
        _toll18 = TOLL(1,_maxVC18)
        _toll19 = TOLL(1,_maxVC19)
        _toll20 = TOLL(1,_maxVC20)
        _toll21 = TOLL(1,_maxVC21)
        _toll22 = TOLL(1,_maxVC22)
        _toll23 = TOLL(1,_maxVC23)
        _toll24 = TOLL(1,_maxVC24)
        _toll25 = TOLL(1,_maxVC25)
        _toll26 = TOLL(1,_maxVC26)
        _toll27 = TOLL(1,_maxVC27)
        _toll28 = TOLL(1,_maxVC28)
        _toll29 = TOLL(1,_maxVC29)
        _toll31 = TOLL(1,_maxVC31)
        _toll32 = TOLL(1,_maxVC32)
       

        
        
        IF (LW.HOV>0 & V>0)
                    
          PRINT CSV=T LIST=iteration(2.0),A(6.0),B(6.0),LW.HOV(4.0),V(8.2),V/C(8.42),TIME(5.2), DISTANCE(5.2), V*TIME(15.2), V*DISTANCE(15.2), _toll1(5.2), _toll2(5.2), _toll3(5.2), _toll4(5.2), _toll5(5.2), _toll6(5.2), _toll7(5.2), _toll8(5.2), _toll9(5.2), _toll10(5.2), _toll11(5.2), _toll12(5.2), _toll13(5.2), _toll14(5.2), _toll15(5.2), _toll16(5.2), _toll17(5.2), _toll18(5.2), _toll19(5.2), _toll20(5.2), _toll21(5.2), _toll22(5.2), _toll23(5.2), _toll24(5.2), _toll25(5.2), _toll26(5.2), _toll27(5.2), _toll28(5.2), _toll29(5.2), _toll31(5.2), _toll32(5.2) PRINTO=1
        ENDIF
    ENDPHASE

ENDRUN
