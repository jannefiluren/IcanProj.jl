
using IcanProj
using NetCDF
using DataFrames
using ProgressMeter
using PyCall
using StatsBase
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

    #fig.figsize = (8, 12)

    ax.set_title($(title_label))

    img_plot = ax.imshow($(resmap), cmap = 'jet')

    cbar = fig.colorbar(img_plot)

    cbar.set_label($(cb_text))

    ax.grid(linestyle='dotted')

    plt.tick_params(axis='both', left='off', top='off', right='off', bottom='off',
                    labelleft='off', labeltop='off', labelright='off', labelbottom='off')

    fig.savefig($(file), dpi = 200, bbox_inches='tight')

    plt.close('all')

    """

end


function add_statistics(df, variables, spaceres, func, postfix)

    colnames = names(df)

    for v in variables, s in spaceres

        ikeep = occursin.(Ref(Regex("$(v)_cfg.*_$(s)_mean")), String.(colnames))

        tmp1 = convert(Array{Float64}, df[colnames[ikeep]])

        tmp2 = [func(tmp1[i,:]) for i in 1:size(tmp1,1)]

        df[Symbol(v * "_" * s * "_" * postfix)] = tmp2
        
    end

    return df
    
end


function add_turbulent_fluxes(df)

    for cfg in 1:32, spaceres in ["1km", "50km"]

        hatmo_name = Symbol("hatmo_cfg$(cfg)_$(spaceres)_mean")

        latmo_name = Symbol("latmo_cfg$(cfg)_$(spaceres)_mean")

        exchng_name = Symbol("exchng_cfg$(cfg)_$(spaceres)_mean")

        df[exchng_name] = df[hatmo_name] + df[latmo_name]
                
    end

    return df
    
end






# Load table with averaged model results

df_all = CSV.File(joinpath(dirname(pathof(IcanProj)), "..", "data", "table_results.txt"), delim = ",") |> DataFrame


# Add turbulent heat exchange components

df_all = add_turbulent_fluxes(df_all)


# Compute cov between configurations

variables = ["swe", "snowdepth", "rnet"]

spaceres = ["1km", "50km"]

func = variation

postfix = "cov"

df_all = add_statistics(df_all, variables, spaceres, func, postfix)


# Compute std between configurations

variables = ["hatmo", "latmo", "exchng"]

spaceres = ["1km", "50km"]

func = std

postfix = "std"

df_all = add_statistics(df_all, variables, spaceres, func, postfix)


# Compute average between configurations

variables = ["swe"]

spaceres = ["1km", "50km"]

func = mean

postfix = "mean"

df_all = add_statistics(df_all, variables, spaceres, func, postfix)


# Plot maps

figpath = joinpath(dirname(pathof(IcanProj)), "..", "plots", "variability_cfgs")

variables = [:swe_1km_cov,           
             :swe_50km_cov,          
             :snowdepth_1km_cov,     
             :snowdepth_50km_cov,    
             :rnet_1km_cov,          
             :rnet_50km_cov,         
             :hatmo_1km_std,         
             :hatmo_50km_std,        
             :latmo_1km_std,         
             :latmo_50km_std,        
             :exchng_1km_std,        
             :exchng_50km_std,
             :swe_1km_mean,
             :swe_50km_mean]       

cb_labels = ["Coefficient of variation",
             "Coefficient of variation",
             "Coefficient of variation",
             "Coefficient of variation",
             "Coefficient of variation",
             "Coefficient of variation",
             "Standard deviation",
             "Standard deviation",
             "Standard deviation",
             "Standard deviation",
             "Standard deviation",
             "Standard deviation",
             "Average",
             "Average"]

cb_units = ["(-)",
            "(-)",
            "(-)",
            "(-)",
            "(-)",
            "(-)",
            "(W/m2)",
            "(W/m2)",
            "(W/m2)",
            "(W/m2)",
            "(W/m2)",
            "(W/m2)",
            "(mm)",
            "(mm)"]

title_labels = ["SWE - 1km",
                "SWE - 50km",
                "Snowdepth - 1km",
                "Snowdepth - 50km",
                "Net radiation - 1km",
                "Net radiation - 50km",
                "Sensible heat fluxes - 1km",
                "Sensible heat fluxes - 50km",
                "Latent heat fluxes - 1km",
                "Latent heat fluxes - 50km",
                "Turbulent heat fluxes - 1km",
                "Turbulent heat fluxes - 50km",
                "SWE - 1km",
                "SWE - 50km"]
                
for (v, cl, cu, t) in zip(variables, cb_labels, cb_units, title_labels)
    
    plot_map(df_all, v, cl, cu, t, figpath)
    
end
