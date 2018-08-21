
"""
Create netcdf file for one variable.
"""
function create_netcdf(filename, var, var_atts, dim_time, dim_space, time_str, id, id_desc)

    time = collect(1:dim_time)
    space = collect(1:dim_space)

    timeatts = Dict("format" => "yyyy-mm-dd HH:MM:SS")
    spaceatts = Dict("id" => id_desc)
    
    nccreate(filename, var, "dim_time", time, timeatts, "dim_space", space, spaceatts, atts = var_atts)
    nccreate(filename, "time_str", "dim_time", time, t=String)
    nccreate(filename, "id", "dim_space", space)

    ncwrite(time_str, filename, "time_str")
    ncwrite(id, filename, "id")

    ncclose()

    return nothing

end


"""
Get filename to one netcdf with results.
"""
function get_filename(path, variable, spatial_res, iexp)

    file = joinpath(path, "results_$(iexp)", "$(variable)_$(spatial_res).nc")
    
    return file
    
end


"""
Load results from one netcdf.
"""
function load_result(path, variable, spatial_res, iexp)
    
    file = get_filename(path, variable, spatial_res, iexp)

    res = ncread(file, variable)

    return res

end


"""
Load time from one netcdf.
"""
function load_time(path, variable, spatial_res)

    file = get_filename(path, variable, spatial_res, 1)

    time = ncread(file, "time_array")

    time = [DateTime(time[1,i],time[2,i],time[3,i],time[4,i]) for i in 1:size(time,2)]

    return time

end


"""
Load a time slice from a results netcdf.
"""
function load_time_slice(path, variable, spatial_res, iexp, itime = [])

    tmp = load_result(path, variable, spatial_res, 1)

    data = fill(0.0, size(tmp,1), length(iexp))

    for i in iexp

        @show i

        tmp = load_result(path, variable, spatial_res, i)

        if isempty(itime)
            data[:, i] = mean(tmp, dims=2)
        else
            data[:, i] = tmp[:, itime]
        end
        
    end

    return data

end


"""
Load a space slice from a results netcdf.
"""
function load_space_slice(path, variable, spatial_res, iexp, ispace = [])

    tmp = load_result(path, variable, spatial_res, 1)

    data = fill(0.0, length(iexp), size(tmp, 2))

    for i in iexp

        @show i

        tmp = load_result(path, variable, spatial_res, i)

        if isempty(ispace)
            data[i, :] = mean(tmp, 1)
        else
            data[i, :] = tmp[ispace, :]
        end
        
    end

    return data

end
