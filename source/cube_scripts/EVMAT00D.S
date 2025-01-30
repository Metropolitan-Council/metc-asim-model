; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='School TAZs'

FILEO PRINTO[1] = "%SCENARIO_DIR%\TAZ_SchoolList.csv"
FILEI ZDATI[1] = "%SE%\SchoolTAZs.csv",
Z=#1,District=#2,Sch1TAZs=#3,Sch2TAZs=#4,Sch3TAZs=#5,wSch1=#6,wSch2=#7,wSch3=#8
FILEI MATI[1] = "%SCENARIO_DIR%\HWY_SKIM_%PREV_ITER%_MD.skm"

; This script outputs 10 closest school TAZs for each TAZ
; Inputs- Highway skim file (HWY_SKIM_4_AM.skm) and list of TAZs with school Districts, Number of school TAZs within district and school TAZ indicator
; Output - List of 10 closest TAZs in order for three types of schools, for each TAZ in the model
; Moby Khan 11/2/16

Zones = %int_zones%

; Use SR offpeak distance to identify closest schools
mw[100]=mi.1.a2pdist

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
