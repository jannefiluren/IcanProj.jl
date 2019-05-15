using IcanProj
using Statistics
using PyPlot
using NetCDF
using Dates
using JFSM2
using StatsBase
using DataFrames


cfg = 32

variable = "swe"

file_fine = "/data04/jmg/fsm_simulations/netcdf/fsmres_forest/results_$(cfg)/$(variable)_1km.nc"

file_coarse = "/data04/jmg/fsm_simulations/netcdf/fsmres_forest/results_$(cfg)/$(variable)_50km.nc"

df_links = link_results(file_fine, file_coarse)

data_coarse, data_aggregated, ngrids  = unify_results(file_fine, file_coarse, df_links, variable)

disallowmissing!(df_links)

df_agg = aggregate(df_links, :id_coarse, [mean, skewness, median])

bias = mean(data_coarse - data_aggregated, dims = 1)

bias = dropdims(bias, dims = 1)

scatter(df_agg.elev_median .- df_agg.elev_mean, bias)

bias(df_agg.elev_skewness[.!isnan.(df_agg.elev_skewness)], bias[.!isnan.(df_agg.elev_skewness)])