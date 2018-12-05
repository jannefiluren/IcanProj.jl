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


function compute_error_all(path, variable)

    res_coarse = ["5km", "10km", "25km", "50km"]

    resall = Array{Array{Dict,1}}(undef, length(res_coarse))

    for i in 1:length(res_coarse)

        @show res_coarse[i]

        resall[i] = compute_error(path, res_coarse[i], variable)

    end

    return resall

end


function plot_error_scales(resall, variable, ylabel_left, ylabel_right)

    data_rmse = zeros(4, 32)
    data_bias = zeros(4, 32)

    for i in 1:4, j in 1:32
        data_rmse[i, j] = resall[i][j]["rmse"]
        data_bias[i, j] = resall[i][j]["abs_bias"]
    end

    df_cfg = cfg_table()

    exchng_0 = convert(Array{Bool}, df_cfg[:exchng] .== 0)
    exchng_1 = convert(Array{Bool}, df_cfg[:exchng] .== 1)

    py"""
    import matplotlib.pyplot as plt

    fig, ax = plt.subplots(1, 2, figsize=(8,3))

    ax[0].plot($(data_rmse[:, exchng_0]), color = 'red', label = 'Option 0')
    ax[0].plot($(data_rmse[:, exchng_1]), color = 'blue', label = 'Option 1', linestyle = '--')

    ax[0].set_ylabel($ylabel_left)

    ax[0].set_xticks($(collect(0:3)))
    ax[0].xaxis.set_ticklabels(["5km", "10km", "25km", "50km"])

    ax[0].annotate("(A)", xy=[0.1, 0.8], xycoords='axes fraction', fontsize=12)

    ax[1].plot($(data_bias[:, exchng_0]), color = 'red', label = 'Option 0')
    ax[1].plot($(data_bias[:, exchng_1]), color = 'blue', label = 'Option 1', linestyle = '--')

    ax[1].yaxis.tick_right()

    ax[1].yaxis.set_label_position('right')

    ax[1].set_ylabel($ylabel_right)

    ax[1].set_xticks($(collect(0:3)))
    ax[1].xaxis.set_ticklabels(["5km", "10km", "25km", "50km"])

    ax[1].annotate("(B)", xy=[0.1, 0.8], xycoords='axes fraction', fontsize=12)

    plt.show()

    plt.savefig($(joinpath(pathfig, "$(variable).png")), dpi = 600)
    """

    return nothing

end


# Error different scales - overall settings

pathres = "/data04/jmg/fsm_simulations/netcdf/fsmres_forest"

pathfig = joinpath(dirname(pathof(IcanProj)), "..", "plots", "error_scales")


# Snow water equivalent

variable = "swe"

resall = compute_error_all(pathres, variable)

plot_error_scales(resall, variable, "RMSE (\$mm\$)", "Abs bias (\$mm\$)")

# Net radiation

variable = "rnet"

resall = compute_error_all(pathres, variable)

plot_error_scales(resall, variable, "RMSE (\$W/m^2\$)", "Abs bias (\$W/m^2\$)")

# Sensible heat fluxes

variable = "hatmo"

resall = compute_error_all(pathres, variable)

plot_error_scales(resall, variable, "RMSE (\$W/m^2\$)", "Abs bias (\$W/m^2\$)")

# Latent heat fluxes

variable = "latmo"

resall = compute_error_all(pathres, variable)

plot_error_scales(resall, variable, "RMSE (\$W/m^2\$)", "Abs bias (\$W/m^2\$)")








#=
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
=#

#=
function plot_error_scales(resall, metric, df_cfg)

    data = map(x -> x[metric], resall)

    data = permutedims(data)
    
    exchng_0 = convert(Array{Bool}, df_cfg[:exchng] .== 0)
    exchng_1  = convert(Array{Bool}, df_cfg[:exchng] .== 1)

    figure()

    plot(collect(1:size(data,1)), data, color = "gray")

    fill_between(collect(1:size(data,1)),
                 maximum(data[:, exchng_0], dims = 2)[:],
                 minimum(data[:, exchng_0], dims = 2)[:],
                 facecolor = "red", edgecolor = "red", alpha = 0.5,
                 label = "Exchng=0")

    fill_between(collect(1:size(data,1)),
                 maximum(data[:, exchng_1], dims = 2)[:],
                 minimum(data[:, exchng_1], dims = 2)[:],
                 facecolor = "blue", edgecolor = "blue", alpha = 0.5,
                 label = "Exchng=1")

    xticks(collect(1:size(data,1)), ["5km", "10km", "25km", "50km"])

    legend()

end
=#





#=
resall = compute_error_all(pathres, variable)

data_rmse = map(x -> x["abs_bias"], resall)
data_bias = map(x -> x["rmse"], resall)

data_rmse = permutedims(data_rmse)
data_bias = permutedims(data_bias)

exchng_0 = convert(Array{Bool}, df_cfg[:exchng] .== 0)
exchng_1  = convert(Array{Bool}, df_cfg[:exchng] .== 1)

py"""
import matplotlib.pyplot as plt

fig, ax = plt.subplots(1, 2, figsize=(8,3))

ax[0].plot($(data_rmse[:, exchng_0]), color = 'red', label = 'Option 0')
ax[0].plot($(data_rmse[:, exchng_1]), color = 'blue', label = 'Option 1')

ax[0].set_ylabel($ylabel_left)

ax[0].set_xticks($(collect(0:3)))
ax[0].xaxis.set_ticklabels(["5km", "10km", "25km", "50km"])

ax[0].annotate("(A)", xy=[0.1, 0.8], xycoords='axes fraction', fontsize=12)

ax[1].plot($(data_bias[:, exchng_0]), color = 'red', label = 'Option 0')
ax[1].plot($(data_bias[:, exchng_1]), color = 'blue', label = 'Option 1')

ax[1].yaxis.tick_right()

ax[1].yaxis.set_label_position('right')

ax[1].set_ylabel($ylabel_right)

ax[1].set_xticks($(collect(0:3)))
ax[1].xaxis.set_ticklabels(["5km", "10km", "25km", "50km"])

ax[1].annotate("(B)", xy=[0.1, 0.8], xycoords='axes fraction', fontsize=12)

plt.show()

plt.savefig($(joinpath(pathfig, "$(variable).png")), dpi = 600)
"""

=#



#=

# Snow water equivalent

variable = "swe"

title_str = "Snow water equivalent"
metric_vec = ["perc_bias", "abs_bias", "rmse", "nrmse"]
ylabel_vec = ["Bias (%)", "Abs Bias (mm)", "RMSE (mm)", "NRMSE (-)"]

resall = compute_error_all(pathres, variable)

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
metric_vec = ["bias", "abs_bias", "rmse"]
ylabel_vec = ["Bias (W/m2)", "Abs Bias (W/m2)", "RMSE (W/m2)"]

resall = compute_error_all(pathres, variable)

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
metric_vec = ["bias", "abs_bias", "rmse"]
ylabel_vec = ["Bias (W/m2)", "Abs Bias (W/m2)", "RMSE (W/m2)"]

resall = compute_error_all(pathres, variable)

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
metric_vec = ["bias", "abs_bias", "rmse", "nrmse"]
ylabel_vec = ["Bias (W/m2)", "Abs Bias (W/m2)", "RMSE (W/m2)", "NRMSE (-)"]

resall = compute_error_all(pathres, variable)

for (metric, ylab) in zip(metric_vec, ylabel_vec)

    plot_error_scales(resall, metric, df_cfg)
    title(title_str)
    ylabel(ylab)

    savefig(joinpath(pathfig, "$(variable)_$(metric).png"))

    close()

end

=#