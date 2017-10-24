

using IcanProj
using JLD2

###################################################################################

# Settings

opt = Dict()

opt["base_folder"] = "/data02/Ican/vic_sim/past_1km"
opt["target_folder"] = "/data02/Ican/vic_sim/jan_past_new"

opt["startyear"] = 1982
opt["endyear"] = 2012
opt["timestep"] = 3
opt["output_force"] = "FALSE"
opt["full_energy"] = "TRUE"
opt["output_binary"] = "TRUE"


###################################################################################

# Load metadata about watersheds

@load Pkg.dir("IcanProj", "data", "wsh_info.jld2") wsh_info

# Read soil parameter file

soil_param = read_soil_params(opt["base_folder"])

# Read vegetation parameter file

veg_param = read_veg_param(opt["base_folder"])


###################################################################################

# Clear target folder

rm(opt["target_folder"], force = true, recursive = true)


###################################################################################

# Loop over selected watersheds

for wsh_single in wsh_info

    # Loop over grid resolutions

    for res in [:ind_1km, :ind_5km, :ind_10km, :ind_25km, :ind_50km]

        try

            info("Processing $(wsh_single.name) for resolution $(string(res)[5:end])")

            # Folder names

            path_sim = joinpath(opt["target_folder"], string(wsh_single.regine_main), string(res)[5:end])

            path_params = joinpath(path_sim, "params")

            path_results = joinpath(path_sim, "results")

            path_forcings = joinpath(path_sim, "forcing")

            # Create folders

            mkpath(path_params)

            mkpath(path_results)

            mkpath(path_forcings)

            # Write global parameter file

            if res == :ind_1km

                write_global_param(path_sim,
                                   opt["base_folder"],
                                   opt["startyear"],
                                   opt["endyear"],
                                   opt["timestep"],
                                   opt["output_force"],
                                   opt["full_energy"],
                                   opt["output_binary"])

            else

                write_global_param(path_sim,
                                   path_sim,
                                   opt["startyear"],
                                   opt["endyear"],
                                   opt["timestep"],
                                   opt["output_force"],
                                   opt["full_energy"],
                                   opt["output_binary"])

            end

            # Write vegetation library file

            file_veg_src = joinpath(opt["base_folder"], "params", "veglib_param")
            file_veg_dst = joinpath(path_params, "veglib_param")

            cp(file_veg_src, file_veg_dst, remove_destination=true)

            # Aggregate and write soil parameter file

            soil_param_ave = average_soilparams(soil_param, wsh_single, res)

            write_soil_params(path_sim, soil_param_ave)

            # Write vegetation parameter file

            veg_param_ave = average_vegparams(veg_param, wsh_single, res)

            write_veg_params(path_sim, veg_param_ave)

            # Write model forcing data

            if res != :ind_1km

                average_forcings(opt["base_folder"], path_sim, soil_param, wsh_single, res)

            end

        catch

            info("Failed processing $(wsh_single.name) for resolution $(string(res)[5:end])")

        end

    end

end
