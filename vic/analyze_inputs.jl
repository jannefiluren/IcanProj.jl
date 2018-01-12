

using IcanProj
using DataFrames
using PyPlot



"""
Load input variables directly from the forcing files.
"""
function load_from_forcings(watersheds, resolutions, opt)

    meteo_wsh = Dict()

    for watershed in watersheds

        meteo_res = Dict()

        for resolution in resolutions

            # Read soil parameter file with data about latitude and longitude

            path_param = joinpath(opt["target_folder"], watershed, resolution)

            soil_param = read_soil_params(path_param)

            # Path to model forcings for the given resolution

            if resolution == "1km"
                path_forcing = joinpath(opt["base_folder"])
            else
                path_forcing = joinpath(opt["target_folder"], watershed, resolution)
            end

            # Read one forcing file to get the size

            row = soil_param[1, :]

            lat = @sprintf("%0.5f", row[:lat][1])
            lon = @sprintf("%0.5f", row[:lon][1])

            file_src = joinpath(path_forcing, "forcing/data_$(lat)_$(lon)")

            prec, tmin, tmax, wind = read_vic_forcing(file_src)

            # Allocate arrays

            prec_array = zeros(Float64, length(prec), size(soil_param,1))
            tmin_array = zeros(Float64, length(prec), size(soil_param,1))
            tmax_array = zeros(Float64, length(prec), size(soil_param,1))
            wind_array = zeros(Float64, length(prec), size(soil_param,1))

            for i in 1:size(soil_param,1)
                
                row = soil_param[i, :]

                lat = @sprintf("%0.5f", row[:lat][1])
                lon = @sprintf("%0.5f", row[:lon][1])

                file_src = joinpath(path_forcing, "forcing/data_$(lat)_$(lon)")

                prec, tmin, tmax, wind = read_vic_forcing(file_src)

                prec_array[:, i] = prec
                tmin_array[:, i] = tmin
                tmax_array[:, i] = tmax
                wind_array[:, i] = wind
                
            end

            # Compute summary statistics

            meteo = DataFrame()

            meteo[:prec_mean] = mean(prec_array, 2)[:,1]
            meteo[:tmin_mean] = mean(tmin_array, 2)[:,1]
            meteo[:tmax_mean] = mean(tmax_array, 2)[:,1]
            meteo[:wind_mean] = mean(wind_array, 2)[:,1]

            meteo[:prec_std] = std(prec_array, 2)[:,1]
            meteo[:tmin_std] = std(tmin_array, 2)[:,1]
            meteo[:tmax_std] = std(tmax_array, 2)[:,1]
            meteo[:wind_std] = std(wind_array, 2)[:,1]

            meteo[:prec_range] = maximum(prec_array, 2)[:,1] - minimum(prec_array, 2)[:,1]
            meteo[:tmin_range] = maximum(tmin_array, 2)[:,1] - minimum(tmin_array, 2)[:,1]
            meteo[:tmax_range] = maximum(tmax_array, 2)[:,1] - minimum(tmax_array, 2)[:,1]
            meteo[:wind_range] = maximum(wind_array, 2)[:,1] - minimum(wind_array, 2)[:,1]

            meteo_res[resolution] = meteo

        end

        meteo_wsh[watershed] = meteo_res

    end

    return meteo_wsh
    
end


    
"""
Plot input data characteristics against different resolutions.
"""
function plot_elevation_meteo(meteo_wsh, watersheds, resolutions, var_name, ylabel_name, file_name)

    ioff()

    fig = plt[:figure](figsize = (8, 6))

    for watershed in watersheds

        var = Float64[]

        for resolution in resolutions

            push!(var, mean(meteo_wsh[watershed][resolution][var_name]))

        end

        var[isnan.(var)] = 0

        plot(var, label = wsh_name[watershed])

    end

    legend()

    plt[:xticks](collect(0:length(resolutions)-1), resolutions)
    plt[:xlabel]("Spatial resolution")
    plt[:ylabel](ylabel_name)

    file_name = joinpath(Pkg.dir("IcanProj", "plots", "$(file_name).png"))

    rm(file_name, force=true)                       
    savefig(file_name, dpi = 300)

    close(fig)
    
end




# Get settings

opt = get_options()

wsh_info = get_wsh_info()

wsh_name = get_wsh_name(wsh_info)

resolutions = opt["resolutions"]

watersheds = opt["stat_sel"]


# Load inputs from forcing files

meteo_wsh = load_from_forcings(watersheds, resolutions, opt)




# Plot the different variables

colnames = names(meteo_wsh[watershed][resolution])

for name in colnames
    
    var_name = name
    ylabel_name = String(name)
    file_name = String(name)

    plot_elevation_meteo(meteo_wsh, watersheds, resolutions, var_name, ylabel_name, file_name)

end



