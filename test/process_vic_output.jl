
using JLD2
using DataFrames
using IcanProj


"""
Summaries results from vic into single tables.
"""
function summaries_results(watersheds, resolutions)

    for watershed in watersheds

        for resolution in resolutions

            @show resolution

            # Read results in simulation directory

            path = joinpath(path_sim, watershed, resolution, "results")
            
            df_res = read_all_results(path)

            # Save results to evaluation directory

            path = joinpath(path_eval, watershed)

            mkpath(path)

            writetable(joinpath(path, "res_$(resolution).csv"), df_res)

            @save joinpath(path, "res_$(resolution).jld2") df_res watershed resolution

        end

    end

end


# Process data

path_sim = "/data02/Ican/vic_sim/jan_past_new/"

path_eval = "/data02/Ican/vic_sim/jan_eval_new/"

watersheds = readdir(path_sim)

resolutions = ["5km", "10km", "25km", "50km"]  #readdir(joinpath(path_sim, watershed))

summaries_results(watersheds, resolutions)
