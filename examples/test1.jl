push!(LOAD_PATH, "../src");
using JuMP
using Nlopt, Gurobi

solver = Nlopt.Optimizer

#model = Model(optimizer_with_attributes(solver, "lp_solver" => Gurobi.Optimizer()));
model = Model(solver);

#optimizer_with_attributes(lp_solver=Gurobi.Optimizer())
set_optimizer_attribute(model, "lp_solver", Gurobi.Optimizer)

#model.lp_solver = Ipopt.Optimizer()
#lp = Model(Ipopt.Optimizer)
#MOI.set(model, lp)

@variable(model, X);
#@variable(model, Y);
@objective(model, Min, X^2 + X);
@NLconstraint(model, X^2 - X == 2);


println("________________________________________");
print(model);
println("________________________________________");
JuMP.optimize!(model);

println("Xsol = ",JuMP.value.(X));