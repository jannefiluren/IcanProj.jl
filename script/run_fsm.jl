
using JFSM
using NetCDF
using TimeSeries
using IcanProj
using ProgressMeter
using ExcelReaders
using DataFrames




"""
Run fsm and save results to netcdf.
"""
function run_simulation(path, tstart, tstop, am, cm, dm, em, hm, dt, res, iexp, pot_melt, comp_prec)

    # Read metadata

    id = ncread(joinpath(path, "forcings", "rainf_$(res).nc"), "id")
    
    id_desc = ncgetatt(joinpath(path, "forcings", "rainf_$(res).nc"), "dim_space", "id")
    
    # Space dimension

    dim_s_in = length(id)
    
    # Read time for forcings

    time_str_in = ncread(joinpath(path, "forcings", "tair_$(res).nc"), "time_str")

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

    ts_3h = TimeArray(time_in, fill(0.0, length(time_in), 3))
    
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

    mkpath(joinpath(path, "results_$(iexp)"))

    create_netcdf(joinpath(path, "results_$(iexp)", "hs_$(res).nc"), "hs", Dict("units" => "m"), dim_t_out, dim_s_out, time_str_out, id, id_desc)
    create_netcdf(joinpath(path, "results_$(iexp)", "swe_$(res).nc"), "swe", Dict("units" => "mm"), dim_t_out, dim_s_out, time_str_out, id, id_desc)
    create_netcdf(joinpath(path, "results_$(iexp)", "rof_$(res).nc"), "rof", Dict("units" => "unknown"), dim_t_out, dim_s_out, time_str_out, id, id_desc)
    
    # Read input and run model

    @showprogress 1 "Running..." for i in 1:dim_s_in

        # Read forcings
        
        ncread!(joinpath(path, "forcings", "rainf_$(res).nc"), "rainf", rainf, start = [istart, i], count=[dim_t_in, 1])
        ncread!(joinpath(path, "forcings", "snowf_$(res).nc"), "snowf", snowf, start = [istart, i], count=[dim_t_in, 1])
        ncread!(joinpath(path, "forcings", "tair_$(res).nc"),  "tair",  tair,  start = [istart, i], count=[dim_t_in, 1])
        ncread!(joinpath(path, "forcings", "iswr_$(res).nc"),  "iswr",  iswr,  start = [istart, i], count=[dim_t_in, 1])
        ncread!(joinpath(path, "forcings", "ilwr_$(res).nc"),  "ilwr",  ilwr,  start = [istart, i], count=[dim_t_in, 1])
        ncread!(joinpath(path, "forcings", "pres_$(res).nc"),  "pres",  pres,  start = [istart, i], count=[dim_t_in, 1])
        ncread!(joinpath(path, "forcings", "rhum_$(res).nc"),  "rhum",  rhum,  start = [istart, i], count=[dim_t_in, 1])
        ncread!(joinpath(path, "forcings", "wind_$(res).nc"),  "wind",  wind,  start = [istart, i], count=[dim_t_in, 1])

        # Compute snowfall and rainfall from precipitation and temperature

        if comp_prec == 1
            
            prec = snowf + rainf

            fill!(snowf, 0.0)
            fill!(rainf, 0.0)

            snowf[tair .<= 0.0] .= prec[tair .<= 0.0]
            rainf[tair .> 0.0] .= prec[tair .> 0.0]

        end
        
        metdata = [year_in month_in day_in hour_in iswr ilwr snowf/dt rainf/dt tair+273.15 rhum wind pres*1000]

        # Initilize states

        md = FsmType(am, cm, dm, em, hm, dt)

        # Run model

        if pot_melt == 1
            results, desc = run_fsm_special(md, metdata)
        else
            results, desc = run_fsm(md, metdata)
        end
        
        # Aggregate to daily
        
        ts_3h.values .= results

        ts_24h_mean = collapse(ts_3h, day, first, mean)

        ts_24h_sum = collapse(ts_3h, day, first, sum)
        
        # Save to netcdf

        ncwrite(ts_24h_mean.values[:,1], joinpath(path, "results_$(iexp)", "hs_$(res).nc"), "hs", start=[1, i], count=[-1, 1])
        ncwrite(ts_24h_mean.values[:,2], joinpath(path, "results_$(iexp)", "swe_$(res).nc"), "swe", start=[1, i], count=[-1, 1])
        ncwrite(ts_24h_sum.values[:,3], joinpath(path, "results_$(iexp)", "rof_$(res).nc"), "rof", start=[1, i], count=[-1, 1])
        
    end

    ncclose()

end



function run_all_resultions(path, tstart, tstop, dt, df_settings)

    for row in eachrow(df_settings)
        
        for res in ["50km", "25km", "10km", "5km", "1km"]

            run_simulation(path,
                           tstart,
                           tstop,
                           Int64(row[:am]),
                           Int64(row[:cm]),
                           Int64(row[:dm]),
                           Int64(row[:em]),
                           Int64(row[:hm]),
                           dt,
                           res,
                           Int64(row[:experiment]),
                           Int64(row[:pot_melt]),
                           Int64(row[:comp_prec]))
            
            print("Finished for $(res)\n")
            
        end

    end

end



# Settings common for all simulations

path = "/data02/Ican/vic_sim/fsm_past_1km/netcdf"

dt = 3600*3

tstart = DateTime(2002, 9, 1, 0, 0, 0)

tstop  = DateTime(2003, 8, 31, 21, 0, 0)

# Settings specific for each run

file = Pkg.dir("IcanProj", "data", "simulations.xlsx")

df_settings = readxlsheet(DataFrame, file, "simulations")

# Run simulations

run_all_resultions(path, tstart, tstop, dt, df_settings)
