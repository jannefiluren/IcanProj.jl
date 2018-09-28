using IcanProj
using NetCDF
using DataFrames
using ProgressMeter
using Statistics


function forcings_table(path)

    df_all = CSV.File(joinpath(dirname(pathof(IcanProj)), "..", "data", "df_links.csv")) |> DataFrame

    variables = ["ilwr", "iswr", "pres", "rainf", "rhum", "snowf", "tair", "wind"]

    for variable in variables

        @show variable

        file = joinpath(path, "$(variable)_1km.nc")

        idname = Symbol(ncgetatt(file, "dim_space", "id"))

        dataname = Symbol("$(variable)_mean")

        ids = convert(Array{Int64}, ncread(file, "id"))

        ntime = length(ncread(file, "dim_time"))

        nspace = length(ncread(file, "dim_space"))

        dataave = fill(0.0, nspace)
        
        for itime in 1:ntime

            dataave += ncread(file, variable, start = [1,itime], count=[-1,1])/ntime

        end

        df_nc = DataFrame()

        df_nc[idname] = ids

        df_nc[dataname] = dataave[:]

        df_all = join(df_all, df_nc, on = idname)

    end

    return df_all

end


path = "/data02/Ican/vic_sim/fsm_past_1km/netcdf/forcings_st"

df_all = forcings_table(path)

file = joinpath(dirname(pathof(IcanProj)), "..", "data", "forcings_summary.txt")

writetable(file, df_all)

