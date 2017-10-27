# Run vic for all watersheds and resolutions

using IcanProj

opt = get_options()

path_sim = opt["target_folder"]

watersheds = opt["stat_sel"]

resolutions = opt["resolutions"]

for watershed in watersheds

    resolutions = ["1km", "5km", "10km", "25km", "50km"]

    for resolution in resolutions

        info("Running vic for $(watershed) at $(resolution) resolution")

        run(`/felles/jmg/VIC.4.2.d/src/./vicNl -g $(joinpath(path_sim, watershed, resolution, "params/global_param"))`)

    end

end
