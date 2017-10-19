# Run vic for all watersheds and resolutions

path_sim = "/data02/Ican/vic_sim/jan_past"

wsh_names = readdir(path_sim)

for wsh_name in wsh_names

    resolutions = readdir(joinpath(path_sim, wsh_name))

    for resolution in resolutions

        info("Running vic for $(wsh_name) at $(resolution) resolution")

        run(`/felles/jmg/VIC.4.2.d/src/./vicNl -g $(joinpath(path_sim, wsh_name, resolution, "params/global_param"))`)

    end

end