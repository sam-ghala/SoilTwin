# test parameters.jl
using SoilTwin
using Test

include(joinpath(@__DIR__,"parameters_tests.jl"))
include(joinpath(@__DIR__,"profiles_tests.jl"))
include(joinpath(@__DIR__,"state_tests.jl"))
include(joinpath(@__DIR__,"problems_tests.jl"))
include(joinpath(@__DIR__,"interface_tests.jl"))