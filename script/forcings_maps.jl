using IcanProj
using NetCDF
using DataFrames
using ProgressMeter
using Statistics
using CSV
using PyCall


function project_results(df::DataFrame, on::Symbol)
  
  map_values = fill(NaN, 1550, 1195)
  
  map_values[df[:ind_julia]] = df[on]
  
  return map_values
  
end


# Settings

figpath = joinpath(dirname(pathof(IcanProj)), "..", "plots", "forcings")


# Load data

df_all = CSV.File(joinpath(dirname(pathof(IcanProj)), "..", "data", "forcings_summary.txt")) |> DataFrame

df_all.prec_mean = 365*8*(df_all.rainf_mean .+ df_all.snowf_mean)


# Plot averages

map_prec = project_results(df_all, :prec_mean)

map_wind = project_results(df_all, :wind_mean)

map_tair = project_results(df_all, :tair_mean)

file = joinpath(figpath, "forcings_mean.png")

py"""
import matplotlib.pyplot as plt
from mpl_toolkits.axes_grid1 import make_axes_locatable
import numpy as np

fig, ax = plt.subplots(1, 3)

fig.set_size_inches(12, 8)

# Precipitation

im = ax[0].imshow($(map_prec), cmap = 'jet', vmin=-0.1, vmax=4000)

ax[0].grid(linestyle='dotted')
ax[0].tick_params(axis='both', left=False, top=False, right=False, bottom=False, labelleft=False, labeltop=False, labelright=False, labelbottom=False)
ax[0].annotate("(A)", xy=(0.1,0.85), xycoords="axes fraction")

divider = make_axes_locatable(ax[0])
cax = divider.new_vertical(size="5%", pad=0.05, pack_start=True)
fig.add_axes(cax)
fig.colorbar(im, cax=cax, orientation="horizontal", label=u"Precipitation (mm/year)")

# Wind speed

im = ax[1].imshow($(map_wind), cmap = 'jet', vmin=-0.1, vmax=9)

ax[1].grid(linestyle='dotted')
ax[1].tick_params(axis='both', left=False, top=False, right=False, bottom=False, labelleft=False, labeltop=False, labelright=False, labelbottom=False)
ax[1].annotate("(B)", xy=(0.1,0.85), xycoords="axes fraction")

divider = make_axes_locatable(ax[1])
cax = divider.new_vertical(size="5%", pad=0.05, pack_start=True)
fig.add_axes(cax)
fig.colorbar(im, cax=cax, orientation="horizontal", label=u"Wind speed (m/s)")

# Air temperature

im = ax[2].imshow($(map_tair), cmap = 'jet', vmin=-9, vmax=9)

ax[2].grid(linestyle='dotted')
ax[2].tick_params(axis='both', left=False, top=False, right=False, bottom=False, labelleft=False, labeltop=False, labelright=False, labelbottom=False)
ax[2].annotate("(C)", xy=(0.1,0.85), xycoords="axes fraction")

divider = make_axes_locatable(ax[2])
cax = divider.new_vertical(size="5%", pad=0.05, pack_start=True)
fig.add_axes(cax)
fig.colorbar(im, cax=cax, orientation="horizontal", label=u"Air temperature (°C)")

# Save plot

fig.savefig($(file), dpi = 600, bbox_inches='tight')

plt.close()
"""


# Plot standard deviations

df_tmp = by(df_all, :ind_10km, d -> DataFrame(tair_std = std(d[:tair_mean]), wind_std = std(d[:wind_mean]), prec_std = std(d[:prec_mean])))

df_10km = join(df_all, df_tmp, on = :ind_10km)

df_tmp = by(df_all, :ind_50km, d -> DataFrame(tair_std = std(d[:tair_mean]), wind_std = std(d[:wind_mean]), prec_std = std(d[:prec_mean])))

df_50km = join(df_all, df_tmp, on = :ind_50km)

prec_10km = project_results(df_10km, :prec_std)

wind_10km = project_results(df_10km, :wind_std)

tair_10km = project_results(df_10km, :tair_std)

prec_50km = project_results(df_50km, :prec_std)

wind_50km = project_results(df_50km, :wind_std)

tair_50km = project_results(df_50km, :tair_std)

prec_max = maximum(df_50km.prec_std[.!isnan.(df_50km.prec_std)])

wind_max = maximum(df_50km.wind_std[.!isnan.(df_50km.wind_std)])

tair_max = maximum(df_50km.tair_std[.!isnan.(df_50km.tair_std)])

file = joinpath(figpath, "forcings_std.png")

py"""
import matplotlib.pyplot as plt
from mpl_toolkits.axes_grid1 import make_axes_locatable
import numpy as np

fig, ax = plt.subplots(2, 3)

fig.set_size_inches(18, 12)

# Precipitation - 10 km

im = ax[0,0].imshow($(prec_10km), cmap = 'jet', vmin=-0.1, vmax=$(prec_max))

ax[0,0].grid(linestyle='dotted')
ax[0,0].tick_params(axis='both', left=False, top=False, right=False, bottom=False, labelleft=False, labeltop=False, labelright=False, labelbottom=False)
ax[0,0].annotate("(A)", xy=(0.1,0.85), xycoords="axes fraction")

divider = make_axes_locatable(ax[0,0])
cax = divider.new_vertical(size="5%", pad=0.05, pack_start=True)
fig.add_axes(cax)
cb = fig.colorbar(im, cax=cax, orientation="horizontal", label=u"Precipitation (mm/year)")

cb.remove()

# Precipitation - 50 km

im = ax[1,0].imshow($(prec_50km), cmap = 'jet', vmin=-0.1, vmax=$(prec_max))

ax[1,0].grid(linestyle='dotted')
ax[1,0].tick_params(axis='both', left=False, top=False, right=False, bottom=False, labelleft=False, labeltop=False, labelright=False, labelbottom=False)
ax[1,0].annotate("(D)", xy=(0.1,0.85), xycoords="axes fraction")

divider = make_axes_locatable(ax[1,0])
cax = divider.new_vertical(size="5%", pad=0.05, pack_start=True)
fig.add_axes(cax)
fig.colorbar(im, cax=cax, orientation="horizontal", label=u"Precipitation (mm/year)")

# Wind speed - 10 km

im = ax[0,1].imshow($(wind_10km), cmap = 'jet', vmin=-0.1, vmax=$(wind_max))

ax[0,1].grid(linestyle='dotted')
ax[0,1].tick_params(axis='both', left=False, top=False, right=False, bottom=False, labelleft=False, labeltop=False, labelright=False, labelbottom=False)
ax[0,1].annotate("(B)", xy=(0.1,0.85), xycoords="axes fraction")

divider = make_axes_locatable(ax[0,1])
cax = divider.new_vertical(size="5%", pad=0.05, pack_start=True)
fig.add_axes(cax)
cb = fig.colorbar(im, cax=cax, orientation="horizontal", label=u"Wind speed (m/s)")
cb.remove()

# Wind speed - 50 km

im = ax[1,1].imshow($(wind_50km), cmap = 'jet', vmin=-0.1, vmax=$(wind_max))

ax[1,1].grid(linestyle='dotted')
ax[1,1].tick_params(axis='both', left=False, top=False, right=False, bottom=False, labelleft=False, labeltop=False, labelright=False, labelbottom=False)
ax[1,1].annotate("(E)", xy=(0.1,0.85), xycoords="axes fraction")

divider = make_axes_locatable(ax[1,1])
cax = divider.new_vertical(size="5%", pad=0.05, pack_start=True)
fig.add_axes(cax)
fig.colorbar(im, cax=cax, orientation="horizontal", label=u"Wind speed (m/s)")

# Air temperature - 10 km

im = ax[0,2].imshow($(tair_10km), cmap = 'jet', vmin=-0.1, vmax=$(tair_max))

ax[0,2].grid(linestyle='dotted')
ax[0,2].tick_params(axis='both', left=False, top=False, right=False, bottom=False, labelleft=False, labeltop=False, labelright=False, labelbottom=False)
ax[0,2].annotate("(C)", xy=(0.1,0.85), xycoords="axes fraction")

divider = make_axes_locatable(ax[0,2])
cax = divider.new_vertical(size="5%", pad=0.05, pack_start=True)
fig.add_axes(cax)
cb = fig.colorbar(im, cax=cax, orientation="horizontal", label=u"Air temperature (°C)")
cb.remove()

# Air temperature - 50 km

im = ax[1,2].imshow($(tair_50km), cmap = 'jet', vmin=-0.1, vmax=$(tair_max))

ax[1,2].grid(linestyle='dotted')
ax[1,2].tick_params(axis='both', left=False, top=False, right=False, bottom=False, labelleft=False, labeltop=False, labelright=False, labelbottom=False)
ax[1,2].annotate("(F)", xy=(0.1,0.85), xycoords="axes fraction")

divider = make_axes_locatable(ax[1,2])
cax = divider.new_vertical(size="5%", pad=0.05, pack_start=True)
fig.add_axes(cax)
fig.colorbar(im, cax=cax, orientation="horizontal", label=u"Air temperature (°C)")

# Save plot

fig.savefig($(file), dpi = 200, bbox_inches='tight')

plt.close()
"""
