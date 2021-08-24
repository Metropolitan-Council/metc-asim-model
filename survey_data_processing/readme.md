# MetCouncil HTS Data Processing for Model Comparisons

## Step 0: Pre-requisites

* Create Python environment
  * The Python libraries for running ActivitySim are inclusive of those needed to run the Survey Processing App
  * Thus -- you can use the environment.yml file in the metc-asim-model repo
  * If you have Conda installed -- run in the command line: conda env create -f environment.yml 
  * Troubleshooting: I had to move some conda packages into Pip in a copy of the environment.yml to install them (might have related to my version of Conda).   

* Confirm you have R installed (version 4.0.2 or higher)
  * Rstudio is also handy!

* Download or confirm you have data available
  * Raw survey data files (unlabeled)
  * Labeled survey data files (includes TAZs)
  * TAZ shapefile for the region
  * Skims matrix with distance skims between TAZs

* Create/edit settings file with filepaths
  * Example: survey_data_processing/metc_settings.yaml (edit or replace this)
  * Replace file paths with file/folder paths you'll use 
  * For visualizer sub-folders; you can re-create the same folder structure expressed in the existing settings
    * Mostly applies to the Visualizer/data/calibration_runs/summarized subfolder
  * Data processing scripts read the settings file so that you don't have to change the path references in every script
	* You DO need to change the settings file path in the scripts that reference it if you're not running from the .bat file (to reference the correct path on your computer/server)

## To run automatically & skip the steps 1-5:

* Data prep, SPA, and visualizer summaries:
	* run_data_prep_scripts.bat
	* Edit the settings file path
	* Run via command line
* Run the visualizer (see step 6)

Otherwise -- to run each script and confirm things look good -- follow the steps below!

## Step 1: Format HTS data to be used in Survey Processing Application (SPA)

Time: <5 minutes

* Script: pre_spa_processing.R
* Inputs needed: Raw HTS data (unlabeled); labeled HTS data (for cleaned timestamps); folder for SPA inputs (create the folder if you don't have one)
* Ensure that the settings file path in the script is pointing to the right file
* Run the script -- if any filepaths are wrong in the settings, fix and run again. 
* What the script does:
  * Aggregates certain fields so that the SPA tool is set up to map them to the correct model format
  * Formats the "trips" file as a "place" file with a record at the beginning of each day
  * Derives other fields like departure/arrival hour/minute
  * Outputs edited files, including four "place" files (one for each day of week)
 

## Step 2: Run SPA

Time: ~1 hour (varies by machine)

* Script: _init_.py
* Ensure that the settings file path is pointing to the right file
* Run the script
* Check that outputs are in the SPA Processed folder under day 1, 2, 3, and 4 sub-folders
* What the tool does:
  * Links change mode trips together
  * Processes trips into tours and joint tours
  * Re-codes modes/purposes to match model formats

## Step 3: Prepare survey data summaries for Visualizer dashboard

* Script: MetC_visualizer_prep.R
* Ensure that the settings file path is pointing to the right file
* Ensure you're in a brand new R environment (restart R session or restart RStudio)
* Run the script
* What the script does:
  * Creates summaries of the survey data
  * Stores summaries in specified path for use in the visualizer
  
Time: ~5 minutes

## Step 4: Prepare Census data summaries for Visualizer dashboard

* Note that these have been pushed to git, BUT you can re-create them with the scripts if needed.
* Script: Visualizer/Get_census_data_CMAP.R
* Script: Visualizer/AutoOwnership_Census_CMAP.R
* Edit settings & params files
* These scripts generate Visualizer summaries based on census/ACS data.

Time: ~5 minutes

## Step 5: Prepare ActivitySim output summaries for Visualizer dashboard

* Script: Summarize_ActivitySim_metc.R
* Ensure that the settings file path is pointing to the right file
* Run the script
* What the script does:
  * Splits tour/trip model outputs into joint tours/trips
  * Creates summaries of the model outputs for the Visualizer

Time: ~45 minutes

## Step 6: Run the visualizer

* Script: generateDashboard_metc_vs_asim.bat
* Edit the various paths/inputs as needed -- R location, settings file, etc.
* Run via the command line
