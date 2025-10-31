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
    # save model 
    if solver.save_model # && trained_result.objective < 10.0
        save_path = isnothing(solver.save_path) ? generate_filename(problem, solver, "models", true) : solver.save_path
        params_to_save = isa(trained_result.u, ComponentArray) ? Vector(trained_result.u) : trained_result.u
        save_data = Dict(
            :params => params_to_save,
            :loss => trained_result.objective,
            :duration => duration(problem),
            :soil_params => problem.soil_params,
            :architecture => solver.architecture.layers,
            :timestamp => Dates.now()
        )
        BSON.@save save_path save_data
        println("Model saved to $(save_path) ($(length(params_to_save)) parameters)")
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
# save_path = "test.bson"

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
    max_iters = 150,
    save_model = true,
    # save_path = nothing,
)

println("Attempting to solve with PINN...")
# solution = solve(problem, solver)
# @time solve(problem, solver)