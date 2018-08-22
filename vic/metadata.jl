



"""
Load metadata for selected stations.
"""
function load_metadata(stat_sel)

    file = joinpath(dirname(pathof(IcanProj)), "..", "data", "stations_metadata.xlsx")

    df_all = readxlsheet(DataFrame ,file, "Ark1")

    df_all[:regine_main] = string.(convert.(Int, df_all[:regine_area])) .* "." .* string.(convert.(Int, df_all[:main_no]))

    df_sel = @from i in df_all begin
        @where i.regine_main in stat_sel
        @select i
        @collect DataFrame
    end

    return df_sel

end


"""
Print nice table with metadata.
"""
function clean_metadata(df_sel)

    df_nice = @from i in df_sel begin
        @select {i.regine_main, i.station_name, i.area_total, i.utm_east_z33, i.utm_north_z33, i.perc_agricul,
                 i.perc_bog, i.perc_forest, i.perc_glacier, i.perc_lake, i.perc_mountain, i.perc_urban,
                 i.height_minimum, i.height_maximum}
        @collect DataFrame
    end

    return df_nice

end


"""
Compute indicies for different resolutions.
"""
function resolution_ind(res)
    @assert 50%res == 0
    ind = zeros(Int, 50, 50)
    counter = 1
    for irow = 1:res:50, icol = 1:res:50
        ind[irow:irow+res-1, icol:icol+res-1] = counter
        counter += 1
    end
    return ind
end

function resolution_ind(res, nrow, ncol)
    @assert 50%res==0
    ind = fill(-9999, nrow, ncol)
    nrow = nrow-nrow%res-res+1
    ncol = ncol-ncol%res-res+1
    counter = 1
    for irow = 1:res:nrow, icol = 1:res:ncol
        ind[irow:irow+res-1, icol:icol+res-1] = counter
        counter += 1
    end
    return ind
end


"""
Collect metadata for selected watershed.
"""
function get_watershed_data(df_sel)

    # Get digital elevation data

    file = joinpath(dirname(pathof(IcanProj)), "..", "raw/elevation.asc")
    
    dem = read_esri_raster(file)

    elev = dem["data"]
    
    # Get information about senorge extent

    ind_senorge, xcoord, ycoord = senorge_info()

    # Get information about gridcells with valid input data

    joinpath(dirname(pathof(IcanProj)), "..", "data", "InnenforNorge_20170516.txt")

    tmp = readdlm(Pkg.dir("IcanProj", "data", "InnenforNorge_20170516.txt"), ';'; header=true)

    has_metdata = convert.(Int64, tmp[1][:,2]) + 1

    valid_cells = fill(false, size(elev))
    valid_cells = similar(elev, Bool)    
    valid_cells[findin(ind_senorge, has_metdata)] = true

    # Catchment information
    
    dbk_ind = read_dbk_ind()

    # Indices for different resolutions

    ind_1km  = resolution_ind(1)
    ind_5km  = resolution_ind(5)
    ind_10km = resolution_ind(10)
    ind_25km = resolution_ind(25)
    ind_50km = resolution_ind(50)

    # Loop over stations

    wsh_info = WatershedData[]
    
    for row in eachrow(df_sel)

        # Basic metadata

        name = row[:station_name]
        regine_main = row[:regine_main]
        dbk = row[:drainage_basin_key][1]

        # Find a grid box around the watershed with valid cells
    
        wsh_ind = dbk_ind[dbk]
    
        xcoord_center = mean(xcoord[findin(ind_senorge, wsh_ind)])
        ycoord_center = mean(ycoord[findin(ind_senorge, wsh_ind)])
    
        dist = sqrt.((xcoord - xcoord_center).^2 + (ycoord - ycoord_center).^2)
        
        xmin_ind, ymin_ind = findn(dist .== minimum(dist))
        
        xmin_ind, ymin_ind = xmin_ind[1], ymin_ind[1]
        
        shift_vec = [0 -1 1 -2 2 -3 3 -4 4 -5 5 -6 6 -7 7 -8 8 -9 9 -10 10 -11 11 -12 12 -13 13 -14 14]
    
        xrange, yrange = [], []
        
        for xshift = shift_vec, yshift = shift_vec
            
            xrange = (xmin_ind-25+xshift):(xmin_ind+24+xshift)
            yrange = (ymin_ind-25+yshift):(ymin_ind+24+yshift)
    
            if sum(valid_cells[xrange, yrange]) == 2500
                break
            end
    
        end

        println("Number valid cells for $(name)/$(regine_main): $(sum(valid_cells[xrange, yrange]))")
        println("Percentage glacier for $(name)/$(regine_main): $(round(row[:perc_glacier], 2))")

        # Save data if enough input data is available
        
        if sum(valid_cells[xrange, yrange]) == 2500

            println("Saved $(name)/$(regine_main)")
            
            wsh_tmp = WatershedData(
                name,
                regine_main,
                dbk,
                xrange,
                yrange,
                ind_senorge[xrange, yrange] - 1,
                ind_1km,
                ind_5km,
                ind_10km,
                ind_25km,
                ind_50km,
                elev[xrange, yrange]
            )

            push!(wsh_info, wsh_tmp)

        else

            println("Skipped $(name)/$(regine_main): not enough input data")

        end
        
    end

    return wsh_info

end


"""
Link drainage basin key to watershed name.
"""
function get_wsh_name(wsh_info)

    wsh_name = Dict()

    for wsh_one in wsh_info

        name = wsh_one.name
        regine_main = wsh_one.regine_main

        wsh_name[regine_main] = name

    end

    return wsh_name

end
