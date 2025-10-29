struct PINNArchitecture 
    name::String
    layers::Vector{Int}
    activation::Function
    batch_size::Int
    loss_weights::NamedTuple{(:pde, :bc, :ic), Tuple{Float64, Float64, Float64}}
    function PINNArchitecture(
        name::String,
        layers::Vector{Int},
        activation::Function,
        batch_size::Int,
        loss_weights::NamedTuple
    )
        @assert length(layers) >= 2 "Must have at least input and output layers"
        @assert layers[1] == 2 "Input layer must be size 2 (z, t)"
        @assert layers[end] == 1 "Output layer must be size 1, moisture"
        @assert batch_size > 0 "Batch size must be positive"
        # @assert all(loss_weights .>= 0) "Loss weights must be non-negative"
        
        new(name, layers, activation, batch_size, loss_weights)
    end
end

function minimal_architecture()
    return PINNArchitecture(
        "minimal",
        [2, 16, 16, 1],
        tanh,
        500,
        (pde=1.0, bc=2.0, ic=2.0)
    )
end

function development_architecture()
    return PINNArchitecture(
        "development",
        [2, 32, 32, 32, 1],
        tanh,
        1500,
        (pde=1.0, bc=2.0, ic=2.0)
    )
end

function get_architecture(profile::Symbol)
    architectures = Dict(
        :minimal => minimal_architecture(),
        :development => development_architecture()
    )
    
    if !haskey(architectures, profile)
        throw(ArgumentError("Unknown profile: $profile. Must be :minimal, :development, or :production"))
    end
    
    return architectures[profile]
end

function setup_pinn_network(architecture::PINNArchitecture)
    chain_layers = []
    for i in 1:(length(architecture.layers)-1)
        if i == length(architecture.layers) - 1 
            push!(chain_layers, Lux.Dense(architecture.layers[i], architecture.layers[i + 1]))
        else
            push!(chain_layers, Lux.Dense(architecture.layers[i], architecture.layers[i + 1], architecture.activation))
        end
    end

    chain = Lux.Chain(chain_layers...)

    discretization = PhysicsInformedNN(
        chain, QuadratureTraining(;
            batch = architecture.batch_size,
            abstol = 1e-5,
            reltol = 1e-5,
        ),
        adaptive_loss = GradientScaleAdaptiveLoss(
            100,
            weight_change_inertia = 0.9,
            pde_loss_weights = architecture.loss_weights.pde,
            bc_loss_weights = architecture.loss_weights.bc,
            additional_loss_weights = architecture.loss_weights.ic
        )
    )
    return discretization
end

function assemble_pde_system(eq, conditions, vars, depth_range, time_span, discretization)
    domains = [
        vars.z ∈ depth_range,
        vars.t ∈ time_span
    ]
    
    @named pde_system = PDESystem(eq, conditions, domains, [vars.z, vars.t], [vars.ψ(vars.z, vars.t)])
    prob = discretize(pde_system, discretization)
    
    return prob
end

# Printing 

function Base.show(io::IO, arch::PINNArchitecture)
    n_hidden = length(arch.layers) - 2
    n_params = sum(arch.layers[i] * arch.layers[i+1] + arch.layers[i+1] for i in 1:(length(arch.layers)-1))
    
    print(io, "PINNArchitecture: $(arch.layers[1])→")
    for i in 2:(length(arch.layers)-1)
        print(io, "$(arch.layers[i])→")
    end
    print(io, "$(arch.layers[end])\n")
    print(io, "  Hidden layers: $n_hidden\n")
    print(io, "  Activation: $(arch.activation)\n")
    print(io, "  Parameters: ~$n_params\n")
    print(io, "  Batch size: $(arch.batch_size)")
end

function assemble_pde_system(equation, all_conditions, symbolic_vars,
                                    problem,
                                    discretization)
    domains = [
        symbolic_vars.z ∈ problem.depth_range,
        symbolic_vars.t ∈ problem.time_span
    ]
    @named pde_system = PDESystem(equation, all_conditions, 
                                    domains, [symbolic_vars.z, symbolic_vars.t], 
                                    symbolic_vars.ψ(symbolic_vars.z, symbolic_vars.t))
    prob = discretize(pde_system, discretization) 
    return prob
end


function wrap_as_moisture_profile(
        trained_result,
        discretization,
        soil_params,
        depth_range,
        time_range
    )
    phi = discretization.phi
    θ_func = (z, t) -> begin
        input = reshape([z, t], (2, 1))
        output = phi(trained_result.u, input)
        return output[1]
    end
    return ContinuousMoistureProfile(θ_func, depth_range, time_range; soil_params=soil_params)
end
