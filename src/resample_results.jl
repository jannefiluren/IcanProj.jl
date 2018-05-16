

function link_table(file::String)

    id = Symbol(ncgetatt(file, "dim_space", "id"))
    
    df_links = readtable(Pkg.dir("IcanProj", "data", "df_links.csv"))

    eval(:(df_nc = DataFrame($(id) = convert(Array{Int64}, ncread($(file), "id")),
                             nc = 1:length(ncread($(file), "id")))))

    df_final = join(df_links, df_nc, on = id)

    return df_final

end





function link_table(path::String, variable::String, space_res::String)

    file = get_filename(path, variable, space_res, 1)

    id = Symbol(ncgetatt(file, "id", "id"))

    df_links = readtable(Pkg.dir("IcanProj", "data", "df_links.csv"))

    eval(:(df_nc = DataFrame($(id) = convert(Array{Int64}, ncread($(file), "id")),
                             nc = 1:length(ncread($(file), "id")))))

    df_final = join(df_links, df_nc, on = id)

    return df_final

end


function link_results(file_fine::String, file_coarse::String) #, id_fine, id_coarse)

    # Metadata table
    
    df_meta = readtable(Pkg.dir("IcanProj", "data", "df_links.csv"))

    # Get attributes

    id_fine = ncgetatt(file_fine, "id", "id")

    if typeof(id_fine) == Void
        id_fine = ncgetatt(file_fine, "dim_space", "id")
    end

    id_coarse = ncgetatt(file_coarse, "id", "id")

    if typeof(id_coarse) == Void
        id_coarse = ncgetatt(file_coarse, "dim_space", "id")
    end

    # Fine resolution

    df_fine = DataFrame(id_fine = convert(Array{Int64}, ncread(file_fine, "id")),
                        nc_fine = 1:length(ncread(file_fine, "id")))

    # Coarse resolution

    df_coarse = DataFrame(id_coarse = convert(Array{Int64}, ncread(file_coarse, "id")),
                          nc_coarse = 1:length(ncread(file_coarse, "id")))

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

    dim_space = ncread(file_fine, "id")

    if size(var_fine, 2) != length(dim_space)
        var_fine = var_fine'
    end
    
    var_coarse = ncread(file_coarse, variable)

    dim_space = ncread(file_coarse, "id")

    if size(var_coarse, 2) != length(dim_space)
        var_coarse = var_coarse'
    end

    var_agg = fill(0.0, size(var_coarse))

    ngrids = fill(0.0, size(var_coarse, 2))

    for row in eachrow(df_links)
        
        var_agg[:, row[:nc_coarse]] += var_fine[:, row[:nc_fine]] / row[:n_sum]

        ngrids[row[:nc_coarse]] += 1 

    end

    ncclose()
    
    return var_coarse, var_agg, ngrids
    
end


"""
Project results to a map using senorge extents.
"""
function project_results(values, df_links, on = :nc_coarse)

    map_values = fill(NaN, 1550, 1195)

    map_values[df_links[:ind_julia]] = values[df_links[on]]

    return map_values

end
























