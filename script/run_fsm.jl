
using JFSM
using NetCDF
using TimeSeries
using IcanProj
using ProgressMeter


"""
Run fsm and save results to netcdf.
"""
function run_test(path, tstart, tstop, am, cm, dm, em, hm, dt, res)

    # Read metadata

    id = ncread(joinpath(path, "rainf_$(res).nc"), "id")
    
    id_desc = ncgetatt(joinpath(path, "rainf_$(res).nc"), "dim_space", "id")
    
    # Space dimension

    dim_s_in = length(id)
    
    # Read time for forcings

    time_str_in = ncread(joinpath(path, "tair_$(res).nc"), "time_str")

    time_in = DateTime.(time_str_in, "yyyy-mm-dd HH:MM:SS")

    # Starting position of forcings and time dimension

    istart = find(time_in .== tstart)[1]

    dim_t_in = sum(tstart .<= time_in .<= tstop)

    # Crop forcing time

    time_in = time_in[istart:(istart+dim_t_in-1)]

    # Split forcing time

    year_in = Dates.year.(time_in)
    
    month_in = Dates.month.(time_in)
    
    day_in = Dates.day.(time_in)
    
    hour_in = Dates.hour.(time_in)
    
    # Time and dimensions for outputs

    ts_3h = TimeArray(time_in, rand(length(time_in)))
    
    ts_24h = collapse(ts_3h, day, first, mean)

    time_str_out = Dates.format.(ts_24h.timestamp, "yyyy-mm-dd HH:MM:SS")

    dim_t_out = length(time_str_out)

    dim_s_out = dim_s_in

    # Meteorological inputs

    rainf = fill(0.0, dim_t_in)
    snowf = fill(0.0, dim_t_in)
    tair  = fill(0.0, dim_t_in)
    iswr  = fill(0.0, dim_t_in)
    ilwr  = fill(0.0, dim_t_in)
    pres  = fill(0.0, dim_t_in)
    rhum  = fill(0.0, dim_t_in)
    wind  = fill(0.0, dim_t_in)

    # Create output files

    create_netcdf(joinpath(path, "hs_$(res).nc"), "hs", Dict("units" => "m"), dim_t_out, dim_s_out, time_str_out, id, id_desc)
    
    # Read input and run model

    @showprogress 1 "Running..." for i in 1:dim_s_in

        # Read forcings
        
        ncread!(joinpath(path, "rainf_$(res).nc"), "rainf", rainf, start = [istart, i], count=[dim_t_in, 1])
        ncread!(joinpath(path, "snowf_$(res).nc"), "snowf", snowf, start = [istart, i], count=[dim_t_in, 1])
        ncread!(joinpath(path, "tair_$(res).nc"),  "tair",  tair,  start = [istart, i], count=[dim_t_in, 1])
        ncread!(joinpath(path, "iswr_$(res).nc"),  "iswr",  iswr,  start = [istart, i], count=[dim_t_in, 1])
        ncread!(joinpath(path, "ilwr_$(res).nc"),  "ilwr",  ilwr,  start = [istart, i], count=[dim_t_in, 1])
        ncread!(joinpath(path, "pres_$(res).nc"),  "pres",  pres,  start = [istart, i], count=[dim_t_in, 1])
        ncread!(joinpath(path, "rhum_$(res).nc"),  "rhum",  rhum,  start = [istart, i], count=[dim_t_in, 1])
        ncread!(joinpath(path, "wind_$(res).nc"),  "wind",  wind,  start = [istart, i], count=[dim_t_in, 1])

        metdata = [year_in month_in day_in hour_in iswr ilwr snowf/dt rainf/dt tair+273.15 rhum wind pres*1000]

        # Initilize states

        md = FsmType(am, cm, dm, em, hm, dt)

        # Run model

        hs = run_fsm(md, metdata)

        # Aggregate to daily

        ts_3h.values .= hs

        ts_24h = collapse(ts_3h, day, first, mean)
        
        # Save to netcdf

        ncwrite(ts_24h.values, joinpath(path, "hs_$(res).nc"), "hs", start=[1, i], count=[-1, 1])
        
    end

    ncclose()

end



# Run snow model

path = "/data02/Ican/vic_sim/fsm_past_1km/netcdf"

dt = 3600*3

am = 0
cm = 0
dm = 0
em = 0
hm = 0

tstart = DateTime(2002, 9, 1, 0, 0, 0)
tstop  = DateTime(2005, 8, 31, 21, 0, 0)

res_all = ["50km", "25km", "10km", "5km", "1km"]

# Loop over all resolutions

for res in res_all
    
    run_test(path, tstart, tstop, am, cm, dm, em, hm, dt, res)
    
    print("Finished for $(res)\n")
    
end


