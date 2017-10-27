

"""
Get global settings.
"""
function get_options()
    
    opt = Dict()

    opt["base_folder"] = "/data02/Ican/vic_sim/past_1km"
    opt["target_folder"] = "/data02/Ican/vic_sim/jan_past_newest"
    opt["eval_foler"] = "/data02/Ican/vic_sim/jan_eval_new"

    # opt["stat_sel"] = ["191.2", "122.11", "2.32", "2.279", "224.1", "12.70", "22.4"]

    opt["stat_sel"] = ["191.2", "122.11", "2.32", "2.279", "224.1", "12.70", "62.5", "22.4"]


    opt["resolutions"] = ["1km", "5km", "10km", "25km", "50km"]
    
    opt["startyear"] = 1982
    opt["endyear"] = 2012
    opt["timestep"] = 3
    opt["output_force"] = "FALSE"
    opt["full_energy"] = "TRUE"
    opt["output_binary"] = "TRUE"

    return opt

end


"""
Get wsh_info file.
"""
function get_wsh_info()

    @load Pkg.dir("IcanProj", "data", "wsh_info.jld2") wsh_info

    return wsh_info

end
