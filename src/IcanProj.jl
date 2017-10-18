module IcanProj


using ExcelReaders
using DataFrames
using NveData
using Query
using JLD2
using FileIO
using PyPlot


# Global variables

const stat_sel = ["191.2", "122.11"] ###, "2.32", "2.279", "224.1", "2.142", "12.70", "62.5", "22.4"]

export stat_sel


# Handle metadata

export WatershedData, load_metadata, clean_metadata, get_watershed_data

include("metadata.jl")


# Functions for handling vic data

export write_global_param, write_soil_params, write_vic_forcing, write_veg_params

export read_soil_params, read_veg_param

export read_vic_forcing, read_mtclim

export read_fluxes, read_all_fluxes, read_snow, read_all_snow

include("vic_io.jl")


# Function for aggregating data (from finer to courser grid resolution)

export average_forcings, average_soilparams, average_vegparams

include("vic_agg.jl")








# Plotting functions

export analysis_elevation

include("plots/analysis_elevation.jl")



end
