"""
    ConstantFlux(flux::Float64)

Constant water flux at surface.
- Positive flux = water entering soil (infiltration/rain)
- Negative flux = water leaving soil (evaporation)

# Example
```julia
rain = ConstantFlux(1e-6)  # 3.6 mm/hr constant rain
evap = ConstantFlux(-5e-7)  # Evaporation
```
"""
struct ConstantFlux <: AbstractBoundaryCondition
    flux::Float64  # m/s
end

struct DryingSurface <: AbstractBoundaryCondition
    initial_moisture::Float64
    drying_rate::Float64
    
    function DryingSurface(initial_moisture, drying_rate)
        @assert 0.0 <= initial_moisture <= 1.0 "Moisture must be in [0,1]"
        @assert drying_rate >= 0.0 "Drying rate must be non-negative"
        new(initial_moisture, drying_rate)
    end
end