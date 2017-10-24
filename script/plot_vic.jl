using JLD2
using DataFrames
using PyPlot

# Set paths

path_eval = "/data02/Ican/vic_sim/jan_eval_new/"

# Dict to store all results

dict_res = Dict()

# Loop through directories

watersheds = readdir(path_eval)

watershed = watersheds[2]

resolutions = ["5km", "10km", "25km", "50km"]

for resolution in resolutions

    # Read results

    file = joinpath(path_eval, watershed, "res_$(resolution).csv")

    df_res = readtable(file)

    df_res[:time] = DateTime.(df_res[:time], DateFormat("yyyy-mm-ddTHH:MM:SS"))

    dict_res[resolution] = df_res

end


# Plot average snow water equivalent

for (resolution, df) in dict_res

    plot(df[:time], df[:runoff] + df[:baseflow])

end
