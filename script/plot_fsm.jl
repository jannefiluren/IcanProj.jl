using DataFrames
using NetCDF
using IcanProj
using PyPlot
using NveData


# Test with 1km resolution

ind_senorge, xcoord, ycoord = senorge_info()

file = Pkg.dir("IcanProj", "data", "df_links.csv")

df_meta = readtable(file)
    
file = "/data02/Ican/vic_sim/fsm_past_1km/netcdf/hs_1km.nc"

time_str = ncread(file, "time_str")

time = DateTime.(time_str, "yyyy-mm-dd HH:MM:SS")

itime = find(time .== DateTime(2005, 8, 1))[1]

df_left = DataFrame(ind_senorge = ncread(file, "ind_senorge"),
                    hs = ncread(file, "hs", start = [itime, 1], count = [1,-1])[:])

df = join(df_left, df_meta, on=:ind_senorge)


# Project results to map

imap = convert(Array{Int64}, df[:ind_julia])

hs = convert(Array{Float64}, df[:hs])

tmp = fill(NaN, size(ind_senorge))

tmp[imap] = hs

PyPlot.imshow(tmp)





# Test with 5km resolution

ind_senorge, xcoord, ycoord = senorge_info()

file = Pkg.dir("IcanProj", "data", "df_links.csv")

df_meta = readtable(file)
    
file = "/data02/Ican/vic_sim/fsm_past_1km/netcdf/hs_5km.nc"

time_str = ncread(file, "time_str")

time = DateTime.(time_str, "yyyy-mm-dd HH:MM:SS")

itime = find(time .== DateTime(2005, 3, 1))[1]

ind_coarse = convert(Array{Int64}, ncread(file, "ind_5km"))

hs_coarse = ncread(file, "hs", start = [itime, 1], count = [1,-1])[:]

ind_fine = df_meta[:ind_5km]

hs_resampled = fill(0.0, length(ind_fine))

for i in eachindex(ind_coarse)

    hs_resampled[ind_fine .== ind_coarse[i]] = hs_coarse[i]

end




imap = convert(Array{Int64}, df[:ind_julia])

hs = convert(Array{Float64}, hs_resampled)

tmp = fill(NaN, size(ind_senorge))

tmp[imap] = hs

PyPlot.imshow(tmp)




