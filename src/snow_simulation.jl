



using DataFrames
using NveData
using IcanProj


# Load digital elevation data

file = joinpath(Pkg.dir("NveData"), "raw/elevation.asc")

dem = read_esri_raster(file)

elev = dem["data"]

# Senorge info

senorge_ind, xcoord, ycoord = senorge_info()

# Grid indicies for coarse scale simulation

res = 50

nrow, ncol = size(senorge_ind)

boxes_ind = resolution_ind(res, nrow, ncol)

# Extract boxes with complete data

data_all = [boxes_ind[:] senorge_ind[:] elev[:]]

data_valid = []

for ibox in 1:maximum(data_all[:,1])

    isel = data_all[:,1] .== ibox

    data_tmp = data_all[isel,:]

    if !any(data_tmp[:,2:3].==-9999)
        data_valid = [data_valid; data_tmp]
    end

end


# Load soil parameter file





# Loop data for one grid box




















