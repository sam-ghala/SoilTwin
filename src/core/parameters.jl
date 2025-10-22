using SoilTwin
# parameters that describe the soil
# store soil hydraulic parameters and provide validation and library

struct SoilParameters
    θsat::Float64
    θres::Float64
    α::Float64
    n::Float64 # m = 1 - 1/n
    Ks::Float64
    function SoilParameters(θsat::Float64, θres::Float64, α::Float64, n::Float64, Ks::Float64)
        p = new(θsat, θres, α, n, Ks)

        if !(p.θsat > p.θres)
            error("Invalid SoilParameters: θsat must be greater than θres (got $(p.θsat) ≤ $(p.θres))")
        elseif !(0 < p.θsat <= 0.6)
            error("Invalid SoilParameters: θsat must be in (0, 0.6], got $(p.θsat)")
        elseif !(0 < p.α <= 1.0)
            error("Invalid SoilParameters: α must be in (0, 1.0], got $(p.α)")
        elseif !(1.0 < p.n <= 3.0)
            error("Invalid SoilParameters: n must be in (1.0, 3.0], got $(p.n)")
        elseif !(1e-7 <= p.Ks <= 1e-3)
            error("Invalid SoilParameters: Ks must be between 1e-7 and 1e-3, got $(p.Ks)")
        end
        return p
    end
end

SOIL_LIBRARY = Dict(
    "sand" => SoilParameters(0.41, 0.057, 0.145, 2.68, 1.04e-4),
    "loamy_sand" => SoilParameters(0.39, 0.065, 0.124, 2.28, 3.16e-5),
    "sandy_loam" => SoilParameters(0.41, 0.078, 0.075, 1.89, 1.58e-5),
    "loam" => SoilParameters(0.43, 0.095, 0.036, 1.56, 6.30e-6),
    "silt_loam" => SoilParameters(0.45, 0.134, 0.020, 1.41, 1.99e-6),
    "silty_clay_loam" => SoilParameters(0.46, 0.174, 0.010, 1.31, 4.00e-7),
    "clay_loam" => SoilParameters(0.47, 0.200, 0.009, 1.23, 2.51e-7),
    "silty_clay" => SoilParameters(0.48, 0.210, 0.008, 1.19, 1.58e-7),
    "clay" => SoilParameters(0.50, 0.220, 0.006, 1.09, 1.00e-7)
)