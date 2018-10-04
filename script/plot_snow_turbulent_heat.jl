using IcanProj
using NetCDF
using DataFrames
using PyPlot
using Statistics


# Global settings

path = "/data04/jmg/fsm_simulations/netcdf/fsmres_open/results_32"


# Load latent heat fluxes

variable = "latmo"

file_fine = joinpath(path, "$(variable)_1km.nc")

file_coarse = joinpath(path, "$(variable)_50km.nc")

df_links = link_results(file_fine, file_coarse)

latmo_coarse, latmo_aggregated = unify_results(file_fine, file_coarse, df_links, variable)


# Load snow water equivalents

variable = "swe"

file_fine = joinpath(path, "$(variable)_1km.nc")

file_coarse = joinpath(path, "$(variable)_50km.nc")

df_links = link_results(file_fine, file_coarse)

swe_coarse, swe_aggregated = unify_results(file_fine, file_coarse, df_links, variable)

























