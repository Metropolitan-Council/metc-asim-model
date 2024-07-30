RUN PGM=NETWORK MSG='Add counts'
FILEO NETO = "%SCENARIO_DIR%\highway\ValidationCk.NET"
FILEI NETI[1] = "%SCENARIO_DIR%\highway\HWY_LDNET_4_DAILY.NET"
FILEI LINKI[2] = "E:\Met_Council\metc-asim-model\source\validation\highway_assignment\counts_for_net.csv",
 VAR=A,B,Count_AM,Count_MD,Count_PM,Count_NT,Count_DY
FILEO LINKO = "%SCENARIO_DIR%\highway\Valid_Ck.SHP" FORMAT=SHP

VGRATIO = 0

IF(LI.2.COUNT_DY > 0)
	VGRATIO = LI.1.VOL_AUTO_DAILY / LI.2.COUNT_DY
ENDIF
ENDRUN