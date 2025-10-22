# parameters that describe the soil
# store soil hydraulic parameters and provide validation and library

struct SoilParameters
    θsat::Float64
    θres::Float64
    α::Float64
    n::Float64 # m = 1 - 1/n
    Ks::Float64
end

function valid_parameters(p::parameters)
    return (p.θsat > p.θres) && 
            (0 < p.θs <= 0.6) && 
            (0 < p.α <= 1.0) && 
            (1.0 < p.n <= 3.0) && 
            (1e-7 <= p.Ks <= 1e-3)
end

SOIL_LIBRARY = Dict(
    "sand" => parameters(0.41, 0.057, 0.145, 2.68, 1.04e-4),
    "loamy_sand" => parameters(0.39, 0.065, 0.124, 2.28, 3.16e-5),
    "sandy_loam" => parameters(0.41, 0.078, 0.075, 1.89, 1.58e-5),
    "loam" => parameters(0.43, 0.095, 0.036, 1.56, 6.30e-6),
    "silt_loam" => parameters(0.45, 0.134, 0.020, 1.41, 1.99e-6),
    "silty_clay_loam" => parameters(0.46, 0.174, 0.010, 1.31, 4.00e-7),
    "clay_loam" => parameters(0.47, 0.200, 0.009, 1.23, 2.51e-7),
    "silty_clay" => parameters(0.48, 0.210, 0.008, 1.19, 1.58e-7),
    "clay" => parameters(0.50, 0.220, 0.006, 1.09, 1.00e-7)
)