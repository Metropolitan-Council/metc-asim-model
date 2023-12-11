import pandas as pd
from simpledbf import Dbf5
import numpy as np
import sys
import os

def read_config(filename):
	f = open(filename)
	config_dict = {}
	for lines in f:
		items = lines[4:].split('=', 1)
		if len(items)>1:
			config_dict[items[0].strip()] = items[1].strip()
	return config_dict

# Read Arguments
if len(sys.argv) < 2:
	print("Incorrect number of arguments")
	sys.exit(2)
	
print("Preparing data for ActivitySim...")
cfg = read_config(sys.argv[1])

INPUT_FOLDER = cfg['MAIN_DIRECTORY'] + cfg['SE'].strip('%MAIN_DIRECTORY%') + os.sep

OUTPUT_FOLDER = INPUT_FOLDER #cfg['MAIN_DIRECTORY'] + cfg['ASIM_DATA'].strip('%MAIN_DIRECTORY%') + os.sep

INPUT_HH = cfg['HH_NAME']
INPUT_PERSON = cfg['POP_NAME']
INPUT_ZONES = cfg['ZONE_NAME']
SCHOOL_LOCATIONS = cfg['SCHOOL_TAZ']
TAZ_TO_COUNTY = cfg['TAZ_COUNTY']

# Households
def runHH():
	try:
		dbfFile = Dbf5(INPUT_FOLDER + INPUT_HH)
	except FileNotFoundError:
		print(f"The input household file is not found, expected to be at {INPUT_FOLDER + INPUT_HH}. Check files and paths in set_parameters.txt.")
		return(2)
	hhDf = dbfFile.to_dataframe()
	hhDf.rename(columns = {"HHID": "household_id"}, inplace = True)
	hhDf.set_index("household_id", inplace = True)
	hhDf.to_csv(OUTPUT_FOLDER + "households.csv")
	return(0)

# Persons
def runPer():
	try:
		dbfFile = Dbf5(INPUT_FOLDER + INPUT_PERSON)
	except FileNotFoundError:
		print(f"The input persons file is not found, expected to be at {INPUT_FOLDER + INPUT_PERSON}. Check files and paths in set_parameters.txt.")
		return(2)
	personDf = dbfFile.to_dataframe()
	personDf.rename(columns = {"PERSONID": "person_id", "HHID": "household_id"}, inplace = True)
	personDf.set_index("person_id", inplace = True)
	personDf['member_id'] = personDf.groupby(["household_id"]).cumcount() + 1
	personDf.to_csv(OUTPUT_FOLDER + "persons.csv")
	return(0)

# Zones
def runZones():
	try:
		dbfFile = Dbf5(INPUT_FOLDER + INPUT_ZONES)
	except FileNotFoundError:
		print(f"The input zonal data file is not found, expected to be at {INPUT_FOLDER + INPUT_PERSON}. Check files and paths in set_parameters.txt.")
		return(2)
	landUseDf = dbfFile.to_dataframe()
	landUseDf.rename(columns = {"ZONE": "zone_id"}, inplace = True)
	landUseDf.set_index("zone_id", inplace = True)
	landUseDf.sort_index(inplace = True)
	landUseDf['area_type'] = np.array(landUseDf[['CBD', 'SUBURB3', 'SUBURB2', 'RURAL']]).nonzero()[1]+1
	try:
		schoolLocs = pd.read_csv(INPUT_FOLDER + SCHOOL_LOCATIONS).rename(columns = {'TAZ': 'zone_id'}) 
		schoolLocs.set_index('zone_id', inplace = True)
	except FileNotFoundError:
		print(f"The input school location file is not found, expected to be at {INPUT_FOLDER + SCHOOL_LOCATIONS}. Check files and paths in set_parameters.txt.")
		return(2)
	
	landUseDf = landUseDf.join(schoolLocs, how = 'left')
	landUseDf['K_8'] = landUseDf['K_8'].fillna(0)
	landUseDf['G9_12'] = landUseDf['G9_12'].fillna(0)
	try:
		dbfFile = Dbf5(INPUT_FOLDER + TAZ_TO_COUNTY)
	except FileNotFoundError:
		print(f"The input TAZ-County Name correspondence file is not found, expected to be at {INPUT_FOLDER + TAZ_TO_COUNTY}. Check files and paths in set_parameters.txt.")
		return(2)
	coTaz = dbfFile.to_dataframe()
	coTaz.rename(columns = {"N": "zone_id", "NAME": "COUNTY"}, inplace = True)
	coTaz.set_index("zone_id", inplace = True)
	coTaz.sort_index(inplace = True)
	landUseDf = landUseDf.join(coTaz[['COUNTY', 'STATEFP']])
	try:
		mldist = pd.read_csv(os.path.join(cfg['MAIN_DIRECTORY'], cfg['SCENARIO_NAME'], 'nearestml.csv')).set_index('zone_id')
	except FileNotFoundError:
		print(f"The managed lanes distance file is not found")
		return(2)
	landUseDf = landUseDf.join(mldist)
	landUseDf.to_csv(OUTPUT_FOLDER + "land_use.csv")
	return(0)

print("Preparing Zones for ActivitySim...")
rc = runZones()
if rc > 0:
	print("There were errors preparing data for ActivitySim. RUN FAILED.")
	sys.exit(2)

print("Preparing Synthetic Households for ActivitySim...")
rc = runHH()
if rc > 0:
	print("There were errors preparing data for ActivitySim. RUN FAILED.")
	sys.exit(2)
	
print("Preparing Synthetic Population for ActivitySim...")
rc = runPer()
if rc > 0:
	print("There were errors preparing data for ActivitySim. RUN FAILED.")
	sys.exit(2)
	
print("Reticulating Splines...")