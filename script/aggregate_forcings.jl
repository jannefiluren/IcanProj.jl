
using DataFrames
using NetCDF
using IcanProj
using ProgressMeter


function aggregate_forcings(path, var, res)

    # Symbol for resolution

    ind_res = Symbol("ind_$(res)")
    
    # Metadata from table

    df_meta = CSV.File(joinpath(dirname(pathof(IcanProj)), "..", "data", "df_links.csv")) |> DataFrame
    
    # Metadata from input netcdfs

    file_in = joinpath(path, "forcings_ts/$(var)_1km.nc")

    nc_in = Dict("ind_senorge" => ncread(file_in, "id"),
                 "time_str" => ncread(file_in, "time_str"),
                 "var_atts" => ncgetatt(file_in, var, "units"))

    # Create netcdfs

    file_out = joinpath(path, "forcings_ts/$(var)_$(res).nc")

    var_atts = Dict("units" => nc_in["var_atts"])

    dim_time = length(nc_in["time_str"])

    dim_space = length(unique(df_meta[ind_res]))

    time_str = nc_in["time_str"]

    id = convert(Array{Int64}, unique(df_meta[ind_res]))

    id_desc = String(ind_res)
    
    create_netcdf(file_out, var, var_atts, dim_time, dim_space, time_str, id, id_desc)

    # Aggregate forcings

    icol_out = 1

    @showprogress 1 "Running..." for ind_unique in unique(df_meta[ind_res])

        itarget = find(df_meta[ind_res] .== ind_unique)

        data_agg = fill(0.0, dim_time)

        tmp = fill(0.0, dim_time)
        
        for ind_senorge in df_meta[:ind_senorge][itarget]

            icol_in = find(nc_in["ind_senorge"] .== ind_senorge)[1]

            ncread!(file_in, var, tmp, start=[1,icol_in], count=[-1,1])

            data_agg = data_agg + tmp / length(itarget)
            
        end
        
        ncwrite(data_agg, file_out, var, start=[1,icol_out], count=[-1,1])

        icol_out += 1
        
    end

    ncclose()

    return nothing

end



# Settings

path = "/data04/jmg/fsm_simulations/netcdf"

var_all = ["ilwr", "iswr", "pres", "rainf", "snowf", "wind", "rhum", "tair"]

res_all = ["50km", "25km", "10km", "5km"]

# Loop over all variables and resolutions

for var in var_all, res in res_all

    aggregate_forcings(path, var, res)

    print("Finished $(var) for $(res)\n")

end






