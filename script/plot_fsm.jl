
using IcanProj
using NetCDF
using ProgressMeter
using DataFrames
using PyPlot


function aggregate_results!(data_grid, df_cmp)

    df_old_1km = df_cmp
    
    df_old_1km[:variable] = data_grid[df_old_1km[:ind_julia]]
    
    df_agg = aggregate(df_old_1km, :id, mean)

    df_new_1km = join(df_old_1km, df_agg, on = :id)

    data_grid[df_new_1km[:ind_julia]] = df_new_1km[:variable_mean]

    return nothing
    
end







# Settings

file_ref = "/data02/Ican/vic_sim/fsm_past_1km/netcdf/hs_1km.nc"

file_cmp = "/data02/Ican/vic_sim/fsm_past_1km/netcdf/hs_5km.nc"

variable = "hs"

id_desc = :ind_5km

tstart = DateTime(2002, 10, 1)

tstop = DateTime(2003, 10, 1)


# Load time information

timevec = ncread(file_ref, "time_str")

timevec = DateTime.(timevec, "yyyy-mm-dd HH:MM:SS")


# Link resolutions

df_ref = link_resolutions(file_ref, :ind_senorge)

df_cmp = link_resolutions(file_cmp, id_desc)


# Initilize variables

tmp = resample_results(file_ref, timevec[1], "hs", df_ref)

tmp[.!isnan.(tmp)] .= 0.0

sqerror = copy(tmp)
meanref = copy(tmp)
meancmp = copy(tmp)
resref = copy(tmp)
rescmp = copy(tmp)


# Loop over selected period

timevec = timevec[tstart .<= timevec .<= tstop]

@showprogress "Computing for ... " for timeload in timevec

    # Load and resample results
    
    resample_results!(resref, file_ref, timeload, "hs", df_ref)

    resample_results!(rescmp, file_cmp, timeload, "hs", df_cmp)

    # Aggregate fine resolution results

    aggregate_results!(resref, df_cmp)

    # Compute statistics

    sqerror += (resref - rescmp).^2

    meanref += resref

    meancmp += rescmp

end


# Compute stuff

rmse = sqrt.(sqerror/length(timevec))

meanref = meanref/length(timevec)

meancmp = meancmp/length(timevec)

nrmse = rmse ./ meanref

pbias = 100 * (meancmp ./ meanref-1)

# Plot stuff

figure()
imshow(meanref)
colorbar()
title("Mean hs (m) for fine scale run")

figure()
imshow(meancmp)
colorbar()
title("Mean hs (m) for coarse scale run")

figure()
imshow(pbias)
colorbar()
title("Bias in hs (%) between coarse and fine scale run")

figure()
imshow(nrmse)
colorbar()
title("NRMSE (-) between coarse and fine scale run")
