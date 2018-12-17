
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

        rename!(df_tmp, Symbol("elev_mean") => meanname)

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


plot_map(df_links, :elev, "Altitude", "(m)", "Resolution 1km", figpath)

plot_map(df_links, :mean_5km, "Altitude", "(m)", "Resolution 5km", figpath)

plot_map(df_links, :mean_10km, "Altitude", "(m)", "Resolution 10km", figpath)

plot_map(df_links, :mean_25km, "Altitude", "(m)", "Resolution 25km", figpath)

plot_map(df_links, :mean_50km, "Altitude", "(m)", "Resolution 50km", figpath)



map_1km = project_results(df_links, :elev)

map_10km = project_results(df_links, :mean_10km)

map_50km = project_results(df_links, :mean_50km)


file = joinpath(figpath, "elevations.png")


py"""

import matplotlib.pyplot as plt
from mpl_toolkits.axes_grid1 import make_axes_locatable

fig, ax = plt.subplots(1, 3)

fig.set_size_inches(12, 8)

im = ax[0].imshow($(map_1km), cmap = 'jet', vmin = -0.1, vmax = 2301)
ax[0].grid(linestyle='dotted')
ax[0].annotate('(a) 1 km', xy = (0.1, 0.9), xycoords = 'axes fraction')
ax[0].tick_params(axis='both', left=False, top=False, right=False, bottom=False, labelleft=False, labeltop=False, labelright=False, labelbottom=False)

divider = make_axes_locatable(ax[0])
cax = divider.append_axes("right", size="5%", pad=0.05)
cb = plt.colorbar(im, cax=cax)

cb.remove()

im = ax[1].imshow($(map_10km), cmap = 'jet', vmin = -0.1, vmax = 2301)
ax[1].grid(linestyle='dotted')
ax[1].annotate('(b) 10 km', xy = (0.1, 0.9), xycoords = 'axes fraction')
ax[1].tick_params(axis='both', left=False, top=False, right=False, bottom=False, labelleft=False, labeltop=False, labelright=False, labelbottom=False)

divider = make_axes_locatable(ax[1])
cax = divider.append_axes("right", size="5%", pad=0.05)
cb = plt.colorbar(im, cax=cax)

cb.remove()

im = ax[2].imshow($(map_50km), cmap = 'jet', vmin = -0.1, vmax = 2301)
ax[2].grid(linestyle='dotted')
ax[2].annotate('(c) 50 km', xy = (0.1, 0.9), xycoords = 'axes fraction')
ax[2].tick_params(axis='both', left=False, top=False, right=False, bottom=False, labelleft=False, labeltop=False, labelright=False, labelbottom=False)

divider = make_axes_locatable(ax[2])
cax = divider.append_axes("right", size="5%", pad=0.05)
cb = plt.colorbar(im, cax=cax)
cb.set_label("Altitude (m.a.s.l)")

fig.savefig($(file), dpi = 600, bbox_inches='tight')

plt.close('all')

"""


