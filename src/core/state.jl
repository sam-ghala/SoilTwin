""" 
    SoilMoistureState(profile::AbstractMoistureProfile; t::Float64=0.0, top_flux::Float64=0.0, bottom_flux::Float64=0.0)
A mutable struct to represent the state of soil moisture at a given time, including the moisture profile and boundary fluxes.
# Arguments
- `profile::AbstractMoistureProfile` - the soil moisture profile
- `t::Float64` - current time in seconds (default: 0.0)
- `top_flux::Float64` - flux at the top boundary (default: 0.0)
- `bottom_flux::Float64` - flux at the bottom boundary (default: 0.0)
"""
mutable struct SoilMoistureState
    profile::AbstractMoistureProfile
    t::Float64
    top_flux::Float64
    bottom_flux::Float64
    function SoilMoistureState(profile::AbstractMoistureProfile; t::Float64=0.0, top_flux::Float64=0.0, bottom_flux::Float64=0.0)
        return new(profile, t, top_flux, bottom_flux)
    end
end
"""
    update!(state::SoilMoistureState; profile=nothing, t::Float64=nothing, top_flux::Float64=nothing, bottom_flux::Float64=nothing)
Update the SoilMoistureState in place with new values for profile, time, and boundary fluxes.
"""
function update!(state::SoilMoistureState; profile = nothing, t=nothing, top_flux=nothing, bottom_flux=nothing)
    t !== nothing && (state.t = t)
    top_flux !== nothing && (state.top_flux = top_flux)
    bottom_flux !== nothing && (state.bottom_flux = bottom_flux)
    profile !== nothing && (state.profile = profile)
    return state
end

# printing
function Base.show(io::IO, state::SoilMoistureState)
    print(io, "SoilMoistureState at t=$(state.t/3600) hrs")
end