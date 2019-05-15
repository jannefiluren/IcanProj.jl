
using NetCDF
using DataFrames
using CSV
using IcanProj
using Statistics
using StatsBase
using PyPlot


function forcings_mean(path_simulations, target_variable, df_links)

  file = joinpath(path_simulations, "forcings_st/$(target_variable)_1km.nc")

  nspace = length(ncread(file, "dim_space"))
  ntime = length(ncread(file, "dim_time"))
  
  data, tmp = zeros(nspace), zeros(nspace)

  for i in 1:ntime

    ncread!(file, target_variable, tmp, start=[1, i], count=[-1, 1])

    data += tmp / ntime

  end
  
  df_tmp = DataFrame(ind_senorge = Int.(ncread(file, "id")), data = data)

  df_links = join(df_links, df_tmp, on = :ind_senorge, kind = :left)

  return df_links

end


function compute_spread(df_res)

  df_std = DataFrame(resolution = String[], y = Float64[], lowererror = Float64[], uppererror = Float64[])

  for resolution in [:ind_5km, :ind_10km, :ind_25km, :ind_50km]

    df_aggregated = aggregate(df_res, resolution, std)

    data_std = df_aggregated.data_std

    ikeep = .!isnan.(data_std)

    data_std = data_std[ikeep]

    y = percentile(data_std, 50)

    lowererror = percentile(data_std, 50) .- percentile(data_std, 10)
    
    uppererror = percentile(data_std, 90) .- percentile(data_std, 50)

    push!(df_std, (String(resolution), y, lowererror, uppererror))

  end

  return df_std

end


function compute_variability(path_simulations, target_variable)

  df_links = CSV.read(joinpath(dirname(pathof(IcanProj)), "..", "data", "df_links.csv")) |> DataFrame

  df_res = forcings_mean(path_simulations, target_variable, df_links)

  df_std = compute_spread(df_res)

  return df_std

end


# Settings

path_simulations = "/data04/jmg/fsm_simulations/netcdf"

path_results = joinpath(dirname(pathof(IcanProj)), "..", "plots", "forcings")


# Plot results

fig, axes = plt[:subplots](nrows = 3, ncols = 2)

fig[:set_size_inches](8, 7)


# Air temperature

target_variable = "tair"

df_std = compute_variability(path_simulations, target_variable)

axes[1][:errorbar](collect(1:4), df_std.y, yerr=permutedims([df_std.lowererror df_std.uppererror]), fmt="o")

axes[1][:xaxis][:set_ticklabels]([])

axes[1][:set_ylabel]("Air temperature (C)")

df_std |> CSV.write(joinpath(path_results, "$(target_variable)_std.csv"))


# Relative humidity

target_variable = "rhum"

df_std = compute_variability(path_simulations, target_variable)

axes[4][:errorbar](collect(1:4), df_std.y, yerr=permutedims([df_std.lowererror df_std.uppererror]), fmt="o")

axes[4][:xaxis][:set_ticklabels]([])

axes[4][:yaxis][:tick_right]()

axes[4][:yaxis][:set_label_position]("right")

axes[4][:set_ylabel]("Relative humidity (%)")

df_std |> CSV.write(joinpath(path_results, "$(target_variable)_std.csv"))


# Wind speed

target_variable = "wind"

df_std = compute_variability(path_simulations, target_variable)

axes[2][:errorbar](collect(1:4), df_std.y, yerr=permutedims([df_std.lowererror df_std.uppererror]), fmt="o")

axes[2][:xaxis][:set_ticklabels]([])

axes[2][:set_ylabel]("Wind speed (m/s)")

df_std |> CSV.write(joinpath(path_results, "$(target_variable)_std.csv"))


# Snowfall

target_variable = "snowf"

df_std = compute_variability(path_simulations, target_variable)

axes[5][:errorbar](collect(1:4), df_std.y, yerr=permutedims([df_std.lowererror df_std.uppererror]), fmt="o")

axes[5][:xaxis][:set_ticklabels]([])

axes[5][:yaxis][:tick_right]()

axes[5][:yaxis][:set_label_position]("right")

axes[5][:set_ylabel]("Snowfall (mm/3h)")

df_std |> CSV.write(joinpath(path_results, "$(target_variable)_std.csv"))


# Incoming shortwave radiation

target_variable = "iswr"

df_std = compute_variability(path_simulations, target_variable)

axes[3][:errorbar](collect(1:4), df_std.y, yerr=permutedims([df_std.lowererror df_std.uppererror]), fmt="o")

axes[3][:set_xticks](collect(1:4))

axes[3][:set_xticklabels](["5km", "10km", "25km", "50km"])

axes[3][:set_ylabel]("Incoming shortwave\nradiation (W/m2)")

df_std |> CSV.write(joinpath(path_results, "$(target_variable)_std.csv"))


# Incoming longwave radiation

target_variable = "ilwr"

df_std = compute_variability(path_simulations, target_variable)

axes[6][:errorbar](collect(1:4), df_std.y, yerr=permutedims([df_std.lowererror df_std.uppererror]), fmt="o")

axes[6][:set_xticks](collect(1:4))

axes[6][:set_xticklabels](["5km", "10km", "25km", "50km"])

axes[6][:yaxis][:tick_right]()

axes[6][:yaxis][:set_label_position]("right")

axes[6][:set_ylabel]("Incoming longwave\nradiation (W/m2)")

df_std |> CSV.write(joinpath(path_results, "$(target_variable)_std.csv"))


# Save figure

fig[:savefig](joinpath(path_results, "forcings_variability.png"), dpi=600)

