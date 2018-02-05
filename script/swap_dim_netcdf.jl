

# Swap time and space dimensions in netcdfs with forcing data

path_ts = "/data02/Ican/vic_sim/fsm_past_1km/netcdf/forcings_ts"

path_st = "/data02/Ican/vic_sim/fsm_past_1km/netcdf/forcings_st"

files = readdir(path_ts)

for file in files

    file_ts = joinpath(path_ts, file)

    file_st = joinpath(path_st, file)

    run(`ncpdq -a dim_time,dim_space $(file_ts) $(file_st)`)

end
