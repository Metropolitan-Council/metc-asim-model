# Metropolitan Council Travel Demand Model

## Overview

This is a model that simulates choices made by people throughout their day - if and when they go to work, school, out to eat, shopping, etc. This is used to forecast the mobility effects of transportation investments.

This model is built in a mixture of Python 3 (ActivitySim) and Cube Voyager (Auxiliary Models, Skimming and Assignment). The main model batch file was built by WSP, and modified by RSG to remove TourCast and implement ActivitySim.

**Currently in Development**

## Dependencies

Anaconda 3 64 bit is required to create the environment and run Activitysim. This model also requires a licensed copy of Cube Voyager 6.4, which must be purchased separately. 

## Getting Started

1. Create an Anaconda environment: `conda env create -f environment.yml`

2. Create a data subfolder and copy the input data to it. For various reasons, this data is not 

3. Run the model with the batch file `runAsim.bat`

## More Information

Contact Dennis Farmer at the Metropolitan Council for questions regarding the overall model.

Cube Voyager can be purchased from [Bentley](https://www.bentley.com/en/products/product-line/mobility-simulation-and-analytics/cube-voyager)

More information about ActivitySim can be found at the [ActivitySim Website](https://activitysim.github.io/).