
#using JLD2
#using IcanProj
#using PyPlot



"""
Plot elevation range against different spatial resolutions.
"""
function analysis_elevation()

    @load Pkg.dir("IcanProj", "data", "wsh_info.jld2") wsh_info

    # Watersheds and resolutions

    resolutions = ["1km", "5km", "10km", "25km", "50km"]

    watersheds = [x.name for x in wsh_info]

    # Compute elevation range for each watershed and resolution

    elev_range = zeros(length(resolutions), length(watersheds))
    elev_std = zeros(length(resolutions), length(watersheds))

    j = 1

    for wsh_single in wsh_info

        i = 1

        for resolution in resolutions
            
            elev_mean = []

            iboxes = getfield(wsh_single, Symbol("ind_$(resolution)"))

            for ibox in unique(iboxes)
                
                push!(elev_mean, mean(wsh_single.elev[iboxes .== ibox]))

            end

            elev_range[i, j] = maximum(elev_mean) - minimum(elev_mean)
            
            elev_std[i, j] = length(elev_mean) > 1 ? std(convert(Array{Float64,1}, elev_mean)) : 0
            
            i += 1

        end

        j += 1

    end

    # Plot results for elevation range

    ioff()

    fig = plt[:figure](figsize = (8, 6))

    for icol in 1:size(elev_range, 2)

        plt[:plot](elev_range[:,icol], label = watersheds[icol])

    end

    plt[:xlabel]("Spatial resolution")
    plt[:ylabel]("Elevation range (m)")
    plt[:xticks](collect(0:length(resolutions)-1), resolutions)
    plt[:legend]()

    file_name = joinpath(Pkg.dir("IcanProj", "plots", "elev_range.png"))

    rm(file_name, force=true)                       
    savefig(file_name, dpi = 300)

    close(fig)

    # Plot results for elevation std

    fig = plt[:figure](figsize = (8, 6))

    for icol in 1:size(elev_std, 2)

        plt[:plot](elev_std[:,icol], label = watersheds[icol])

    end

    plt[:xlabel]("Spatial resolution")
    plt[:ylabel]("Elevation range (m)")
    plt[:xticks](collect(0:length(resolutions)-1), resolutions)
    plt[:legend]()

    file_name = joinpath(Pkg.dir("IcanProj", "plots", "elev_std.png"))

    rm(file_name, force=true)                       
    savefig(file_name, dpi = 300)

    close(fig)

end
