

using IcanProj
using PyPlot
using DataFrames
using PyCall
using JFSM2
using CSV
using Statistics

import IcanProj.project_results


function project_results(df::DataFrame, on::Symbol)

    map_values = fill(NaN, 1550, 1195)

    map_values[df[:ind_julia]] = df[on]

    return map_values

end


function plot_map(df, variable, cb_label, cb_unit, title_label, figpath)

    resmap = project_results(df, variable)

    file = joinpath(figpath, String(variable) * ".png")

    cb_text =  cb_label * " " * cb_unit
    
    py"""

    import matplotlib.pyplot as plt

    fig, ax = plt.subplots()

    #fig.figsize = (6, 12)

    ax.set_title($(title_label))

    img_plot = ax.imshow($(resmap), cmap = 'jet', vmin = -0.1, vmax = 1.1)

    cbar = fig.colorbar(img_plot)

    cbar.set_label($(cb_text))

    #cbar.set_clim(0, 1)

    ax.grid(linestyle='dotted')

    plt.tick_params(axis='both', left='off', top='off', right='off', bottom='off',
                    labelleft='off', labeltop='off', labelright='off', labelbottom='off')

    plt.tight_layout()

    fig.savefig($(file), dpi = 200, bbox_inches='tight')

    plt.close('all')

    """

    @info "finished plotting"

end


# Load results

path = dirname(pathof(IcanProj))

df_res = CSV.read(joinpath(path, "..", "data", "table_errors_50km.txt"))

df_links = CSV.read(joinpath(path, "..", "data", "df_links.csv"))

df_all = join(df_links, df_res, on = :ind_50km)

cfgs = cfg_table()


# Plot average error for all cfgs with exchng = 0

for variable in ["swe", "latmo", "hatmo", "melt"]

    cfg_subset = cfgs[convert(Array{Bool}, cfgs[:exchng] .== 0), :]

    colnames = Symbol.("nse_$(variable)_cfg" .* string.(cfg_subset[:cfg]))

    df_all[Symbol("nse_$(variable)_exchng0")] =  mean(convert(Array, df_all[colnames]), dims = 2)[:]

end


# Plot average error for all cfgs with exchng = 1

for variable in ["swe", "latmo", "hatmo", "melt"]

    cfg_subset = cfgs[convert(Array{Bool}, cfgs[:exchng] .== 1), :]

    colnames = Symbol.("nse_$(variable)_cfg" .* string.(cfg_subset[:cfg]))

    df_all[Symbol("nse_$(variable)_exchng1")] =  mean(convert(Array, df_all[colnames]), dims = 2)[:]

end


# Plot averaged results

info = [(:nse_swe_exchng0,   "NSE", "(-)", "SWE exchnge = 0"),
        (:nse_latmo_exchng0, "NSE", "(-)", "Latmo exchnge = 0"),
        (:nse_hatmo_exchng0, "NSE", "(-)", "Hatmo exchnge = 0"),
        (:nse_melt_exchng0,  "NSE", "(-)", "Melt exchnge = 0"),
        (:nse_swe_exchng1,   "NSE", "(-)", "SWE exchnge = 1"),
        (:nse_latmo_exchng1, "NSE", "(-)", "Latmo exchnge = 1"),
        (:nse_hatmo_exchng1, "NSE", "(-)", "Hatmo exchnge = 1"),
        (:nse_melt_exchng1,  "NSE", "(-)", "Melt exchnge = 1")]

figpath = joinpath(path, "..", "plots", "error_maps")

for (v, cl, cu, t) in info

    plot_map(df_all, v, cl, cu, t, figpath)

end




#variable = :nse_rnet_cfg1

#cb_label = "Correlation coeffcient"

#cb_unit = "(-)"

#title_label = "SWE"

#figpath = "dummy"

#plot_map(df_all, variable, cb_label, cb_unit, title_label, figpath)

#mapres = project_results(df, :r_swe_cfg1)

#figure()
#imshow(mapres)



