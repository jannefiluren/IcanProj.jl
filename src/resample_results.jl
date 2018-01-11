


"""
Create dataframe with information for linking different scales.
"""
function link_results(file_fine, file_coarse, id_fine, id_coarse)

    # Metadata table
    
    df_meta = readtable(Pkg.dir("IcanProj", "data", "df_links.csv"))
    
    # Fine resolution

    df_fine = DataFrame(id_fine = convert(Array{Int64}, ncread(file_fine, id_fine)),
                        nc_fine = 1:length(ncread(file_fine, id_fine)))

    # Coarse resolution

    df_coarse = DataFrame(id_coarse = convert(Array{Int64}, ncread(file_coarse, id_coarse)),
                          nc_coarse = 1:length(ncread(file_coarse, id_coarse)))

    # Link resolutions
    
    df_links = DataFrame(id_fine = df_meta[Symbol(id_fine)],
                         id_coarse = df_meta[Symbol(id_coarse)],
                         ind_julia = df_meta[:ind_julia])

    df_links = join(df_links, df_fine, on = :id_fine)

    df_links = join(df_links, df_coarse, on = :id_coarse)
    
    # Compute number of fine scale grid cells in coarse grid

    tmp = DataFrame(nc_coarse = df_links[:nc_coarse],
                    n = 1)

    tmp = aggregate(tmp, :nc_coarse, sum)

    df_links = join(df_links, tmp, on = :nc_coarse)

    # Sort results
    
    sort!(df_links, cols = [:id_fine])

    return(df_links)
    
end


"""
Aggregate fine scale results and return together with coarse scale results.
"""
function unify_results(file_fine, file_coarse, df_links, variable)
    
    var_fine = ncread(file_fine, variable)

    var_coarse = ncread(file_coarse, variable)

    var_agg = fill(0.0, size(var_coarse))

    for row in eachrow(df_links)
        var_agg[:, row[:nc_coarse]] += var_fine[:, row[:nc_fine]] / row[:n_sum]
    end

    return var_coarse, var_agg
    
end


"""
Project results to a map using senorge extents.
"""
function project_results(values, df_links)

    map_values = fill(NaN, 1550, 1195)

    map_values[df_links[:ind_julia]] = values[df_links[:nc_coarse]]

    return map_values

end

























#=

using DataFrames
using NetCDF
using IcanProj
using PyPlot
using NveData


function link_resolutions(file_nc, id_desc)

    df_meta = readtable(Pkg.dir("IcanProj", "data", "df_links.csv"))
    
    df_left = DataFrame(ind_nc = 1:length(ncread(file_nc, "dim_space")),
                        id = convert(Array{Int64}, ncread(file_nc, String(id_desc))))

    df_right = DataFrame(id = df_meta[id_desc],
                         ind_julia = df_meta[:ind_julia])

    df = join(df_left, df_right, on=:id)

    return(df)
    
end


function resample_results!(grid, file_nc, timeload, variable, df)
    
    time_nc = ncread(file_nc, "time_str")
    
    itime = find(time_nc .== Dates.format(timeload, "yyyy-mm-dd HH:MM:SS"))[1]

    variable = ncread(file_nc, variable, start = [itime, 1], count = [1,-1])[:]

    for row in eachrow(df)

        grid[row[:ind_julia]] = variable[row[:ind_nc]]

    end

    return nothing
    
end


function resample_results(file_nc, timeload, variable, df)

    grid = fill(NaN, 1550, 1195)
    
    resample_results!(grid, file_nc, timeload, variable, df)

    return(grid)

end

=#






