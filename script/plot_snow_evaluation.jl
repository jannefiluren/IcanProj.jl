
# Script for creating Figure 4 in scale manuscript


using IcanProj
using CSV
using DataFrames
using NearestNeighbors
using NetCDF
using Dates
using Statistics
using PyPlot
using JFSM2


# Function for computing error statistics

function compute_error(path_res, cfg, df_obs, idxs, time_sim)

    file_swe = joinpath(path_res, "results_$(cfg)", "swe_1km.nc")
    file_hs = joinpath(path_res, "results_$(cfg)", "snowdepth_1km.nc")
    
    swe = ncread(file_swe, "swe")
    hs = ncread(file_hs, "snowdepth")
    
    swe_obs, swe_sim = Float64[], Float64[]
    hs_obs, hs_sim = Float64[], Float64[]
    
    for ix in 1:length(idxs)
    
        idx = idxs[ix]
    
        time_obs = DateTime(df_obs.year[ix], df_obs.month[ix], df_obs.day[ix])
    
        it = findfirst(t -> t == time_obs, time_sim)
    
        if (it != nothing)
    
            push!(swe_obs, 1000*df_obs.swe[ix])
            push!(swe_sim, swe[idx, it])
    
            push!(hs_obs, df_obs.hs[ix])
            push!(hs_sim, hs[idx, it])
    
        end
    
    end

    @info "Number of measurements: $(length(swe_obs))" 

    bias_swe = mean(swe_sim .- swe_obs)
    rmse_swe = sqrt(mean((swe_sim .- swe_obs).^2))
    mean_swe_obs = mean(swe_obs);

    bias_hs = mean(hs_sim .- hs_obs)
    rmse_hs = sqrt(mean((hs_sim .- hs_obs).^2))
    mean_hs_obs = mean(hs_obs);

    return bias_swe, rmse_swe, mean_swe_obs, bias_hs, rmse_hs, mean_hs_obs

end


# Settings

path_res = "/data04/jmg/fsm_simulations/netcdf/fsmres_open"

path_figure = joinpath(dirname(pathof(IcanProj)), "..", "plots", "snow_evaluation")


# Read tables

df_links = CSV.File(joinpath(dirname(pathof(IcanProj)), "..", "data", "df_links.csv")) |> DataFrame

df_obs = CSV.File(joinpath(dirname(pathof(IcanProj)), "..", "data", "snowdata.csv")) |> DataFrame


# Load metadata from simulations

file = joinpath(path_res, "results_32/swe_1km.nc")

time_sim = ncread(file, "time_array")

time_sim = [DateTime(time_sim[1, i], time_sim[2, i], time_sim[3, i], time_sim[4, i]) for i in 1:size(time_sim, 2)]

df_tmp = DataFrame(ind_senorge = convert.(Int, ncread(file, "id")))

df_links = join(df_tmp, df_links, on = :ind_senorge, kind = :left)


# Search for indicies for the model

coord_model = permutedims([df_links.xcoord df_links.ycoord])

coord_obs = permutedims([df_obs.xcoord df_obs.ycoord])

coord_model[ismissing.(coord_model)] .= -1000000

tree = BruteTree(coord_model)

idxs, dists = knn(tree, coord_obs, 1, true)

idxs = [x[1] for x in idxs]

dists = [x[1] for x in dists]


# Compute error statistics for all configurations

bias_swe_all, rmse_swe_all, mean_swe_obs_all = [], [], []
bias_hs_all, rmse_hs_all, mean_hs_obs_all = [], [], [], []

for cfg in 1:32

    println(cfg)

    bias_swe, rmse_swe, mean_swe_obs, bias_hs, rmse_hs, mean_hs_obs = compute_error(path_res, cfg, df_obs, idxs, time_sim)

    push!(bias_swe_all, bias_swe)
    push!(rmse_swe_all, rmse_swe)
    push!(mean_swe_obs_all, mean_swe_obs)
    
    push!(bias_hs_all, bias_hs)
    push!(rmse_hs_all, rmse_hs)
    push!(mean_hs_obs_all, mean_hs_obs)

end


# Save to tables

df_res = DataFrame(bias_swe_all = bias_swe_all,
                   rmse_swe_all = rmse_swe_all,
                   mean_swe_obs_all = mean_swe_obs_all,
                   bias_hs_all = bias_hs_all,
                   rmse_hs_all = rmse_hs_all,
                   mean_hs_obs_all = mean_hs_obs_all)

df_res |> CSV.write(joinpath(path_figure, "table_snow_evaluation.csv"))


# Plot results

ax = figure(figsize = (10, 4))
plot(bias_swe_all ./ mean_swe_obs_all, marker="o", linestyle="None")
xlabel("Model configuration")
ylabel("Normalized bias (-)")
title("SWE")
xticks(collect(0:31), collect(1:32))
savefig(joinpath(path_figure, "bias_swe.png"), dpi = 200)
close()

ax = figure(figsize = (10, 4))
plot(rmse_swe_all ./ mean_swe_obs_all, marker="o", linestyle="None")
xlabel("Model configuration")
ylabel("Normalized RMSE (-)")
title("SWE")
xticks(collect(0:31), collect(1:32))
savefig(joinpath(path_figure, "rmse_swe.png"), dpi = 200)
close()

ax = figure(figsize = (10, 4))
plot(bias_hs_all ./ mean_hs_obs_all, marker="o", linestyle="None")
xlabel("Model configuration")
ylabel("Normalized bias (-)")
title("Snow depth")
xticks(collect(0:31), collect(1:32))
savefig(joinpath(path_figure, "bias_hs.png"), dpi = 200)
close()

ax = figure(figsize = (10, 4))
plot(rmse_hs_all ./ mean_hs_obs_all, marker="o", linestyle="None")
xlabel("Model configuration")
ylabel("Normalized RMSE (-)")
title("Snow depth")
xticks(collect(0:31), collect(1:32))
savefig(joinpath(path_figure, "rmse_hs.png"), dpi = 200)
close()


# Box plots

cfgs = cfg_table()

fig, axes = plt[:subplots](nrows = 3, ncols = 2)

fig[:set_size_inches](8, 6)

fig[:text](0.04, 0.5, "Bias (%)", va="center", rotation="vertical")

fig[:text](1-0.04, 0.5, "NRMSE (-)", va="center", rotation="vertical")

fig[:text](0.5, 0.04, "Parameterization option", ha = "center")


# Bias for snow water equivalent

variable = 100 .* df_res.bias_swe_all ./ df_res.mean_swe_obs_all


explanation = cfgs.exchng

axes[1][:boxplot]([variable[explanation .== 0] variable[explanation .== 1]])

axes[1][:xaxis][:set_ticklabels]([])

axes[1][:annotate]("Exchng", xy=[0.03; 0.8], xycoords="axes fraction", fontsize=10.0)


explanation = cfgs.hydrol

axes[2][:boxplot]([variable[explanation .== 0] variable[explanation .== 1]])

axes[2][:xaxis][:set_ticklabels]([])

axes[2][:annotate]("Hydrol", xy=[0.03; 0.8], xycoords="axes fraction", fontsize=10.0)


explanation = cfgs.albedo

axes[3][:boxplot]([variable[explanation .== 0] variable[explanation .== 1]])

axes[3][:set_xticklabels](["0", "1"])

axes[3][:annotate]("Albedo", xy=[0.03; 0.8], xycoords="axes fraction", fontsize=10.0)


# RMSE for snow water equivalent

variable = df_res.rmse_swe_all ./ df_res.mean_swe_obs_all


explanation = cfgs.exchng

axes[4][:boxplot]([variable[explanation .== 0] variable[explanation .== 1]])

axes[4][:xaxis][:set_ticklabels]([])

axes[4][:yaxis][:tick_right]()

axes[4][:yaxis][:set_label_position]("right")

axes[4][:annotate]("Exchng", xy=[0.03; 0.8], xycoords="axes fraction", fontsize=10.0)


explanation = cfgs.hydrol

axes[5][:boxplot]([variable[explanation .== 0] variable[explanation .== 1]])

axes[5][:xaxis][:set_ticklabels]([])

axes[5][:yaxis][:tick_right]()

axes[5][:yaxis][:set_label_position]("right")

axes[5][:annotate]("Hydrol", xy=[0.03; 0.8], xycoords="axes fraction", fontsize=10.0)


explanation = cfgs.albedo

axes[6][:boxplot]([variable[explanation .== 0] variable[explanation .== 1]])

axes[6][:set_xticklabels](["0", "1"])

axes[6][:yaxis][:tick_right]()

axes[6][:yaxis][:set_label_position]("right")

axes[6][:annotate]("Albedo", xy=[0.03; 0.8], xycoords="axes fraction", fontsize=10.0)


# Save figure

savefig(joinpath(path_figure, "error_vs_parameterization.pdf"), dpi = 600)



