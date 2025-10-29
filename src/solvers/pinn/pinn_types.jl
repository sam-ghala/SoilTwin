struct PINNSolver <: AbstractSoilMoistureSolver
    architecture::PINNArchitecture
    max_iters::Int
    transfer_from::Union{Nothing,String} # path
    save_model::Bool
    save_path::Union{Nothing,String} # path

    function PINNSolver(; profile::Symbol = :development,
                        max_iters::Int = 400,
                        transfer_from::Union{Nothing,String} = nothing,
                        save_model::Bool = false,
                        save_path::Union{Nothing,String} = nothing
    )
        architecture = get_architecture(profile)
        return new(architecture, max_iters, transfer_from, save_model, save_path)
    end
    # custom architecture constructor
    function PINNSolver(architecture::PINNArchitecture;
                        max_iters::Int = 400,
                        transfer_from::Union{Nothing,String} = nothing,
                        save_model::Bool = false,
                        save_path::Union{Nothing,String} = nothing
    )
        if save_model && save_path === nothing
            throw(ArgumentError("save_path must be provided if save_model is true"))    
        end
        return new(architecture, max_iters, transfer_from, save_model, save_path)
    end
end