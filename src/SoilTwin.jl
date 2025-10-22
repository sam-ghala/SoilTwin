module SoilTwin

using Interpolations

include("core/parameters.jl")
include("core/profiles.jl")

export SoilParameters, SOIL_LIBRARY
export AbstractMoistureProfile, DiscreteMoistureProfile, ContinuousMoistureProfile
export depth_range, time_range, to_discrete, to_continuous

end