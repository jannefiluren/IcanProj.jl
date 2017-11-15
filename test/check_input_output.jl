

using IcanProj
using JLD2


"""
Load input variables directly from the forcing files.
"""
function load_from_forcings(watershed, resolution, res_vic, opt)

    # Path to model forcings for the given resolution

    if resolution == "1km"
        path_forcing = joinpath(opt["base_folder"])
    else
        path_forcing = joinpath(opt["target_folder"], watershed, resolution)
    end

    # Read one forcing file to get the size

    lat = @sprintf("%0.5f", res_vic.lat[1])
    lon = @sprintf("%0.5f", res_vic.lon[1])

    file_src = joinpath(path_forcing, "forcing/data_$(lat)_$(lon)")

    prec, tmin, tmax, wind = read_vic_forcing(file_src)

    # Allocate arrays

    prec_array = zeros(Float64, length(prec), length(res_vic.lat))
    tmin_array = zeros(Float64, length(prec), length(res_vic.lat))
    tmax_array = zeros(Float64, length(prec), length(res_vic.lat))
    wind_array = zeros(Float64, length(prec), length(res_vic.lat))

    # Read rest of forcing files

    for i in 1:length(res_vic.lat)

        lat = @sprintf("%0.5f", res_vic.lat[i])
        lon = @sprintf("%0.5f", res_vic.lon[i])

        file_src = joinpath(path_forcing, "forcing/data_$(lat)_$(lon)")

        prec, tmin, tmax, wind = read_vic_forcing(file_src)

        prec_array[:, i] = prec
        tmin_array[:, i] = tmin
        tmax_array[:, i] = tmax
        wind_array[:, i] = wind
        
    end

    return prec_array, tmin_array, tmax_array, wind_array

end




# Get settings

opt = get_options()

resolutions = opt["resolutions"]

watersheds = opt["stat_sel"]


# Process all results

for watershed in watersheds

    for resolution in resolutions

        # Load simulation results

        file = joinpath(opt["eval_folder"], watershed, "res_$(resolution).jld2")

        @load file res_vic

        # Load forcing files

        prec_input, tmin_input, tmax_input, wind_input = load_from_forcings(watershed, resolution, res_vic, opt)
        info("$(watershed) $(resolution)")

        # Compare precipitation

        iprec = find(res_vic.var_names .== "prec")

        prec_output = res_vic.data_all[:, iprec[1], :]

        check = all(round.(prec_input,2) .== round.(prec_output,2))

        info("Precipitation $(check) $(mean(prec_output))")

        # Compare air temperature (not useful to check exact match due to interpolation within mtclim)

        iair = find(res_vic.var_names .== "air_temp")

        air_output = res_vic.data_all[:, iair[1], :]

        air_input = (tmin_input + tmax_input)/2

        info("Air temperature $(round(mean(abs.(air_output-air_input)),1))")

        # Compare wind speed

        iwind = find(res_vic.var_names .== "wind")

        wind_output = res_vic.data_all[:, iwind[1], :]

        check = all(round.(wind_input,2) .== round.(wind_output,2))

        info("Wind $(watershed) $(mean(wind_output))\n\n\n")

    end

end
