using Test
using SoilTwin

@testset "State Testing" begin
    depths = [0.1, 0.3, 0.5]
    times = [0.0, 1800.0, 3600.0]
    values = [0.2 0.25 0.3;
              0.22 0.27 0.32;
              0.24 0.29 0.34]
    profile = DiscreteMoistureProfile(depths, times, values)
    soil = SoilParameters(0.45, 0.05, 0.1, 1.5, 1e-5)
    state = SoilMoistureState(profile, t=0.0, top_flux=0.0, bottom_flux=0.0)
end