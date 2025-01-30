; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Transit Accessibility'
FILEI ZDATI[1] = "%SCENARIO_DIR%\zones_%PREV_ITER%.dbf"

FILEO PRINTO[1] = "%SCENARIO_DIR%\transit_accessibility.csv"
FILEI MATI[1] = "%SCENARIO_DIR%\XIT_WK_SKIM_%PREV_ITER%_PK.SKM"

; This script creates transit accessibility measures for each TAZ
; Inputs- Transit skim file (PK_XIT_WK.SKM) and Zonal Data File (zones.dbf)
; Output - Transit accessibility measures (transit_accessibility.csv)
; Moby Khan 11/2/16

Zones = %int_zones%

; Six different constants are used to calculate six different transit accessibility measures
mw[100]=mi.1.TRNTIME
C_1=1
C_2=2
C_5=5
C_10=10
C_15=15
C_20=20

; The following loop calculates T_bar
if (i=1) ; this if statement makes sure T_bar is calculated only once since it is the same for all i's
  LOOP a=1,Zones
    LOOP b=1,Zones
      if (matval(1,1,a,b)>0)
        T_sum = T_sum + matval(1,1,a,b)
        NumPairs = NumPairs + 1
      endif
    ENDLOOP
  ENDLOOP
  T_bar = T_sum / NumPairs
endif


; Use a constant value of T_bar if desired, otherwise T_bar is calculated in step above
; T_bar=38.65447734

; Calculate first step of accessibility measure for all ij pair based on the formula emp_j * exp(-C*T_ij/T_bar)
jloop
  if(mw[100]>0) ; check that transit skims exist for ij pair, otherwise accessibility is 0
    mw[1]=zi.1.tot_emp[j]*exp(-1*C_1*mw[100]/T_bar) ;accvalT1
    mw[2]=zi.1.tot_emp[j]*exp(-1*C_2*mw[100]/T_bar) ;accvalT2 
    mw[3]=zi.1.tot_emp[j]*exp(-1*C_5*mw[100]/T_bar) ;accvalT5 
    mw[4]=zi.1.tot_emp[j]*exp(-1*C_10*mw[100]/T_bar) ;accvalT10 
    mw[5]=zi.1.tot_emp[j]*exp(-1*C_15*mw[100]/T_bar) ;accvalT15 
    mw[6]=zi.1.tot_emp[j]*exp(-1*C_20*mw[100]/T_bar) ;accvalT20 
    mw[7]=zi.1.ret_emp[j]*exp(-1*C_1*mw[100]/T_bar) ;accvalR1 
    mw[8]=zi.1.ret_emp[j]*exp(-1*C_2*mw[100]/T_bar) ;accvalR2 
    mw[9]=zi.1.ret_emp[j]*exp(-1*C_5*mw[100]/T_bar) ;accvalR5 
    mw[10]=zi.1.ret_emp[j]*exp(-1*C_10*mw[100]/T_bar) ;accvalR10 
    mw[11]=zi.1.ret_emp[j]*exp(-1*C_15*mw[100]/T_bar) ;accvalR15 
    mw[12]=zi.1.ret_emp[j]*exp(-1*C_20*mw[100]/T_bar) ;accvalR20 
    mw[13]=zi.1.nret_emp[j]*exp(-1*C_1*mw[100]/T_bar) ;accvalN1
    mw[14]=zi.1.nret_emp[j]*exp(-1*C_2*mw[100]/T_bar) ;accvalN2
    mw[15]=zi.1.nret_emp[j]*exp(-1*C_5*mw[100]/T_bar) ;accvalN5
    mw[16]=zi.1.nret_emp[j]*exp(-1*C_10*mw[100]/T_bar) ;accvalN10
    mw[17]=zi.1.nret_emp[j]*exp(-1*C_15*mw[100]/T_bar) ;accvalN15
    mw[18]=zi.1.nret_emp[j]*exp(-1*C_20*mw[100]/T_bar) ;accvalN20
  endif
endjloop

; Declare arrays(columns) for each of the accesibility measures
ARRAY TETRacc1=Zones,TETRacc2=Zones,TETRacc5=Zones,TETRacc10=Zones,TETRacc15=Zones,TETRacc20=Zones,RETRacc1=Zones,RETRacc2=Zones,RETRacc5=Zones,RETRacc10=Zones,RETRacc15=Zones,RETRacc20=Zones,NETRacc1=Zones,NETRacc2=Zones,NETRacc5=Zones,NETRacc10=Zones,NETRacc15=Zones,NETRacc20=Zones

; Sum across all rows(js), add 1 and take natural log to obtain accessibility measures

; Total Employment Accessibility
TETRacc1[i]=ln(1+rowsum(1))
TETRacc2[i]=ln(1+rowsum(2))
TETRacc5[i]=ln(1+rowsum(3))
TETRacc10[i]=ln(1+rowsum(4))
TETRacc15[i]=ln(1+rowsum(5))
TETRacc20[i]=ln(1+rowsum(6))

; Retail Employment Accessibility
RETRacc1[i]=ln(1+rowsum(7))
RETRacc2[i]=ln(1+rowsum(8))
RETRacc5[i]=ln(1+rowsum(9))
RETRacc10[i]=ln(1+rowsum(10))
RETRacc15[i]=ln(1+rowsum(11))
RETRacc20[i]=ln(1+rowsum(12))

; Non-retail Employment Accessibility
NETRacc1[i]=ln(1+rowsum(13))
NETRacc2[i]=ln(1+rowsum(14))
NETRacc5[i]=ln(1+rowsum(15))
NETRacc10[i]=ln(1+rowsum(16))
NETRacc15[i]=ln(1+rowsum(17))
NETRacc20[i]=ln(1+rowsum(18))


; Create csv headers
if(i=1)
  print csv=T,
  printo=1,list="Zone","TETRacc1","TETRacc2","TETRacc5","TETRacc10","TETRacc15","TETRacc20",
  "RETRacc1","RETRacc2","RETRacc5","RETRacc10","RETRacc15","RETRacc20",
  "NETRacc1","NETRacc2","NETRacc5","NETRacc10","NETRacc15","NETRacc20"
endif

; Output actual data
print csv=T,
printo=1,list=i,form=10.10,list=TETRacc1[i],TETRacc2[i],TETRacc5[i],TETRacc10[i],TETRacc15[i],TETRacc20[i],
RETRacc1[i],RETRacc2[i],RETRacc5[i],RETRacc10[i],RETRacc15[i],RETRacc20[i],
NETRacc1[i],NETRacc2[i],NETRacc5[i],NETRacc10[i],NETRacc15[i],NETRacc20[i]


ENDRUN
