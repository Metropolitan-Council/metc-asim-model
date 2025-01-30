; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Highway Accessibility'
FILEI ZDATI[1] = "%SCENARIO_DIR%\zones_%PREV_ITER%.dbf"

FILEO PRINTO[1] = "%SCENARIO_DIR%\highway_accessibility.csv"
FILEI MATI[1] = "%SCENARIO_DIR%\HWY_SKIM_%PREV_ITER%_AM.skm"

; This script creates highway accessibility measures for each TAZ
; Inputs- Highway skim file (HWY_SKIM_4_AM.skm) and Zonal Data File (zones.dbf)
; Output - Highway accessibility measures (highway accessibility.csv)
; Moby Khan 11/2/16

Zones = %int_zones%

mw[100]=mi.1.daptime

; Six different constants are used to calculate six different highway accessibility measures
C_1=1
C_2=2
C_5=5
C_10=10
C_15=15
C_20=20

; The following loop calculates T_bar
if (i=1)
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

; Use a constant value of T_bar if desired
; T_bar=44.2

; Calculate first step of accessibility measure for all ij pair based on the formula emp_j * exp(-C*T_ij/T_bar)
jloop
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
  if(mi.1.daptoll>0)
    mw[19]=zi.1.tot_emp[j]*exp(-1*C_1*mw[100]/T_bar) ;accvalM1
    mw[20]=zi.1.tot_emp[j]*exp(-1*C_2*mw[100]/T_bar) ;accvalM2
    mw[21]=zi.1.tot_emp[j]*exp(-1*C_5*mw[100]/T_bar) ;accvalM5
    mw[22]=zi.1.tot_emp[j]*exp(-1*C_10*mw[100]/T_bar) ;accvalM10
    mw[23]=zi.1.tot_emp[j]*exp(-1*C_15*mw[100]/T_bar) ;accvalM15
    mw[24]=zi.1.tot_emp[j]*exp(-1*C_20*mw[100]/T_bar) ;accvalM20
  endif
endjloop


; Declare arrays(columns) for each of the accesibility measures
ARRAY TEhwyacc1=Zones,TEhwyacc2=Zones,TEhwyacc5=Zones,TEhwyacc10=Zones,TEhwyacc15=Zones,TEhwyacc20=Zones,REhwyacc1=Zones,REhwyacc2=Zones,REhwyacc5=Zones,REhwyacc10=Zones,REhwyacc15=Zones,REhwyacc20=Zones,NEhwyacc1=Zones,NEhwyacc2=Zones,NEhwyacc5=Zones,NEhwyacc10=Zones,NEhwyacc15=Zones,NEhwyacc20=Zones,MEhwyacc1=Zones,MEhwyacc2=Zones,MEhwyacc5=Zones,MEhwyacc10=Zones,MEhwyacc15=Zones,MEhwyacc20=Zones

; Sum across all rows(js), add 1 and take natural log to obtain accessibility measures for all i
; Highway accessibility Measures are calculated for Total Employment, Retail Employment, Non-retail employment and finally for MnPass Connections

; Total Employment Accessibility
TEhwyacc1[i]=ln(1+rowsum(1))
TEhwyacc2[i]=ln(1+rowsum(2))
TEhwyacc5[i]=ln(1+rowsum(3))
TEhwyacc10[i]=ln(1+rowsum(4))
TEhwyacc15[i]=ln(1+rowsum(5))
TEhwyacc20[i]=ln(1+rowsum(6))

; Retail Employment Accessibility
REhwyacc1[i]=ln(1+rowsum(7))
REhwyacc2[i]=ln(1+rowsum(8))
REhwyacc5[i]=ln(1+rowsum(9))
REhwyacc10[i]=ln(1+rowsum(10))
REhwyacc15[i]=ln(1+rowsum(11))
REhwyacc20[i]=ln(1+rowsum(12))

; Non-retail Employment Accessibility
NEhwyacc1[i]=ln(1+rowsum(13))
NEhwyacc2[i]=ln(1+rowsum(14))
NEhwyacc5[i]=ln(1+rowsum(15))
NEhwyacc10[i]=ln(1+rowsum(16))
NEhwyacc15[i]=ln(1+rowsum(17))
NEhwyacc20[i]=ln(1+rowsum(18))

; MnPass Accesibility 
MEhwyacc1[i]=ln(1+rowsum(19))
MEhwyacc2[i]=ln(1+rowsum(20))
MEhwyacc5[i]=ln(1+rowsum(21))
MEhwyacc10[i]=ln(1+rowsum(22))
MEhwyacc15[i]=ln(1+rowsum(23))
MEhwyacc20[i]=ln(1+rowsum(24))


; Create csv headers
if(i=1)
print csv=T,
printo=1,list="Zone","TEhwyacc1","TEhwyacc2","TEhwyacc5","TEhwyacc10","TEhwyacc15","TEhwyacc20",
"REhwyacc1","REhwyacc2","REhwyacc5","REhwyacc10","REhwyacc15","REhwyacc20",
"NEhwyacc1","NEhwyacc2","NEhwyacc5","NEhwyacc10","NEhwyacc15","NEhwyacc20",
"MEhwyacc1","MEhwyacc2","MEhwyacc5","MEhwyacc10","MEhwyacc15","MEhwyacc20"
endif

; Output actual data
print csv=T,
printo=1,list=i,form=10.10,list=TEhwyacc1[i],TEhwyacc2[i],TEhwyacc5[i],TEhwyacc10[i],TEhwyacc15[i],TEhwyacc20[i],
REhwyacc1[i],REhwyacc2[i],REhwyacc5[i],REhwyacc10[i],REhwyacc15[i],REhwyacc20[i],
NEhwyacc1[i],NEhwyacc2[i],NEhwyacc5[i],NEhwyacc10[i],NEhwyacc15[i],NEhwyacc20[i],
MEhwyacc1[i],MEhwyacc2[i],MEhwyacc5[i],MEhwyacc10[i],MEhwyacc15[i],MEhwyacc20[i]

ENDRUN
