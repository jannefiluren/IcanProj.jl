
using IcanProj
using NetCDF
using DataFrames
using PyPlot


function mean_error(res)

    # Settings

    file_fine = "/data02/Ican/vic_sim/fsm_past_1km/netcdf/tmp/results_1/swe_1km.nc"

    file_coarse = "/data02/Ican/vic_sim/fsm_past_1km/netcdf/tmp/results_1/swe_$(res).nc"

    variable = "swe"

    # Load data

    df_links = link_results(file_fine, file_coarse)

    hs_coarse, hs_fine_agg, ngrids = unify_results(file_fine, file_coarse, df_links, variable)

    # Compute errors

    rmse = sqrt.(mean((hs_coarse - hs_fine_agg).^2, 1))

    rmse_mean = sum(rmse[:] .* ngrids[:]/sum(ngrids[:]))

    return rmse_mean
    
end




res_all = ["5km", "10km", "25km", "50km"]

rmse_mean = []


for res in res_all

    push!(rmse_mean, mean_error(res))
    
end


figure()
scatter(collect(0:length(res_all)-1), rmse_mean)
plt[:xticks](collect(0:length(res_all)-1), res_all)
xlabel("Spatial resolution")
#ylabel("RMSE (m)")
#title("Snow depth")
ylim([0, maximum(rmse_mean)+0.02])
