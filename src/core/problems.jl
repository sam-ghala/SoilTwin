"""
    SoilMoistureProblem

Defines a complete soil moisture prediction problem.
# Arguments
- `initial_state::SoilMoistureState` - the initial state of the soil moisture
- `soil_params::SoilParameters` - the soil parameters
- `boundary_conditions::Dict{Symbol,Union{Function,Float64}}` - boundary conditions at top and bottom (:top, :bottom)
- `time_span::Tuple{Float64, Float64}` - simulation time span (start, end) in seconds
- `depth_range::Tuple{Float64, Float64}` - depth range (min, max) in meters
"""
struct SoilMoistureProblem
    initial_state::SoilMoistureState
    soil_params::SoilParameters
    boundary_conditions::BoundaryConditions
    time_span::Tuple{Float64,Float64}
    depth_range::Tuple{Float64,Float64}

    function SoilMoistureProblem(initial_state::SoilMoistureState,
                                    soil_params::SoilParameters; 
                                    top_bc::AbstractBoundaryCondition = ConstantFlux(0.0),
                                    bottom_bc::AbstractBoundaryCondition = FreeDrainage(),
                                    time_span::Tuple{Float64, Float64}=(0.0, 3600.0), 
                                    depth_range::Tuple{Float64, Float64}=(0.0, 1.0))
        bcs = BoundaryConditions(top_bc, bottom_bc)
        if !(time_span[1] < time_span[2])
            throw(ArgumentError("Invalid time_span: start time must be less than end time"))
        end
        if !(initial_state.t == time_span[1])
            throw(ArgumentError("Initial state time must match the start of time_span"))
        end
        return new(initial_state, soil_params, bcs, time_span, depth_range)
    end
end

duration(problem::SoilMoistureProblem) = problem.time_span[2] - problem.time_span[1]

function Base.show(io::IO, prob::SoilMoistureProblem)
    dur = duration(prob) / 3600
    print(io, "SoilMoistureProblem: $(dur) hour simulation\n")
    print(io, "  Soil: $(typeof(prob.soil_params))\n")
    print(io, "  Depth: $(prob.depth_range[1])m to $(prob.depth_range[2])m\n")
    print(io, "  Time: $(prob.time_span[1])s to $(prob.time_span[2])s")
end