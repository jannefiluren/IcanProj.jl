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

data_rmse = zeros(5, 32)
data_bias = zeros(5, 32)

for i in 1:4, j in 1:32
    data_rmse[i+1, j] = resall[i][j]["rmse"]
    data_bias[i+1, j] = resall[i][j]["abs_bias"]
end

df_cfg = cfg_table()

exchng_0 = convert(Array{Bool}, df_cfg[:exchng] .== 0)
exchng_1 = convert(Array{Bool}, df_cfg[:exchng] .== 1)

resolutions = [1, 5, 10, 25, 50]

py"""
import matplotlib.pyplot as plt

fig, ax = plt.subplots(1, 2, figsize=(8, 3.5), tight_layout = True)

ax[0].plot($resolutions, $(data_rmse[:, exchng_0]), color = 'red', label = 'Option 0')
ax[0].plot($resolutions, $(data_rmse[:, exchng_1]), color = 'blue', label = 'Option 1', linestyle = '--')

ax[0].set_ylabel($ylabel_left)

ax[0].set_xticks($resolutions)
ax[0].set_xlabel("Resolution (km)")

ax[0].annotate("(A)", xy=[0.1, 0.8], xycoords='axes fraction', fontsize=12)

ax[1].plot($resolutions, $(data_bias[:, exchng_0]), color = 'red', label = 'Option 0')
ax[1].plot($resolutions, $(data_bias[:, exchng_1]), color = 'blue', label = 'Option 1', linestyle = '--')

ax[1].yaxis.tick_right()

ax[1].yaxis.set_label_position('right')

ax[1].set_ylabel($ylabel_right)

ax[1].set_xticks($resolutions)
ax[1].set_xlabel("Resolution (km)")

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

plot_error_scales(resall, variable, "RMSE (\$mm\$)", "MAB (\$mm\$)")


# Net radiation

variable = "rnet"

resall = compute_error_all(pathres, variable)

plot_error_scales(resall, variable, "RMSE (\$W/m^2\$)", "MAB (\$W/m^2\$)")


# Sensible heat fluxes

variable = "hatmo"

resall = compute_error_all(pathres, variable)

plot_error_scales(resall, variable, "RMSE (\$W/m^2\$)", "MAB (\$W/m^2\$)")


# Latent heat fluxes

variable = "latmo"

resall = compute_error_all(pathres, variable)

plot_error_scales(resall, variable, "RMSE (\$W/m^2\$)", "MAB (\$W/m^2\$)")


