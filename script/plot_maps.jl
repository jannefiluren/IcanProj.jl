
using IcanProj
using NetCDF
using DataFrames
using PyPlot


# Settings

variable = "hatmo"

file_fine = "/data02/Ican/vic_sim/fsm_simulations/netcdf/fsmres/results_32/$(variable)_1km.nc"

file_coarse = "/data02/Ican/vic_sim/fsm_simulations/netcdf/fsmres/results_32/$(variable)_50km.nc"


#file_fine = "/data02/Ican/vic_sim/fsm_simulations/netcdf/forcings_st/$(variable)_1km.nc"

#file_coarse = "/data02/Ican/vic_sim/fsm_simulations/netcdf/forcings_st/$(variable)_50km.nc"


# Load data

df_links = link_results(file_fine, file_coarse)

hs_coarse, hs_aggregated = unify_results(file_fine, file_coarse, df_links, variable)













# Compute metrics

rmse = sqrt.(mean((hs_coarse - hs_aggregated).^2 ,1))

meanref = mean(hs_aggregated, 1)

meancmp = mean(hs_coarse, 1)

nrmse = rmse ./ meanref

bias = (meancmp - meanref) ./ meanref

nse = 1 - var(hs_coarse-hs_aggregated, 1) ./ var(hs_aggregated .- mean(hs_aggregated, 1), 1)



# Project to map

rmse_map = project_results(rmse[:], df_links)

meanref_map = project_results(meanref[:], df_links)

meancmp_map = project_results(meancmp[:], df_links)

nrmse_map = project_results(nrmse[:], df_links)

bias_map = project_results(bias[:], df_links)


nse_map = project_results(nse[:], df_links)

#=
# Plot maps

figure()
imshow(meanref_map)
cb = colorbar()
cb[:set_label](variable)
title("Fine scale run")


figure()
imshow(meancmp_map)
cb = colorbar()
cb[:set_label](variable)
title("Coarse scale run")


figure()
imshow(bias_map)
cb = colorbar()
cb[:set_label]("Bias (-)")
title("$(variable) - coarse divded by fine scale")


figure()
imshow(nrmse_map)
cb = colorbar()
cb[:set_label]("NRMSE (-)")
title(variable)
=#




figure()
imshow(nse_map)
cb = colorbar()
cb[:set_label]("NSE (-)")
title(variable)

#=
for icell in 1:100

    plot(hs_coarse[:,icell], label = "coarse")
    plot(hs_aggregated[:,icell], label = "fine")

    legend()

    sleep(2)

    close("all")

end
=#
