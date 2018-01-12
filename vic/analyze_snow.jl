
using VannModels
using IcanProj
using JLD2
using PyPlot
using DataFrames


function snow_sim(time, prec, tair)

    ntimes = size(prec, 1)
    nregion = size(prec, 2)

    frac_lus = DataFrame(dummy = fill(1/nregion, nregion))

    mdata = TinSnow(24.0, time[1], frac_lus)

    swe = fill(0.0, size(prec))

    for i in 1:ntimes
        
        mdata.p_in .= prec[i,:]
        mdata.tair .= tair[i,:]
        
        run_timestep(mdata)

        swe[i,:] .= mdata.swe[1,:]

    end

    return swe

end




opt = get_options()
 
watershed = opt["stat_sel"][3]



# Load results

file = joinpath(opt["eval_folder"], watershed, "res_1km.jld2")

@load file res_vic

# Get forcing variables

time, prec = get_variable(res_vic, "prec", average = false)

time, tair = get_variable(res_vic, "air_temp", average = false)

# Run snow model

swe = snow_sim(time, prec, tair)

































