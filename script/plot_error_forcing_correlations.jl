
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


# Plot results

cols = [:ilwr_std, :iswr_std, :snowf_std, :tair_std, :rhum_std, :wind_std, :elev_std]

fig = figure(figsize = (7, 8))

subplots_adjust(hspace=0.0)

subplot(411)
boxplot(convert(Array{Float64}, df_swe[:, cols]), 0, "")
ylim([0, 1])
yticks(0.1:0.2:0.9)
annotate("SWE",	xy=[0.85; 0.2], xycoords="axes fraction", fontsize=10.0)

subplot(412)
boxplot(convert(Array{Float64}, df_latmo[:, cols]), 0, "")
ylim([0, 1])
yticks(0.1:0.2:0.9)
annotate("LATMO",	xy=[0.85; 0.2], xycoords="axes fraction", fontsize=10.0)

subplot(413)
boxplot(convert(Array{Float64}, df_hatmo[:, cols]), 0, "")
ylim([0, 1])
yticks(0.1:0.2:0.9)
annotate("HATMO",	xy=[0.85; 0.2], xycoords="axes fraction", fontsize=10.0)

subplot(414)
boxplot(convert(Array{Float64}, df_rnet[:, cols]), 0, "")
ylim([0, 1])
xticks(collect(1:length(cols)), [String(c)[1:end-4] for c in cols])
yticks(0.1:0.2:0.9)
annotate("RNET",	xy=[0.85; 0.2], xycoords="axes fraction", fontsize=10.0)

fig[:text](0.04, 0.5, "Correlation between scale error and input variability", va="center", rotation="vertical")

# Save figure

savefig(joinpath(path_figure, "correlation_plot.png"), dpi = 600)


