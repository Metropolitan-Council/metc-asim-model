; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.
RUN PGM=NETWORK MSG='Set Managed Lanes for: %NETNAME%'

FILEI LINKI[1] = "%SCENARIO_DIR%\ALL_NET.net"
FILEO NETO = "%SCENARIO_DIR%\HWY_NET_%TOD%.net"


  IF (RCI=100) DELETE ; Remove Rail
  IF (Bike=1) DELETE ;Remove Bike paths
  
  IF (RCI=98 | RCI=101) DELETE

  ;ENDIF

; Rachel editing below to reflect HOV/mnpass of increased revenue scenario. will also work for the current revenue scenario and the existing 2040 model. 
  IF (HOV > 0)
  ;HOV Lane Configurations
  ;MnPass On is the default condition
   _ON=1
  ;For Mainline Lane ADD and MINUS the default condition is Zero - depending how the lane is coded, some require adding lanes when MNPASS off and some require reducing mainline lanes when mnpass is on. see Rewriting_HOVScripts_HNNETOOC.xlxs and FullMakeNetworkXX.s for HOV groupings 
   _ADD=0

  IF (%TOD%=1) ; Overnight 7:00 PM to 5:00 AM , all off 
    IF (HOV=1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,61) ;MnPass Off
      _ON=0
    ENDIF
    IF (HOV=111,112,113,114,118,119,122,123,126,127,130,131,132,133,134,135,136,137,139,141,142,143,144,145) ;Mainline Lane increase when off 
      _ADD=1
    ENDIF
  ENDIF
  
  IF (%TOD%=2)  ; Reverse Lane Change over 5:00 AM to 6:00 AM  and 1:00 PM to 2:00 PM ; all off same as above 
    IF (HOV=1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,61) ;MnPass Off
      _ON=0
    ENDIF
    IF (HOV=111,112,113,114,118,119,122,123,126,127,130,131,132,133,134,135,136,137,139,141,142,143,144,145) ;Mainline Lane increase when off 
      _ADD=1
    ENDIF
  ENDIF  
  
  IF (%TOD%=3)  ; AM Peak Period 6:00 AM to 10:00 AM
    IF (HOV=2,3,4,6,8,10,11,13,17,19,20,22,25,27,29,31,33,35,40,41,42,45) ;MnPass Off
      _ON=0
    ENDIF
    IF (HOV=101,105,107,109,121,124,128,138) ;Mainline Lane Decrease
      _ADD=-1
    ENDIF
    IF (HOV=111,113,119,122,127,131,133,135,141,142,145) ;Mainline Lane increase when off 
      _ADD=1
    ENDIF
  ENDIF  
  
  IF (%TOD%=4)  ; Mid Day Period 10:00 AM to 1:00 PM same as overnight, first TOD period
    IF (HOV=1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,61) ;MnPass Off
      _ON=0
    ENDIF
    IF (HOV=111,112,113,114,118,119,122,123,126,127,130,131,132,133,134,135,136,137,139,141,142,143,144,145) ;Mainline Lane increase when off 
      _ADD=1
    ENDIF
  ENDIF
  
  IF (%TOD%=5)  ; Pre PM Peak Period 2:00 PM to 3:00 PM same as overnight, first period 
    IF (HOV=1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,61) ;MnPass Off
      _ON=0
    ENDIF
    IF (HOV=111,112,113,114,118,119,122,123,126,127,130,131,132,133,134,135,136,137,139,141,142,143,144,145) ;Mainline Lane increase when off 
      _ADD=1
    ENDIF
  ENDIF
  
  IF (%TOD%=6)  ; PM Peak Period 3:00 PM to 7:00 PM
    IF (HOV=1,3,5,7,9,10,12,14,18,21,23,24,26,28,30,32,34,38,39,43,44,61) ;MnPass Off
      _ON=0
    ENDIF
    IF (HOV=102,104,108,117,120,125,129,140) ;Mainline Lane Decrease
      _ADD=-1
    ENDIF
    IF (HOV=112,114,118,123,126,130,132,134,139,143,144) ;Mainline Lane Increase
      _ADD=1
    ENDIF
  ENDIF
  
  ; Update capacity
  IF (_ON=1) 
    Capacity=Capacity * ((lanes+_ADD) / lanes)
  ELSE 
    Capacity = 0
  ENDIF
  
  ENDIF  ; HOV links
  
ENDRUN
