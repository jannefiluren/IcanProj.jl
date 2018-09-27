using DataFrames
using NetCDF
using IcanProj
using Statistics
using CSV
using ProgressMeter


function write_netcdfs(path, savefolder, res, frac_landuse, lai_landuse, hcan_landuse)

    filename = joinpath(path, savefolder, "params_$(res).nc")

    isfile(filename) && rm(filename, force = true)

    dim_space = collect(1:size(frac_landuse, 1))
    dim_classes = collect(1:size(frac_landuse, 2))

    nccreate(filename, "frac_landuse", "dim_space", dim_space, "dim_classes", dim_classes)
    nccreate(filename, "lai_landuse", "dim_space", dim_space, "dim_classes", dim_classes)
    nccreate(filename, "hcan_landuse", "dim_space", dim_space, "dim_classes", dim_classes)

    ncwrite(frac_landuse, filename, "frac_landuse")
    ncwrite(lai_landuse, filename, "lai_landuse")
    ncwrite(hcan_landuse, filename, "hcan_landuse")

    ncclose(filename)

end


function aggregate_params(path, res, name)

    @info res

    # Metadata from table

    df_landuse = CSV.File(joinpath(dirname(pathof(IcanProj)), "..", "data", "landuse.csv"), rows_for_type_detect = typemax(Int)) |> DataFrame

    # Metadata from input netcdfs

    file_in = joinpath(path, "forcings_st", "tair_$(res).nc")

    # Grid cell indicies in netcdf files

    ind_nc = Int.(ncread(file_in, "id"))

    # Leaf area index and canopy height

    lai = [1.4, 4.3, 6.7, 9.1, 0.9, 2.4, 2.3, 4.4, 0.1, 0.2, 0.3, 0.4, 0]
    hcan = [7.5, 12.3, 16.8, 22, 7.5, 11.6, 17, 17.2, 4.9, 8.4, 12.2, 18.3, 0]

    # Output arrays for forest runs

    landuse_classes = 3

    frac_landuse = Array{Float64}(undef, length(ind_nc), landuse_classes)
    lai_landuse = Array{Float64}(undef, length(ind_nc), landuse_classes)
    hcan_landuse = Array{Float64}(undef, length(ind_nc), landuse_classes)

    @showprogress 1 "Running for ..." for i in eachindex(ind_nc)

        ind_cell = ind_nc[i]

        irows = findall(df_landuse[Symbol(name)] .== ind_cell)

        tmp = colwise(mean, df_landuse[irows, 9:end])
        
        isorted = sortperm(tmp, rev=true)

        ifinal = isorted[1:landuse_classes]
        
        frac_landuse[i, :] = tmp[ifinal] ./ sum(tmp[ifinal])

        lai_landuse[i, :] = lai[ifinal]

        hcan_landuse[i, :] = hcan[ifinal]

    end

    # Save to netcdfs for forest runs

    write_netcdfs(path, "params_forest", res, frac_landuse, lai_landuse, hcan_landuse)

    # Deal with simulations omitting forest processes

    frac_landuse = ones(length(ind_nc), 1)
    lai_landuse = zeros(length(ind_nc), 1)
    hcan_landuse = zeros(length(ind_nc), 1)

    # Save to netcdfs for forest runs

    write_netcdfs(path, "params_open", res, frac_landuse, lai_landuse, hcan_landuse)
    
end


# Settings

path = "/data04/jmg/fsm_simulations/netcdf"

res_name= Dict("1km" => "ind_senorge",
               "5km" => "ind_5km",
               "10km" => "ind_10km",
               "25km" => "ind_25km",
               "50km" => "ind_50km")

for (res, name) in res_name

    aggregate_params(path, res, name)

end



