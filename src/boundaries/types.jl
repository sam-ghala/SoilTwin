"""
Abstract type for all boundary conditions.

Concrete types must implement:
- `to_symbolic(bc, problem, symbolic_vars, location)` → symbolic expression for PINN
- `to_flux_function(bc, problem, location)` → function for numerical solver
"""
abstract type AbstractBoundaryCondition end

# Location markers
@enum BoundaryLocation begin
    TOP_BOUNDARY
    BOTTOM_BOUNDARY
end

"""
Container for top and bottom BCs in a problem.
"""
struct BoundaryConditions
    top::AbstractBoundaryCondition
    bottom::AbstractBoundaryCondition
end
