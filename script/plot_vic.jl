using JLD2
using DataFrames
using PyPlot
using IcanProj



"""
Load all results into a dictonary.
"""
function get_results(path)

    resolutions = ["5km", "10km", "25km", "50km"]

    watersheds = readdir(path)

    dict_wsh = Dict()

    for watershed in watersheds

        dict_res = Dict()

        for resolution in resolutions
            
            file = joinpath(path, watershed, "res_$(resolution).csv")

            df = readtable(file)

            df[:time] = DateTime.(df[:time], DateFormat("yyyy-mm-ddTHH:MM:SS"))

            dict_res[resolution] = df

        end

        dict_wsh[watershed] = dict_res

    end

    return dict_wsh

end


"""
Compute monthly summary statistics.
"""
function monthly_summary(dict_wsh)

    dict_monthly = Dict()

    for (key_wsh, value_wsh) in dict_wsh

        dict_res = Dict()

        for (key_res, value_res) in value_wsh

            # Crop first time step containing weired data

            df = value_res[2:end, :]

            df[:year] = Dates.year.(df[:time])

            df[:month] = Dates.month.(df[:time])

            delete!(df, :time)

            # Variables for summation

            df_tmp = df[[:prec, :evap, :runoff, :baseflow, :year, :month]]

            df_tmp[:total_runoff] = df_tmp[:runoff] + df_tmp[:baseflow] 

            df_tmp = df_tmp |> groupby([:year, :month]) |> sum

            delete!(df_tmp, :year)

            df_sum = df_tmp |> groupby(:month) |> mean

            # Variables for averaging

            df_tmp = df[[:swe, :snow_depth, :month]]

            df_mean = df_tmp |> groupby(:month) |> mean

            # Add to dictionary

            df_all = [df_mean df_sum]

            delete!(df_all, :month_1)
            
            dict_res[key_res] = [df_mean df_sum]

        end

        dict_monthly[key_wsh] = dict_res

    end

    return dict_monthly

end


"""
Link drainage basin key to watershed name.
"""
function get_wsh_name(wsh_info)

    wsh_name = Dict()

    for wsh_one in wsh_info

        name = wsh_one.name
        regine_main = wsh_one.regine_main

        wsh_name[regine_main] = name

    end

    return wsh_name

end


"""
Plot monthly variabels.
"""
function plot_monthly(dict_monthly, wsh_name, var_name, ylabel_name, plot_title, file_name)

    fig = figure(figsize=(15, 10))

    subplots_adjust(hspace = 0.0)

    i = 1

    for (key_wsh, value_wsh) in dict_monthly

        for (key_res, df) in value_wsh

            ax = fig[:add_subplot]("42$(i)")

            ax[:text](0.05, 0.8, "$(wsh_name[key_wsh])", verticalalignment = "bottom", horizontalalignment = "left", transform=ax[:transAxes])
            
            plot(df[:month], df[var_name], label = key_res)

            xlabel("Month")

            ylabel(ylabel_name)

        end

        i += 1

        if i == 8
            legend()
        end

    end

    suptitle(plot_title)

    file_name = Pkg.dir("IcanProj", "plots", "monthly_$(file_name).png")

    rm(file_name, force=true)                       
    savefig(file_name, dpi = 300)

    close(fig)
    
end




# Set paths

path = "/data02/Ican/vic_sim/jan_eval_new/"

# Load all necessary results

dict_wsh = get_results(path)

dict_monthly = monthly_summary(dict_wsh)

@load Pkg.dir("IcanProj", "data", "wsh_info.jld2") wsh_info

wsh_name = get_wsh_name(wsh_info)

# Plot monthly averaged states and fluxes

plot_monthly(dict_monthly, wsh_name, :swe_mean, "SWE (mm)", "Snow water equivalent", "swe")

plot_monthly(dict_monthly, wsh_name, :snow_depth_mean, "HS (cm)", "Snow depth", "hs")

plot_monthly(dict_monthly, wsh_name, :evap_sum_mean, "Evap (mm/month)", "Evapotranspiration", "evap")

plot_monthly(dict_monthly, wsh_name, :total_runoff_sum_mean, "Runoff (mm/month)", "Runoff", "runoff")
