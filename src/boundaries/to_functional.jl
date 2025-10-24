function to_flux_function(bc::AbstractBoundaryCondition, problem, location)
    error("to_flux_function not implemented for $(typeof(bc))")
end

function to_flux_function(bc::ConstantFlux, problem, location)
    return (t, θ_boundary) -> bc.flux
end

function to_flux_function(bc::FreeDrainage, problem, location)
    return function(t, θ_boundary)
        # Free drainage -> q = -K(θ)
        K = hydraulic_conductivity(θ_boundary, problem.soil_params)
        return -K
    end
end