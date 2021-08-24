# Metropolitan Council ActivitySim Model

## Overview

This is a model that simulates choices made by people throughout their day - if and when they go to work, school, out to eat, shopping, etc. This is used to forecast the effects of transportation investments.

This model is built in a mixture of Python 3 (ActivitySim) and Cube Voyager (Skimming and Assignment).

**Currently in Development**

## Dependencies

Anaconda 3 64 bit is required to create the environment and run Activitysim. This model also requires a licensed copy of Cube Voyager 6.4, which must be purchased separately. 

## Getting Started

1. Create an Anaconda environment: `conda env create -f environment.yml`

2. Install the correct version of ActivitySim with `pip install activitysim==1.0.2`

3. Create a data subfolder and copy the input data to it

4. Run ActivitySim with the batch file `runAsim.bat`

(expect this to change as the model is developed)

### Settings

The settings.yml should be adjusted based on the size of the model. 

**Small Sample** 

For a small sample of 500 households, set the following:
```
multiprocess: False
num_processes: 1
chunk_training_mode: disabled
```

**Large Sample**

For a large sample, such as the entire model region, set the following:

```
multiprocess: True
num_processes - set to the number of processes to use, should be less than or equal to the number of physical cores 
chunk_size - set to a decent amount (500_000_000 has been used in development, indicating 500,000,000 / 500 MB RAM; this should probably be considered a minimum)
```

(note that the above portion related to the entire model may change)
