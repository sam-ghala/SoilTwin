# a soil moisture profile will tell me the  moisture at any time and depth within its domain 

"""
    AbstractMoistureProfile

All concrete profile types must implement:
- `(profile::AbstractMoistureProfile)(z, t)` - evaluate moisture at depth z, time t
- `depth_range(profile)` - get valid depth range
- `time_range(profile)` - get valid time range
"""
abstract type AbstractMoistureProfile end

function (profile::AbstractMoistureProfile)(z, t)
    error("Profile type $(typeof(profile)) must implement callable interface: profile(z, t)")
end

depth_range(profile::AbstractMoistureProfile) = error("Must implement depth_range")
time_range(profile::AbstractMoistureProfile) = error("Must implement time_range")

"""
    DiscreteMoistureProfile(depths, times, values; soil_params=nothing)

Moisture values at discrete depths and times from numerical solvers or sensor data.

# Arguments
- `depths::Vector{Float64}`: Depth points in meters (must be sorted)
- `times::Vector{Float64}`: Time points in seconds (must be sorted)  
- `values::Matrix{Float64}`: Moisture values where `values[i,j]` = moisture at `times[i]`, `depths[j]`
- `soil_params::Union{SoilParameters,Nothing}`: Optional soil parameters
"""
struct DiscreteMoistureProfile <: AbstractMoistureProfile
    depths::Vector{Float64}
    times::Vector{Float64}
    values::Matrix{Float64} # rows: times, cols: depths
    soil_params::Union{SoilParameters, Nothing}
    interp

    function DiscreteMoistureProfile(depths::Vector{Float64}, times::Vector{Float64}, values::Matrix{Float64}; soil_params=nothing)
        @assert length(depths) == size(values, 2) "Number of depths must match number of columns in values"
        @assert length(times) == size(values, 1) "Number of times must match number of rows in values"
        @assert issorted(depths) "Depths must be sorted in ascending order"
        @assert issorted(times) "Times must be sorted in ascending order"
        @assert all(0.0 .<= values) && all(values .<= 1.0) "Moisture values must be within [0, 1]"
        # interpolation setup
        itp = interpolate((times, depths), values, Gridded(Linear()))
        etp = extrapolate(itp, Line())
        new(depths, times, values, soil_params, etp)
    end
end

function (profile::DiscreteMoistureProfile)(z::Real, t::Real)
    # User interface is profile(depth, time) following physics convention u(x,t)
    # But interpolator expects (time, depth) to match matrix layout [time_idx, depth_idx]
    return profile.interp(t,z)
end

depth_range(profile::DiscreteMoistureProfile) = (minimum(profile.depths), maximum(profile.depths))
time_range(profile::DiscreteMoistureProfile) = (minimum(profile.times), maximum(profile.times))

"""
    ContinuousMoistureProfile(θ_func, depth_bounds, time_bounds; soil_params=nothing)

Moisture values at continuous depths and times.

# Arguments
- `θ_func::Function` - function with signature `func(z, t) -> moisture`
- `depth_bounds::Tuple{Float64, Float64}` - valid depth range
- `time_bounds::Tuple{Float64, Float64}` - valid time range
- `soil_params::Union{SoilParameters, Nothing}` - optional soil parameters
"""
struct ContinuousMoistureProfile <: AbstractMoistureProfile
    θ_func::Function
    depth_bounds::Tuple{Float64, Float64}
    time_bounds::Tuple{Float64, Float64}
    soil_params::Union{SoilParameters, Nothing}

    function ContinuousMoistureProfile(θ_func::Function, depth_bounds::Tuple{Float64, Float64}, time_bounds::Tuple{Float64, Float64}; soil_params=nothing)
        @assert depth_bounds[1] < depth_bounds[2] "Invalid depth bounds"
        @assert time_bounds[1] < time_bounds[2] "Invalid time bounds"
        new(θ_func, depth_bounds, time_bounds, soil_params)
    end
end

function (profile::ContinuousMoistureProfile)(z::Real, t::Real)
    return profile.θ_func(z, t)
end

depth_range(profile::ContinuousMoistureProfile) = profile.depth_bounds
time_range(profile::ContinuousMoistureProfile) = profile.time_bounds

# conversion between types
"""
    to_discrete(profile::AbstractMoistureProfile, depths, times)

Convert any profile to discrete representation by sampling at specified points.
"""
function to_discrete(profile::ContinuousMoistureProfile, depth_points::Vector{Float64}, time_points::Vector{Float64})
    values = [profile(z, t) for t in time_points, z in depth_points]
    return DiscreteMoistureProfile(depth_points, time_points, values; soil_params=profile.soil_params)
end
"""
    to_continuous(profile::DiscreteMoistureProfile)

Convert any profile to continuous representation by creating a ContinuousMoistureProfile that interpolates.
"""
function to_continuous(profile::DiscreteMoistureProfile)
    θ_func = (z, t) -> profile(z, t)
    depth_bounds = depth_range(profile)
    time_bounds = time_range(profile)
    return ContinuousMoistureProfile(θ_func, depth_bounds, time_bounds; soil_params=profile.soil_params)
end

# printing

function Base.show(io::IO, profile::DiscreteMoistureProfile)
    nt, nz = size(profile.values)
    zmin, zmax = depth_range(profile)
    tmin, tmax = time_range(profile)
    print(io, "DiscreteMoistureProfile: $nt time points × $nz depths\n")
    print(io, "  Depth: $(zmin)m to $(zmax)m\n")
    print(io, "  Time: $(tmin)s to $(tmax/3600)hrs")
end

function Base.show(io::IO, profile::ContinuousMoistureProfile)
    zmin, zmax = depth_range(profile)
    tmin, tmax = time_range(profile)
    print(io, "ContinuousMoistureProfile\n")
    print(io, "  Depth: $(zmin)m to $(zmax)m\n")
    print(io, "  Time: $(tmin)s to $(tmax/3600)hrs")
end