"""
    generate_model_name(problem, solver; base_dir="models")

Generate a descriptive filename for saving PINN models.

Format: `{base_dir}/pinn_{soil}_{duration}hr_{profile}_{timestamp}.bson`
"""
# generate file name for pinn solver
function generate_filename(
    problem::SoilMoistureProblem,
    solver::PINNSolver,
    base_dir::String="models/",
    include_timestamp::Bool=true
)
    soil_name = problem.soil_params.name
    duration_hrs = duration(problem) / 3600
    profile_name = solver.architecture.name

    filename_parts = [
        "pinn",
        string(soil_name),
        "$(round(Int,duration_hrs))hr",
        profile_name,
    ]
    if include_timestamp
        timestamp = Dates.format(Dates.now(), "yyyy-mm-dd_HHMMSS")
        push!(filename_parts, timestamp)
    end
    filename = join(filename_parts, "_") * ".bson"

    if !isdir(base_dir)
        @warn "Creating directory: $base_dir"
        mkpath(base_dir)
    end

    return joinpath(base_dir, filename)
end