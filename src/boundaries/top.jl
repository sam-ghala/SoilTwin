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