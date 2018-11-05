
using IcanProj
using NetCDF
using DataFrames
using PyPlot
using Statistics
using CSV


function compute_errors(path_simulations, cfg, target_variable)

  file_fine = joinpath(path_simulations, "fsmres_forest", "results_$(cfg)", "$(target_variable)_1km.nc")

  file_coarse = joinpath(path_simulations, "fsmres_forest", "results_$(cfg)", "$(target_variable)_50km.nc")

  df_links = link_results(file_fine, file_coarse)

  data_coarse, data_aggregated, ngrids  = unify_results(file_fine, file_coarse, df_links, target_variable)

  rmse = sqrt.(mean((data_coarse .- data_aggregated).^2 , dims = 1))

  rmse = dropdims(rmse, dims = 1)

  return rmse

end


function forcings_mean(path_simulations, target_variable, df_links)

  file = joinpath(path_simulations, "forcings_st/$(target_variable)_1km.nc")

  nspace = length(ncread(file, "dim_space"))
  ntime = length(ncread(file, "dim_time"))
  
  data, tmp = zeros(nspace), zeros(nspace)

  for i in 1:ntime

    ncread!(file, target_variable, tmp, start=[1, i], count=[-1, 1])

    data += tmp / ntime

#    if i % 1000 == 0
#      @show i
#    end

  end
  
  df_tmp = DataFrame(id_fine = Int.(ncread(file, "id")), data = data)

  df_links = join(df_links, df_tmp, on = :id_fine, kind = :left)

  rename!(df_links, :data => Symbol(target_variable))

  return df_links

end


function compute_references(path_simulations, cfg, target_variable, reference_variables)

  file_fine = joinpath(path_simulations, "fsmres_forest", "results_$(cfg)", "$(target_variable)_1km.nc")

  file_coarse = joinpath(path_simulations, "fsmres_forest", "results_$(cfg)", "$(target_variable)_50km.nc")

  df_links = link_results(file_fine, file_coarse)

  for reference_variable in reference_variables

    df_links = forcings_mean(path_simulations, reference_variable, df_links)

  end

  df_agg = aggregate(df_links, :id_coarse, [mean, std])

  return df_agg

end


function compute_correlations(rmse, refs, reference_variables)

  df = DataFrame()

  tmp_variables = [reference_variables; "elev"]

  for reference_variable in Symbol.(vcat(tmp_variables .* "_mean", tmp_variables .* "_std"))

    ikeep = .!isnan.(refs[reference_variable])

    df[reference_variable] = cor(rmse[ikeep], refs[reference_variable][ikeep])

  end

  return df

end



function run_all()
  

  path_results = joinpath(dirname(pathof(IcanProj)), "..", "data")

  path_simulations = "/data04/jmg/fsm_simulations/netcdf"

  target_variables = ["swe", "latmo", "hatmo", "rnet"]

  reference_variables = ["ilwr", "iswr", "rainf", "snowf", "rhum", "tair", "wind"]


  for target_variable in target_variables

    @show target_variable

    df_all = []

    for cfg in 1:32

      @show cfg

      rmse = compute_errors(path_simulations, cfg, target_variable)

      refs = compute_references(path_simulations, cfg, target_variable, reference_variables)

      if cfg == 1
        df_all = compute_correlations(rmse, refs, reference_variables)
      else
        df_tmp = compute_correlations(rmse, refs, reference_variables)
        append!(df_all, df_tmp)
      end

    end

    file_final = joinpath(path_results, "correlation_error_$(target_variable).csv")

    df_all |> CSV.write(file_final, delim = ";")

  end

end


run_all()


#=


# Settings

cfg = 32

variable = "latmo"

file_fine = "/data04/jmg/fsm_simulations/netcdf/fsmres_forest/results_$(cfg)/$(variable)_1km.nc"

file_coarse = "/data04/jmg/fsm_simulations/netcdf/fsmres_forest/results_$(cfg)/$(variable)_50km.nc"


# Load data

df_links = link_results(file_fine, file_coarse)

data_coarse, data_aggregated, ngrids  = unify_results(file_fine, file_coarse, df_links, variable)


# Compute mean elevation

df_agg = aggregate(df_links, :id_coarse, [mean, std])


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

elev_map = project_results(df_agg[:elev_mean], df_links)


# Plot maps

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


