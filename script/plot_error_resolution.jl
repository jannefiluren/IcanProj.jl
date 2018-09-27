
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

        hs_coarse, hs_aggregated, ngrids = unify_results(file_fine, file_coarse, df_links, variable)

        # Compute metrics per grid cell

        err = hs_coarse - hs_aggregated

        rmse = sqrt.(mean(err.^2 , dims = 1))

        meanref = mean(hs_aggregated, dims = 1)

        meancmp = mean(hs_coarse, dims = 1)

        nrmse = rmse ./ meanref

        bias = 100*(meancmp ./ meanref .- 1)

        absbias = abs.(bias)

        # Return as averages

        weights = ngrids[:]/sum(ngrids[:])

        res[iexp] = Dict("rmse" => sum(rmse[:] .* weights),
                         "meanref" => sum(meanref[:] .* weights),
                         "meancmp" => sum(meancmp[:] .* weights),
                         "nrmse" => sum(nrmse[:] .* weights),
                         "absbias" => sum(absbias[:] .* weights))

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







# Rank plots

if false

    pathres = "/data04/jmg/fsm_simulations/netcdf/fsmres"

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

# Error different scales

pathres = "/data04/jmg/fsm_simulations/netcdf/fsmres"

df_cfg = cfg_table()

res_fine = "1km"

experiment = 1:32

pathfig = joinpath(dirname(pathof(IcanProj)), "..", "plots", "error_scales")

# Snow depth

variable = "snowdepth"

resall = compute_error_all(pathres, res_fine, experiment, variable)

metric = "absbias"

plot_error_scales(resall, metric, df_cfg)
title("Snow depth")
ylabel("Absolute bias (%)")

savefig(joinpath(pathfig, "$(variable)_$(metric).png"))

metric = "nrmse"

plot_error_scales(resall, metric, df_cfg)
title("Snow depth")
ylabel("NRMSE (-)")

savefig(joinpath(pathfig, "$(variable)_$(metric).png"))

# Snow water equivalent
        
variable = "swe"

resall = compute_error_all(pathres, res_fine, experiment, variable)

metric = "absbias"

plot_error_scales(resall, metric, df_cfg)
title("Snow water equivalent")
ylabel("Absolute bias (%)")

savefig(joinpath(pathfig, "$(variable)_$(metric).png"))

metric = "nrmse"

plot_error_scales(resall, metric, df_cfg)
title("Snow water equivalent")
ylabel("NRMSE (-)")

savefig(joinpath(pathfig, "$(variable)_$(metric).png"))





# Interactive plots

#=

df_cfg = cfg_table()

pathres = "/data02/Ican/vic_sim/fsm_past_1km/netcdf/tmp/"

res_fine = "1km"

experiment = 1:32

pathfig = joinpath(dirname(pathof(IcanProj)), "..", "plots", "rank")

variable = "swe"

res_coarse = "50km"

res = compute_error(pathres, res_fine, res_coarse, experiment, variable)

metric = map(x -> x["nrmse"], res)

figure()
for icfg in 1:32
    plot(1, metric[icfg], "o")
    str = "$(df_cfg[icfg, 1])  $(df_cfg[icfg, 3])  $(df_cfg[icfg, 4])  $(df_cfg[icfg, 5])  $(df_cfg[icfg, 6])"
    annotate(str, xy=(1.02, metric[icfg]))
    xlim(0.5, 1.5)
end

=#








# Settings

# path = "/data02/Ican/vic_sim/fsm_past_1km/netcdf/tmp/"

# res_fine = "5km"

#res_coarse = ["25km", "50km"]

#experiment = 1:32


# Snow depth

#variable = "snowdepth"

#res_hs = compute_error_all_resolutions(path, res_fine, res_coarse, experiment, variable)


# Snow water equivalent

#variable = "swe"

#res_swe = compute_error_all_resolutions(path, res_fine, res_coarse, experiment, variable)

















# Matrices

# nrmse_hs = map(x -> x["nrmse"], res_hs)

# nrmse_swe = map(x -> x["nrmse"], res_swe)

# absbias_hs = map(x -> x["absbias"], res_hs)

#=absbias_swe = map(x -> x["absbias"], res_swe)




# Interactive plots



=#









#=

figure()
plot(nrsme_hs')
xticks(collect(0:length(res_coarse)-1), res_coarse)
xlabel("Spatial resolution")
ylabel("NRMSE")
title("Snow depth")



figure()
plot(nrmse_swe')

figure()
plot(bias_hs')

figure()
plot(bias_swe')    



df_cfg = cfg_table()

mat_cfg = convert(Array{Int64,2}, df_cfg)

p = sortperm(absbias_swe[:,end])
imshow(mat_cfg[reverse(p),:])


var = absbias_swe


figure()
for icfg in 1:32
    data = var[icfg, :]
    plot(data)
    xticks(collect(0:length(data)-1), res_coarse)
  #  xlabel("Spatial resolution")
#    ylabel("NRMSE")
 #   title("Snow depth")
    annotate(string([df_cfg[icfg, i] for i in 1:6]), xy=(length(data)-1, data[end]))
    xlim(-0.5, length(data)-0.5)
end
=#



#=

# Settings

file_fine = "/data02/Ican/vic_sim/fsm_past_1km/netcdf/tmp/results_1/snowdepth_1km.nc"

file_coarse = "/data02/Ican/vic_sim/fsm_past_1km/netcdf/tmp/results_1/snowdepth_50km.nc"

#id_fine = "ind_senorge"

#id_coarse = "ind_50km"

variable = "snowdepth"


# Load data

df_links = link_results(file_fine, file_coarse) #, id_fine, id_coarse)

hs_coarse, hs_aggregated = unify_results(file_fine, file_coarse, df_links, variable)


# Compute metrics

rmse = sqrt.(mean((hs_coarse - hs_aggregated).^2 ,1))

meanref = mean(hs_aggregated, 1)

meancmp = mean(hs_coarse, 1)

nrmse = rmse ./ meanref

bias = meancmp ./ meanref


# Project to map

rmse_map = project_results(rmse[:], df_links)

meanref_map = project_results(meanref[:], df_links)

meancmp_map = project_results(meancmp[:], df_links)

nrmse_map = project_results(nrmse[:], df_links)

bias_map = project_results(bias[:], df_links)


# Plot maps

figure()
imshow(meanref_map)
cb = colorbar()
cb[:set_label]("Snow depth (m)")
title("Fine scale run")


figure()
imshow(meancmp_map)
cb = colorbar()
cb[:set_label]("Snow depth (m)")
title("Coarse scale run")


figure()
imshow(bias_map)
cb = colorbar()
cb[:set_label]("Bias (-)")
title("Snow depth - coarse divded by fine scale")


figure()
imshow(nrmse_map)
cb = colorbar()
cb[:set_label]("NRMSE (-)")
title("Snow depth")

=#
