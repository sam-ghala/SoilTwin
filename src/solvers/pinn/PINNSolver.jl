struct PINNSolver <: AbstractSoilMoistureSolver
    architecture::PINNArchitecture
    max_iters::Int
    transfer_from::Union{Nothing,String} # path
    save_model::Bool
    save_path::Union{Nothing,String} # path

    function PINNSolver(; profile::Symbol = :development,
                        max_iters::Int = 400,
                        transfer_from::Union{Nothing,String} = nothing,
                        save_model::Bool = false,
                        save_path::Union{Nothing,String} = nothing
    )
        if save_model && save_path === nothing
            throw(ArgumentError("save_path must be provided if save_model is true"))
        end
        architecture = get_architecture(profile)
        return new(architecture, max_iters, transfer_from, save_model, save_path)
    end
    # custom architecture constructor
    function PINNSolver(architecture::PINNArchitecture;
                        max_iters::Int = 400,
                        transfer_from::Union{Nothing,String} = nothing,
                        save_model::Bool = false,
                        save_path::Union{Nothing,String} = nothing
    )
        if save_model && save_path === nothing
            throw(ArgumentError("save_path must be provided if save_model is true"))    
        end
        return new(architecture, max_iters, transfer_from, save_model, save_path)
    end
end

function solve(problem::SoilMoistureProblem, solver::PINNSolver)
    equation, symbolic_vars = setup_richards_equation(problem) # returns eq correctly
    # next 
    top_symbolic = to_symbolic(problem.boundary_conditions.top, problem, symbolic_vars, TOP_BOUNDARY)
    bottom_symbolic = to_symbolic(problem.boundary_conditions.bottom, problem, symbolic_vars, BOTTOM_BOUNDARY)
    initial_conditions = setup_initial_conditions(problem, symbolic_vars)
    all_conditions = vcat(top_symbolic, bottom_symbolic, initial_conditions)

    discretization = setup_pinn_network(solver.architecture)
    pde_problem = assemble_pde_system(equation, all_conditions, symbolic_vars,
                                    problem,
                                    discretization
    )
    # remake pde problem if transfering
    # if !isnothing(transfer_from) && isfile(transfer_from)

    # end
    trained_result, loss_history = train_pinn(pde_problem, solver.max_iters)
    solution = wrap_as_moisture_profile(
        trained_result,
        discretization,
        problem.soil_params,
        problem.depth_range,
        problem.time_span
    )
    println("PINN Solver Complete")
    if solver.save_model && trained_result.objective < 10.0
        # savepath = isnothing(save_path) ? "models/pinn_dev_$(duration(problem)/3600)hr.bson" : "models/pinn_transfer_dev_$(duration(problem)/3600)hr.bson"# change model_name
        params_to_save = isa(trained_result.u, ComponentArray) ? Vector(trained_result.u) : trained_result.u
        save_data = Dict(
            :params => params_to_save,
            :loss => trained_result.objective,
            :duration => duration(problem))
        BSON.@save solver.save_path save_data
        println("Model saved to $(solver.save_path) ($(length(params_to_save)) parameters)")
    end
    # visualize
    plot_solution(discretization.phi, trained_result, (problem.time_span[2]))
    return solution
end

# Example run
soil = SOIL_LIBRARY["loam"]
depths = [0.0, 0.5, 1.0]
moisture_init = [0.1775, 0.20 , 0.24]
times = [0.0, 0.0001]
values = vcat(
    reshape(moisture_init, 1, 3),
    reshape(moisture_init, 1, 3)
)
save_path = "test.bson"

profile = DiscreteMoistureProfile(depths, times, values; soil_params=soil)
state = SoilMoistureState(profile)

problem = SoilMoistureProblem(
    state,
    soil,
    top_bc = DryingSurface(0.1775, 0.005),
    bottom_bc = FixedMoisture(0.24),
    time_span = (0.0,600.0)
)

solver = PINNSolver(
    profile = :development,
    max_iters = 100,
    save_model = false,
    save_path = save_path,
)

println("Attempting to solve with PINN...")
solution = solve(problem, solver)# Add this to your test script, BEFORE solving

println("\n=== Checking Initial Network Predictions ===")

# Create a minimal test to see what untrained network predicts
test_discretization = setup_pinn_network(solver.architecture)

# Get the untrained network
using Random
Random.seed!(123)
ps, st = Lux.setup(Random.default_rng(), test_discretization.chain)

# Test a few points
test_points = [
    [0.0, 0.0],    # surface, t=0
    [0.5, 0.0],    # middle, t=0
    [1.0, 0.0],    # bottom, t=0
    [0.0, 300.0],  # surface, t=300s
]

println("Untrained network predictions:")
for pt in test_points
    pred = test_discretization.chain(pt, ps, st)[1]
    ψ_pred = pred[1]
    ψ_actual = -exp(ψ_pred)
    
    println("  z=$(pt[1]), t=$(pt[2]):")
    println("    ψ_network = $(round(ψ_pred, digits=2))")
    println("    ψ_actual = $(round(ψ_actual, digits=2))")
    println("    Is NaN/Inf? $(isnan(ψ_actual) || isinf(ψ_actual))")
end

# After creating problem, before solving
println("\n=== Checking BC Values ===")

# What values are we enforcing at surface?
test_times = [0.0, 300.0, 600.0]
for t in test_times
    # DryingSurface formula
    progress = t / 600.0
    θ_surface = 0.1775 - 0.005 * progress
    ψ_surface = θ_to_ψ(θ_surface, soil)
    
    println("t=$(t)s: θ=$(round(θ_surface, digits=4)) → ψ=$(round(ψ_surface, digits=2))m")
end

println("\nBottom BC:")
ψ_bottom = θ_to_ψ(0.24, soil)
println("  θ=0.24 → ψ=$(round(ψ_bottom, digits=2))m (constant)")

# Check IC
println("\nInitial Condition:")
for z in [0.0, 0.5, 1.0]
    θ_ic = problem.initial_state.profile(z, 0.0)
    ψ_ic = θ_to_ψ(θ_ic, soil)
    println("  z=$(z)m: θ=$(round(θ_ic, digits=4)) → ψ=$(round(ψ_ic, digits=2))m")
end