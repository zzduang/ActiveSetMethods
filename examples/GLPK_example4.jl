using GLPK
using MathOptInterface
using Test
const MOI = MathOptInterface

optimizer = model = GLPK.Optimizer();

x = MOI.add_variable(optimizer)
MOI.add_constraint(optimizer, MOI.SingleVariable(x), MOI.Integer())
f = MOI.VectorAffineFunction([MOI.VectorAffineTerm(1, MOI.ScalarAffineTerm(1.0, x))], [-0.5])
ci = MOI.add_constraint.(optimizer, f, MOI.Nonnegatives(1))
MOI.set(optimizer, MOI.ObjectiveSense(), MOI.MIN_SENSE)
MOI.set(optimizer, MOI.ObjectiveFunction{MOI.SingleVariable}(), MOI.SingleVariable(x))

# `optimize!`ing at this point is fine, but if I add:
#MOI.set(optimizer, MOI.ConstraintFunction(), ci, f)

# the following test fails (instead, the termination status is 18, OtherError):
MOI.optimize!(optimizer)
@test MOI.get(optimizer, MOI.TerminationStatus()) == MOI.Success