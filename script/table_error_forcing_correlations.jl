
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

  bias = mean(data_coarse .- data_aggregated, dims = 1)

  bias = dropdims(bias, dims = 1)

  rmse = sqrt.(mean((data_coarse .- data_aggregated).^2 , dims = 1))

  rmse = dropdims(rmse, dims = 1)

  return rmse, bias

end


function get_metadata(path_simulations)

  file_fine = joinpath(path_simulations, "fsmres_forest", "results_1", "swe_1km.nc")

  file_coarse = joinpath(path_simulations, "fsmres_forest", "results_1", "swe_50km.nc")

  df_links = link_results(file_fine, file_coarse)

  df_agg = aggregate(df_links, :id_coarse, [mean, std])

  return df_agg

end


function compute_correlations(rmse, bias, df_links, target_variable)

  df = DataFrame()

  ikeep = .!isnan.(df_links[:elev_std])

  df[Symbol("r_" * target_variable * "_elev_for_bias")] = cor(bias[ikeep], df_links[:elev_std][ikeep])

  df[Symbol("r_" * target_variable * "_elev_for_rmse")] = cor(rmse[ikeep], df_links[:elev_std][ikeep])

  return df

end


function run_all()
  

  path_results = joinpath(dirname(pathof(IcanProj)), "..", "data")

  path_simulations = "/data04/jmg/fsm_simulations/netcdf"

  target_variables = ["swe", "latmo", "hatmo", "rnet"]

  
  df_links = get_metadata(path_simulations)


  for target_variable in target_variables

    @show target_variable

    df_all = []

    for cfg in 1:32

      @show cfg

      rmse, bias = compute_errors(path_simulations, cfg, target_variable)

      if cfg == 1
        df_all = compute_correlations(rmse, bias, df_links, target_variable)
      else
        df_tmp = compute_correlations(rmse, bias, df_links, target_variable)
        append!(df_all, df_tmp)
      end

    end

    file_final = joinpath(path_results, "correlation_error_$(target_variable).csv")

    df_all |> CSV.write(file_final, delim = ";")

  end

end


run_all()