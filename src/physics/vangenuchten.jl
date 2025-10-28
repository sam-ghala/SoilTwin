function ψ_to_θ(ψ_val, soil_params::SoilParameters = SoilParameters(0.43, 0.078, 3.6, 1.56, 2.89e-6))
    θs = soil_params.θsat
    θr = soil_params.θres
    α = soil_params.α
    n = soil_params.n
    m = 1 - 1/n
    if ψ_val >= 0
        return θs
    else
        θe = (1 + (α * abs(ψ_val))^n)^(-m)
        return θr + (θs - θr) * θe
    end
end

function θ_to_ψ(θ_val, soil_params::SoilParameters = SoilParameters(0.43, 0.078, 3.6, 1.56, 2.89e-6))
    θs = soil_params.θsat
    θr = soil_params.θres
    α = soil_params.α
    n = soil_params.n
    m = 1 - 1/n
    θe = clamp((θ_val - θr) / (θs - θr), 0.001, 0.999)
    if θe >= 0.999
        return -0.001
    else
        return -(1/α) * ((θe^(-1/m) - 1)^(1/n))
    end
end