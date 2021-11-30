; Do not change filenames or add or remove FILEI/FILEO statements using an editor. Use Cube/Application Manager.


LOOP TOD=1,6,1 ; There are six unique network configurations
 IF(TOD=1) NETNAME='Overnight 7:00 PM to 5:00 AM'
 IF(TOD=2) NETNAME='Reverse Lane Change Over 5:00 AM to 6:00 AM  and 1:00 PM to 2:00 PM'
 IF(TOD=3) NETNAME='AM Peak Period 6:00 AM to 10:00 AM'
 IF(TOD=4) NETNAME='Mid Day Period 10:00 AM to 1:00 PM'
 IF(TOD=5) NETNAME='Pre PM Peak Period 2:00 PM to 3:00 PM'
 IF(TOD=6) NETNAME='PM Peak Period 3:00 PM to 7:00 PM'
