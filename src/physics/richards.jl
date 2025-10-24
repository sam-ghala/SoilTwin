function setup_richards_equation(problem::SoilMoistureProblem)
    θsat, θres, α, n, Ks = problem.soil_params.θsat, problem.soil_params.θres, problem.soil_params.α, problem.soil_params.n, problem.soil_params.Ks
    m = 1 - 1/n
    duration = problem.time_span[2] - problem.time_span[1]
    @parameters z t
    @variables ψ(..)
    Dz = Differential(z)
    Dt = Differential(t)
    # Richards Equation in Pressure form
    ψ_actual = -exp(ψ(z,t))
    h_pos = -ψ_actual
    Se_vg = (1 + (α * h_pos)^n)^(-m)
    Se = 0.01 + 0.98 * Se_vg
    Se_1m = Se^(1/m)
    K_ψ = Ks * sqrt(Se) * (1 - (1 - Se_1m)^m)^2
    C_base = (θsat - θres) * α * n * m * (α * h_pos)^(n-1) * (1 + (α * h_pos)^n)^(-m-1)
    C_min = 1e-9 # 5
    C_ψ = C_base + C_min

    eq = (1/duration) * C_ψ * (-exp(ψ(z,t))) * Dt(ψ(z,t)) ~ Dz(K_ψ * (-exp(ψ(z,t)) * Dz(ψ(z,t)) + 1.0))
    
    return eq, (z=z, t=t, ψ=ψ, Dz=Dz, Dt=Dt)
end
