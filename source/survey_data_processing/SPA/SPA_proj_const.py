from collections import defaultdict
import sys
import yaml as yaml
import os


################## Constants ##########################################
COMPUTE_TRIP_DIST = True     #true if trip distance is to be computed from route file
NEGLIGIBLE_DELTA_TIME = 10   #time stamps within this margin of difference can be considered as identical
# DH [02/20/2020] Increased max number of volunteer hours from 120 -> 180
MAX_VOLUNTEER_MINUTES = 180  #work duration le this value is considered volunteer work
MAX_XFERS = 3                #number of place holders for transit transfers in the output trip file
START_OF_DAY_MIN = 180      #3:00am
TIME_WINDOW_BIN_MIN = 30    #bin width in minutes

# DH [02/11/20] Added below to determine whether trip distance should be included when determining
#   primary trip location
USE_DISTANCE_IN_PRIMARY_LOCATION_SCORE = True

if len(sys.argv) > 1:
    settings_file = sys.argv[1]
else:
   settings_file = r'F:/Projects/Clients/MetCouncilASIM/tasks/metc-asim-model/activitysim/survey_data_processing/metc_inputs.yml'


with open(settings_file) as file:
    settings = yaml.full_load(file)

IN_DIR = os.path.join(settings['proj_dir'], 'SPA_Inputs') + '/'
if USE_DISTANCE_IN_PRIMARY_LOCATION_SCORE:
    OUT_DIR = os.path.join(settings['proj_dir'], 'SPA_Processed')  + '/'
else:
    OUT_DIR = path.join(settings['proj_dir'], 'SPA_Processed', 'trip_purp_no_distance') + '/'



SurveyChangeModeCode = 12
SurveyHomeCode = [0]
SURVEY_DO_PU_PURP_CODE = 4
SurveySchoolPurp = [2,3]
SurveyWorkPurp = [1]
SurveyWorkRelatedPurp = 10

################## Dictionaries ##########################################

# BMP - updated to represent trip purposes in TSM surveys
SurveyTpurp2Purp = {  #map TPURP from TSM surveys to the corresponding PURP code
    0: 0,
    1: 1,
    2: 2,
    3: 3,
    4: 4,
    5: 5,
    6: 6,
    7: 7,
    8: 8,
    9: 9,
    10: 10,
    11: 11,
    12: 12,
    13: 13,
    -9: -9
    }

# BMP - updated to represent modes in TSM surveys
# DH [02/03/20] - updated to represent agg modes in SEMCOG survey / design doc
SurveyMode = { #map Survey mode name to mode code
    'SOV': 1,
    'HOV2': 2,
    'HOV3': 3,
    'WALK': 4,
    'BIKE': 5,
    'TAXI': 8,
    'SCHOOLBUS': 11,
    'TRANSIT-LOCAL': 6,
    'TRANSIT-PREMIUM': 7,
    'TNC-SINGLE': 9,
    'TNC-SHARED': 10,
    'OTHER': 12
    }

# BMP - survey definition for driver/passanger
SurveyDriver = {
    'DRIVER': 1,
    'PASSENGER': 0,
    'NA': 995
    }

# BMP - survey definition for toll payment
SurveyToll = {
    'TOLL': 1,
    'NOTOLL': 0
    }

SurveyTbus2TransitType = defaultdict(lambda: 'BUS', {1: 'BUS', 2: 'LRT', 3: 'BRT'})
