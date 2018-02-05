
using IcanProj
using NetCDF
using DataFrames
using PyPlot
using JFSM2


function compute_statistics(data)

    res = Dict("mean" => mean(data, 2),
               "std" => std(data, 2),
               "cv" => std(data, 2) ./ mean(data, 2))

    return res
    
end
    


function plot_hydrol_exchng(time, data, df_cfg, fig_title)

    hydrol_off = convert(Array{Bool}, df_cfg[:hydrol] .== 0)
    hydrol_on  = convert(Array{Bool}, df_cfg[:hydrol] .== 1)

    exchng_off = convert(Array{Bool}, df_cfg[:exchng] .== 0)
    exchng_on  = convert(Array{Bool}, df_cfg[:exchng] .== 1)

    figure(figsize = (9, 6))

    fill_between(time,
                 maximum(data[hydrol_off .& exchng_off,:], 1)[:],
                 minimum(data[hydrol_off .& exchng_off,:], 1)[:],
                 facecolor = "gray", edgecolor = "gray", alpha = 0.5,
                 label = "Hydrol=0 & Exchng=0")

    fill_between(time,
                 maximum(data[hydrol_on .& exchng_off,:], 1)[:],
                 minimum(data[hydrol_on .& exchng_off,:], 1)[:],
                 facecolor = "green", edgecolor = "green", alpha = 0.5,
                 label = "Hydrol=1 & Exchng=0")

    fill_between(time,
                 maximum(data[hydrol_off .& exchng_on,:], 1)[:],
                 minimum(data[hydrol_off .& exchng_on,:], 1)[:],
                 facecolor = "blue", edgecolor = "blue", alpha = 0.5,
                 label = "Hydrol=0 & Exchng=1")

    fill_between(time,
                 maximum(data[hydrol_on .& exchng_on,:], 1)[:],
                 minimum(data[hydrol_on .& exchng_on,:], 1)[:],
                 facecolor = "red", edgecolor = "red", alpha = 0.5,
                 label = "Hydrol=1 & Exchng=1")

    legend(loc=2)

    ylabel("SWE (mm)")

    title(fig_title)
    
end



respath = "/data02/Ican/vic_sim/fsm_past_1km/netcdf/new"

figpath = Pkg.dir("IcanProj", "plots", "config_ts")

variable = "swe"

iexp = 1:32

for spatial_res in ["5km", "50km"]

    time = load_time(respath, variable, spatial_res)

    data = load_time_slice(respath, variable, spatial_res, iexp)

    stats = compute_statistics(data)

    imin = indmin(stats["cv"])

    imax = indmax(stats["cv"])

    datamin = load_space_slice(respath, variable, spatial_res, iexp, imin)

    datamax = load_space_slice(respath, variable, spatial_res, iexp, imax)

    df_cfg = cfg_table()

    fig_title = "Spatial resolution $(spatial_res)"

    plot_hydrol_exchng(time, datamin, df_cfg, fig_title)

    savefig(joinpath(figpath, "datamin_$(spatial_res).png"))
    
    plot_hydrol_exchng(time, datamax, df_cfg, fig_title)

    savefig(joinpath(figpath, "datamax_$(spatial_res).png"))

end















#=

ipos = 62
figure()
for icfg in 1:32
    data = datamax[icfg, :]
    plot(collect(1:length(data)), data)
    annotate(string([df_cfg[icfg, i] for i in 1:6]), xy=(ipos, data[ipos]))
    @show data[ipos]
end

=#





#=
cfg_vec = [:albedo, :condct, :densty, :exchng, :hydrol]

for cfg in cfg_vec

    ioff = convert(Array{Bool}, df_cfg[cfg] .== 0)
    ion = convert(Array{Bool}, df_cfg[cfg] .== 1)
    
    figure()
    plot(time, datamin[ioff,:]', label = "off", color = "gray")
    plot(time, datamin[ion,:]', label = "on", color = "blue")
    ylabel("SWE (mm)")
    title(string(cfg))
    
    figure()
    plot(time, datamax[ioff,:]', label = "off", color = "gray")
    plot(time, datamax[ion,:]', label = "on", color = "blue")
    ylabel("SWE (mm)")
    title(string(cfg))
    
end

=#



#=

plot(time, datamin[hydrol_off .& exchng_on,:]', label = "on", color = "blue")
plot(time, datamin[hydrol_on .& exchng_off,:]', label = "off", color = "pink")
plot(time, datamin[hydrol_on .& exchng_on,:]', label = "on", color = "yellow")
ylabel("SWE (mm)")

figure()
plot(time, datamax[hydrol_off .& exchng_off,:]', label = "off", color = "gray")
plot(time, datamax[hydrol_off .& exchng_on,:]', label = "on", color = "blue")
plot(time, datamax[hydrol_on .& exchng_off,:]', label = "off", color = "pink")
plot(time, datamax[hydrol_on .& exchng_on,:]', label = "on", color = "yellow")
ylabel("SWE (mm)")

=#



#=
hydrol_off = convert(Array{Bool}, df_cfg[:hydrol] .== 0)
hydrol_on  = convert(Array{Bool}, df_cfg[:hydrol] .== 1)

exchng_off = convert(Array{Bool}, df_cfg[:exchng] .== 0)
exchng_on  = convert(Array{Bool}, df_cfg[:exchng] .== 1)

figure()
plot(time, datamin[hydrol_off .& exchng_off,:]', label = "off", color = "gray")
plot(time, datamin[hydrol_off .& exchng_on,:]', label = "on", color = "blue")
plot(time, datamin[hydrol_on .& exchng_off,:]', label = "off", color = "pink")
plot(time, datamin[hydrol_on .& exchng_on,:]', label = "on", color = "yellow")
ylabel("SWE (mm)")

figure()
plot(time, datamax[hydrol_off .& exchng_off,:]', label = "off", color = "gray")
plot(time, datamax[hydrol_off .& exchng_on,:]', label = "on", color = "blue")
plot(time, datamax[hydrol_on .& exchng_off,:]', label = "off", color = "pink")
plot(time, datamax[hydrol_on .& exchng_on,:]', label = "on", color = "yellow")
ylabel("SWE (mm)")
=#







#=

# Test for plotting maps

path = "/data02/Ican/vic_sim/fsm_past_1km/netcdf/tmp"

variable = "swe"

spatial_res = "50km"

iexp = 1:32

itime = 200

data = load_time_slice(path, variable, spatial_res, iexp)

stats = compute_statistics(data)

df = link_table(path, variable, spatial_res)

map_values = project_map(stats["mean"], df)

figure()
imshow(map_values)
cb = colorbar()
=#

#=
# Test for plotting time series

map_values = fill(NaN, 1550, 1195)

map_values[df[:ind_julia]] = df[:nc]

figure()
imshow(map_values)
cb = colorbar()

ispace = 169

spatial_res = "10km"

data = load_space_slice(path, variable, spatial_res, iexp, ispace)

figure()
plot(data')
=#