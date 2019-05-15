

# Script for creating Figure 13 in scale manuscript


using CSV
using DataFrames
using IcanProj
using PyPlot


# Settings

path_results = joinpath(dirname(pathof(IcanProj)), "..", "data")

path_figure = joinpath(dirname(pathof(IcanProj)), "..", "plots", "correlation_plot")


# Load results

file_swe = joinpath(path_results, "correlation_error_swe.csv")

df_swe = CSV.read(file_swe, delim = ";") |> DataFrame

file_latmo = joinpath(path_results, "correlation_error_latmo.csv")

df_latmo = CSV.read(file_latmo, delim = ";") |> DataFrame

file_hatmo = joinpath(path_results, "correlation_error_hatmo.csv")

df_hatmo = CSV.read(file_hatmo, delim = ";") |> DataFrame

file_rnet = joinpath(path_results, "correlation_error_rnet.csv")

df_rnet = CSV.read(file_rnet, delim = ";") |> DataFrame


# Dataframe for bias and rmse

df_rmse = DataFrame(swe = df_swe.r_swe_elev_for_rmse,
                    latmo = df_latmo.r_latmo_elev_for_rmse,
                    hatmo = df_hatmo.r_hatmo_elev_for_rmse,
                    rnet = df_rnet.r_rnet_elev_for_rmse)

df_bias = DataFrame(swe = df_swe.r_swe_elev_for_bias,
                    latmo = df_latmo.r_latmo_elev_for_bias,
                    hatmo = df_hatmo.r_hatmo_elev_for_bias,
                    rnet = df_rnet.r_rnet_elev_for_bias)


# Plot results

fig = figure(figsize = (5, 2.7))

boxplot(convert(Array{Float64}, df_rmse).^2, 0, "")
ylim([0, 1])
yticks(0:0.2:1)
ylabel("Squared correlation\ncoefficient (-)")
xticks(collect(1:4), uppercase.(String.(names(df_rmse))))

savefig(joinpath(path_figure, "correlation_plot.pdf"), dpi = 600)


# Print summary statistics

describe(df_rmse)