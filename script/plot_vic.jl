using JLD2
using DataFrames
using PyPlot
using IcanProj





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

        if i == 6
            legend()
        end

    end

    suptitle(plot_title)

    file_name = Pkg.dir("IcanProj", "plots", "monthly_$(file_name).png")

    rm(file_name, force=true)                       
    savefig(file_name, dpi = 300)

    close(fig)
    
end



"""
Compute yearly average evapotranspiration.
"""
function yearly_average_evapotranspiration(dict_monthly)

    df_evap = DataFrame()

    df_evap[:Resolution] = collect(keys(dict_monthly["224.1"]))

    for (key_wsh, dict_wsh) in dict_monthly

        evap_sum = []

        for (key_res, df_res) in dict_wsh
            
            push!(evap_sum, sum(df_res[:evap_sum_mean]))

        end

        df_evap[Symbol(wsh_name[key_wsh])] = evap_sum

    end

    return df_evap

end





# Load all necessary results

opt = get_options()

path = opt["eval_folder"]




dict_wsh = get_summary_tables(path, opt)

dict_monthly = monthly_summary(dict_wsh)

@load Pkg.dir("IcanProj", "data", "wsh_info.jld2") wsh_info

wsh_name = get_wsh_name(wsh_info)



# Plot monthly averaged states and fluxes

plot_monthly(dict_monthly, wsh_name, :swe_mean, "SWE (mm)", "Snow water equivalent", "swe")

plot_monthly(dict_monthly, wsh_name, :snow_depth_mean, "HS (cm)", "Snow depth", "hs")

plot_monthly(dict_monthly, wsh_name, :evap_sum_mean, "Evap (mm/month)", "Evapotranspiration", "evap")

plot_monthly(dict_monthly, wsh_name, :total_runoff_sum_mean, "Runoff (mm/month)", "Runoff", "runoff")




# Dataframe with yearly mean evapotranspiration

df_evap = yearly_average_evapotranspiration(dict_monthly)







# Plot time series

function plot_time_series(dict_wsh, wsh_key, var_name, ylabel_name)

    dict_res = dict_wsh[wsh_key]

    for (key_res, df_res) in dict_res
        
        #plot(df_res[:time], df_res[:runoff]+df_res[:baseflow], label = key_res)
        plot(df_res[:time], df_res[var_name], label = key_res)

    end

    legend()
    title(wsh_name[wsh_key])
    ylabel(ylabel_name)

end

wsh_key = "22.4"
var_name = :evap
ylabel_name = "Evapotranspiration (mm/3h)"
plot_time_series(dict_wsh, wsh_key, var_name, ylabel_name)
