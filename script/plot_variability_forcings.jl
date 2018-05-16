
using IcanProj
using NetCDF
using DataFrames
using ProgressMeter
using PyCall



function project_results(df::DataFrame, on::Symbol)

    map_values = fill(NaN, 1550, 1195)

    map_values[df[:ind_julia]] = df[on]

    return map_values

end


function add_variability(df_all)

    variables = ["ilwr", "iswr", "pres", "rainf", "rhum", "snowf", "tair", "wind", "prec"]

    for variable in variables

        namemean = Symbol(variable * "_mean")

        namestd = Symbol(variable * "_std")

        df_tmp = by(df_all, :ind_50km, d -> DataFrame(data_std = std(d[namemean])))

        names!(df_tmp, [:ind_50km, namestd])

        df_all = join(df_all, df_tmp, on = :ind_50km)

    end

    return df_all
        
end


function plot_map(df, variable, cb_label, cb_unit, title_label, figpath)

    resmap = project_results(df, variable)

    file = joinpath(figpath, String(variable) * ".png")

    cb_text =  cb_label * " " * cb_unit
    
    py"""

    import matplotlib.pyplot as plt

    fig, ax = plt.subplots()

    #fig.figsize = (8, 12)

    ax.set_title($(title_label))

    img_plot = ax.imshow($(resmap), cmap = 'jet')

    cbar = fig.colorbar(img_plot)

    cbar.set_label($(cb_text))

    ax.grid(linestyle='dotted')

    plt.tick_params(axis='both', left='off', top='off', right='off', bottom='off',
                    labelleft='off', labeltop='off', labelright='off', labelbottom='off')

    fig.savefig($(file), dpi = 200)

    plt.close('all')

    """

end



df_all = readtable(Pkg.dir("IcanProj", "data", "forcings_summary.txt"))

df_all[:prec_mean] = min.(365*8(df_all[:rainf_mean] + df_all[:snowf_mean]), 4500)


df_all = add_variability(df_all)

figpath = Pkg.dir("IcanProj", "plots", "forcings")


variable = ["ilwr",
            "iswr",
            "pres",   
            "rainf",  
            "rhum",   
            "snowf",  
            "tair",   
            "wind",
            "prec"]   

cb_unit = ["(W/m2)",
           "(W/m2)",
           "(kPa)",
           "(mm/timestep)",
           "(%)",
           "(mm/timestep)",
           "(C)",
           "(m/s)",
           "(mm/year)"]

title_label = ["Incoming longwave radiation",
               "Incoming shortwave radiation",
               "Air pressure",
               "Rainfall",
               "Relative humidity",
               "Snowfall",
               "Air temperature",
               "Wind speed",
               "Precipitation"]

# Plot standard deviations

cb_label = "Standard deviation"

variable_std = convert.(Symbol, variable .* "_std")

for (v, cu, t) in zip(variable_std, cb_unit, title_label)
    
    plot_map(df_all, v, cb_label, cu, t, figpath)
    
end

# Plot averages

cb_label = "Average"

variable_mean = convert.(Symbol, variable .* "_mean")

for (v, cu, t) in zip(variable_mean, cb_unit, title_label)
    
    plot_map(df_all, v, cb_label, cu, t, figpath)
    
end
