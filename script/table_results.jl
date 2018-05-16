using IcanProj
using NetCDF
using DataFrames
using ProgressMeter


function results_table(path)

    df_all = readtable(Pkg.dir("IcanProj", "data", "df_links.csv"))
    
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


path = "/data02/Ican/vic_sim/fsm_past_1km/netcdf/fsm2"

df_all = results_table(path)

file = Pkg.dir("IcanProj", "data", "table_results.txt")

writetable(file, df_all)

