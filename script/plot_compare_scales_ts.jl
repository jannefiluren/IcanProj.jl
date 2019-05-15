using IcanProj
using NetCDF
using DataFrames
using CSV
using Statistics
using PyPlot
using Dates


# Settings

path = "/data04/jmg/fsm_simulations/netcdf/fsmres_open"

cfg = 32

variable = "latmo"

resolution = "5km"

# Load and link custom results

file_fine = joinpath(path, "results_$(cfg)", "$(variable)_1km.nc")

file_coarse = joinpath(path, "results_$(cfg)", "$(variable)_$(resolution).nc")

df_links = link_results(file_fine, file_coarse)

var_coarse, var_ref, ngrids = unify_results(file_fine, file_coarse, df_links, variable)

(any(isnan.(var_ref)) | any(isnan.(var_coarse))) ? error("nans in results") : nothing

# Load and link swes

file_fine = joinpath(path, "results_$(cfg)", "swe_1km.nc")

file_coarse = joinpath(path, "results_$(cfg)", "swe_$(resolution).nc")

swe_coarse, swe_ref, ngrids = unify_results(file_fine, file_coarse, df_links, "swe")

(any(isnan.(swe_ref)) | any(isnan.(swe_coarse))) ? error("nans in results") : nothing

# Load time

ta = ncread(file_coarse, "time_array")

t = [DateTime(ta[1,i],ta[2,i],ta[3,i],ta[4,i]) for i in 1:size(ta, 2)]

# Compute scale error

scale_error = var_coarse - var_ref

scale_rmse = sqrt.(mean(scale_error.^2, dims = 1))

print("Number of time steps: $(size(scale_error, 1))")
print("Number of grid cells: $(size(scale_error, 2))")
print("Maximum rmse: $(maximum(scale_rmse))")


# Plots

if true

  fig, axes = plt[:subplots](nrows = 3, ncols = 1)

  axes[1][:plot](t, scale_error, color = "gray")
  
  axes[2][:plot](t, var_ref, color = "gray")
  
  axes[3][:plot](t, var_coarse, color = "gray")

  
  #axes[1][:plot](t, cumsum(scale_error, dims = 1), color = "gray")

  # mean_coarse = [mean(var_coarse[i, ikeep[i, :]]) for i in 1:size(ikeep, 1)]

  # mean_ref = [mean(var_ref[i, ikeep[i, :]]) for i in 1:size(ikeep, 1)]

end


