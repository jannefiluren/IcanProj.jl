
using IcanProj
using NetCDF
using ProgressMeter
using DataFrames
using PyPlot


# Settings

file_fine = "/data02/Ican/vic_sim/fsm_past_1km/netcdf_old/hs_1km.nc"

file_coarse = "/data02/Ican/vic_sim/fsm_past_1km/netcdf_old/hs_50km.nc"

id_fine = "ind_senorge"

id_coarse = "ind_50km"

variable = "hs"


# Load data

df_links = link_results(file_fine, file_coarse, id_fine, id_coarse)

hs_coarse, hs_aggregated = unify_results(file_fine, file_coarse, df_links, variable)


# Compute metrics

rmse = sqrt.(mean((hs_coarse - hs_aggregated).^2 ,1))

meanref = mean(hs_aggregated, 1)

meancmp = mean(hs_coarse, 1)

nrmse = rmse ./ meanref

bias = meancmp ./ meanref


# Project to map

rmse_map = project_results(rmse[:], df_links)

meanref_map = project_results(meanref[:], df_links)

meancmp_map = project_results(meancmp[:], df_links)

nrmse_map = project_results(nrmse[:], df_links)

bias_map = project_results(bias[:], df_links)


# Plot maps

figure()
imshow(meanref_map)
cb = colorbar()
cb[:set_label]("Snow depth (m)")
title("Fine scale run")


figure()
imshow(meancmp_map)
cb = colorbar()
cb[:set_label]("Snow depth (m)")
title("Coarse scale run")


figure()
imshow(bias_map)
cb = colorbar()
cb[:set_label]("Bias (-)")
title("Snow depth - coarse divded by fine scale")


figure()
imshow(nrmse_map)
cb = colorbar()
cb[:set_label]("NRMSE (-)")
title("Snow depth")
