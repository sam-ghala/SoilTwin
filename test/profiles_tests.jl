using Test
using SoilTwin

@testset "DiscreteMoistureProfile" begin
    depths = [0.05, 0.20, 0.50, 1.00]
    times = [0.0, 3600.0, 7200.0]
    values = [0.15 0.18 0.22 0.25;
                0.14 0.17 0.21 0.24;
                0.13 0.16 0.20 0.23]
    soil = SoilParameters(0.43, 0.078, 0.036, 1.56, 6.3e-6)
    profile = DiscreteMoistureProfile(depths, times, values)
    @test profile isa SoilTwin.DiscreteMoistureProfile
    @test profile(0.20, 3600.0) ≈ 0.17
    @test profile(0.50, 7200.0) ≈ 0.20
end

@testset "ContinuousMoistureProfile" begin
    θ_func = (z, t) -> 0.15 + 0.01*z + 0.0001*t
    depth_bounds = (0.0, 1.0)
    time_bounds = (0.0, 7200.0)
    soil = SoilParameters(0.43, 0.078, 0.036, 1.56, 6.3e-6)
    profile = ContinuousMoistureProfile(θ_func, depth_bounds, time_bounds; soil_params=soil)
    @test profile isa SoilTwin.ContinuousMoistureProfile
    @test profile(0.20, 3600.0) ≈ 0.15 + 0.01*0.20 + 0.0001*3600.0
    @test profile(0.50, 7200.0) ≈ 0.15 + 0.01*0.50 + 0.0001*7200.0
end