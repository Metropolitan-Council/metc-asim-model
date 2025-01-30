RUN PGM="C:\Program Files (x86)\Citilabs\Cube\TRCOPY.bat" PARAMETERS='"%zone_attribs%" "%zone_attribs%_prev.dbf" '
ENDRUN

; Script for program MATRIX in file "C:\USERS\MKHAN\DESKTOP\PROJECTS\METCOUNCIL\METCOUNCIL_ABM08102015\CUBE\EVMAT00A.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Highway Accessibility'

FILEO PRINTO[1] = "%SCENARIO_DIR%\highway_accessibility.csv"
FILEI MATI[1] = "%hwy_AMskims%"
FILEI ZDATI[1] = "%zone_attribs%_prev.dbf"

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


; Script for program MATRIX in file "C:\USERS\MKHAN\DESKTOP\PROJECTS\METCOUNCIL\METCOUNCIL_ABM08102015\CUBE\EVMAT00B.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Transit Accessibility'

FILEO PRINTO[1] = "%SCENARIO_DIR%\transit_accessibility.csv"
FILEI ZDATI[1] = "%zone_attribs%_prev.dbf"
FILEI MATI[1] = "%xit_WK_PKskims%"

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


; Script for program MATRIX in file "C:\USERS\MKHAN\DESKTOP\PROJECTS\METCOUNCIL\METCOUNCIL_ABM08102015\CUBE\EVMAT00C.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Distance to External'

FILEO PRINTO[1] = "%SCENARIO_DIR%\distancetoexternal.csv"
FILEI MATI[1] = "%hwy_NTskims%"

; This script calculates the minimum distance to external zone for each TAZ
; Input- Highway skim file (HWY_SKIM_4_AM.skm)
; Output - Distance to closest external TAZ for each TAZ (distancetoexternal.csv)
; Moby Khan 11/2/16

Zones = %int_zones%

; Use drive alone distance for distance measure
mw[100]=mi.1.dapdist

; Initiate with a large MINDIST which will be overwritten subsequently
MINDIST=1000

; Loop through only external zones
jloop
  if (j=2918,2916,2960,2958,2959,2863,2864,2861,2860,2855,3001,3004,2993,2973,2974,2994,
  2995,2987,3021,3022,3019,2527,2554,2553,2558,2557,2556,2555,2573,2572,2601,2603,
  2510,2602,2607,2807,2806,2808,2838,2835,2824,2826,2827,2829,2828,2865,2857,2531,
  2534,2532,2533,2537,2739,2757,2758,2759,2742,2760,2761,2762,2683,2696,2684,2699,
  2775,2776,2777,2779,2599,2600,2591,2569,2571,2570,2559,2707,2708,2712,2713,2714,
  2716,2717,2718,2726,2605,2606,2612,2613,2627,2629)
    if (MINDIST>mw[100]) ; Check if current ij distance is smaller than previous MINDIST
      MINDIST=MW[100] ; Update MINDIST with new distance
    endif
  endif
endjloop

; Create csv headers
if(i=1)
print csv=T,
printo=1,list="Zone","MINDIST"
endif

; Output actual data
print csv=T,
printo=1,list=i,MINDIST



ENDRUN


; Script for program MATRIX in file "C:\USERS\MKHAN\DESKTOP\PROJECTS\METCOUNCIL\METCOUNCIL_ABM08102015\CUBE\EVMAT00D.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='School TAZs'

FILEO PRINTO[1] = "%SCENARIO_DIR%\TAZ_SchoolList.csv"
FILEI ZDATI[1] = "%SCENARIO_DIR%\SchoolTAZs.csv",Z=#1,District=#2,Sch1TAZs=#3,Sch2TAZs=#4,Sch3TAZs=#5,wSch1=#6,wSch2=#7,wSch3=#8
FILEI MATI[1] = "%hwy_AMskims%"

; This script outputs 10 closest school TAZs for each TAZ
; Inputs- Highway skim file (HWY_SKIM_4_AM.skm) and list of TAZs with school Districts, Number of school TAZs within district and school TAZ indicator
; Output - List of 10 closest TAZs in order for three types of schools, for each TAZ in the model
; Moby Khan 11/2/16

Zones = %int_zones%

; Use Drive-alone distance to identify closest schools
mw[100]=mi.1.dapdist

; Declare two arrays for-
; SCH1NUM which contains 10 closest elementary school TAZs for each TAZ
; distSch1TAZ which contains the distance to these 10 closest TAZs

ARRAY SCH1NUM=Zones,10, dist_Sch1TAZ=Zones,10

; Calculate SCH1NUM1
dist_Sch1TAZ[i][1]=1000 ; Initiate with a large distance which gets replaced when a shorter distance is encountered
if (wSch1[i]>0) ; if the TAZ itself contains a school, then the closest TAZ is itself
  SCH1NUM[i][1]=i
  dist_Sch1TAZ[i][1]=matval(1,dapdist,i,i)
  else 
    jloop ; otherwise loop through all js to pick the closest school TAZ
      if (District[i]=District[j] & wSch1[j]>0) ; check to make sure that the school districts are same and destination j is a TAZ w/school
        if (dist_Sch1TAZ[i][1] > mw[100]) ; if the distance to the previously selected zone is larger than the distance to current zone
          SCH1NUM[i][1] = j ; replace the TAZ with current zone
          dist_Sch1TAZ[i][1] = mw[100] ; update the distance, loop through remaining js
        endif
      endif
    endjloop 
endif

; Calculate SCH1NUM2 through SCH1NUM10 by initiating a loop SCH1LOOP that corresponds to 2-10
LOOP SCH1LOOP=2,10
  dist_Sch1TAZ[i][SCH1LOOP]=1000 ; Initiate with a large distance which gets replaced when a shorter distance is encountered
  
  ; if the number of schools within the school district is less than the loop number, set school TAZ to 0. For example, the 5th school TAZ for a district that has only 4 schools should be 0
  if (Sch1TAZs[i]<SCH1LOOP) 
    SCH1NUM[i][SCH1LOOP]=0
    else
      jloop ; otherwise loop through all js to pick the next closest school TAZ
        if (District[i]=District[j] & wSch1[j]>0) ; check to make sure that the school districts are same and destination j is a TAZ w/school
          if (dist_Sch1TAZ[i][SCH1LOOP] > mw[100] & mw[100]>=dist_Sch1TAZ[i][SCH1LOOP-1] & j!=SCH1NUM[i][SCH1LOOP-1])
          ; check that the previous distance is larger than the new distance
          ; check that the distance to the current zone is greater than or equal to the previous closest TAZ
          ; check that the current zone is not the same as the previous or (n-1)th TAZ
            if (SCH1LOOP>2) ; check that the current zone is not the same as (n-2)th TAZ
                if (SCH1NUM[i][SCH1LOOP-2]!=j)
                  SCH1NUM[i][SCH1LOOP] = j ; replace the TAZ with current zone
                  dist_Sch1TAZ[i][SCH1LOOP] = mw[100]
                endif
            else
              SCH1NUM[i][SCH1LOOP] = j ; replace the TAZ with current zone
              dist_Sch1TAZ[i][SCH1LOOP] = mw[100] ; update the distance, loop through remaining js
            endif
          endif
        endif
      endjloop 
  endif
ENDLOOP


; Repeat above for School types 2 and 3 (Middle and High School)

ARRAY SCH2NUM=Zones,10, dist_Sch2TAZ=Zones,10

; Calculate SCH2NUM1
dist_Sch2TAZ[i][1]=1000 ; Initiate with a large distance which gets replaced when a shorter distance is encountered
if (wSch2[i]>0) ; if the TAZ itself contains a school, then the closest TAZ is itself
  SCH2NUM[i][1]=i
  dist_Sch2TAZ[i][1]=matval(1,dapdist,i,i)
  else 
    jloop ; otherwise loop through all js to pick the closest school TAZ
      if (District[i]=District[j] & wSch2[j]>0) ; check to make sure that the school districts are same and destination j is a TAZ w/school
        if (dist_Sch2TAZ[i][1] > mw[100]) ; if the distance to the previously selected zone is larger than the distance to current zone
          SCH2NUM[i][1] = j ; replace the TAZ with current zone
          dist_Sch2TAZ[i][1] = mw[100] ; update the distance, loop through remaining js
        endif
      endif
    endjloop 
endif

; Calculate SCH2NUM2 through SCH2NUM10 by initiating a loop SCH2LOOP that corresponds to 2-10
LOOP SCH2LOOP=2,10
  dist_Sch2TAZ[i][SCH2LOOP]=1000 ; Initiate with a large distance which gets replaced when a shorter distance is encountered
  
  ; if the number of schools within the school district is less than the loop number, set school TAZ to 0. For example, the 5th school TAZ for a district that has only 4 schools should be 0
  if (Sch2TAZs[i]<SCH2LOOP) 
    SCH2NUM[i][SCH2LOOP]=0
    else
      jloop ; otherwise loop through all js to pick the next closest school TAZ
        if (District[i]=District[j] & wSch2[j]>0) ; check to make sure that the school districts are same and destination j is a TAZ w/school
          if (dist_Sch2TAZ[i][SCH2LOOP] > mw[100] & mw[100]>=dist_Sch2TAZ[i][SCH2LOOP-1] & j!=SCH2NUM[i][SCH2LOOP-1])
          ; check that the previous distance is larger than the new distance
          ; check that the distance to the current zone is greater than or equal to the previous closest TAZ
          ; check that the current zone is not the same as the previous or (n-1)th TAZ
            if (SCH2LOOP>2) ; check that the current zone is not the same as (n-2)th TAZ
                if (SCH2NUM[i][SCH2LOOP-2]!=j)
                  SCH2NUM[i][SCH2LOOP] = j ; replace the TAZ with current zone
                  dist_Sch2TAZ[i][SCH2LOOP] = mw[100]
                endif
            else
              SCH2NUM[i][SCH2LOOP] = j ; replace the TAZ with current zone
              dist_Sch2TAZ[i][SCH2LOOP] = mw[100] ; update the distance, loop through remaining js
            endif
          endif
        endif
      endjloop 
  endif
ENDLOOP


ARRAY SCH3NUM=Zones,10, dist_Sch3TAZ=Zones,10

; Calculate SCH3NUM1
dist_Sch3TAZ[i][1]=1000 ; Initiate with a large distance which gets replaced when a shorter distance is encountered
if (wSch3[i]>0) ; if the TAZ itself contains a school, then the closest TAZ is itself
  SCH3NUM[i][1]=i
  dist_Sch3TAZ[i][1]=matval(1,dapdist,i,i)
  else 
    jloop ; otherwise loop through all js to pick the closest school TAZ
      if (District[i]=District[j] & wSch3[j]>0) ; check to make sure that the school districts are same and destination j is a TAZ w/school
        if (dist_Sch3TAZ[i][1] > mw[100]) ; if the distance to the previous zone is larger than the distance to current zone
          SCH3NUM[i][1] = j ; replace the TAZ with current zone
          dist_Sch3TAZ[i][1] = mw[100] ; update the distance, loop through remaining js
        endif
      endif
    endjloop 
endif

; Calculate SCH3NUM2 through SCH3NUM10 by initiating a loop SCH3LOOP that corresponds to 2-10
LOOP SCH3LOOP=2,10
  dist_Sch3TAZ[i][SCH3LOOP]=1000 ; Initiate with a large distance which gets replaced when a shorter distance is encountered
  
  ; if the number of schools within the school district is less than the loop number, set school TAZ to 0. For example, the 5th school TAZ for a district that has only 4 schools should be 0
  if (Sch3TAZs[i]<SCH3LOOP) 
    SCH3NUM[i][SCH3LOOP]=0
    else
      jloop ; otherwise loop through all js to pick the next closest school TAZ
        if (District[i]=District[j] & wSch3[j]>0) ; check to make sure that the school districts are same and destination j is a TAZ w/school
          if (dist_Sch3TAZ[i][SCH3LOOP] > mw[100] & mw[100]>=dist_Sch3TAZ[i][SCH3LOOP-1] & j!=SCH3NUM[i][SCH3LOOP-1])
          ; check that the previous distance is larger than the new distance
          ; check that the distance to the current zone is greater than or equal to the previous closest TAZ
          ; check that the current zone is not the same as the previous or (n-1)th TAZ
            if (SCH3LOOP>2) ; check that the current zone is not the same as (n-2)th TAZ
                if (SCH3NUM[i][SCH3LOOP-2]!=j)
                  SCH3NUM[i][SCH3LOOP] = j ; replace the TAZ with current zone
                  dist_Sch3TAZ[i][SCH3LOOP] = mw[100]
                endif
            else
              SCH3NUM[i][SCH3LOOP] = j ; replace the TAZ with current zone
              dist_Sch3TAZ[i][SCH3LOOP] = mw[100] ; update the distance, loop through remaining js
            endif
          endif
        endif
      endjloop 
  endif
ENDLOOP




; Create csv headers
if(i=1)
print csv=T,
printo=1,list="Zone","SCH1NUM1","SCH1NUM2","SCH1NUM3","SCH1NUM4","SCH1NUM5","SCH1NUM6","SCH1NUM7","SCH1NUM8","SCH1NUM9","SCH1NUM10","SCH2NUM1","SCH2NUM2","SCH2NUM3","SCH2NUM4","SCH2NUM5","SCH2NUM6","SCH2NUM7","SCH2NUM8","SCH2NUM9","SCH2NUM10","SCH3NUM1","SCH3NUM2","SCH3NUM3","SCH3NUM4","SCH3NUM5","SCH3NUM6","SCH3NUM7","SCH3NUM8","SCH3NUM9","SCH3NUM10"
endif

; Output actual data
print csv=T,
printo=1,form=10.0,list=i,SCH1NUM[i][1],SCH1NUM[i][2],SCH1NUM[i][3],SCH1NUM[i][4],SCH1NUM[i][5],SCH1NUM[i][6],SCH1NUM[i][7],SCH1NUM[i][8],SCH1NUM[i][9],SCH1NUM[i][10],SCH2NUM[i][1],SCH2NUM[i][2],SCH2NUM[i][3],SCH2NUM[i][4],SCH2NUM[i][5],SCH2NUM[i][6],SCH2NUM[i][7],SCH2NUM[i][8],SCH2NUM[i][9],SCH2NUM[i][10],SCH3NUM[i][1],SCH3NUM[i][2],SCH3NUM[i][3],SCH3NUM[i][4],SCH3NUM[i][5],SCH3NUM[i][6],SCH3NUM[i][7],SCH3NUM[i][8],SCH3NUM[i][9],SCH3NUM[i][10]

ENDRUN


; Script for program MATRIX in file "C:\USERS\MKHAN\DESKTOP\PROJECTS\METCOUNCIL\METCOUNCIL_ABM08102015\CUBE\EVMAT00E.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='University Enrollment'
FILEI ZDATI[1] = "%zone_attribs%_prev.dbf"
FILEI MATI[1] = "%hwy_AMskims%"
FILEO PRINTO[1] = "%SCENARIO_DIR%\universityenrollment.csv"

; This script calculated university enrollment based on 1,2,5 and 10 mile buffers around TAZs.
; Inputs- Highway skim file (HWY_SKIM_4_AM.skm) and Zonal Data File (zones.dbf)
; Output - University Enrollment for each TAZ by distance buffers (universityenrollment.csv)
; Moby Khan 11/2/16

Zones = %int_zones%

; Buffer is based on drive-alone distance
mw[100]=mi.1.dapdist

; Create arrays for each buffers - 1,2,5 and 10 miles
ARRAY ENROLLED1=Zones,ENROLLED2=Zones,ENROLLED5=Zones,ENROLLED10=Zones

; Loop through all j's and sum enrollment if destination j is within the buffer
jloop
  if (mw[100]<=1) ; 1 mile
    ENROLLED1[i] = ENROLLED1[i] + zi.1.ENROLLED[j]
  endif
  if (mw[100]<=2) ; 2 miles
    ENROLLED2[i] = ENROLLED2[i] + zi.1.ENROLLED[j]
  endif
  if (mw[100]<=5) ; 5 miles
    ENROLLED5[i] = ENROLLED5[i] + zi.1.ENROLLED[j]
  endif
  if (mw[100]<=10) ; 10 miles
    ENROLLED10[i] = ENROLLED10[i] + zi.1.ENROLLED[j]
  endif
endjloop


; Create csv headers
if(i=1)
print csv=T,
printo=1,list="Zone","ENROLLED1","ENROLLED2","ENROLLED5","ENROLLED10"
endif

; Output actual data
print csv=T,
printo=1,list=i,form=10.0,list=ENROLLED1[i],ENROLLED2[i],ENROLLED5[i],ENROLLED10[i]


ENDRUN


; Script for program MATRIX in file "C:\USERS\MKHAN\DESKTOP\PROJECTS\METCOUNCIL\METCOUNCIL_ABM08102015\CUBE\EVMAT00F.S"
; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Update Zonal Database'
FILEO RECO[1] = "%zone_attribs%",
form=10.0,FIELDS=ZONE,ZONEID,POPULATION,HOUSEHOLDS,RET_EMP,NRET_EMP,AMC_EMP,MAN_EMP,OFF_EMP,MED1_EMP,MED2_EMP,RST_EMP,K12_EMP,ENT_EMP,TOT_EMP,
form=10.8,FIELDS=AREA,MIX_DENS,
form=10.0,FIELDS=TERM_TIME,
form=10.0,FIELDS=PARK_COST,NONWRKPRK,
form=10.0,FIELDS=ENROLLED,ENROLLED2,ENROLLED5,ENROLLED10,
form=10.8,FIELDS=TETRACC15,TEHWYACC10,REHWYACC10,NEHWYACC10,MEHWYACC10,
form=10.2,FIELDS=EXT_DIST,
form=10.0,FIELDS=CBD,SUBURB3,SUBURB2,RURAL,
form=10.8,FIELDS=HHDENSITY,LOGMXDENS,RETEMPDEN,POPDENS,TOTEMPDEN,TRHWACCRAT,
form=10.0,FIELDS=TW_ACC,SCH1NUM1,SCH1NUM2,SCH1NUM3,SCH1NUM4,SCH1NUM5,SCH1NUM6,SCH1NUM7,SCH1NUM8,SCH1NUM9,SCH1NUM10,SCH2NUM1,SCH2NUM2,SCH2NUM3,SCH2NUM4,SCH2NUM5,SCH2NUM6,SCH2NUM7,SCH2NUM8,SCH2NUM9,SCH2NUM10,SCH3NUM1,SCH3NUM2,SCH3NUM3,SCH3NUM4,SCH3NUM5,SCH3NUM6,SCH3NUM7,SCH3NUM8,SCH3NUM9,SCH3NUM10,DISTRICT
FILEI ZDATI[6] = "%SCENARIO_DIR%\universityenrollment.csv", Z=#1,ENROLLED2=#3,ENROLLED5=#4,ENROLLED10=#5
FILEI ZDATI[5] = "%SCENARIO_DIR%\TAZ_SchoolList.csv", Z=#1,SCH1NUM1=#2,SCH1NUM2=#3,SCH1NUM3=#4,SCH1NUM4=#5,SCH1NUM5=#6,SCH1NUM6=#7,SCH1NUM7=#8,SCH1NUM8=#9,SCH1NUM9=#10,SCH1NUM10=#11,SCH2NUM1=#12,SCH2NUM2=#13,SCH2NUM3=#14,SCH2NUM4=#15,SCH2NUM5=#16,SCH2NUM6=#17,SCH2NUM7=#18,SCH2NUM8=#19,SCH2NUM9=#20,SCH2NUM10=#21,SCH3NUM1=#22,SCH3NUM2=#23,SCH3NUM3=#24,SCH3NUM4=#25,SCH3NUM5=#26,SCH3NUM6=#27,SCH3NUM7=#28,SCH3NUM8=#29,SCH3NUM9=#30,SCH3NUM10=#31
FILEI ZDATI[4] = "%SCENARIO_DIR%\distancetoexternal.csv", Z=#1,EXT_DIST=#2
FILEI ZDATI[3] = "%SCENARIO_DIR%\transit_accessibility.csv", Z=#1,TETRACC15=#6
FILEI ZDATI[2] = "%SCENARIO_DIR%\highway_accessibility.csv", Z=#1,TEHWYACC10=#5,REHWYACC10=#11,NEHWYACC10=#17,MEHWYACC10=#23
FILEI ZDATI[1] = "%zone_attribs%_prev.dbf"


ZONES=%int_zones%

; Update all variables
ro.ZONE=zi.1.ZONE[i]
ro.ZONEID=zi.1.ZONEID[i]
ro.POPULATION=zi.1.POPULATION[i]
ro.HOUSEHOLDS=zi.1.HOUSEHOLDS[i]
ro.RET_EMP=zi.1.RET_EMP[i]
ro.NRET_EMP=zi.1.NRET_EMP[i]
ro.AMC_EMP=zi.1.AMC_EMP[i]
ro.MAN_EMP=zi.1.MAN_EMP[i]
ro.OFF_EMP=zi.1.OFF_EMP[i]
ro.MED1_EMP=zi.1.MED1_EMP[i]
ro.MED2_EMP=zi.1.MED2_EMP[i]
ro.RST_EMP=zi.1.RST_EMP[i]
ro.K12_EMP=zi.1.K12_EMP[i]
ro.ENT_EMP=zi.1.ENT_EMP[i]
ro.TOT_EMP=zi.1.TOT_EMP[i]
ro.AREA=zi.1.AREA[i]
ro.MIX_DENS=zi.1.MIX_DENS[i]
ro.TERM_TIME=zi.1.TERM_TIME[i]
ro.PARK_COST=zi.1.PARK_COST[i]
ro.NONWRKPRK=zi.1.NONWRKPRK[i]
ro.ENROLLED=zi.1.ENROLLED[i]
ro.ENROLLED2=zi.6.ENROLLED2[i]
ro.ENROLLED5=zi.6.ENROLLED5[i]
ro.ENROLLED10=zi.6.ENROLLED10[i]
ro.TETRACC15=zi.3.TETRACC15[i]
ro.TEHWYACC10=zi.2.TEHWYACC10[i]
ro.REHWYACC10=zi.2.REHWYACC10[i]
ro.NEHWYACC10=zi.2.NEHWYACC10[i]
ro.MEHWYACC10=zi.2.MEHWYACC10[i]
ro.EXT_DIST=zi.4.EXT_DIST[i]
ro.CBD=zi.1.CBD[i]
ro.SUBURB3=zi.1.SUBURB3[i]
ro.SUBURB2=zi.1.SUBURB2[i]
ro.RURAL=zi.1.RURAL[i]
ro.HHDENSITY=zi.1.HHDENSITY[i]
ro.LOGMXDENS=zi.1.LOGMXDENS[i]
ro.RETEMPDEN=zi.1.RETEMPDEN[i]
ro.POPDENS=zi.1.POPDENS[i]
ro.TOTEMPDEN=zi.1.TOTEMPDEN[i]
ro.TRHWACCRAT=zi.1.TRHWACCRAT[i]
ro.TW_ACC=zi.1.TW_ACC[i]
ro.SCH1NUM1=zi.5.SCH1NUM1[i]
ro.SCH1NUM2=zi.5.SCH1NUM2[i]
ro.SCH1NUM3=zi.5.SCH1NUM3[i]
ro.SCH1NUM4=zi.5.SCH1NUM4[i]
ro.SCH1NUM5=zi.5.SCH1NUM5[i]
ro.SCH1NUM6=zi.5.SCH1NUM6[i]
ro.SCH1NUM7=zi.5.SCH1NUM7[i]
ro.SCH1NUM8=zi.5.SCH1NUM8[i]
ro.SCH1NUM9=zi.5.SCH1NUM9[i]
ro.SCH1NUM10=zi.5.SCH1NUM10[i]
ro.SCH2NUM1=zi.5.SCH2NUM1[i]
ro.SCH2NUM2=zi.5.SCH2NUM2[i]
ro.SCH2NUM3=zi.5.SCH2NUM3[i]
ro.SCH2NUM4=zi.5.SCH2NUM4[i]
ro.SCH2NUM5=zi.5.SCH2NUM5[i]
ro.SCH2NUM6=zi.5.SCH2NUM6[i]
ro.SCH2NUM7=zi.5.SCH2NUM7[i]
ro.SCH2NUM8=zi.5.SCH2NUM8[i]
ro.SCH2NUM9=zi.5.SCH2NUM9[i]
ro.SCH2NUM10=zi.5.SCH2NUM10[i]
ro.SCH3NUM1=zi.5.SCH3NUM1[i]
ro.SCH3NUM2=zi.5.SCH3NUM2[i]
ro.SCH3NUM3=zi.5.SCH3NUM3[i]
ro.SCH3NUM4=zi.5.SCH3NUM4[i]
ro.SCH3NUM5=zi.5.SCH3NUM5[i]
ro.SCH3NUM6=zi.5.SCH3NUM6[i]
ro.SCH3NUM7=zi.5.SCH3NUM7[i]
ro.SCH3NUM8=zi.5.SCH3NUM8[i]
ro.SCH3NUM9=zi.5.SCH3NUM9[i]
ro.SCH3NUM10=zi.5.SCH3NUM10[i]
ro.DISTRICT=zi.1.DISTRICT[i]

; create output dbf
write reco=1

ENDRUN


