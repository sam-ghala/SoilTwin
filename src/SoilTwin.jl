module SoilTwin

using Interpolations
using DifferentialEquations
using ModelingToolkit
using Symbolics
using NeuralPDE
using Lux
using LineSearches
using Optimization, OptimizationOptimJL
using Statistics
using Plots
using BSON
using BSON: @save, @load
using ComponentArrays

include("core/parameters.jl")
include("core/profiles.jl")
include("core/state.jl")
include("boundaries/types.jl")
include("boundaries/top.jl")
include("boundaries/bottom.jl")
include("boundaries/to_symbolic.jl")
include("boundaries/to_functional.jl")

include("core/problems.jl")
include("core/interface.jl")

include("physics/richards.jl")
include("physics/vangenuchten.jl")

include("solvers/pinn/architectures.jl")
include("solvers/pinn/training.jl")
include("solvers/pinn/PINNSolver.jl")

include("utils/visualization.jl")
include("data/sensors.jl")

export SoilParameters, SOIL_LIBRARY
export AbstractMoistureProfile, DiscreteMoistureProfile, ContinuousMoistureProfile
export depth_range, time_range, to_discrete, to_continuous
export SoilMoistureState, update
export SoilMoistureProblem, duration
export AbstractBoundaryCondition, BoundaryLocation, BoundaryConditions
export ConstantFlux, FreeDrainage

end
