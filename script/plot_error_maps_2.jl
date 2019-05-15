
# Script for creating Figure 10, 11, 12 in scale manuscript


using IcanProj
using Statistics
using PyPlot
using PyCall


function compute_metrics(cfg, variable)

  # File path_results

  file_fine = "/data04/jmg/fsm_simulations/netcdf/fsmres_forest/results_$(cfg)/$(variable)_1km.nc"

  file_coarse = "/data04/jmg/fsm_simulations/netcdf/fsmres_forest/results_$(cfg)/$(variable)_50km.nc"

  # Load data

  df_links = link_results(file_fine, file_coarse)

  data_coarse, data_aggregated, ngrids  = unify_results(file_fine, file_coarse, df_links, variable)

  # Compute metrics

  rmse = sqrt.(mean((data_coarse .- data_aggregated).^2 , dims = 1))

  meanref = mean(data_aggregated, dims = 1)

  meancmp = mean(data_coarse, dims = 1)

  nrmse = rmse ./ meanref

  bias = (meancmp .- meanref)

  perc_bias = 100 .* bias ./ meanref

  # Project to map

  rmse_map = project_results(rmse[:], df_links)

  nrmse_map = project_results(nrmse[:], df_links)

  bias_map = project_results(bias[:], df_links)

  perc_bias_map = project_results(perc_bias[:], df_links)

  # Return results

  return rmse_map, bias_map

end


# Global settings

cfg = 32

path_results = joinpath(dirname(pathof(IcanProj)), "..", "plots", "error_maps_2")


# Compute metrics

rmse_swe, bias_swe = compute_metrics(cfg, "swe")

rmse_latmo, bias_latmo = compute_metrics(cfg, "latmo")

rmse_hatmo, bias_hatmo = compute_metrics(cfg, "hatmo")

rmse_rnet, bias_rnet = compute_metrics(cfg, "rnet")


# Plot rmse

py"""
import matplotlib.pyplot as plt
import numpy as np
fig, ax = plt.subplots(2, 2, tight_layout=True, figsize = (8, 8))
"""

py"""
data_map = np.array($(rmse_swe))
data_vec = data_map[~np.isnan(data_map)]

map = ax[0,0].imshow(data_map) #, vmin = 0, vmax = 85)
cb = fig.colorbar(map, ax=ax[0,0], fraction=0.046, pad=0.04)
cb.set_label("RMSE ($mm$)", size = 11)
ax[0,0].annotate("(A) SWE", xy=(0.1,0.9), xycoords="axes fraction", fontsize = 12)
ax[0,0].axis('off')
inset_ax = ax[0,0].inset_axes([0.6, 0.15, 0.3, 0.3])
inset_ax.hist(data_vec, density=True, bins=10, color="gray")
inset_ax.tick_params(axis='both', which='major', labelsize=7)
inset_ax.tick_params(axis='both', which='minor', labelsize=7)
inset_ax.set_xlabel("RMSE ($mm$)", fontsize = 8)
inset_ax.set_ylabel("Density (-)", fontsize = 8)
"""

py"""
data_map = np.array($(rmse_rnet))
data_vec = data_map[~np.isnan(data_map)]

map = ax[0,1].imshow(data_map) #, vmin = 0, vmax = 2.8)
cb = fig.colorbar(map, ax=ax[0,1], fraction=0.046, pad=0.04)
cb.set_label("RMSE ($W/m^2$)", size = 11)
ax[0,1].annotate("(B) RNET", xy=(0.1,0.9), xycoords="axes fraction", fontsize = 12)
ax[0,1].axis('off')
inset_ax = ax[0,1].inset_axes([0.6, 0.15, 0.3, 0.3])
inset_ax.hist(data_vec, density=True, bins=10, color="gray")
inset_ax.tick_params(axis='both', which='major', labelsize=7)
inset_ax.tick_params(axis='both', which='minor', labelsize=7)
inset_ax.set_xlabel("RMSE ($W/m^2$)", fontsize = 8)
inset_ax.set_ylabel("Density (-)", fontsize = 8)
"""

py"""
data_map = np.array($(rmse_hatmo))
data_vec = data_map[~np.isnan(data_map)]

map = ax[1,0].imshow(data_map) #, vmin = 0, vmax = 2.8)
cb = fig.colorbar(map, ax=ax[1,0], fraction=0.046, pad=0.04)
cb.set_label("RMSE ($W/m^2$)", size = 11)
ax[1,0].annotate("(C) HATMO", xy=(0.1,0.9), xycoords="axes fraction", fontsize = 12)
ax[1,0].axis('off')
inset_ax = ax[1,0].inset_axes([0.6, 0.15, 0.3, 0.3])
inset_ax.hist(data_vec, density=True, bins=10, color="gray")
inset_ax.tick_params(axis='both', which='major', labelsize=7)
inset_ax.tick_params(axis='both', which='minor', labelsize=7)
inset_ax.set_xlabel("RMSE ($W/m^2$)", fontsize = 8)
inset_ax.set_ylabel("Density (-)", fontsize = 8)
"""

py"""
data_map = np.array($(rmse_latmo))
data_vec = data_map[~np.isnan(data_map)]

map = ax[1,1].imshow(data_map) #, vmin = 0, vmax = 2.8)
cb = fig.colorbar(map, ax=ax[1,1], fraction=0.046, pad=0.04)
cb.set_label("RMSE ($W/m^2$)", size = 11)
ax[1,1].annotate("(D) LATMO", xy=(0.1,0.9), xycoords="axes fraction", fontsize = 12)
ax[1,1].axis('off')
inset_ax = ax[1,1].inset_axes([0.6, 0.15, 0.3, 0.3])
inset_ax.hist(data_vec, density=True, bins=10, color="gray")
inset_ax.tick_params(axis='both', which='major', labelsize=7)
inset_ax.tick_params(axis='both', which='minor', labelsize=7)
inset_ax.set_xlabel("RMSE ($W/m^2$)", fontsize = 8)
inset_ax.set_ylabel("Density (-)", fontsize = 8)
"""

file_name = "maps_rmse_$(cfg).pdf"

py"""
plt.savefig($(joinpath(path_results, file_name)), dpi=600)
plt.close()
"""


# Plot bias

py"""
import matplotlib.pyplot as plt
import numpy as np
fig, ax = plt.subplots(2, 2, tight_layout=True, figsize = (8, 8))
"""

py"""
data_map = np.array($(bias_swe))
data_vec = data_map[~np.isnan(data_map)]
limit = np.max(np.abs(data_vec))

map = ax[0,0].imshow(data_map, vmin = -limit, vmax = limit, cmap="jet")
cb = fig.colorbar(map, ax=ax[0,0], fraction=0.046, pad=0.04)
cb.set_label("Bias ($mm$)", size = 11)
ax[0,0].annotate("(A) SWE", xy=(0.1,0.9), xycoords="axes fraction", fontsize = 12)
ax[0,0].axis('off')
inset_ax = ax[0,0].inset_axes([0.6, 0.15, 0.3, 0.3])
inset_ax.hist(data_vec, density=True, bins=10, color="gray")
inset_ax.tick_params(axis='both', which='major', labelsize=7)
inset_ax.tick_params(axis='both', which='minor', labelsize=7)
inset_ax.set_xlabel("Bias ($mm$)", fontsize = 8)
inset_ax.set_ylabel("Density (-)", fontsize = 8)
inset_ax.set_xlim(-limit, limit)
"""

py"""
data_map = np.array($(bias_rnet))
data_vec = data_map[~np.isnan(data_map)]
limit = np.max(np.abs(data_vec))

map = ax[0,1].imshow(data_map, vmin = -limit, vmax = limit, cmap="jet")
cb = fig.colorbar(map, ax=ax[0,1], fraction=0.046, pad=0.04)
cb.set_label("Bias ($W/m^2$)", size = 11)
ax[0,1].annotate("(B) RNET", xy=(0.1,0.9), xycoords="axes fraction", fontsize = 12)
ax[0,1].axis('off')
inset_ax = ax[0,1].inset_axes([0.6, 0.15, 0.3, 0.3])
inset_ax.hist(data_vec, density=True, bins=10, color="gray")
inset_ax.tick_params(axis='both', which='major', labelsize=7)
inset_ax.tick_params(axis='both', which='minor', labelsize=7)
inset_ax.set_xlabel("Bias ($W/m^2$)", fontsize = 8)
inset_ax.set_ylabel("Density (-)", fontsize = 8)
inset_ax.set_xlim(-limit, limit)
"""

py"""
data_map = np.array($(bias_hatmo))
data_vec = data_map[~np.isnan(data_map)]
limit = np.max(np.abs(data_vec))

map = ax[1,0].imshow(data_map, vmin = -limit, vmax = limit, cmap="jet")
cb = fig.colorbar(map, ax=ax[1,0], fraction=0.046, pad=0.04)
cb.set_label("Bias ($W/m^2$)", size = 11)
ax[1,0].annotate("(C) HATMO", xy=(0.1,0.9), xycoords="axes fraction", fontsize = 12)
ax[1,0].axis('off')
inset_ax = ax[1,0].inset_axes([0.6, 0.15, 0.3, 0.3])
inset_ax.hist(data_vec, density=True, bins=10, color="gray")
inset_ax.tick_params(axis='both', which='major', labelsize=7)
inset_ax.tick_params(axis='both', which='minor', labelsize=7)
inset_ax.set_xlabel("Bias ($W/m^2$)", fontsize = 8)
inset_ax.set_ylabel("Density (-)", fontsize = 8)
inset_ax.set_xlim(-limit, limit)
"""

py"""
data_map = np.array($(bias_latmo))
data_vec = data_map[~np.isnan(data_map)]
limit = np.max(np.abs(data_vec))

map = ax[1,1].imshow(data_map, vmin = -limit, vmax = limit, cmap="jet")
cb = fig.colorbar(map, ax=ax[1,1], fraction=0.046, pad=0.04)
cb.set_label("Bias ($W/m^2$)", size = 11)
ax[1,1].annotate("(D) LATMO", xy=(0.1,0.9), xycoords="axes fraction", fontsize = 12)
ax[1,1].axis('off')
inset_ax = ax[1,1].inset_axes([0.6, 0.15, 0.3, 0.3])
inset_ax.hist(data_vec, density=True, bins=10, color="gray")
inset_ax.tick_params(axis='both', which='major', labelsize=7)
inset_ax.tick_params(axis='both', which='minor', labelsize=7)
inset_ax.set_xlabel("Bias ($W/m^2$)", fontsize = 8)
inset_ax.set_ylabel("Density (-)", fontsize = 8)
inset_ax.set_xlim(-limit, limit)
"""

file_name = "maps_bias_$(cfg).pdf"

py"""
plt.savefig($(joinpath(path_results, file_name)), dpi=600)
plt.close()
"""
