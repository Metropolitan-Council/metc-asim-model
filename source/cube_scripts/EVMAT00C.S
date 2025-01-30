; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=MATRIX MSG='Distance to External'

FILEO PRINTO[1] = "%SCENARIO_DIR%\distancetoexternal.csv"
FILEI MATI[1] = "%SCENARIO_DIR%\HWY_SKIM_%PREV_ITER%_MD.skm"

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
