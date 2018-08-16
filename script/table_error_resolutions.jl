
using IcanProj
using NetCDF
using DataFrames
using CSV


function compute_statistics(var_coarse, var_ref, mask)

    n = size(var_coarse, 2)

    nse = fill(0.0, n)
    r = fill(0.0, n)
    bias = fill(0.0, n)
    
    for i in 1:n

        ikeep = find(mask[:, i])

        if length(ikeep) > 10

            sim = var_coarse[ikeep, i]
            
            ref = var_ref[ikeep, i]

            nse[i] = 1 - var(sim - ref) / var(ref - mean(ref))

            r[i] = cor(sim, ref)

            bias[i] = mean(sim - ref)

        else

            nse[i] = NaN

            r[i] = NaN

            bias[i] = NaN

        end
        
    end

    return nse, r, bias

end


function results_table(path, cfgs, variables, spaceres)

    # Create empty table
    
    file_tmp = joinpath(path, "results_1", "swe_$(spaceres).nc")
    
    idname = Symbol(ncgetatt(file_tmp, "id", "id"))

    ids = convert(Array{Int64}, ncread(file_tmp, "id"))

    df_res = DataFrame()

    df_res[idname] = ids

    for c in cfgs

        println("Running cfg $(c)")
        
        # Mask indicating presence of snow

        file_fine = joinpath(path, "results_$(c)", "swe_1km.nc")

        file_coarse = joinpath(path, "results_$(c)", "swe_$(spaceres).nc")

        df_links = link_results(file_fine, file_coarse)

        swe_coarse, swe_ref = unify_results(file_fine, file_coarse, df_links, "swe")

        mask = (swe_coarse .> 0) .| (swe_ref .> 0)

        # Compute statistics for all variables

        for v in variables

            file_fine = joinpath(path, "results_$(c)", "$(v)_1km.nc")

            file_coarse = joinpath(path, "results_$(c)", "$(v)_$(spaceres).nc")

            var_coarse, var_ref, ngrids = unify_results(file_fine, file_coarse, df_links, v)

            nse, r, bias = compute_statistics(var_coarse, var_ref, mask)

            nse_name = Symbol("nse_$(v)_cfg$(c)")

            r_name = Symbol("r_$(v)_cfg$(c)")

            bias_name = Symbol("bias_$(v)_cfg$(c)")

            df_res[nse_name] = nse

            df_res[r_name] = r

            df_res[bias_name] = bias

            df_res[:ngrids] = ngrids 

        end

    end

    return df_res

end



path = "/data02/Ican/vic_sim/fsm_simulations/netcdf/fsmres"

cfgs = 1:32

variables = ["gsurf", "hatmo", "latmo", "melt", "rnet", "rof", "snowdepth", "swe"]

for spaceres in ["5km", "10km", "25km", "50km"]

    println("Running spaceres $(spaceres)")

    df = results_table(path, cfgs, variables, spaceres)

    filesave = Pkg.dir("IcanProj", "data", "table_errors_$(spaceres).txt")

    CSV.write(filesave, df)

end



