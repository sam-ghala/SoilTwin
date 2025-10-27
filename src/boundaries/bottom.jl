"""
    FreeDrainage()

Free drainage (unit hydraulic gradient) at bottom boundary.

Condition: ∂ψ/∂z = -1, so flux q = -K(ψ)

This is the most common bottom BC for deep soil columns where:
- Water drains freely downward
- No water table influence
- Gravity-driven flow

# Physical meaning
Water leaves bottom at rate equal to hydraulic conductivity at that depth.
No capillary rise from below.
"""
struct FreeDrainage <: AbstractBoundaryCondition end

struct FixedMoisture <: AbstractBoundaryCondition
    moisture::Float64
    
    function FixedMoisture(moisture)
        @assert 0.0 <= moisture <= 1.0 "Moisture must be in [0,1]"
        new(moisture)
    end
end