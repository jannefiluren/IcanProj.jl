
using IcanProj
using NetCDF
using DataFrames
using PyPlot
using JFSM2
using PyCall
using Statistics


function compute_error(path, res_fine, res_coarse, experiment, variable)

    res = Vector{Dict}(undef, length(experiment))
    
    for iexp in experiment

        @show iexp
        
        # File names
        
        file_fine = get_filename(path, variable, res_fine, iexp)

        file_coarse = get_filename(path, variable, res_coarse, iexp)

        # Load data

        df_links = link_results(file_fine, file_coarse)

        data_coarse, data_aggregated, ngrids = unify_results(file_fine, file_coarse, df_links, variable)

        # Compute metrics per grid cell

        err = data_coarse - data_aggregated

        rmse = sqrt.(mean(err.^2 , dims = 1))

        meanref = mean(data_aggregated, dims = 1)

        meancmp = mean(data_coarse, dims = 1)

        nrmse = rmse ./ meanref

        bias = meancmp .- meanref

        perc_bias = 100*(meancmp ./ meanref .- 1)

        # Return as averages

        weights = ngrids[:]/sum(ngrids[:])

        res[iexp] = Dict("rmse" => sum(rmse[:] .* weights),
                         "meanref" => sum(meanref[:] .* weights),
                         "meancmp" => sum(meancmp[:] .* weights),
                         "nrmse" => sum(nrmse[:] .* weights),
                         "bias" => sum(bias[:] .* weights),
                         "perc_bias" => sum(perc_bias[:] .* weights))

    end

    return res

end


function compute_error_all(path, res_fine, experiment, variable)

    resall = Array{Dict}(undef, 32, 0)

    for res_coarse in ["5km", "10km", "25km", "50km"]

        @show res_coarse

        res = compute_error(path, res_fine, res_coarse, experiment, variable)

        resall = [resall res]

    end

    return resall

end


function plot_cfg_text(data, var_name)

    figure()
    for icfg in 1:32
        tmp = data[icfg, :]
        plot(tmp)
        xticks(collect(0:length(tmp)-1), res_coarse)
        xlabel("Spatial resolution")
        ylabel(var_name)
        annotate(string([df_cfg[icfg, i] for i in 1:6]), xy=(length(tmp)-1, tmp[end]))
        xlim(-0.5, length(tmp)-0.5)
    end
    
end


function plot_rank(data, ylabrank, titlerank, filename)

    df_cfg = cfg_table()

    mat_cfg = convert(Array{Int64,2}, df_cfg)
    
    isorted = sortperm(data)

    mat_cfg = mat_cfg[isorted, :] 

    xtext = string.(names(df_cfg))
    ytext = round.(data[isorted], digits = 3)
    
    ikeep = [1,3,4,5,6]
    
    xtext = xtext[ikeep]
    ytext = ytext

    mat_cfg = mat_cfg[:, ikeep]

    py"""
    import numpy as np
    import matplotlib.pyplot as plt
    import matplotlib.colors as mcolors

    xtext = $xtext
    ytext = $ytext
    data = $mat_cfg

    cmap, norm = mcolors.from_levels_and_colors([-100, 0.5, 100], ['blue', 'yellow'])

    plt.figure(figsize=(6, 8))
    plt.pcolor(data, cmap=cmap, norm=norm)
    plt.xticks(np.arange(0.5, len(xtext), 1), xtext, rotation = 45)
    plt.yticks(np.arange(0.5, len(ytext), 1), ytext)
    plt.colorbar()
    plt.ylabel($ylabrank)
    plt.title($titlerank)

    #plt.show()
    plt.savefig($filename)
    plt.close()
    """
    
end



function plot_error_scales(resall, metric, df_cfg)

    data = map(x -> x[metric], resall)

    data = permutedims(data)
    
    exchng_off = convert(Array{Bool}, df_cfg[:exchng] .== 0)
    exchng_on  = convert(Array{Bool}, df_cfg[:exchng] .== 1)

    figure()

    plot(collect(1:size(data,1)), data, color = "gray")

    fill_between(collect(1:size(data,1)),
                 maximum(data[:, exchng_off], dims = 2)[:],
                 minimum(data[:, exchng_off], dims = 2)[:],
                 facecolor = "red", edgecolor = "red", alpha = 0.5,
                 label = "Exchng=0")

    fill_between(collect(1:size(data,1)),
                 maximum(data[:, exchng_on], dims = 2)[:],
                 minimum(data[:, exchng_on], dims = 2)[:],
                 facecolor = "blue", edgecolor = "blue", alpha = 0.5,
                 label = "Exchng=1")

    xticks(collect(1:size(data,1)), ["5km", "10km", "25km", "50km"])

    legend()

end



# Error different scales - overall settings

pathres = "/data04/jmg/fsm_simulations/netcdf/fsmres_forest"

df_cfg = cfg_table()

res_fine = "1km"

experiment = 1:32

pathfig = joinpath(dirname(pathof(IcanProj)), "..", "plots", "error_scales")


# Snow depth

variable = "snowdepth"

title_str = "Snow depth"
metric_vec = ["perc_bias", "rmse", "nrmse"]
ylabel_vec = ["Bias (%)", "RMSE (m)", "NRMSE (-)"]

resall = compute_error_all(pathres, res_fine, experiment, variable)

for (metric, ylab) in zip(metric_vec, ylabel_vec)

    plot_error_scales(resall, metric, df_cfg)
    title(title_str)
    ylabel(ylab)

    savefig(joinpath(pathfig, "$(variable)_$(metric).png"))

    close()

end


# Snow water equivalent

variable = "swe"

title_str = "Snow water equivalent"
metric_vec = ["perc_bias", "rmse", "nrmse"]
ylabel_vec = ["Bias (%)", "RMSE (mm)", "NRMSE (-)"]

resall = compute_error_all(pathres, res_fine, experiment, variable)

for (metric, ylab) in zip(metric_vec, ylabel_vec)

    plot_error_scales(resall, metric, df_cfg)
    title(title_str)
    ylabel(ylab)

    savefig(joinpath(pathfig, "$(variable)_$(metric).png"))

    close()

end


# Latent heat fluxes

variable = "latmo"

title_str = "Latent heat fluxes"
metric_vec = ["bias", "rmse"]
ylabel_vec = ["Bias (W/m2)", "RMSE (W/m2)"]

resall = compute_error_all(pathres, res_fine, experiment, variable)

for (metric, ylab) in zip(metric_vec, ylabel_vec)

    plot_error_scales(resall, metric, df_cfg)
    title(title_str)
    ylabel(ylab)

    savefig(joinpath(pathfig, "$(variable)_$(metric).png"))

    close()

end


# Sensible heat fluxes

variable = "hatmo"

title_str = "Sensible heat fluxes"
metric_vec = ["bias", "rmse"]
ylabel_vec = ["Bias (W/m2)", "RMSE (W/m2)"]

resall = compute_error_all(pathres, res_fine, experiment, variable)

for (metric, ylab) in zip(metric_vec, ylabel_vec)

    plot_error_scales(resall, metric, df_cfg)
    title(title_str)
    ylabel(ylab)

    savefig(joinpath(pathfig, "$(variable)_$(metric).png"))

    close()

end


# Net radiation

variable = "rnet"

title_str = "Net radiation"
metric_vec = ["bias", "rmse", "nrmse"]
ylabel_vec = ["Bias (W/m2)", "RMSE (W/m2)", "NRMSE (-)"]

resall = compute_error_all(pathres, res_fine, experiment, variable)

for (metric, ylab) in zip(metric_vec, ylabel_vec)

    plot_error_scales(resall, metric, df_cfg)
    title(title_str)
    ylabel(ylab)

    savefig(joinpath(pathfig, "$(variable)_$(metric).png"))

    close()

end


# Melt

variable = "melt"

title_str = "Melt"
metric_vec = ["bias", "rmse", "nrmse"]
ylabel_vec = ["Bias (mm/day)", "RMSE (mm/day)", "NRMSE (-)"]

resall = compute_error_all(pathres, res_fine, experiment, variable)

for (metric, ylab) in zip(metric_vec, ylabel_vec)

    plot_error_scales(resall, metric, df_cfg)
    title(title_str)
    ylabel(ylab)

    savefig(joinpath(pathfig, "$(variable)_$(metric).png"))

    close()

end








# Rank plots

if false

    pathres = "/data04/jmg/fsm_simulations/netcdf/fsmres_forest"

    res_fine = "1km"

    experiment = 1:32

    pathfig = joinpath(dirname(pathof(IcanProj)), "..", "plots", "rank")

    for variable in ["snowdepth", "swe"], res_coarse in ["5km", "10km", "25km", "50km"]

        @show variable, res_coarse

        res = compute_error(pathres, res_fine, res_coarse, experiment, variable)

        for metric in ["nrmse", "absbias"]

            data = map(x -> x[metric], res)

            filename = joinpath(pathfig, "$(variable)_$(metric)_$(res_coarse).png")

            plot_rank(data, "$(metric)", "$(variable) - $(res_coarse)", filename)

        end
        
    end

end





















#=
function compute_error_all_resolutions(path, res_fine, res_coarse, experiment, variable)

    res = Array{Dict, 2}(length(experiment), length(res_coarse))

    for i in eachindex(experiment), j in eachindex(res_coarse)

        @show i, j
        
        res[i, j] = compute_error_one_resolution(path,
                                                 res_fine,
                                                 res_coarse[j],
                                                 experiment[i],
                                                 variable)
        
    end

    return res

end
=#


