# parameters that describe the soil
# store soil hydraulic parameters and provide validation and library
"""
    SoilParameters(θsat::Float64, θres::Float64, α::Float64, n::Float64, Ks::Float64)
A struct to hold soil hydraulic parameters based on the van Genuchten model.
# Arguments
- `θsat::Float64` - saturated volumetric water content (m³/m³)
- `θres::Float64` - residual volumetric water content (m³/m³)
- `α::Float64` - van Genuchten parameter (1/m)
- `n::Float64` - van Genuchten parameter (dimensionless, n > 1)
- `Ks::Float64` - saturated hydraulic conductivity (m/s)
"""
struct SoilParameters
    name::String
    θsat::Float64
    θres::Float64
    α::Float64
    n::Float64 # m = 1 - 1/n
    Ks::Float64
    function SoilParameters(name::String, θsat::Float64, θres::Float64, α::Float64, n::Float64, Ks::Float64)
        p = new(name,θsat, θres, α, n, Ks)

        if !(p.θsat > p.θres)
            error("Invalid SoilParameters: θsat must be greater than θres (got $(p.θsat) ≤ $(p.θres))")
        elseif !(0 < p.θsat <= 0.6)
            error("Invalid SoilParameters: θsat must be in (0, 0.6], got $(p.θsat)")
        elseif !(0 < p.α <= 15.0)
            error("Invalid SoilParameters: α must be in (0, 15.0], got $(p.α)")
        elseif !(1.0 < p.n <= 3.0)
            error("Invalid SoilParameters: n must be in (1.0, 3.0], got $(p.n)")
        elseif !(0 <= p.Ks)
            error("Invalid SoilParameters: Ks must be positive, got $(p.Ks)")
        end
        return p
    end
end

SOIL_LIBRARY = Dict(
    "sand" => SoilParameters("sand",0.43, 0.045, 14.5, 2.68, 8.25e-5),
    "loamy_sand" => SoilParameters("loamy_sand",0.41, 0.057, 12.4, 2.28, 4.05e-5),
    "sandy_loam" => SoilParameters("sandy_loam",0.41, 0.065, 7.5, 1.89, 1.23e-5),
    "loam" => SoilParameters("loam",0.43, 0.078, 3.6, 1.56, 2.89e-6),
    "silt_loam" => SoilParameters("silt_loam",0.45, 0.067, 2.0, 1.41, 1.25e-6),
    "silty_clay_loam" => SoilParameters("silty_clay_loam",0.48, 0.089, 1.0, 1.23, 6.94e-7),
    "clay_loam" => SoilParameters("clay_loam",0.46, 0.095, 1.9, 1.31, 2.88e-7),
    "silty_clay" => SoilParameters("silty_clay",0.48, 0.070, 0.5, 1.09, 4.17e-8),
    "clay" => SoilParameters("clay",0.38, 0.068, 0.8, 1.09, 5.56e-9)
)