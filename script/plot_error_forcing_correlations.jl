
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

fig = figure(figsize = (7, 3))

# subplot(211)
boxplot(convert(Array{Float64}, df_rmse).^2, 0, "")
ylim([0, 1])
yticks(0:0.2:1)
ylabel("Squared correlation coefficient")
xticks(collect(1:4), uppercase.(String.(names(df_bias))))
#annotate("(a)", xy = [0.9,0.2], xycoords = "axes fraction")

# subplot(212)
# boxplot(convert(Array{Float64}, df_bias), 0, "")
# ylim([-1, 1])
# yticks(-1:0.5:1)
# ylabel("Correlation coefficient between\nbias and topograpic variability")
# xticks(collect(1:4), uppercase.(String.(names(df_bias))))
# annotate("(b)", xy = [0.9,0.2], xycoords = "axes fraction")

# fig[:align_ylabels]()

savefig(joinpath(path_figure, "correlation_plot.png"), dpi = 600)


