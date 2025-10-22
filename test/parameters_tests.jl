using Test
using SoilTwin

@testset "SoilParameters type" begin
    p = SoilTwin.SoilParameters(0.45, 0.05, 0.1, 1.8, 1e-5)
    @test p isa SoilTwin.SoilParameters
    @test p.θsat == 0.45
    @test p.θres == 0.05
end