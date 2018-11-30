
using DataFrames
using JFSM2
using PyPlot
using PyCall
using Statistics
using IcanProj
using CSV


function load_results()

    res_all = Dict()

    for spaceres in ["5km", "10km", "25km", "50km"]

        file = joinpath(dirname(pathof(IcanProj)), "..", "data", "table_errors_$(spaceres).txt")

        res_all[spaceres] = CSV.File(file, delim = ",") |> DataFrame

    end

    return res_all
    
end


function ranking_of_options(res_all, variable, measure)

    # Determine performance for each configuration

    spaceres = "50km"

    cfgs = 1:32

    data = fill(0.0, length(cfgs))

    df_res = res_all[spaceres]

    for i in cfgs

        tmp = df_res[Symbol("$(measure)_$(variable)_cfg$(cfgs[i])")]

        tmp = tmp[map(x -> !isnan(x), tmp)]   

        data[i] = median(tmp)

    end

    # Sort the configuration table after performance
    
    df_cfg = cfg_table()

    df_cfg = df_cfg[[:exchng, :hydrol, :albedo, :condct, :densty]]

    mat_cfg = convert(Array{Int64,2}, df_cfg)

    if measure == "nse"
        data = 1 .- data
    end

    isorted = sortperm(data)

    mat_cfg = mat_cfg[isorted, :] 

    xtext = uppercase.(string.(names(df_cfg)))
    
    ytext = collect(1:2:32)
    
    return mat_cfg, xtext, ytext

end


# Load results

res_all = load_results()


# Set up plot

py"""
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors

xtext = $xtext
ytext = $ytext

fig, ax = plt.subplots(2, 2, figsize=(6,6)) 

cmap, norm = mcolors.from_levels_and_colors([-100, 0.5, 100], ['red', 'blue'])

fig.text(0.04, 0.5, "Ranking from lowest to highest error", va="center", rotation="vertical")
"""

# Snow water equivalent

mat_cfg, xtext, ytext = ranking_of_options(res_all, "swe", "rmse")

py"""
data = $mat_cfg

ax[0,0].pcolor(data, edgecolors='k', cmap=cmap, norm=norm, alpha = 0.5)
ax[0,0].set_xticks(np.arange(0.5, len(xtext), 1)) #, xtext, rotation = 45)
ax[0,0].set_xticklabels("")
ax[0,0].set_yticks(np.arange(0.5, 32, 2)) #, ytext)
ax[0,0].set_yticklabels(ytext)
ax[0,0].set_title("SWE")
"""

# Net radiation

mat_cfg, xtext, ytext = ranking_of_options(res_all, "rnet", "rmse")

py"""
data = $mat_cfg

ax[0,1].pcolor(data, edgecolors='k', cmap=cmap, norm=norm, alpha = 0.5)
ax[0,1].set_xticks(np.arange(0.5, len(xtext), 1)) #, xtext, rotation = 45)
ax[0,1].set_xticklabels("")
ax[0,1].set_yticks(np.arange(0.5, 32, 2)) #, ytext)
ax[0,1].set_yticklabels("")
ax[0,1].set_title("RNET")
"""

# Sensible heat fluxes

mat_cfg, xtext, ytext = ranking_of_options(res_all, "hatmo", "rmse")

py"""
data = $mat_cfg

ax[1,0].pcolor(data, edgecolors='k', cmap=cmap, norm=norm, alpha = 0.5)
ax[1,0].set_xticks(np.arange(0.5, len(xtext), 1)) 
ax[1,0].set_xticklabels(xtext, rotation = 45)
ax[1,0].set_yticks(np.arange(0.5, 32, 2))
ax[1,0].set_yticklabels(ytext)
ax[1,0].set_title("HATMO")
"""

# Latent heat fluxes

mat_cfg, xtext, ytext = ranking_of_options(res_all, "latmo", "rmse")

py"""
data = $mat_cfg

ax[1,1].pcolor(data, edgecolors='k', cmap=cmap, norm=norm, alpha = 0.5)
ax[1,1].set_xticks(np.arange(0.5, len(xtext), 1)) 
ax[1,1].set_xticklabels(xtext, rotation = 45)
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







#=

function load_results()

    res_all = Dict()

    for spaceres in ["5km", "10km", "25km", "50km"]

        file = joinpath(dirname(pathof(IcanProj)), "..", "data", "table_errors_$(spaceres).txt")

        res_all[spaceres] = CSV.File(file, delim = ",") |> DataFrame

    end

    return res_all
    
end



function error_matrix(res_all, variable, measure)

    spaceres = ["5km", "10km", "25km", "50km"]

    cfgs = 1:32

    data = fill(0.0, length(cfgs), length(spaceres))

    for j in eachindex(spaceres)

        df_res = res_all[spaceres[j]]

        for i in cfgs

            tmp = df_res[Symbol("$(measure)_$(variable)_cfg$(cfgs[i])")]

            tmp = tmp[map(x -> !isnan(x), tmp)]   

            data[i,j] = median(tmp)

        end
        
    end

    return data, spaceres

end




function plot_rank(data, ylabrank, titlerank, filename)

    df_cfg = cfg_table()

    mat_cfg = convert(Array{Int64,2}, df_cfg)
    
    isorted = sortperm(data)

    mat_cfg = mat_cfg[isorted, :] 

    xtext = uppercase.(string.(names(df_cfg)))
    ytext = collect(1:2:32) #round.(data[isorted], 3)
    
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

    cmap, norm = mcolors.from_levels_and_colors([-100, 0.5, 100], ['red', 'blue'])

    plt.figure(figsize=(6, 6))
    plt.pcolor(data, cmap=cmap, norm=norm, alpha = 0.5)
    plt.xticks(np.arange(0.5, len(xtext), 1), xtext, rotation = 45)
    plt.yticks(np.arange(0.5, 32, 2), ytext)
    plt.colorbar()
    plt.ylabel($ylabrank)
    plt.title($titlerank)

    plt.show()
    plt.savefig($filename, dpi=200, bbox_inches='tight')
    plt.close()
    """
    
end



res_all = load_results()

figpath = joinpath(dirname(pathof(IcanProj)), "..", "plots", "rank")


# Snow water equivalent

filename = joinpath(figpath, "swe_rmse.png")

res, spaceres = error_matrix(res_all, "swe", "rmse")

plot_rank(res[:,end], "Ranking from lowest to highest error", "SWE", filename)


# Latent heat exchange

filename = joinpath(figpath, "latmo_rmse.png")

res, spaceres = error_matrix(res_all, "latmo", "rmse")

plot_rank(res[:,end], "Ranking from lowest to highest error", "LATMO", filename)


# Sensible heat exchange

filename = joinpath(figpath, "hatmo_rmse.png")

res, spaceres = error_matrix(res_all, "hatmo", "rmse")

plot_rank(res[:,end], "Ranking from lowest to highest error", "HATMO", filename)


# Net radiation

filename = joinpath(figpath, "rnet_rmse.png")

res, spaceres = error_matrix(res_all, "rnet", "rmse")

plot_rank(res[:,end], "Ranking from lowest to highest error", "RNET", filename)

=#