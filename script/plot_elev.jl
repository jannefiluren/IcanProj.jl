
using IcanProj
using DataFrames
using PyCall
using CSV
using Statistics

import IcanProj.project_results

function mean_elevation(df)

    for spaceres in ["5km", "10km", "25km", "50km"]

        indname = Symbol("ind_$(spaceres)")

        meanname = Symbol("mean_$(spaceres)")

        df_tmp = df[[:elev, indname]]

        df_tmp = aggregate(df_tmp, indname, mean)

        rename!(df_tmp, Symbol("elev_Statistics.mean") => meanname)

        df = join(df, df_tmp, on = indname)
        
    end

    return df

end


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

    img_plot = ax.imshow($(resmap), cmap = 'jet', vmin = -0.1, vmax = 2301)

    cbar = fig.colorbar(img_plot)

    cbar.set_label($(cb_text))

    #cbar.set_clim(0, 1)

    ax.grid(linestyle='dotted')

    plt.tick_params(axis='both', left=False, top=False, right=False, bottom=False,
                    labelleft=False, labeltop=False, labelright=False, labelbottom=False)

    plt.tight_layout()

    fig.savefig($(file), dpi = 200, bbox_inches='tight')

    plt.close('all')

    """

end


df_links = CSV.File(joinpath(dirname(pathof(IcanProj)), "..", "data", "df_links.csv")) |> DataFrame

df_links = mean_elevation(df_links)

figpath = joinpath(dirname(pathof(IcanProj)), "..", "plots", "altitudes")

# df = df_links
# variable = :elev
# cb_label = "Altitude"
# title_label = "Resolution 1km"


plot_map(df_links, :elev, "Altitude", "(m)", "Resolution 1km", figpath)

plot_map(df_links, :mean_5km, "Altitude", "(m)", "Resolution 5km", figpath)

plot_map(df_links, :mean_10km, "Altitude", "(m)", "Resolution 10km", figpath)

plot_map(df_links, :mean_25km, "Altitude", "(m)", "Resolution 25km", figpath)

plot_map(df_links, :mean_50km, "Altitude", "(m)", "Resolution 50km", figpath)
