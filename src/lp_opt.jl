"""
solve_lp(c_init,A,b,x_L,x_U,constraint_lb,constraint_ub,mu,x_hat)
This function solved the LP subproblem of the SLP line search algorithm on
	nonlinear optimization problem defined in model.
c_init has all weights of the objective function. The last elment of it has the
	constant value of the objective function. c_init is a sparse vector
A is a constraint matrix of the LP subproblem. It is a sparse matrix
b is a vector containing the constant values of the constraint matrix A.
	b is a dense vector.
x_L is a vector containing the lower bound of the original variables of the
	nonlinear optimization problem
x_U is a vector containing the upper bound of the original variables of the
	nonlinear optimization problem
constraint_lb is a vector containing the lower bound of the original constraints
 	of the nonlinear optimization problem
constraint_ub is a vector containing the upper bound of the original constraints
 	of the nonlinear optimization problem
mu is a scalar number which defines the peanlty for constraint violations
x_hat is the estinmated values of the original variables of the nonlinear
	optimization problem

The function returns the slution of the LP subproblem variables, status of the
	LP subproblem solution, and duals of the constraints of the LP subproblem. 
	If the problem is dual_infeasible, the duals of the constraints will be an
	empty array.
"""

function solve_lp(c_init,A,b,x_L,x_U,constraint_lb,constraint_ub,mu,x_hat)

	model = Options_["LP_solver"]()
	n = A.n;
	m = A.m;
	@assert n > 0
	@assert m >= 0

	c = c_init[1:n];

	c0 = c_init[n+1];
	
	#TODO all varialbes are defined as x ... change it to p so it is consistant with 
	# the algorithm
	# Variables are defined as a vector named x
	x = MOI.add_variables(model, n)
	
	# terms is defined for the objective function
	terms = Array{MOI.ScalarAffineTerm{Float64},1}();
	for (ind, val) in zip(c.nzind, c.nzval)
		push!(terms, MOI.ScalarAffineTerm{Float64}(val, MOI.VariableIndex(ind)));
	end

	# Slacks v and u are added only for constrained problems.
	if m > 0
		u = MOI.add_variables(model, m)
		v = MOI.add_variables(model, m)
		append!(terms, MOI.ScalarAffineTerm.(mu, u));
		append!(terms, MOI.ScalarAffineTerm.(mu, v));
	end

	MOI.set(model,
		MOI.ObjectiveFunction{MOI.ScalarAffineFunction{Float64}}(),
		MOI.ScalarAffineFunction(terms, c0))
	MOI.set(model, MOI.ObjectiveSense(), MOI.MIN_SENSE)

	@assert length(x_L) == n
	@assert length(x_U) == n
	
	# The original bounds of the x are imposed on p + x_hat
	for i=1:n
		term = MOI.ScalarAffineTerm{Float64}(1.0, x[i]);

		if x_L[i] != -Inf
			MOI.Utilities.normalize_and_add_constraint(model,
			MOI.ScalarAffineFunction([term], x_hat[i]), MOI.GreaterThan(x_L[i]));
		end
		if x_U[i] != Inf
			MOI.Utilities.normalize_and_add_constraint(model,
			MOI.ScalarAffineFunction([term], x_hat[i]), MOI.LessThan(x_U[i]));
		end
	end

	@assert length(constraint_lb) == m
	@assert length(constraint_ub) == m
	
	# constr is used to retrieve the dual variable of the constraints after solution
	constr = MOI.ConstraintIndex[]
	for i=1:m
		Ai = A[i,:];
		terms = Array{MOI.ScalarAffineTerm{Float64},1}();
		# u_term = Array{MOI.ScalarAffineTerm{Float64},1}();
		# v_term = Array{MOI.ScalarAffineTerm{Float64},1}();
		for (ind, val) in zip(Ai.nzind, Ai.nzval)
			push!(terms, MOI.ScalarAffineTerm{Float64}(val, MOI.VariableIndex(ind)));
		end
		# push!(u_term, MOI.ScalarAffineTerm{Float64}(1.0, u[i]));
		# push!(v_term, MOI.ScalarAffineTerm{Float64}(1.0, v[i]));

		u_term = MOI.ScalarAffineTerm{Float64}(1.0, u[i]);
		v_term = MOI.ScalarAffineTerm{Float64}(1.0, v[i]);;
		push!(terms, MOI.ScalarAffineTerm{Float64}(1.0, u[i]));
		push!(terms, MOI.ScalarAffineTerm{Float64}(-1.0, v[i]));
		if constraint_lb[i] == constraint_ub[i] #This means the constraint is equality
			constr1 = MOI.Utilities.normalize_and_add_constraint(model,
			MOI.ScalarAffineFunction(terms, b[i]), MOI.EqualTo(constraint_lb[i]));
		elseif constraint_lb[i] != -Inf && constraint_ub[i] != Inf && constraint_lb[i] < constraint_ub[i]
			constr2 = MOI.Utilities.normalize_and_add_constraint(model,
			MOI.ScalarAffineFunction(terms, b[i]), MOI.GreaterThan(constraint_lb[i]));
			constr1 = MOI.Utilities.normalize_and_add_constraint(model,
			MOI.ScalarAffineFunction(terms, b[i]), MOI.LessThan(constraint_ub[i]));
			push!(constr, constr2);
		elseif constraint_lb[i] != -Inf
			constr1 = MOI.Utilities.normalize_and_add_constraint(model,
			MOI.ScalarAffineFunction(terms, b[i]), MOI.GreaterThan(constraint_lb[i]));
		elseif constraint_ub[i] != Inf
			constr1 = MOI.Utilities.normalize_and_add_constraint(model,
			MOI.ScalarAffineFunction(terms, b[i]), MOI.LessThan(constraint_ub[i]));
		end
		push!(constr, constr1);
		MOI.Utilities.normalize_and_add_constraint(model,
		MOI.ScalarAffineFunction([u_term], 0.0), MOI.GreaterThan(0.0));
		MOI.Utilities.normalize_and_add_constraint(model,
		MOI.ScalarAffineFunction([v_term], 0.0), MOI.GreaterThan(0.0));
	end


	MOI.optimize!(model);
	status = MOI.get(model, MOI.TerminationStatus());
	if Options_["mode"] == "Debug"
		print(model);
		println("Status: ", status);
	end

	# statusPrimal = MOI.get(model, MOI.PrimalStatus());
	# println("StatusPrimal: ", statusPrimal);
	#
	# statusDual = MOI.get(model, MOI.DualStatus());
	# println("StatusDual: ", statusDual);
	#
	# Pobj = MOI.get(model, MOI.ObjectiveValue());
	# println("Pobj: ", Pobj);
	#
	# Dobj = MOI.get(model, MOI.DualObjectiveValue());
	# println("Dobj: ", Dobj);

	#Dconst = MOI.get(model, MOI.ConstraintPrimal());
	#println("Dconst: ", Dconst);



	Xsol = zeros(n);
	lambda = []


	if status == MOI.OPTIMAL
		Xsol = MOI.get(model, MOI.VariablePrimal(), x);
		if m > 0
			Usol = MOI.get(model, MOI.VariablePrimal(), u);
			Vsol = MOI.get(model, MOI.VariablePrimal(), v);
		end
		lambda = MOI.get(model, MOI.ConstraintDual(1), constr);
		if Options_["mode"] == "Debug"
			println("Xsol: ", Xsol);
			if m > 0
				println("Usol: ", Usol);
				println("Vsol: ", Vsol);
			end
			println("Dual Constraints constr: ", MOI.get(model, MOI.ConstraintDual(1), constr))
		end
	elseif status == MOI.DUAL_INFEASIBLE
		@error "Trust region must be employed."
	else
		@error "Unexpected status: $(status)"
	end

	return(Xsol,lambda,status)
end
