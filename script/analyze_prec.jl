
using IcanProj
using JLD2
using PyPlot






opt = get_options()
 
watershed = opt["stat_sel"][3]


# Load results

file = joinpath(opt["eval_folder"], watershed, "res_1km.jld2")

@load file res_vic

ivar = find(res_vic.var_names .== "swe")

data_swe = res_vic.data_all[:,ivar[1],:]

mean_swe = mean(data_swe,2)

plot(res_vic.time, mean_swe, label = "1km")





file = joinpath(opt["eval_folder"], watershed, "res_50km.jld2")

@load file res_vic

ivar = find(res_vic.var_names .== "swe")

data_swe = res_vic.data_all[:,ivar[1],:]

mean_swe = mean(data_swe,2)

plot(res_vic.time, mean_swe, label = "50km")

ylabel("SWE (mm)")

legend()
