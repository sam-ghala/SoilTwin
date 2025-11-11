using SoilTwin
using Test

@testset "SoilTwin.jl" begin
    include("interface_tests.jl")
    include("parameters_tests.jl")
    include("problems_tests.jl")
    include("profiles_tests.jl")
    include("state_tests.jl")
end
