
using DataFrames
using JFSM2
using PyPlot
using PyCall


function load_results()

    res_all = Dict()

    for spaceres in ["5km", "10km", "25km", "50km"]

        file = joinpath(dirname(pathof(IcanProj)), "..", "data", "table_errors_$(spaceres).txt")

        res_all[spaceres] = CSV.read(file, delim = ",")

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

            tmp = tmp[!isnan.(tmp)]

            data[i,j] = median(tmp) #df_res[Symbol("$(measure)_$(variable)_cfg$(cfgs[i])")])

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


filename = joinpath(figpath, "snowdepth_nse.png")

nseres, spaceres = error_matrix(res_all, "snowdepth", "nse")

plot_rank(1-nseres[:,end], "Ranking from lowest to highest error", "Snowdepth", filename)


filename = joinpath(figpath, "swe_nse.png")

nseres, spaceres = error_matrix(res_all, "swe", "nse")

plot_rank(1-nseres[:,end], "Ranking from lowest to highest error", "SWE", filename)
