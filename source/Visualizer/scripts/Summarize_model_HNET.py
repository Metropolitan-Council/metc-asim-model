#
# ReadNets.py - file to do some reading and summarizing of loaded highway networks (as dbf or csv)
# 
# Andrew Rohne RSG 3/2022
#
# Reads network DBF files (AM, PM, MD, EV, ON), compiles data for ActivitySim Visualizer
# Assumes that this is run within the model stream - uses environment variables setup by
# the model batch file.
#
# NOT FULLY TESTED - Works with Metropolitan Council data, but did not test if it would 
# work with added period labels, etc.

import pandas as pd
from simpledbf import Dbf5
import os
import numpy as np

model_path = os.environ['SCENARIO_DIR']
vis_path = os.environ['VIS_MODEL_DATA_FOLDER']
net_in_path = os.environ['NETWORK_FOLDER']
print(f"Reading Highway Loading Results from {model_path}")

hnetfile = 'HWY_LDNET_4_DAILY.dbf'
periods_labels = {'DAILY': 'Daily', 'AM': 'AM Peak', 'MD': 'Midday', 'PM': 'PM Peak', 'NT': 'Night'}
#count_fields = {'DAILY': 'COUNT', 'AM': 'AM_CNT', 'MD': 'MD_CNT', 'PM': 'PM_CNT', 'NT': 'NT_CNT'}
count_fields = {'DAILY': 'vol_daily', 'AM': 'vol_am', 'MD': 'vol_md', 'PM': 'vol_pm', 'NT': 'vol_on'}
assign_fields = {'DAILY': 'VOL_TOT_DAI', 'AM': 'VOL_TOT_AM', 'MD': 'VOL_TOT_MD', 'PM': 'VOL_TOT_PM', 'NT': 'VOL_TOT_NT'}

rmseGroups = [0, 500, 1500, 2500, 3500, 4500, 5500, 7000, 8500, 10000, 12500, 15000, 17500, 20000, 25000, 35000, 55000, 75000, 120000, 250000]
rmseLimits = [200, 100, 62, 54, 48, 45, 42, 39, 36, 34, 31, 30, 28, 26, 24, 21, 18, 12, 12]

# Reading counts file from inputs
print(f"Reading traffic counts from {net_in_path}")
countsfile = "combined_2018_volumes.csv"


# NOTE: ftCol is the name of the facility type column, check code if it's "FTYPE". ftTrans needs to match _SYSTEM_VARIABLES.R hnet_ft
ftCol = "RCI"
ftTrans = {1: "Freeway", 2: "Freeway",  3: "Expressway",4: "Arterial", 5: "Arterial", 6: "Arterial", 7: "Arterial", 8: "Arterial", 9: "Arterial", 10: "Collector", 11: "Arterial", 12: "Collector", 13: "Ramp", 14: "Ramp", 15: "Collector"}
countyColumn = "COUNTY"
lengthColumn = "DISTANCE"
distMult = 1.0 # in case the distance needs to be converted to another unit

# Don't change anything under this comment
if hnetfile[-4:].lower() == ".dbf":
	hnet = Dbf5(os.path.join(model_path, hnetfile)).to_dataframe()
elif hnetfile[-4:].lower() == ".csv":
	hnet = pd.read_csv(os.path.join(model_path, hnetfile))
else:
	raise ValueError('HNET File is not supported')
    
if countsfile[-4:].lower() == ".dbf":
    counts = Dbf5(os.path.join(net_in_path, countsfile)).to_dataframe()
elif countsfile[-4:].lower() == ".csv":
    counts = pd.read_csv(os.path.join(net_in_path, countsfile))
else:
    raise ValueError('Counts file is not supported')
    
    
hnet = hnet.merge(counts, on = ['A', 'B'], how = 'left')

print(f"Counted Daily VMT: {(hnet[count_fields['DAILY']] * hnet[lengthColumn] * distMult).sum()}")

print(f"Assigned Daily VMT: {(hnet[hnet[count_fields['DAILY']] > 0][assign_fields['DAILY']] * hnet[hnet[count_fields['DAILY']] > 0][lengthColumn] * distMult).sum()}")

# Export HNET first (for assignment summaries)
hnet['FTYPE'] = hnet[ftCol].map(ftTrans)
if countyColumn != "COUNTY":
	hnet.rename(columns = {countyColumn: "COUNTY"}, inplace = True) #NOTE: Untested
	
hnet.rename(columns = {assign_fields['DAILY']: 'DY_ASN', count_fields['DAILY']: 'DY_CNT', assign_fields['AM']: 'AM_ASN', count_fields['AM']: 'AM_CNT', assign_fields['MD']: 'MD_ASN', count_fields['MD']: 'MD_CNT', assign_fields['PM']: 'PM_ASN', count_fields['PM']: 'PM_CNT', assign_fields['NT']: 'NT_ASN', count_fields['NT']: 'NT_CNT'}).to_csv(os.path.join(vis_path, "hnetcnt.csv"), index = False)

asnvmt = []
for k, v in periods_labels.items():
	asnvmt.append(pd.concat([hnet.groupby('FTYPE').apply(lambda s: pd.Series({"COUNTY": "Total", "Period": k, "nLinks": s.shape[0], "vmt": np.sum(s[assign_fields[k]] * s[lengthColumn] * distMult)})).reset_index(),hnet.groupby(['FTYPE', 'COUNTY']).apply(lambda s: pd.Series({"Period": k, "nLinks": s.shape[0], "vmt": np.sum(s[assign_fields[k]] * s[lengthColumn] * distMult)})).reset_index(),hnet.groupby('COUNTY').apply(lambda s: pd.Series({"FTYPE": "Total", "Period": k, "nLinks": s.shape[0], "vmt": np.sum(s[assign_fields[k]] * s[lengthColumn] * distMult)})).reset_index()]))

outasnvmt = pd.concat(asnvmt)
outasnvmt.to_csv(os.path.join(vis_path, "asnvmt.csv"), index = False)

hnet = hnet[(hnet[count_fields['DAILY']] > 0) & (~hnet[count_fields['DAILY']].isna())]
hnet = hnet.reset_index()
hnet['vg'] = pd.cut(hnet['COUNT'], rmseGroups, right = False)
rmse = []
for k, v in periods_labels.items():
    rmse.append(hnet[(hnet[count_fields[k]] > 0) & (~hnet[count_fields[k]].isna())].groupby('vg').apply(lambda s: pd.Series({f"n_{k}": s[count_fields[k]].shape[0], f"mae_{k}": np.abs(s[count_fields[k]] - s[assign_fields[k]]).mean(), f"rmse_{k}": np.sqrt(np.power(s[count_fields[k]] - s[assign_fields[k]], 2).mean()), f"prmse_{k}": np.sqrt(np.power(s[count_fields[k]] - s[assign_fields[k]], 2).mean()) / (s[count_fields[k]].sum() / (s[count_fields[k]].count()-1)) if s[count_fields[k]].count() > 1 else 0})).reset_index())
outrmse = rmse[0]
for x in range(1, len(rmse)):
	outrmse = outrmse.merge(rmse[x], on = 'vg')
outrmse['limit'] = rmseLimits
outrmse.to_csv(os.path.join(vis_path, "hassign_vgsum.csv"), index = True, index_label="vgidx")

vmtcomp = []
for k, v in periods_labels.items():
    vmtcomp.append(hnet[(hnet[count_fields[k]].fillna(0) > 0)].groupby('FTYPE').apply(lambda s: pd.Series({f"n_{k}": s[count_fields[k]].shape[0], f"obsvmt_{k}": np.sum(s[count_fields[k]] * s[lengthColumn] * distMult), f"asnvmt_{k}": np.sum(s[assign_fields[k]] * s[lengthColumn] * distMult)})))
outvmtcomp = vmtcomp[0]
for x in range(1, len(vmtcomp)):
    outvmtcomp = outvmtcomp.merge(vmtcomp[x], on = 'FTYPE')
outvmtcomp.to_csv(os.path.join(vis_path, "hassign_vmtcomp.csv"), index = True, index_label="FTYPE")

# Overall summaries

overall = pd.DataFrame([{'cntDyVMT': (hnet[count_fields['DAILY']].fillna(0) * hnet[lengthColumn] * distMult).sum()},
{'AsnDyVMT_LWC': (hnet[hnet[count_fields['DAILY']].fillna(0) > 0][assign_fields['DAILY']] * hnet[hnet[count_fields['DAILY']].fillna(0) > 0][lengthColumn] * distMult).sum()},
{'cntDyTot': hnet[count_fields['DAILY']].fillna(0).sum()},

{'cntN': hnet[hnet[count_fields['DAILY']].fillna(0) > 0].count()}])

print(overall)


"""

{'DyRMSE': np.sqrt(np.power(s[count_fields[k]] - s[assign_fields[k]], 2).mean()) / (s[count_fields[k]].sum() / (s[count_fields[k]].count()-1))
"""