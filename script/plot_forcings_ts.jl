using NetCDF
using PyPlot


path = "/data02/Ican/vic_sim/fsm_past_1km/netcdf/forcings_st"


for variable in ["ilwr", "iswr", "pres", "rainf", "snowf", "rhum", "tair", "wind"]

    file_low = joinpath(path, "$(variable)_50km.nc")

    data_low = ncread(file_low, variable)

    file_high = joinpath(path, "$(variable)_1km.nc")

    data_high = ncread(file_high, variable)

    time = ncread(file_low, "time_str")

    time = DateTime.(time, "yyyy-mm-dd HH:MM:SS")

    figure(figsize = (12, 7))
    fill_between(time, minimum(data_high,1)[:], maximum(data_high,1)[:], facecolor = "gray", alpha = 1.0)
    fill_between(time, minimum(data_low,1)[:], maximum(data_low,1)[:], facecolor = "red", alpha = 0.3)
    title("$(variable)")

end
