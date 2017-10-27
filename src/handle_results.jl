

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
