using IcanProj
using JLD2


function check_waterbalance(res_vic::VicRes)

    # Precipitation

    data_prec = get_variable(res_vic, "prec")

    # Evapotranspiration

    data_evap = get_variable(res_vic, "evap")

    # data_trans_veg = get_variable(res_vic, "transp_veg")

    # Sublimation snow

    data_sub_snow = get_variable(res_vic, "sub_snow")

    data_sub_canop = get_variable(res_vic, "sub_canop")

    # Runoff

    data_baseflow = get_variable(res_vic, "baseflow")

    data_runoff = get_variable(res_vic, "runoff")

    # Check waterbalance

    inputs = sum(data_prec)

    outputs = sum(data_evap) + sum(data_sub_snow) + sum(data_sub_canop) + sum(data_baseflow) + sum(data_runoff)

    # Print results

    println("Inputs: $(round(inputs)) mm")
    println("Outputs: $(round(outputs)) mm")
    println("Difference: $(round(inputs)-round(outputs)) mm")

end


# Loop over all simulations

opt = get_options()

watersheds = opt["stat_sel"]

resolutions = opt["resolutions"]

for watershed in watersheds

    for resolution in resolutions

        file = joinpath(opt["eval_folder"], watershed, "res_$(resolution).jld2")

        @load file res_vic


        println()

        println("Watershed: $(watershed)")

        check_waterbalance(res_vic)

        println()

    end

end
