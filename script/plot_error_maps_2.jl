using IcanProj
using Statistics
using PyPlot


function plot_maps(cfg, variable, unit, path_results)

  # File path_results

  file_fine = "/data04/jmg/fsm_simulations/netcdf/fsmres_forest/results_$(cfg)/$(variable)_1km.nc"

  file_coarse = "/data04/jmg/fsm_simulations/netcdf/fsmres_forest/results_$(cfg)/$(variable)_50km.nc"

  # Load data

  df_links = link_results(file_fine, file_coarse)

  data_coarse, data_aggregated, ngrids  = unify_results(file_fine, file_coarse, df_links, variable)

  # Compute metrics

  rmse = sqrt.(mean((data_coarse .- data_aggregated).^2 , dims = 1))

  meanref = mean(data_aggregated, dims = 1)

  meancmp = mean(data_coarse, dims = 1)

  nrmse = rmse ./ meanref

  bias = (meancmp .- meanref)

  perc_bias = 100 .* bias ./ meanref

  # Project to map

  rmse_map = project_results(rmse[:], df_links)

  nrmse_map = project_results(nrmse[:], df_links)

  bias_map = project_results(bias[:], df_links)

  perc_bias_map = project_results(perc_bias[:], df_links)

  # Plot maps

  figure()
  imshow(rmse_map)
  cb = colorbar()
  cb[:set_label]("RMSE ($(unit))")
  title(variable)
  savefig(joinpath(path_results, "$(variable)_rmse.png"))
  close()

  figure()
  imshow(nrmse_map)
  cb = colorbar()
  cb[:set_label]("NRMSE (-)")
  title(variable)
  savefig(joinpath(path_results, "$(variable)_nrmse.png"))
  close()

  figure()
  imshow(bias_map)
  cb = colorbar()
  cb[:set_label]("BIAS ($(unit))")
  title(variable)
  savefig(joinpath(path_results, "$(variable)_bias.png"))
  close()

  figure()
  imshow(perc_bias_map)
  cb = colorbar()
  cb[:set_label]("BIAS (%)")
  title(variable)
  savefig(joinpath(path_results, "$(variable)_perc_bias.png"))
  close()

end


# Global settings

cfg = 32

path_results = joinpath(dirname(pathof(IcanProj)), "..", "plots", "error_maps_2")


# Plot snow water equivalent

variable = "swe"

unit = "mm"

plot_maps(cfg, variable, unit, path_results)


# Plot latent heat exchange

variable = "latmo"

unit = "W/m2"

plot_maps(cfg, variable, unit, path_results)


# Plot sensible heat exchange

variable = "hatmo"

unit = "W/m2"

plot_maps(cfg, variable, unit, path_results)


# Plot net radiation

variable = "rnet"

unit = "W/m2"

plot_maps(cfg, variable, unit, path_results)





#= 
# Plot time series

imin = argmin(rmse[:])
imax = argmax(rmse[:])

figure()
plot(data_coarse[:, imin])
plot(data_aggregated[:, imin])
title("Smallest error")

figure()
plot(data_coarse[:, imax])
plot(data_aggregated[:, imax])
title("Largest error")
 =#