using IcanProj
using NetCDF
using NveData
using PyPlot
using DataFrames
using CSV


function resolution_ind(res, nrow, ncol)
    @assert 50%res==0
    ind = fill(-9999, nrow, ncol)
    nrow = nrow-nrow%res-res+1
    ncol = ncol-ncol%res-res+1
    counter = 1
    for irow = 1:res:nrow, icol = 1:res:ncol
        ind[irow:irow+res-1, icol:icol+res-1] .= counter
        counter += 1
    end
    return ind
end




# Settings

path = "/data04/jmg/fsm_simulations"

# Load soil parameters

soil_param = read_soil_params(path)

# Get information about senorge extent

ind_senorge, xcoord, ycoord = senorge_info()

# Get julia indices

ind_julia = reshape(collect(1:length(ind_senorge[:])), size(ind_senorge))

# Generate indices for coarser grid resolutions

ind_5km = resolution_ind(5, size(ind_senorge,1), size(ind_senorge,2))

ind_10km = resolution_ind(10, size(ind_senorge,1), size(ind_senorge,2))

ind_25km = resolution_ind(25, size(ind_senorge,1), size(ind_senorge,2))

ind_50km = resolution_ind(50, size(ind_senorge,1), size(ind_senorge,2))

ind_5km = convert(Array{Any}, ind_5km)

ind_10km = convert(Array{Any}, ind_10km)

ind_25km = convert(Array{Any}, ind_25km)

ind_50km = convert(Array{Any}, ind_50km)

ind_5km[ind_5km .< 0] .= missing

ind_10km[ind_10km .< 0] .= missing

ind_25km[ind_25km .< 0] .= missing

ind_50km[ind_50km .< 0] .= missing

# Data frame from soil parameters

df_left = DataFrame(ind_senorge = soil_param[:gridcel],
                    lon = soil_param[:lon],
                    lat = soil_param[:lat],
                    elev =soil_param[:elev])

df_right = DataFrame(ind_senorge = ind_senorge[:],
                     xcoord = xcoord[:],
                     ycoord = ycoord[:],
                     ind_julia = ind_julia[:],
                     ind_5km = ind_5km[:],
                     ind_10km = ind_10km[:],
                     ind_25km = ind_25km[:],
                     ind_50km = ind_50km[:])

# Join dataframes

df_links = join(df_left, df_right, on=:ind_senorge)

# Remove missing values

dropmissing!(df_links)

# Convert columns back to integers

df_links[:ind_senorge] = convert(Array{Int64}, df_links[:ind_senorge])

df_links[:ind_5km] = convert(Array{Int64}, df_links[:ind_5km])

df_links[:ind_10km] = convert(Array{Int64}, df_links[:ind_10km])

df_links[:ind_25km] = convert(Array{Int64}, df_links[:ind_25km])

df_links[:ind_50km] = convert(Array{Int64}, df_links[:ind_50km])

# Save to file

file = joinpath(dirname(pathof(IcanProj)), "..", "data", "df_links.csv")

#writetable(file, df_links)

df_links |> CSV.write(file)




#=

# Do some checks


# Some histograms

grid_ids = df_links[:ind_10km]

ngrids = [length(find(grid_ids .== i)) for i in unique(grid_ids)]

plt[:hist](ngrids,10)


# Some maps

imap = df_links[:ind_julia]

tmp = fill(NaN, size(ind_senorge))

tmp[imap] = df_links[:ind_25km]

PyPlot.imshow(tmp)

=#
