; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='University Enrollment'
FILEI ZDATI[1] = "%SCENARIO_DIR%\zones_%PREV_ITER%.dbf"
FILEI MATI[1] = "%SCENARIO_DIR%\HWY_SKIM_%PREV_ITER%_AM.skm"
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
