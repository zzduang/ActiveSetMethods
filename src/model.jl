mutable struct Model{T,Tv,Tt}
    n::Int  # Num vars
    m::Int  # Num cons
    x::Tv  # Starting and final solution
    x_L::Tv # Variables Lower Bound
    x_U::Tv # Variables Upper Bound
    g::Tv  # Final constraint values
    g_L::Tv # Constraints Lower Bound
    g_U::Tv # Constraints Upper Bound
    j_str::Tt
    h_str::Tt
    mult_g::Tv # lagrange multipliers on constraints
    mult_x_L::Tv # lagrange multipliers on lower bounds
    mult_x_U::Tv # lagrange multipliers on upper bounds
    obj_val::T  # Final objective
    status::Int  # Final status

    # Callbacks
    eval_f::Function
    eval_g::Function
    eval_grad_f::Function
    eval_jac_g::Function
    eval_h::Union{Function,Nothing}

    intermediate  # Can be nothing

    # For MathProgBase
    sense::Symbol

    parameters::Parameters

    Model(
        n::Int, 
        m::Int, 
        x_L::Tv, 
        x_U::Tv,
        g_L::Tv,
        g_U::Tv,
        j_str::Tt,
        h_str::Tt,
        eval_f::Function,
        eval_g::Function,
        eval_grad_f::Function,
        eval_jac_g::Function,
        eval_h::Union{Function,Nothing},
        parameters::Parameters
    ) where {T, Tv<:AbstractArray{T}, Tt<:AbstractArray{Tuple{Int64,Int64}}} = new{T,Tv,Tt}(
        n, m,
        zeros(n), x_L, x_U,
        zeros(m), g_L, g_U,
        j_str, h_str,
        zeros(m), zeros(n), zeros(n),
        0.0,
        -5,
        eval_f, eval_g, eval_grad_f, eval_jac_g, eval_h, 
        nothing, :Min,
        parameters
    )
end

function optimize!(model::Model)
    if isnothing(model.parameters.external_optimizer)
    	model.status = -12;
        @error "`external_optimizer` parameter must be set for subproblem solutions."
    else
        if model.parameters.method == "SLP"
            slp = SlpLS(model)
            if model.parameters.algorithm == "Line Search"
                active_set_optimize!(slp);
            end
        else
            @error "The method is not defined"
        end
    end
    return nothing
end
