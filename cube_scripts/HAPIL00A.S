; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.

;NEXTITER = ITER + 1

LOOP TOD=1,4,1
 IF(TOD=1) PER='AM' ASSIGNNAME='AM Peak Period'    HWY_NET ='HWY_NET_3.net'    NETNAME='AM Peak Period 6:00 AM to 10:00 AM'  CAPFAC = 3.75
 IF(TOD=2) PER='MD' ASSIGNNAME='Mid Day Period'    HWY_NET ='HWY_NET_4.net'    NETNAME='Mid Day Period 10:00 AM to 3:00 PM'  CAPFAC = 4.48
 IF(TOD=3) PER='PM' ASSIGNNAME='PM Peak Period'    HWY_NET ='HWY_NET_6.net'    NETNAME='PM Peak Period 3:00 PM to 7:00 PM'   CAPFAC = 3.9
 IF(TOD=4) PER='NT' ASSIGNNAME='Night'             HWY_NET ='HWY_NET_1.net'    NETNAME='Overnight 7:00 PM to 6:00 AM'        CAPFAC = 4.65

