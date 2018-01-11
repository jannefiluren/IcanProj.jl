
using IcanProj
using NetCDF
using ProgressMeter
using DataFrames
using PyPlot



file_fine = "/data02/Ican/vic_sim/fsm_past_1km/netcdf/hs_1km.nc"

file_coarse = "/data02/Ican/vic_sim/fsm_past_1km/netcdf/hs_50km.nc"

id_fine = "ind_senorge"

id_coarse = "ind_50km"

variable = "hs"

df_links = link_results(file_fine, file_coarse, id_fine, id_coarse)

hs_coarse, hs_aggregated = unify_results(file_fine, file_coarse, df_links, variable)



mapped = project_results(mean(hs_aggregated,1), df_links)

figure()
imshow(mapped)



#icol = 150

#plot(hs_aggregated[:,icol])
#plot(hs_coarse[:,icol])








#=

df_links = readtable(Pkg.dir("IcanProj", "data", "df_links.csv"))


# Fine resolution

file_fine = "/data02/Ican/vic_sim/fsm_past_1km/netcdf/hs_1km.nc"

df_fine = DataFrame(id_fine = convert(Array{Int64}, ncread(file_fine, "ind_senorge")),
                    nc_fine = 1:length(ncread(file_fine, "ind_senorge")))

# Coarse resolution

file_coarse = "/data02/Ican/vic_sim/fsm_past_1km/netcdf/hs_50km.nc"

df_coarse = DataFrame(id_coarse = convert(Array{Int64}, ncread(file_coarse, "ind_50km")),
                      nc_coarse = 1:length(ncread(file_coarse, "ind_50km")))


df_all = DataFrame(id_fine = df_links[:ind_senorge],
                   id_coarse = df_links[:ind_50km],
                   ind_julia = df_links[:ind_julia])



df_test = join(df_all, df_fine, on = :id_fine)

df_test = join(df_test, df_coarse, on = :id_coarse)

sort!(df_test, cols = [:id_fine])

tmp =  DataFrame(nc_coarse = df_test[:nc_coarse],
                 n = 1)

tmp = aggregate(tmp, :nc_coarse, sum)

df_test = join(df_test, tmp, on = :nc_coarse)


=#













