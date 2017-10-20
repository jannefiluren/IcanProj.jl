
using JLD2
using DataFrames
using IcanProj


# Set paths

path_sim = "/data02/Ican/vic_sim/jan_past/"

path_eval = "/data02/Ican/vic_sim/jan_eval/"


# Loop through directories

watersheds = readdir(path_sim)

for watershed in watersheds

    resolutions = readdir(joinpath(path_sim, watershed))

    for resolution in resolutions

        
        @show resolution


        # Read results in simulation directory

        path = joinpath(path_sim, watershed, resolution, "results")

        df_snow = read_all_snow(path)

        df_fluxes = read_all_fluxes(path)

        # Save results to evaluation directory

        path = joinpath(path_eval, watershed)

        mkpath(path)

        writetable(joinpath(path, "snow_$(resolution).csv"), df_snow)

        writetable(joinpath(path, "fluxes_$(resolution).csv"), df_fluxes)

        @save joinpath(path, "snow_$(resolution).jld2") df_snow watershed resolution

        @save joinpath(path, "fluxes_$(resolution).jld2") df_fluxes watershed resolution

    end

end
