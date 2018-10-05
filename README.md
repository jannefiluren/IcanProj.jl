# ICAN project repository

This repository contains code for performing simulations and analysis for the ICAN project.

## Preparing meteorological forcing data

- Run mtclim using this r-code: [ican_data](https://github.com/jmgnve/ican_data), and in particular the script `mtclim_for_fsm.R`.

- Convert binary outputs to netcdf´s using `mtclim2netcdf.jl`.

- Convert to correct dimensions using `swap_dim_netcdf.jl` and add a time array `time_array_netcdf.jl`.

## Preparing model parameters

- Use the `aggregate_params.jl` script for generating input parameters to the model.

## Running fsm

- Run the model using `start.jl` from this [FSM2](https://github.com/jmgnve/FSM2/tree/netcdf_landuse) repository.

- For a test run, start the model using `FSM < nlstnc.txt`. For the structure of the input data, meteorological and parameters, see references in the `nlstnc.txt` file. 

## Processing model outputs

- Errors for different spatial scales: `table_error_resolutions.jl`.

## Data locations

- Most data is currently located in `/data04/jmg/fsm_simulations/netcdf`.

## Notes about the MTCLIM model

We are using VIC.4.2.d. for MTCLIM, which is documented [here](http://vic.readthedocs.io/en/vic.4.2.d/) and source code available [here](https://github.com/UW-Hydro/VIC/tree/VIC.4.2.b). An list of possible output variables is [here](http://vic.readthedocs.io/en/vic.4.2.d/Documentation/OutputVarList/).
 
- [Documentation of meteorological forcings](http://vic.readthedocs.io/en/vic.4.2.d/Documentation/ForcingData/) foc vic.
- [Documentation of soil parameter file](http://vic.readthedocs.io/en/vic.4.2.d/Documentation/SoilParam/) for vic.
- [Documentation of vegetation parameter file](http://vic.readthedocs.io/en/vic.4.2.d/Documentation/VegParam/) for vic.
- [Documentation of vegetation library file](http://vic.readthedocs.io/en/vic.4.2.d/Documentation/VegLib/) for vic.
- [Documentation of global parameter file](http://vic.readthedocs.io/en/vic.4.2.d/Documentation/GlobalParam/) for vic.
- [Documentation of flux results file](http://vic.readthedocs.io/en/vic.4.2.d/Documentation/FluxOutputFiles/) foc vic.
- [Documentation of snow results file](http://vic.readthedocs.io/en/vic.4.2.d/Documentation/SnowOutputFile/) foc vic.
