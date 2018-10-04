using IcanProj
using CSV
using DataFrames
using NearestNeighbors
using NetCDF
using Dates
using Statistics


# Function for computing error statistics

function compute_error(path, cfg, df_obs, idxs, time_sim)

    file_swe = joinpath(path, "results_$(cfg)", "swe_1km.nc")
    file_hs = joinpath(path, "results_$(cfg)", "snowdepth_1km.nc")
    
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

    bias_swe = mean(swe_sim .- swe_obs)
    rmse_swe = sqrt(mean((swe_sim .- swe_obs).^2))
    mean_swe_obs = mean(swe_obs);

    bias_hs = mean(hs_sim .- hs_obs)
    rmse_hs = sqrt(mean((hs_sim .- hs_obs).^2))
    mean_hs_obs = mean(hs_obs);

    return bias_swe, rmse_swe, mean_swe_obs, bias_hs, rmse_hs, mean_hs_obs

end


# Settings

path = "/data04/jmg/fsm_simulations/netcdf/fsmres_open"

figpath = joinpath(dirname(pathof(IcanProj)), "..", "plots", "snow_evaluation")


# Read tables

df_links = CSV.File(joinpath(dirname(pathof(IcanProj)), "..", "data", "df_links.csv")) |> DataFrame

df_obs = CSV.File(joinpath(dirname(pathof(IcanProj)), "..", "data", "snowdata.csv")) |> DataFrame


# Load metadata from simulations

file = joinpath(path, "results_32/swe_1km.nc")

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

    bias_swe, rmse_swe, mean_swe_obs, bias_hs, rmse_hs, mean_hs_obs = compute_error(path, cfg, df_obs, idxs, time_sim)

    push!(bias_swe_all, bias_swe)
    push!(rmse_swe_all, rmse_swe)
    push!(mean_swe_obs_all, mean_swe_obs)
    
    push!(bias_hs_all, bias_hs)
    push!(rmse_hs_all, rmse_hs)
    push!(mean_hs_obs_all, mean_hs_obs)

end


# Plot results

ax = figure(figsize = (10, 4))
plot(bias_swe_all ./ mean_swe_obs_all, marker="o", linestyle="None")
xlabel("Model configuration")
ylabel("Normalized bias (-)")
title("SWE")
xticks(collect(0:31), collect(1:32))
savefig(joinpath(figpath, "bias_swe.png"), dpi = 200)
close()

ax = figure(figsize = (10, 4))
plot(rmse_swe_all ./ mean_swe_obs_all, marker="o", linestyle="None")
xlabel("Model configuration")
ylabel("Normalized RMSE (-)")
title("SWE")
xticks(collect(0:31), collect(1:32))
savefig(joinpath(figpath, "rmse_swe.png"), dpi = 200)
close()

ax = figure(figsize = (10, 4))
plot(bias_hs_all ./ mean_hs_obs_all, marker="o", linestyle="None")
xlabel("Model configuration")
ylabel("Normalized bias (-)")
title("Snow depth")
xticks(collect(0:31), collect(1:32))
savefig(joinpath(figpath, "bias_hs.png"), dpi = 200)
close()

ax = figure(figsize = (10, 4))
plot(rmse_hs_all ./ mean_hs_obs_all, marker="o", linestyle="None")
xlabel("Model configuration")
ylabel("Normalized RMSE (-)")
title("Snow depth")
xticks(collect(0:31), collect(1:32))
savefig(joinpath(figpath, "rmse_hs.png"), dpi = 200)
close()
