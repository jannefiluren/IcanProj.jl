


using IcanProj
using JLD2
using PyPlot



"""
Plot results over elevation for resolutions 1 to 25km.
"""
function plot_elevation(opt, var_name, ylabel_name, scaling)

    ioff()

    # Loop over watersheds

    for watershed in opt["stat_sel"]

        fig = figure(figsize=(12, 12))

        subplots_adjust(hspace = 0.0)

        data_min, data_max = 0, 0
        elev_min, elev_max = 0, 0

        res_vic = []

        # Loop over resolutions

        i = 1

        for resolution in opt["resolutions"][1:4]

            # Load results

            file = joinpath(opt["eval_folder"], watershed, "res_$(resolution).jld2")

            @load file res_vic

            # Get variables

            if var_name == "total_runoff"
                
                irunoff = find(res_vic.var_names .== "runoff")
                ibaseflow = find(res_vic.var_names .== "baseflow")
                
                data_runoff = res_vic.data_all[:,irunoff[1],:]
                data_baseflow = res_vic.data_all[:,ibaseflow[1],:]

                data_all = data_runoff + data_baseflow

            else

                ivar = find(res_vic.var_names .== var_name)

                data_all = res_vic.data_all[:,ivar[1],:]

            end

            # Average data for each grid
            
            data_mean = mean(data_all,1)[1,:]
            
            # Get range from of variables

            if resolution == "1km"
                data_min = minimum(data_mean)
                data_max = maximum(data_mean)
                elev_min = minimum(res_vic.elev)
                elev_max = maximum(res_vic.elev)
            end

            # Plot data against elevation

            ax = fig[:add_subplot]("41$(i)")

            scatter(data_mean*scaling, res_vic.elev)
            axvline(mean(data_mean)*scaling, color = "red")

            xlabel(ylabel_name)
            ylabel("Elevation (m)")

            ax[:set_xlim]([data_min*scaling, data_max*scaling])
            ax[:set_ylim]([elev_min, elev_max])
            
            if resolution == "1km"
                title(res_vic.name)
            end

            i += 1

        end

        file_name = Pkg.dir("IcanProj", "plots", "elevation_$(var_name)_$(watershed).png")

        rm(file_name, force=true)                       
        savefig(file_name, dpi = 300)

        close(fig)

    end

end



# Get options

opt = get_options()


info("Plot evapotranspiration")

var_name = "evap"
ylabel_name = "Evapotranspiration (mm/year)"
scaling = 365

plot_elevation(opt, var_name, ylabel_name, scaling)


info("Plot precipitation")

var_name = "prec"
ylabel_name = "Precipitation (mm/year)"
scaling = 365

plot_elevation(opt, var_name, ylabel_name, scaling)


info("Plot snow water equivalent")

var_name = "swe"
ylabel_name = "Snow water equivalent (mm)"
scaling = 1

plot_elevation(opt, var_name, ylabel_name, scaling)


info("Plot total runoff")

var_name = "total_runoff"
ylabel_name = "Total runoff (mm/year)"
scaling = 365

plot_elevation(opt, var_name, ylabel_name, scaling)


info("Plot wind speed")

var_name = "wind"
ylabel_name = "Wind speed (m/s)"
scaling = 1

plot_elevation(opt, var_name, ylabel_name, scaling)


info("Plot air temperature")

var_name = "air_temp"
ylabel_name = "Air temperature (C)"
scaling = 1

plot_elevation(opt, var_name, ylabel_name, scaling)


info("Plot rainfall")

var_name = "rainf"
ylabel_name = "Rainfall (mm/year)"
scaling = 365

plot_elevation(opt, var_name, ylabel_name, scaling)


info("Plot snowfall")

var_name = "snowf"
ylabel_name = "Snowfall (mm/year)"
scaling = 365

plot_elevation(opt, var_name, ylabel_name, scaling)


info("Plot potential evapotranspiration")

var_name = "pet_short"
ylabel_name = "PET short crop (mm/year)"
scaling = 365

plot_elevation(opt, var_name, ylabel_name, scaling)
















