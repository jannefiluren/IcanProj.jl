

"""
Create netcdf file for one variable.
"""
function create_netcdf(filename, var, var_atts, dim_time, dim_space, time_str, lon, lat, id, id_desc)

    time = collect(1:dim_time)
    timeatts = Dict("units" => "none")
    
    space = collect(1:dim_space)
    spaceatts = Dict("units" => "none")

    nccreate(filename, var, "dim_time", time, timeatts, "dim_space", space, spaceatts, atts = var_atts)
    nccreate(filename, "time_str", "dim_time", time, t=String)
    nccreate(filename, "lon", "dim_space", space)
    nccreate(filename, "lat", "dim_space", space)
    nccreate(filename, id_desc, "dim_space", space)

    ncwrite(time_str, filename, "time_str")
    ncwrite(lon, filename, "lon")
    ncwrite(lat, filename, "lat")
    ncwrite(id, filename, id_desc)

    ncclose()

    return nothing

end


"""
Create netcdf file for one variable.
"""
function create_netcdf(filename, var, var_atts, dim_time, dim_space, time_str, id, id_desc)

    time = collect(1:dim_time)
    timeatts = Dict("units" => "none")
    
    space = collect(1:dim_space)
    spaceatts = Dict("units" => "none")

    nccreate(filename, var, "dim_time", time, timeatts, "dim_space", space, spaceatts, atts = var_atts)
    nccreate(filename, "time_str", "dim_time", time, t=String)
    nccreate(filename, id_desc, "dim_space", space)

    ncwrite(time_str, filename, "time_str")
    ncwrite(id, filename, id_desc)

    ncclose()

    return nothing

end
