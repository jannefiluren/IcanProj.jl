

using DataFrames
using NveData
using IcanProj
using VannModels
using StatsBase

import IcanProj.read_vic_forcing


struct SimRes

    swe_error
    swe_fine
    swe_coarse
    elev
    xcoord
    ycoord

end


function get_simulation_domain(res, opt)

    # Indices of coarse resolution grid boxes

    senorge_ind, xcoord, ycoord = senorge_info()

    nrow, ncol = size(senorge_ind)

    boxes_ind = resolution_ind(res, nrow, ncol)

    df_boxes = DataFrame(senorge_ind = senorge_ind[:],
                         boxes_ind = boxes_ind[:],
                         xcoord = xcoord[:],
                         ycoord = ycoord[:])

    # Information from soil parameter file

    soil_param = read_soil_params(opt["base_folder"])

    df_soil = DataFrame(senorge_ind = soil_param[:gridcel] + 1, 
                        lat = soil_param[:lat],
                        lon = soil_param[:lon],
                        elev = soil_param[:elev])

    # Keep cells for simulations 

    df = join(df_soil, df_boxes, on = :senorge_ind, kind = :left)
    
    iremove = find(df[:boxes_ind] .== -9999)

    nkeep = floor(0.8 * res^2)

    for ibox in 1:maximum(df[:boxes_ind])

        isel = find(df[:boxes_ind] .== ibox)
        
        if length(isel) <= nkeep
            append!(iremove, isel)
        elseif length(isel) > nkeep
            nremove = Int(length(isel) - nkeep)
            append!(iremove, sample(isel, nremove, replace=false))
        end

    end

    deleterows!(df, iremove)

    return df

end


function read_vic_forcing(path_forcing, lat, lon)

    lat = @sprintf("%0.5f", lat)

    lon = @sprintf("%0.5f", lon)

    file_src = joinpath(path_forcing, "forcing/data_$(lat)_$(lon)")

    prec, tmin, tmax, wind = read_vic_forcing(file_src)

    return prec, tmin, tmax, wind

end



function snow_sim!(swe, prec, tair)

    mdata = TinSnow(24.0, DateTime(2000,1,1), DataFrame(dummy=1))
    
    for i in 1:length(prec)
        
        mdata.p_in[1] = prec[i]
        mdata.tair[1] = tair[i]
        
        run_timestep(mdata)

        swe[i] += mdata.swe[1,1]

    end

    return nothing

end


function run_single_box(ibox, path_forcing, df)

    # Initilize output arrays

    prec, tmin, tmax, wind = read_vic_forcing(path_forcing, df[:lat][1], df[:lon][1])

    swe_fine = fill(0.0, size(prec))

    swe_coarse = fill(0.0, size(prec))

    tmean_coarse = fill(0.0, size(prec))

    pmean_coarse = fill(0.0, size(prec))

    # Loop over cells in one box

    for icell in ibox

        # Load forcings
        
        prec, tmin, tmax, wind = read_vic_forcing(path_forcing, df[:lat][icell], df[:lon][icell])

        tmean = (tmin + tmax)/2

        tmean_coarse += tmean
        pmean_coarse += prec

        # Snow simulation for fine resolution

        snow_sim!(swe_fine, prec, tmean)

    end

    # Average fine scale results

    swe_fine /= length(ibox)
    tmean_coarse /= length(ibox)
    pmean_coarse /= length(ibox)

    # Snow simulation for coarse resolution

    snow_sim!(swe_coarse, pmean_coarse, tmean_coarse)

    # Compute error between fine and coarse resolution

    swe_error = rmsd(swe_coarse, swe_fine) / mean(swe_fine)

    # Collect results

    elev = df[:elev][ibox]
    xcoord = mean(df[:xcoord][ibox])
    ycoord = mean(df[:ycoord][ibox])

    res = SimRes(swe_error,
                 swe_fine,
                 swe_coarse,
                 elev,
                 xcoord,
                 ycoord)

    return res

end



# Get information about simulation domain

res = 50

opt = get_options()

df = get_simulation_domain(res, opt)



# Snow simulations on different resolutions

path_forcing = joinpath(opt["base_folder"])

boxes_unique = unique(df[:boxes_ind])

res = SimRes[]

for i in boxes_unique

    @show i

    ibox = find(df[:boxes_ind] .== i)

    push!(res, run_single_box(ibox, path_forcing, df))

end


# Save results
