"""
Data container for collecting vic results.
"""
struct VicRes
    name::String
    regine_main::String
    lat::Array{Float64,1}
    lon::Array{Float64,1}
    gridcel::Array{Int64,1}
    elev::Array{Float64,1}
    data_all::Array{Float64,3}
    data_mean::Array{Float64,2}
    var_names::Array{String,1}
    time::Array{DateTime,1}
end


"""
Data container for collecting vic inputs.
"""
struct VicInput
    name::String
    regine_main::String
    lat::Array{Float64,1}
    lon::Array{Float64,1}
    gridcel::Array{Int64,1}
    elev::Array{Float64,1}
    data_all::Array{Float64,3}
    data_mean::Array{Float64,2}
    var_names::Array{String,1}
    time::Array{DateTime,1}
end


"""
Struct with metadata for watersheds.
"""
struct WatershedData

    name::String
    regine_main::String
    dbk::Float64
    xrange::UnitRange{Int64}
    yrange::UnitRange{Int64}
    gridcel::Array{Int64,2}
    ind_1km::Array{Int64,2}
    ind_5km::Array{Int64,2}
    ind_10km::Array{Int64,2}
    ind_25km::Array{Int64,2}
    ind_50km::Array{Int64,2}
    elev::Array{Float64,2}

end
