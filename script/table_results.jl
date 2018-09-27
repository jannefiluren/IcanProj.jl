using IcanProj
using NetCDF
using DataFrames
using ProgressMeter
using CSV


function results_table(path)

    df_all = CSV.File(joinpath(dirname(pathof(IcanProj)), "..", "data", "df_links.csv")) |> DataFrame
    
    for variable in ["gsurf", "hatmo", "latmo", "melt", "rnet", "rof", "snowdepth", "swe"], #, "tsoil", "tsurf"],
        spaceres in ["1km", "50km"],
        cfg in 1:32
        
        @show variable, spaceres, cfg

        file = joinpath(path, "results_$(cfg)", "$(variable)_$(spaceres).nc")

        idname = Symbol(ncgetatt(file, "id", "id"))

        dataname = Symbol("$(variable)_cfg$(cfg)_$(spaceres)_mean")

        ids = convert(Array{Int64}, ncread(file, "id"))

        data = ncread(file, variable)

        df_nc = DataFrame()

        df_nc[idname] = ids

        df_nc[dataname] = mean(data, 2)[:]

        df_all = join(df_all, df_nc, on = idname)

        ncclose()

    end

    return df_all

end


path = "/data04/jmg/fsm_simulations/netcdf/fsmres"

df_all = results_table(path)

file = joinpath(dirname(pathof(IcanProj)), "..", "data", "table_results.txt")

df_all |> CSV.write(file)

