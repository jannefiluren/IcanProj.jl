
using IcanProj
using NetCDF
using DataFrames
using PyPlot
using Statistics


# Settings

cfg = 32

variable = "rnet"

file_fine = "/data04/jmg/fsm_simulations/netcdf/fsmres_forest/results_$(cfg)/$(variable)_1km.nc"

file_coarse = "/data04/jmg/fsm_simulations/netcdf/fsmres_forest/results_$(cfg)/$(variable)_50km.nc"

#file_fine = "/data04/jmg/fsm_simulations/netcdf/forcings_st/$(variable)_1km.nc"

#file_coarse = "/data04/jmg/fsm_simulations/netcdf/forcings_st/$(variable)_50km.nc"


# Load data

df_links = link_results(file_fine, file_coarse)

data_coarse, data_aggregated, ngrids  = unify_results(file_fine, file_coarse, df_links, variable)


# Compute metrics

rmse = sqrt.(mean((data_coarse .- data_aggregated).^2 , dims = 1))

meanref = mean(data_aggregated, dims = 1)

meancmp = mean(data_coarse, dims = 1)

nrmse = rmse ./ meanref

bias = (meancmp .- meanref)

nse = 1 .- var(data_coarse .- data_aggregated, dims = 1) ./ var(data_aggregated .- mean(data_aggregated, dims = 1), dims = 1)


# Project to map

rmse_map = project_results(rmse[:], df_links)

meanref_map = project_results(meanref[:], df_links)

meancmp_map = project_results(meancmp[:], df_links)

nrmse_map = project_results(nrmse[:], df_links)

bias_map = project_results(bias[:], df_links)

nse_map = project_results(nse[:], df_links)


# Plot results

figure()
imshow(rmse_map)
cb = colorbar()
cb[:set_label]("RMSE (-)")
title(variable)


figure()
imshow(bias_map)
cb = colorbar()
cb[:set_label]("BIAS (-)")
title(variable)
