
using DataFrames
using JLD2
using Base.Test

opt = get_options()

info("Load metadata from excel table stations_metadata.xlsx")

df_sel = load_metadata(opt["stat_sel"])

info("Clean the metadata table and save to stat_selected.csv")

df_nice = clean_metadata(df_sel)

writetable(Pkg.dir("IcanProj", "data", "stat_selected.csv"), df_nice)

info("Get data and save in WatershedData struct to wsh_info.jld2")

wsh_info = get_watershed_data(df_sel)

@save Pkg.dir("IcanProj", "data", "wsh_info.jld2") wsh_info

# Run some basic tests on wsh_info

for wsh_single in wsh_info

    @show wsh_single.name
    
    @test all(wsh_single.elev .>= 0)
    @test all(wsh_single.elev .<= 3000)
    @test size(wsh_single.gridcel) == (50, 50)

end
