SET MKL_NUM_THREADS=1

REM Run Cube Skimming, externals, freight, etc (TODO)

REM Run Activitysim
python simulation.py -c configs_mp -c configs -d data -o output_1003

REM Run Cube Assignment (TODO)