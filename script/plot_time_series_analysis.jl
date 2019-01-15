
# Script for creating Figure 14, 15 in scale manuscript


using IcanProj
using Statistics
using PyPlot
using NetCDF
using Dates
using JFSM2
using PyCall


function find_largest_error(file_fine, file_coarse, metric, variable)

  df_links = link_results(file_fine, file_coarse)

  data_coarse, data_aggregated, ngrids  = unify_results(file_fine, file_coarse, df_links, variable)

  bias = mean(data_coarse .- data_aggregated, dims = 1)

  bias = dropdims(bias, dims = 1)

  rmse = sqrt.(mean((data_coarse .- data_aggregated).^2, dims = 1))
  
  rmse = dropdims(rmse, dims = 1)
  
  if metric == "bias_max"

    ikeep = findall(df_links[:nc_coarse] .== argmax(bias))

  end

  if metric == "bias_min"

    ikeep = findall(df_links[:nc_coarse] .== argmin(bias))

  end

  if metric == "rmse"

    ikeep = findall(df_links[:nc_coarse] .== argmax(rmse))

  end
  
  df_subset = df_links[ikeep, :]

  return df_subset

end


function load_fsm_data(file_fine, file_coarse, df_subset, variable)

  time_array = ncread(file_fine, "time_array")

  time_vec = [DateTime(time_array[1, i], time_array[2, i], time_array[3, i], time_array[4, i]) for i in 1:size(time_array, 2)]

  data_fine = zeros(size(df_subset, 1), size(time_array, 2))

  for i in 1:size(df_subset, 1)

    tmp = ncread(file_fine, variable, start = [df_subset[:nc_fine][i], 1], count = [1, -1])

    data_fine[i, :] .= dropdims(tmp, dims = 1)

  end

  data_coarse = ncread(file_coarse, variable, start = [df_subset[:nc_coarse][1], 1], count = [1, -1])

  data_fine = permutedims(data_fine)

  data_coarse = permutedims(data_coarse)

  return time_vec, data_fine, data_coarse

end


function load_input_data(file_fine, file_coarse, df_subset)

  time_array = ncread(file_fine, "time_array")

  time_vec = [DateTime(time_array[1, i], time_array[2, i], time_array[3, i], time_array[4, i]) for i in 1:size(time_array, 2)]

  data_fine = zeros(size(df_subset, 1), size(time_array, 2))

  ind_nc = findall(x -> x in df_subset[:id_fine], Int.(ncread(file_fine, "id")))

  data_fine = zeros(size(df_subset, 1), size(time_array, 2))

  for i in 1:length(ind_nc)

    tmp = ncread(file_fine, variable, start = [ind_nc[i], 1], count = [1, -1])
    
    data_fine[i, :] .= dropdims(tmp, dims = 1)

    @show i

  end

  ind_nc = findall(x -> x in df_subset[:id_coarse], Int.(ncread(file_coarse, "id")))

  data_coarse = ncread(file_coarse, variable, start = [ind_nc[1], 1], count = [1, -1])

  data_fine = permutedims(data_fine)

  data_coarse = permutedims(data_coarse)

  return time_vec, data_fine, data_coarse

end


function results_files(cfg, variable)

  file_fine = "/data04/jmg/fsm_simulations/netcdf/fsmres_forest/results_$(cfg)/$(variable)_1km.nc"

  file_coarse = "/data04/jmg/fsm_simulations/netcdf/fsmres_forest/results_$(cfg)/$(variable)_50km.nc"

  return file_fine, file_coarse

end


function forcing_files(variable)

  file_fine = "/data04/jmg/fsm_simulations/netcdf/forcings_st/$(variable)_1km.nc"

  file_coarse = "/data04/jmg/fsm_simulations/netcdf/forcings_st/$(variable)_50km.nc"

  return file_fine, file_coarse

end


function plot_inputs()

  # Load results

  variable = "tair"

  file_fine, file_coarse = forcing_files(variable)

  tair_time, tair_fine, tair_coarse = load_input_data(file_fine, file_coarse, df_subset)

  variable = "wind"

  file_fine, file_coarse = forcing_files(variable)

  wind_time, wind_fine, wind_coarse = load_input_data(file_fine, file_coarse, df_subset)

  variable = "ilwr"

  file_fine, file_coarse = forcing_files(variable)

  ilwr_time, ilwr_fine, ilwr_coarse = load_input_data(file_fine, file_coarse, df_subset)

  variable = "iswr"

  file_fine, file_coarse = forcing_files(variable)

  iswr_time, iswr_fine, iswr_coarse = load_input_data(file_fine, file_coarse, df_subset)

  # Plot results

  xrange = (DateTime(2008, 9 , 1), DateTime(2009, 9, 1))

  fig, ax = subplots(4, 1, sharex=true)

  fig[:set_size_inches](6, 10)

  ax[1][:grid](axis = "x")
  ax[1][:fill_between](tair_time, minimum(tair_fine, dims=2)[:], maximum(tair_fine, dims=2)[:], color = "gray")
  ax[1][:plot](tair_time, tair_coarse, color = "red")
  ax[1][:set_xlim](xrange)
  ax[1][:set_ylabel]("Air temperature")
  ax[1][:axhline](linewidth = 1, color="blue")

  ax[2][:grid](axis = "x")
  ax[2][:fill_between](wind_time, minimum(wind_fine, dims=2)[:], maximum(wind_fine, dims=2)[:], color = "gray")
  ax[2][:plot](wind_time, wind_coarse, color = "red")
  ax[2][:set_xlim](xrange)
  ax[2][:set_ylabel]("Wind speed")

  ax[3][:grid](axis = "x")
  ax[3][:fill_between](ilwr_time, minimum(ilwr_fine, dims=2)[:], maximum(ilwr_fine, dims=2)[:], color = "gray")
  ax[3][:plot](ilwr_time, ilwr_coarse, color = "red")
  ax[3][:set_xlim](xrange)
  ax[3][:set_ylabel]("Incoming longwave")

  ax[4][:grid](axis = "x")
  ax[4][:fill_between](iswr_time, minimum(iswr_fine, dims=2)[:], maximum(iswr_fine, dims=2)[:], color = "gray")
  ax[4][:plot](iswr_time, iswr_coarse, color = "red")
  ax[4][:set_xlim](xrange)
  ax[4][:set_ylabel]("Incoming shortwave")

  savefig(joinpath(path_figure, "forcings.pdf"), dpi = 600)

end


function plot_fsm_heat_fluxes(df_subset, metric, path_figure)

  fig, ax = subplots(2, 1, sharex=true)

  fig[:set_size_inches](6, 5)
  
  variable = "hatmo"

  xrange = (DateTime(2008, 9 , 1), DateTime(2009, 9, 1))
  yrange = (-100, 50)

  # Load and plot config 30
  
  cfg = 30

  file_fine, file_coarse = results_files(cfg, variable)
  
  hatmo_time, hatmo_fine, hatmo_coarse = load_fsm_data(file_fine, file_coarse, df_subset, variable)
  
  ax[1][:fill_between](hatmo_time, minimum(hatmo_fine, dims=2)[:], maximum(hatmo_fine, dims=2)[:], color = "gray")
  ax[1][:plot](hatmo_time, hatmo_coarse, color = "blue")
  ax[1][:set_xlim](xrange)
  ax[1][:set_ylim](yrange)
  ax[1][:grid](axis = "x")
  
  ax[1][:annotate]("(A) Exchng = 0", xy = (0.05, 0.85), xycoords = "axes fraction")

  # Load and plot config 32

  cfg = 32

  file_fine, file_coarse = results_files(cfg, variable)
  
  hatmo_time, hatmo_fine, hatmo_coarse = load_fsm_data(file_fine, file_coarse, df_subset, variable)
  
  ax[2][:fill_between](hatmo_time, minimum(hatmo_fine, dims=2)[:], maximum(hatmo_fine, dims=2)[:], color = "gray")
  ax[2][:plot](hatmo_time, hatmo_coarse, color = "blue")
  ax[2][:set_xlim](xrange)
  ax[2][:set_ylim](yrange)
  ax[2][:grid](axis = "x")

  ax[2][:annotate]("(B) Exchng = 1", xy = (0.05, 0.85), xycoords = "axes fraction")

  fig[:text](0.02, 0.5, L"$Sensible heat flux (W/m^2)$", va="center", rotation="vertical")

  savefig(joinpath(path_figure, "sensible_heat_fluxes_$(metric).pdf"), dpi = 600)

end


function plot_fms_results(df_subset, path_figure, metric)

  # Common to all plots

  xrange = (DateTime(2010, 9 , 1), DateTime(2011, 9, 1))
  yrange = (-50, 50)

  fig, ax = subplots(4, 2, sharex=true)

  fig[:set_size_inches](12, 10)

  ###############################################################################################

  # Perform analysis for cfg = 30
  
  cfg = 30

  # Load results

  variable = "swe"

  file_fine, file_coarse = results_files(cfg, variable)

  swe_time, swe_fine, swe_coarse = load_fsm_data(file_fine, file_coarse, df_subset, variable)

  variable = "hatmo"

  file_fine, file_coarse = results_files(cfg, variable)
  
  hatmo_time, hatmo_fine, hatmo_coarse = load_fsm_data(file_fine, file_coarse, df_subset, variable)

  variable = "latmo"

  file_fine, file_coarse = results_files(cfg, variable)

  latmo_time, latmo_fine, latmo_coarse = load_fsm_data(file_fine, file_coarse, df_subset, variable)

  variable = "rnet"

  file_fine, file_coarse = results_files(cfg, variable)

  rnet_time, rnet_fine, rnet_coarse = load_fsm_data(file_fine, file_coarse, df_subset, variable)
    
  # Plot results
  
  ax[1, 1][:set_title]("Exchng = 0")

  # SWE

  swe_error = repeat(swe_coarse, 1, size(swe_fine, 2)) - swe_fine

  ax[1, 1][:grid](axis = "x")
  ax[1, 1][:fill_between](swe_time, minimum(swe_fine, dims=2)[:], maximum(swe_fine, dims=2)[:], color = "gray")
  ax[1, 1][:plot](swe_time, swe_coarse, color = "blue")
  ax[1, 1][:plot](swe_time, mean(swe_fine, dims=2)[:], color = "green")
  ax[1, 1][:set_xlim](xrange)
  ax[1, 1][:set_ylim](0, 2000)
  ax[1, 1][:set_ylabel]("SWE (" * L"mm" * ")")

  swe_error = mean(swe_error, dims = 2)

  ax[1, 1][:annotate]("(A) Bias = $(round(mean(swe_error), digits = 0)) | RMSE = $(round(sqrt(mean(swe_error.^2)), digits = 0))", xy = (0.05, 0.85), xycoords = "axes fraction")

  # RNET

  rnet_error = repeat(rnet_coarse, 1, size(rnet_fine, 2)) - rnet_fine

  ax[2, 1][:grid](axis = "x")
  ax[2, 1][:fill_between](rnet_time, minimum(rnet_error, dims=2)[:], maximum(rnet_error, dims=2)[:], color="gray")
  ax[2, 1][:plot](rnet_time, mean(rnet_error, dims=2), color = "red")
  ax[2, 1][:set_xlim](xrange)
  ax[2, 1][:set_ylim](yrange)
  ax[2, 1][:set_ylabel]("RNET (" * L"$W/m^2$" * ")")

  rnet_error = mean(rnet_error, dims = 2)

  ax[2, 1][:annotate]("(C) Bias = $(round(mean(rnet_error), digits = 1)) | RMSE = $(round(sqrt(mean(rnet_error.^2)), digits = 1))", xy = (0.05, 0.85), xycoords = "axes fraction")

  # HATMO

  hatmo_error = repeat(hatmo_coarse, 1, size(hatmo_fine, 2)) - hatmo_fine

  ax[3, 1][:grid](axis = "x")
  ax[3, 1][:fill_between](hatmo_time, minimum(hatmo_error, dims=2)[:], maximum(hatmo_error, dims=2)[:], color="gray")
  ax[3, 1][:plot](hatmo_time, mean(hatmo_error, dims=2), color = "red")
  ax[3, 1][:set_xlim](xrange)
  ax[3, 1][:set_ylim](yrange)
  ax[3, 1][:set_ylabel]("HATMO (" * L"$W/m^2$" * ")")

  hatmo_error = mean(hatmo_error, dims = 2)

  ax[3, 1][:annotate]("(E) Bias = $(round(mean(hatmo_error), digits = 1)) | RMSE = $(round(sqrt(mean(hatmo_error.^2)), digits = 1))", xy = (0.05, 0.85), xycoords = "axes fraction")

  # LATMO

  latmo_error = repeat(latmo_coarse, 1, size(latmo_fine, 2)) - latmo_fine

  ax[4, 1][:grid](axis = "x")
  ax[4, 1][:fill_between](latmo_time, minimum(latmo_error, dims=2)[:], maximum(latmo_error, dims=2)[:], color="gray")
  ax[4, 1][:plot](latmo_time, mean(latmo_error, dims=2), color = "red")
  ax[4, 1][:set_xlim](xrange)
  ax[4, 1][:set_ylim](yrange)
  ax[4, 1][:set_ylabel]("LATMO (" * L"$W/m^2$" * ")")

  latmo_error = mean(latmo_error, dims = 2)

  ax[4, 1][:annotate]("(G) Bias = $(round(mean(latmo_error), digits = 1)) | RMSE = $(round(sqrt(mean(latmo_error.^2)), digits = 1))", xy = (0.05, 0.85), xycoords = "axes fraction")
  
  ###############################################################################################

  # Perform analysis for cfg = 32
  
  cfg = 32

  # Load results

  variable = "swe"

  file_fine, file_coarse = results_files(cfg, variable)

  swe_time, swe_fine, swe_coarse = load_fsm_data(file_fine, file_coarse, df_subset, variable)

  variable = "hatmo"

  file_fine, file_coarse = results_files(cfg, variable)
  
  hatmo_time, hatmo_fine, hatmo_coarse = load_fsm_data(file_fine, file_coarse, df_subset, variable)

  variable = "latmo"

  file_fine, file_coarse = results_files(cfg, variable)

  latmo_time, latmo_fine, latmo_coarse = load_fsm_data(file_fine, file_coarse, df_subset, variable)

  variable = "rnet"

  file_fine, file_coarse = results_files(cfg, variable)

  rnet_time, rnet_fine, rnet_coarse = load_fsm_data(file_fine, file_coarse, df_subset, variable)
    
  # Plot results
  
  ax[1, 2][:set_title]("Exchng = 1")

  # SWE

  swe_error = repeat(swe_coarse, 1, size(swe_fine, 2)) - swe_fine

  ax[1, 2][:grid](axis = "x")
  ax[1, 2][:fill_between](swe_time, minimum(swe_fine, dims=2)[:], maximum(swe_fine, dims=2)[:], color = "gray")
  ax[1, 2][:plot](swe_time, swe_coarse, color = "blue")
  ax[1, 2][:plot](swe_time, mean(swe_fine, dims=2)[:], color = "green")
  ax[1, 2][:set_xlim](xrange)
  ax[1, 2][:set_ylim](0, 2000)
  ax[1, 2][:set_ylabel]("SWE (" * L"mm" * ")")

  swe_error = mean(swe_error, dims = 2)

  ax[1, 2][:annotate]("(B) Bias = $(round(mean(swe_error), digits = 0)) | RMSE = $(round(sqrt(mean(swe_error.^2)), digits = 0))", xy = (0.05, 0.85), xycoords = "axes fraction")

  # RNET

  rnet_error = repeat(rnet_coarse, 1, size(rnet_fine, 2)) - rnet_fine

  ax[2, 2][:grid](axis = "x")
  ax[2, 2][:fill_between](rnet_time, minimum(rnet_error, dims=2)[:], maximum(rnet_error, dims=2)[:], color="gray")
  ax[2, 2][:plot](rnet_time, mean(rnet_error, dims=2), color = "red")
  ax[2, 2][:set_xlim](xrange)
  ax[2, 2][:set_ylim](yrange)
  ax[2, 2][:set_ylabel]("RNET (" * L"$W/m^2$" * ")")

  rnet_error = mean(rnet_error, dims = 2)

  ax[2, 2][:annotate]("(D) Bias = $(round(mean(rnet_error), digits = 1)) | RMSE = $(round(sqrt(mean(rnet_error.^2)), digits = 1))", xy = (0.05, 0.85), xycoords = "axes fraction")

  # HATMO

  hatmo_error = repeat(hatmo_coarse, 1, size(hatmo_fine, 2)) - hatmo_fine

  ax[3, 2][:grid](axis = "x")
  ax[3, 2][:fill_between](hatmo_time, minimum(hatmo_error, dims=2)[:], maximum(hatmo_error, dims=2)[:], color="gray")
  ax[3, 2][:plot](hatmo_time, mean(hatmo_error, dims=2), color = "red")
  ax[3, 2][:set_xlim](xrange)
  ax[3, 2][:set_ylim](yrange)
  ax[3, 2][:set_ylabel]("HATMO (" * L"$W/m^2$" * ")")

  hatmo_error = mean(hatmo_error, dims = 2)

  ax[3, 2][:annotate]("(F) Bias = $(round(mean(hatmo_error), digits = 1)) | RMSE = $(round(sqrt(mean(hatmo_error.^2)), digits = 1))", xy = (0.05, 0.85), xycoords = "axes fraction")

  # LATMO

  latmo_error = repeat(latmo_coarse, 1, size(latmo_fine, 2)) - latmo_fine

  ax[4, 2][:grid](axis = "x")
  ax[4, 2][:fill_between](latmo_time, minimum(latmo_error, dims=2)[:], maximum(latmo_error, dims=2)[:], color="gray")
  ax[4, 2][:plot](latmo_time, mean(latmo_error, dims=2), color = "red")
  ax[4, 2][:set_xlim](xrange)
  ax[4, 2][:set_ylim](yrange)
  ax[4, 2][:set_ylabel]("LATMO (" * L"$W/m^2$" * ")")

  latmo_error = mean(latmo_error, dims = 2)

  ax[4, 2][:annotate]("(H) Bias = $(round(mean(latmo_error), digits = 1)) | RMSE = $(round(sqrt(mean(latmo_error.^2)), digits = 1))", xy = (0.05, 0.85), xycoords = "axes fraction")

  # Save plot

  savefig(joinpath(path_figure, "time_series_analysis_$(metric).pdf"), dpi = 600)
  
end



for metric in ["rmse"] # ["bias_min", "bias_max", "rmse"]


  # Global settings

  path_figure = joinpath(dirname(pathof(IcanProj)), "..", "plots", "time_series_analysis")


  # Detemine which grid cell to analyze

  variable = "swe"

  cfg = 30    # previously 32

  file_fine, file_coarse = results_files(cfg, variable)

  df_subset = find_largest_error(file_fine, file_coarse, metric, variable)


  # Plot two configurations where only exchng differs

  plot_fms_results(df_subset, path_figure, metric)


  # Plot sensible heat fluxes

  plot_fsm_heat_fluxes(df_subset, metric, path_figure)

end
