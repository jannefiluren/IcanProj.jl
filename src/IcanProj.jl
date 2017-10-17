module IcanProj


using ExcelReaders
using DataFrames
using NveData
using Query
using JLD2
using FileIO


# Global variables

const stat_sel = ["191.2", "122.11", "2.32", "2.279", "224.1", "2.142", "12.70", "62.5", "22.4"]

export stat_sel


# Handle metadata

export WatershedData, load_metadata, clean_metadata, get_watershed_data

include("metadata.jl")




end
