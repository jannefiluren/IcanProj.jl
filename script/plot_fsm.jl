using DataFrames
using NetCDF
using IcanProj
using PyPlot
using NveData




function resample_results(file_nc, timeload, variable, id_desc)

    df_meta = readtable(Pkg.dir("IcanProj", "data", "df_links.csv"))

    time_nc = ncread(file_nc, "time_str")
    
    itime = find(time_nc .== Dates.format(timeload, "yyyy-mm-dd HH:MM:SS"))[1]

    df_left = DataFrame(ind_orig = 1:length(ncread(file_nc, "dim_space")),
                        ind_data = convert(Array{Int64}, ncread(file_nc, String(id_desc))))

    df_right = DataFrame(ind_data = df_meta[id_desc],
                         ind_julia = df_meta[:ind_julia])

    df = join(df_left, df_right, on=:ind_data)

    variable = ncread(file_nc, variable, start = [itime, 1], count = [1,-1])[:]

    tmp = fill(NaN, 1550, 1195)

    for row in eachrow(df)

        tmp[row[:ind_julia]] = variable[row[:ind_orig]]

    end

    return(tmp)

end


file_nc = "/data02/Ican/vic_sim/fsm_past_1km/netcdf/hs_25km.nc"

timeload = DateTime(2005,3,1)

variable = "hs"

id_desc = :ind_25km

tmp = resample_results(file_nc, timeload, variable, id_desc)

PyPlot.imshow(tmp)






