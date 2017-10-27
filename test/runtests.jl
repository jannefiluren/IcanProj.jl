using IcanProj
using Base.Test


##########################################################################

# Code for preparing data to vic and running simulations

# 1. Prepare metadata for the experiment catchments

#include("metadata_script.jl")

# 2. Prepare vic input files using the metadata

#include("vic_setup_data.jl")

# 3. Run vic simulations

include("run_vic.jl")


##########################################################################

# Code for tranforming vic raw output files into usable format

# 1. Average vic output and store in dataframes

#include("process_vic_output.jl")










##########################################################################

# Plotting scripts

# include("plots_script.jl")






