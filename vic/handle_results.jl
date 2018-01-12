

"""
Load all summary tables containing average time series into a dictonary.
"""
function get_summary_tables(path, opt)

    resolutions = opt["resolutions"]

    watersheds = opt["stat_sel"]

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
Extract one variable from the processed vic results. 
"""
function get_variable(res_vic::VicRes, var_name; average = true)

    ivar = find(res_vic.var_names .== var_name)

    if average == true
        return res_vic.time[366:end], res_vic.data_mean[366:end,ivar[1]]
    else
        return res_vic.time[366:end], res_vic.data_all[366:end,ivar[1],:]
    end

end



