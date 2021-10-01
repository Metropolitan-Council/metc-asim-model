SET MKL_NUM_THREADS=1
SET CUBE="C:\Program Files\Citilabs\CubeVoyager\Voyager.exe"
SET OUTFOLDER="output"
REM Run Cube Skimming, externals, freight, etc (TODO)

REM Run Activitysim
python simulation.py -c configs_mp -c configs -d data -o %OUTFOLDER%

REM Run Cube Assignment (TODO)
%CUBE% cube\convertOutputMatrices.s /Start