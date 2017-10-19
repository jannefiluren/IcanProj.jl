
"""
Average forcing data.
"""
function average_forcings(base_folder, target_folder, soil_param, wsh_single, resolution)

    iboxes = getfield(wsh_single, resolution)
    ind_senorge = getfield(wsh_single, :ind_senorge)

    for ibox in unique(iboxes)

        isel = findin(soil_param[:gridcel], ind_senorge[iboxes .== ibox])

        ncells = length(isel)

        df_tmp = soil_param[isel, :]

        prec_final, tmin_final, tmax_final, wind_final = 0, 0, 0, 0

        for row in eachrow(df_tmp)

            lat = @sprintf("%0.5f", row[:lat][1])
            lon = @sprintf("%0.5f", row[:lon][1])

            file_src = joinpath(base_folder, "forcing/data_$(lat)_$(lon)")

            prec, tmin, tmax, wind = read_vic_forcing(file_src)

            prec_final += prec/ncells
            tmin_final += tmin/ncells
            tmax_final += tmax/ncells
            wind_final += wind/ncells

        end

        lat = @sprintf("%0.5f", mean(df_tmp[:lat]))
        lon = @sprintf("%0.5f", mean(df_tmp[:lon]))

        file_dst = joinpath(target_folder, "forcing/data_$(lat)_$(lon)")
        
        write_vic_forcing(file_dst, prec_final, tmin_final, tmax_final, wind_final)

    end

end



"""
Average soil parameters, stored in a dataframe, for a grid resolution
using metadata information stored in wsh_single.
"""
function average_soilparams(soil_param, wsh_single, resolution)

    param_all = convert(Array{Float64,2}, soil_param)

    iboxes = getfield(wsh_single, resolution)
    ind_senorge = getfield(wsh_single, :ind_senorge)

    param_tmp = zeros(length(unique(iboxes)), size(param_all, 2))
    
    for ibox in unique(iboxes)

        isel = findin(param_all[:, 2], ind_senorge[iboxes .== ibox])

        for icol in 1:size(param_all, 2)
            param_tmp[ibox, icol] = mean(param_all[isel, icol])
        end
        
    end

    param_tmp[:, 2] .= floor.(param_tmp[:, 2])
    
    df_final = DataFrame(param_tmp)
    names!(df_final, names(soil_param))

    sort!(df_final, cols = :gridcel)

    return df_final
    
end



"""
Average vegetation parameters, stored in a dataframe, for a grid resolution
using metadata information stored in wsh_single.
"""
function average_vegparams(veg_param, wsh_single, resolution)
    
    param_all = convert(Array{Float64, 2}, veg_param)

    iboxes = getfield(wsh_single, resolution)
    ind_senorge = getfield(wsh_single, :ind_senorge)

    param_tmp = []
    
    for ibox in unique(iboxes)

        isel = findin(param_all[:, 1], ind_senorge[iboxes .== ibox])

        param_mean = average_vegparams(param_all, isel)

        if isempty(param_tmp)
            param_tmp = param_mean
        else
            param_tmp = [param_tmp; param_mean]
        end
        
    end

    df_final = DataFrame(param_tmp)

    names!(df_final, names(veg_param))

    sort!(df_final, cols = :gridcel)

    return df_final
    
end



"""
Average vegetation parameters, stored in an array, for a set
of gridcells.
"""
function average_vegparams(param_all, isel)

    # Find parameters belonging to one grid box

    param_box = param_all[isel, :]

    gridcel_mean = floor(mean(param_box[:, 1]))

    # Find vegetation classes within the grid box

    veg_classes = unique(param_box[:, 3])

    Nveg = length(veg_classes)

    # Average parameters over vegetation classes within the box

    param_mean = zeros(Nveg, 20)

    irow = 1

    for veg_class in veg_classes

        # Get parameters for one vegetation class

        iveg = find(param_box[:, 3] .== veg_class)
        
        param_veg = param_box[iveg, :]

        # Compute an area  weighted average of the parameters

        weights = repmat(param_veg[:, 4], 1, 16)

        tmp_mean = sum(param_veg[:, 5:end] .* weights, 1) ./ sum(weights, 1)

        param_mean[irow, 1] = gridcel_mean
        param_mean[irow, 2] = Nveg
        param_mean[irow, 3] = veg_class
        param_mean[irow, 4] = sum(param_veg[:, 4])
        param_mean[irow, 5:end] = tmp_mean

        irow += 1

    end

    # Scale area fractions to one

    param_mean[:, 4] = param_mean[:, 4] / sum(param_mean[:, 4])

    return param_mean

end
