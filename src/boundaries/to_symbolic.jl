function to_symbolic(bc::AbstractBoundaryCondition, problem, vars, location)
    error("to_symbolic not implemented for boundary condition type $(typeof(bc))")
end

# top boundary symbolic conversion for constant flux
function to_symbolic(bc::ConstantFlux, problem, vars, location)
    @assert location == TOP_BOUNDARY
    
    t_bc = range(problem.time_span..., length=10)
    expressions = []
    
    θ_init = problem.initial_state.profile(problem.depth_range[1], problem.time_span[1])
    duration_val = duration(problem)
    
    for ti in t_bc
        progress = (ti - problem.time_span[1]) / duration_val
        Δθ = (bc.flux * duration_val) / (problem.depth_range[2] - problem.depth_range[1])
        θ_surface = θ_init + Δθ * progress
        θ_surface = clamp(θ_surface, problem.soil_params.θres + 0.001, problem.soil_params.θsat - 0.001)
        
        ψ_surface = θ_to_ψ(θ_surface, problem.soil_params)
        push!(expressions, vars.ψ(problem.depth_range[1], ti) ~ ψ_surface)
    end
    
    return expressions
end

# bottom boundary symbolic conversion for free drainage
function to_symbolic(bc::FreeDrainage, problem, vars, location)
    @assert location == BOTTOM_BOUNDARY
    
    t_bc = range(problem.time_span..., length=10)
    expressions = []
    
    θ_bottom = problem.initial_state.profile(problem.depth_range[2], problem.time_span[1])
    ψ_bottom = θ_to_ψ(θ_bottom, problem.soil_params)
    
    for ti in t_bc
        push!(expressions, vars.ψ(problem.depth_range[2], ti) ~ ψ_bottom)
    end
    
    return expressions
end

function setup_initial_conditions(problem, vars)
    z_ic = range(problem.depth_range[1], problem.depth_range[2], length=20)
    ic_expressions = []
    
    for zi in z_ic
        θ_init = problem.initial_state.profile(zi, problem.time_span[1])
        ψ_init = θ_to_ψ(θ_init, problem.soil_params)
        push!(ic_expressions, vars.ψ(zi, problem.time_span[1]) ~ ψ_init)
    end
    
    return ic_expressions
end

function to_symbolic(bc::DryingSurface, problem, vars, location)
    @assert location == TOP_BOUNDARY "DryingSurface only valid at top boundary"
    t_bc = range(problem.time_span[1], problem.time_span[2], length=10)
    expressions = []
    duration_val = duration(problem)
    
    for ti in t_bc
        progress = (ti - problem.time_span[1]) / duration_val
        θ_surface = bc.initial_moisture - bc.drying_rate * progress
        θ_surface = clamp(
            θ_surface, 
            problem.soil_params.θres + 0.001, 
            problem.soil_params.θsat - 0.001
        )
        ψ_surface = θ_to_ψ(θ_surface, problem.soil_params)
        push!(expressions, vars.ψ(problem.depth_range[1], ti) ~ ψ_surface)
    end
    
    return expressions
end

function to_symbolic(bc::FixedMoisture, problem, vars, location)
    t_bc = range(problem.time_span[1], problem.time_span[2], length=10)
    expressions = []
    ψ_fixed = θ_to_ψ(bc.moisture, problem.soil_params)
    z_boundary = location == TOP_BOUNDARY ? problem.depth_range[1] : problem.depth_range[2]
    
    for ti in t_bc
        push!(expressions, vars.ψ(z_boundary, ti) ~ ψ_fixed)
    end
    
    return expressions
end