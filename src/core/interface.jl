
abstract type AbstractSoilMoistureSolver end

function solve(problem::SoilMoistureProblem, solver::AbstractSoilMoistureSolver)
    throw(ErrorException("solve function not implemented for solver type $(typeof(solver))"))
end