
using NetCDF


# Add array with time in netcdfs with forcing data

path_st = "/data04/jmg/fsm_simulations/netcdf/forcings_st"

files = readdir(path_st)

for file in files

    file = joinpath(path_st, file)

    dim_time = ncread(file, "dim_time")

    time_str = ncread(file, "time_str")

    time = DateTime.(time_str, "yyyy-mm-dd HH:MM:SS")

    time_array = [Dates.year.(time) Dates.month.(time) Dates.day.(time) Dates.hour.(time)]

    nccreate(file, "time_array", "ymdh", 4, Dict("ymdh" => "header"), "dim_time")

    ncclose()

    ncwrite(time_array', file, "time_array")

    ncclose()

    @show file

end
