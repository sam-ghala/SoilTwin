using Test
using SoilTwin

@testset "SoilMoistureProblem" begin
    depths = [0.05, 0.20, 0.50, 1.00]
    times = [0.0, 3600.0, 7200.0]
    values = [0.15 0.18 0.22 0.25;
                0.14 0.17 0.21 0.24;
                0.13 0.16 0.20 0.23]
    soil = SOIL_LIBRARY["loam"]
    profile = DiscreteMoistureProfile(depths, times, values, soil_params=soil)
    state = SoilMoistureState(profile)
    
    top = ConstantFlux(1e-6)
    bottom = FreeDrainage()
    @testset "Construction" begin
        prob = SoilMoistureProblem(
            state, 
            soil;
            top = ConstantFlux(1e-6),
            bottom = FreeDrainage(),
            time_span=(0.0, 86400.0),
            depth_range=(depths[1], depths[end])
        )
        
        @test prob isa SoilMoistureProblem
        @test duration(prob) == 86400.0
    end
end