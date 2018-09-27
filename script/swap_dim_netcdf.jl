

# Swap time and space dimensions in netcdfs with forcing data

path_ts = "/data04/jmg/fsm_simulations/netcdf/forcings_ts"

path_st = "/data04/jmg/fsm_simulations/netcdf/forcings_st"

files = readdir(path_ts)

for file in files

    println("Running $(file)")

    file_ts = joinpath(path_ts, file)

    file_st = joinpath(path_st, file)

    run(`ncpdq -a dim_time,dim_space $(file_ts) $(file_st)`)

end
