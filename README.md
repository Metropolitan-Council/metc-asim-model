# Metropolitan Council Travel Demand Model

## Overview

This is a model that simulates choices made by people throughout their day - if and when they go to work, school, out to eat, shopping, etc. This is used to forecast the mobility effects of transportation investments.

This model is built in a mixture of Python 3 (ActivitySim) and Cube Voyager (Auxiliary Models, Skimming and Assignment).

**Currently in Development**

## Dependencies

Anaconda 3 64 bit is required to create the environment and run Activitysim. This model also requires a licensed copy of Cube Voyager 6.4, which must be purchased separately. 

## Getting Started

1. Create a folder for all of this to keep organized

2. Navigate to that folder and clone this repository in it

3. Navigate to the metc-asim-model folder, download the inputs from the project Sharepoint site, they should be placed in Input_2022 in the metc-asim-model folder. Inside the Input_2022 folder, there should be nine subfolders.

4. Copy contributed executables to source\Visualizer\Contrib

5. Create the Anaconda environment: `conda env create --name asim131 --file https://raw.githubusercontent.com/Metropolitan-Council/metc-asim-model/refs/heads/main/source/environment.yml`

6. Copy the set_parameters_template.bat file to set_parameters.bat. Edit the paths in the file as appropriate (R, python, model paths)

7. Switch to the Anaconda environment: `conda activate asim131`

8. Run the model with the batch file `met_council_model.bat`

## More Information

Contact Dennis Farmer at the Metropolitan Council for questions regarding the overall model.

Cube Voyager can be purchased from [Bentley](https://www.bentley.com/en/products/product-line/mobility-simulation-and-analytics/cube-voyager)

More information about ActivitySim can be found at the [ActivitySim Website](https://activitysim.github.io/).
