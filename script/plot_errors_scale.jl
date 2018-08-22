

using DataFrames
using JFSM2
using PyPlot

function load_results()

    res_all = Dict()

    for spaceres in ["5km", "10km", "25km", "50km"]

        filename = joinpath(dirname(pathof(IcanProj)), "..", "data", "table_errors_$(spaceres).txt")

        res_all[spaceres] = CSV.read(filename, delim = ",")

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


function plot_error_scales(data, df_cfg, plottitle, ylimits)

    data = data'

    exchng_off = convert(Array{Bool}, df_cfg[:exchng] .== 0)
    exchng_on  = convert(Array{Bool}, df_cfg[:exchng] .== 1)

    figure(figsize = (5, 4))

    plot(collect(1:size(data,1)), data, color = "gray")

    fill_between(collect(1:size(data,1)),
                 maximum(data[:, exchng_off], 2)[:],
                 minimum(data[:, exchng_off], 2)[:],
                 facecolor = "red", edgecolor = "red", alpha = 0.5,
                 label = "Exchng = 0")

    fill_between(collect(1:size(data,1)),
                 maximum(data[:, exchng_on], 2)[:],
                 minimum(data[:, exchng_on], 2)[:],
                 facecolor = "blue", edgecolor = "blue", alpha = 0.5,
                 label = "Exchng = 1")

    xticks(collect(1:size(data,1)), ["5km", "10km", "25km", "50km"])

    title(plottitle)

    ylim(ylimits)

    ylabel("NSE (-)")
    
    legend()
    
end


# Plot results

res_all = load_results()

df_cfg = cfg_table()

figpath = joinpath(dirname(pathof(IcanProj)), "..", "plots", "error_scales")

tmp = [("swe", "SWE"),
       ("snowdepth", "Snowdepth"),
       ("rnet", "Net radiation")]

for (v, t) in tmp

    nseres, spaceres = error_matrix(res_all, v, "nse")

    plot_error_scales(nseres, df_cfg, t, (0.95, 1.0))

    savefig(joinpath(figpath, "$(v)_error.png"), dpi = 200)
    
end


tmp = [("hatmo", "Sensible heat flux"),
       ("latmo", "Latent heat flux"),
       ("melt", "Surface melt")]

for (v, t) in tmp

    nseres, spaceres = error_matrix(res_all, v, "nse")

    plot_error_scales(nseres, df_cfg, t, (0.3, 1.0))

    savefig(joinpath(figpath, "$(v)_error.png"), dpi = 200)
    
end
