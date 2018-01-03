

"""
Create netcdf file for one variable.
"""
function create_netcdf(filename, var, var_atts, dim_time, dim_space, time_str, lon, lat, senorge_ind)

    time = collect(1:dim_time)
    timeatts = Dict("units" => "none")
    
    space = collect(1:dim_space)
    spaceatts = Dict("units" => "none")

    nccreate(filename, var, "dim_time", time, timeatts, "dim_space", space, spaceatts, atts = var_atts)
    nccreate(filename, "time_str", "dim_time", time, t=String)
    nccreate(filename, "lon", "dim_space", space)
    nccreate(filename, "lat", "dim_space", space)
    nccreate(filename, "senorge_ind", "dim_space", space)

    ncwrite(time_str, filename, "time_str")
    ncwrite(space, filename, "lon")
    ncwrite(space, filename, "lat")
    ncwrite(space, filename, "senorge_ind")

    ncclose()

    return nothing

end
