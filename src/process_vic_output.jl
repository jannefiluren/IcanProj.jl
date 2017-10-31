
using JLD2
using DataFrames
using IcanProj


"""
Summaries results from vic into single tables.
"""
function summaries_results(path_sim, path_eval, watersheds, resolutions)

    # Load watershed names

    @load Pkg.dir("IcanProj", "data", "wsh_info.jld2") wsh_info

    wsh_name = get_wsh_name(wsh_info)
    
    for watershed in watersheds

        for resolution in resolutions

            @show resolution

            # Read results in simulation directory

            df_vic, res_vic = read_all_results(path_sim, watershed, resolution, wsh_name)

            # Save results to evaluation directory

            path = joinpath(path_eval, watershed)

            mkpath(path)

            writetable(joinpath(path, "res_$(resolution).csv"), df_vic)

            @save joinpath(path, "res_$(resolution).jld2") res_vic

        end

    end

end


# Process data

opt = get_options()

path_sim = opt["target_folder"]

path_eval = opt["eval_folder"]

watersheds = opt["stat_sel"]

resolutions = opt["resolutions"]

summaries_results(path_sim, path_eval, watersheds, resolutions)
