using ActiveSetMethods
using PowerModels, JuMP, GLPK, Ipopt

build_acp(data_file::String) = instantiate_model(PowerModels.parse_file(data_file), ACPPowerModel, PowerModels.build_opf)
build_acr(data_file::String) = instantiate_model(PowerModels.parse_file(data_file), ACRPowerModel, PowerModels.build_opf)
build_iv(data_file::String) = instantiate_model(PowerModels.parse_file(data_file), IVRPowerModel, PowerModels.build_opf_iv)

run_opf(data_file::String) = run_opf(build_acp(data_file))
run_opf(pm::AbstractPowerModel) = optimize_model!(pm, optimizer = optimizer_with_attributes(
    ActiveSetMethods.Optimizer, 
    "external_optimizer" => GLPK.Optimizer()
))

include("init_opf.jl")

#=
One can run the following:

pm = build_acp("case3.m")
init_vars(pm)
# or 
init_vars_from_ipopt(pm, build_acp("case3.m"))
run_opf(pm)

pm = build_iv("case3.m")

=#
