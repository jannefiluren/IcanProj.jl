using IcanProj
using NetCDF
using DataFrames
using PyPlot
using Dates
using CSV

# Settings

timeplot = DateTime(2011,4,1,0)

variable = "swe"

cfg = 1

file_forest = "/data04/jmg/fsm_simulations/netcdf/fsmres_forest/results_$(cfg)/$(variable)_1km.nc"

file_open = "/data04/jmg/fsm_simulations/netcdf/fsmres_open/results_$(cfg)/$(variable)_1km.nc"


# Load data

df_links = CSV.read(joinpath(dirname(pathof(IcanProj)), "..", "data", "df_links.csv")) |> DataFrame

tarray = ncread(file_forest, "time_array")

time = [DateTime(tarray[1,i],tarray[2,i],tarray[3,i],tarray[4,i]) for i in 1:size(tarray, 2)]

itime = findfirst(isequal(timeplot), time)

data_forest = ncread(file_forest, variable, start = [1,itime], count=[-1,1])

data_open = ncread(file_open, variable, start = [1,itime], count=[-1,1])

data_forest = dropdims(data_forest, dims = 2)

data_open = dropdims(data_open, dims = 2)


# Create dataframe for linking results_1

df = DataFrame(ind_senorge = convert.(Int, ncread(file_forest, "id")),
               ind_linear = 1:length(df[:ind_senorge]))

df_final = join(df_links, df, on=:ind_senorge)


# Plots

map_forest = project_results(data_forest, df_final, :ind_linear)

figure()
imshow(map_forest)
colorbar()

map_open = project_results(data_open, df_final, :ind_linear)

figure()
imshow(map_open)
colorbar()

figure()
imshow(map_open .- map_forest)
cb = colorbar()
cb[:set_label]("SWE open minus forest (mm)")
title("Date: $(Dates.format(time[itime], "yyyy-mm-dd"))")
