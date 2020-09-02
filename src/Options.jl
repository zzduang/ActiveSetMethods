Options_ = Dict(
"mode"=>"Normal", #If Debug it will allow printing some useful information including collecting values for analysis parameters.
"method"=>"SLP", #Defines the method -- either SLP or SQP (SQP hasn't been implemented yet)
"algorithm"=>"Line Search", #Defines the algorithm -- either Line Search or Trust Region Method (Trust Region algorithm hasn't been implemented yet)
"max_iter"=>1e4, #Defines the maximum number of iterations
"max_iter_inner"=>2000, #Defines the maximum number of iterations for the inner loop (Merit function check)
"LP_solver"=>GLPK.Optimizer, #Defines the external LP solver for the LP suproblem
"time_limit"=>Inf, #Defines the time limit for the solver. (This hasn't been implemented yet)
"epsilon"=>1e-6, #Defines the error threshold
"eta"=>0.4,
"tau"=>0.9,
"rho"=>0.8,
"mu"=>100.0,
"TR_size"=>1000.0, # Initial trust region size
"mu_max"=>1e10, #Defines the maximum value for mu
"alpha_lb"=>1e-8); #Defines the lower bound of alpha
