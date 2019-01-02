using IcanProj
using DataFrames
using JFSM2
using PyPlot
using PyCall
using Statistics


function compute_error(path, res_coarse, variable)

    experiment = 1:32

    res = Vector{Dict}(undef, length(experiment))
    
    for iexp in experiment

        @show iexp
        
        # File names
        
        file_fine = get_filename(path, variable, "1km", iexp)

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

        abs_bias = abs.(bias)

        perc_bias = 100*(meancmp ./ meanref .- 1)

        # Return as averages

        weights = ngrids[:]/sum(ngrids[:])

        res[iexp] = Dict("rmse" => sum(rmse[:] .* weights),
                         "meanref" => sum(meanref[:] .* weights),
                         "meancmp" => sum(meancmp[:] .* weights),
                         "nrmse" => sum(nrmse[:] .* weights),
                         "bias" => sum(bias[:] .* weights),
                         "abs_bias" => sum(abs_bias[:] .* weights),
                         "perc_bias" => sum(perc_bias[:] .* weights))

    end

    return res

end


function ranking_of_options(resall, variable, measure)

    data_rmse = map(x -> x[measure], resall)

    df_cfg = cfg_table()

    df_cfg = df_cfg[[:exchng, :hydrol, :albedo, :condct, :densty]]

    mat_cfg = convert(Array{Int64, 2}, df_cfg)

    if measure == "nse"
        data = 1 .- data
    end

    isorted = sortperm(data_rmse)

    mat_cfg = mat_cfg[isorted, :] 

    xtext = uppercase.(string.(names(df_cfg)))
    
    ytext = collect(1:2:32)
    
    return mat_cfg, xtext, ytext

end


# Error different scales - overall settings

pathres = "/data04/jmg/fsm_simulations/netcdf/fsmres_forest"

res_coarse = "50km"

measure = "rmse"

pathfig = joinpath(dirname(pathof(IcanProj)), "..", "plots", "error_scales")


# Set up plot

py"""
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors

fig, ax = plt.subplots(2, 2, figsize=(6,6)) 

cmap, norm = mcolors.from_levels_and_colors([-100, 0.5, 100], ['red', 'blue'])

fig.text(0.04, 0.5, "Ranking from lowest to highest error", va="center", rotation="vertical")
"""

# Snow water equivalent

variable = "swe"

resall = compute_error(pathres, res_coarse, variable)

mat_cfg, xtext, ytext = ranking_of_options(resall, variable, measure)

py"""
data = $mat_cfg

ax[0,0].pcolor(data, edgecolors='k', cmap=cmap, norm=norm, alpha = 1.0)
ax[0,0].set_xticks(np.arange(0.5, len($xtext), 1)) #, xtext, rotation = 45)
ax[0,0].set_xticklabels("")
ax[0,0].set_yticks(np.arange(0.5, 32, 2)) #, ytext)
ax[0,0].set_yticklabels($ytext)
ax[0,0].set_title("SWE")
"""

# Net radiation

variable = "rnet"

resall = compute_error(pathres, res_coarse, variable)

mat_cfg, xtext, ytext = ranking_of_options(resall, variable, measure)

py"""
data = $mat_cfg

ax[0,1].pcolor(data, edgecolors='k', cmap=cmap, norm=norm, alpha = 1.0)
ax[0,1].set_xticks(np.arange(0.5, len($xtext), 1)) #, xtext, rotation = 45)
ax[0,1].set_xticklabels("")
ax[0,1].set_yticks(np.arange(0.5, 32, 2)) #, ytext)
ax[0,1].set_yticklabels("")
ax[0,1].set_title("RNET")
"""

# Sensible heat fluxes

variable = "hatmo"

resall = compute_error(pathres, res_coarse, variable)

mat_cfg, xtext, ytext = ranking_of_options(resall, variable, measure)

py"""
data = $mat_cfg

ax[1,0].pcolor(data, edgecolors='k', cmap=cmap, norm=norm, alpha = 1.0)
ax[1,0].set_xticks(np.arange(0.5, len($xtext), 1)) 
ax[1,0].set_xticklabels($xtext, rotation = 45)
ax[1,0].set_yticks(np.arange(0.5, 32, 2))
ax[1,0].set_yticklabels($ytext)
ax[1,0].set_title("HATMO")
"""

# Latent heat fluxes

variable = "latmo"

resall = compute_error(pathres, res_coarse, variable)

mat_cfg, xtext, ytext = ranking_of_options(resall, variable, measure)

py"""
data = $mat_cfg

ax[1,1].pcolor(data, edgecolors='k', cmap=cmap, norm=norm, alpha = 1.0)
ax[1,1].set_xticks(np.arange(0.5, len($xtext), 1)) 
ax[1,1].set_xticklabels($xtext, rotation = 45)
ax[1,1].set_yticks(np.arange(0.5, 32, 2))
ax[1,1].set_yticklabels("")
ax[1,1].set_title("LATMO")
"""

# Save figure

figname = joinpath(dirname(pathof(IcanProj)), "..", "plots", "rank", "ranking_50km.png")

py"""
plt.show()
plt.savefig($figname, dpi=200, bbox_inches='tight')
plt.close()
"""

