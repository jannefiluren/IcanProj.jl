
using IcanProj
using JLD2
using PyPlot





"""
Plot analysis using Budyko kind of equations.
"""
function plot_budyko(opt, watershed)


    # Various equations to compute aet from prec and pet

    schreiber(pet_div_p) = 1 - exp(-pet_div_p)

    pike(pet_div_p) = 1 / sqrt(1 + (1/pet_div_p)^2)

    budyko(pet_div_p) = sqrt(pet_div_p * (1 - exp(-pet_div_p)) * tanh(1/pet_div_p))

    zhang(pet_div_p, w) = (1 + w*pet_div_p) / (1 + w*pet_div_p + 1/pet_div_p)


    # Load results

    file = joinpath(opt["eval_folder"], watershed, "res_1km.jld2")

    @load file res_vic


    # Get precipitation and potential evapotranspiration

    ivar = find(res_vic.var_names .== "prec")

    data_prec = res_vic.data_all[2:end,ivar[1],:]

    ivar = find(res_vic.var_names .== "pet_short")

    data_pet = res_vic.data_all[2:end,ivar[1],:]


    ivar = find(res_vic.var_names .== "evap")

    data_aet = res_vic.data_all[2:end,ivar[1],:]



    # Compute yearly average prec and pet for each gridcell

    mean_prec = 365 * mean(data_prec, 1)

    mean_pet = 365 * mean(data_pet, 1)

    mean_aet = 365 * mean(data_aet, 1)

    pet_div_p = mean_pet./mean_prec

    aet_div_p = mean_aet./mean_prec



    # Compute error in aet estimates by using the mean of the function or
    # the function of the mean

    zhang(x) = zhang(x, 0.3)

    aet_mean_func = []
    aet_func_mean = []

    for f in [schreiber, pike, budyko, zhang]

        push!(aet_mean_func, mean(f.(pet_div_p) .* mean_prec ))
        push!(aet_func_mean, f(mean(pet_div_p)) * mean(mean_prec))

    end


    # The error should be positive

    error_aet = aet_func_mean - aet_mean_func

    error_min = round(minimum(error_aet), 1)
    error_max = round(maximum(error_aet), 1)


    # Plot results

    ioff()

    fig = figure(figsize=(7, 5))

    ax = fig[:add_subplot](111)

    x_values = collect(0.001:0.001:2)

    plot(x_values, schreiber.(x_values), label = "schreiber")
    plot(x_values, pike.(x_values), label = "pike")
    plot(x_values, budyko.(x_values), label = "budyko")
    plot(x_values, zhang.(x_values, 0.3), label = "zhang (w = 0.3)")

    scatter(pet_div_p, aet_div_p)
    
    min_ratio = minimum(pet_div_p)
    max_ratio = maximum(pet_div_p)

    axvspan(min_ratio, max_ratio, alpha=0.5, color="gray", label = "Spread in observed\nconditions")

    error_str = "Min error = $(error_min) mm/year\nMax error = $(error_max) mm/year"

    ax[:text](0.6, 0.5, error_str, transform=ax[:transAxes])

    xlabel("PET / P")
    ylabel("ET / P")
    title(res_vic.name)
    legend()

    file_name = Pkg.dir("IcanProj", "plots", "budyko_$(watershed).png")

    rm(file_name, force=true)                       
    savefig(file_name, dpi = 300)

    close(fig)

end



# Get options

opt = get_options()

for watershed in opt["stat_sel"]

    plot_budyko(opt, watershed)

end
