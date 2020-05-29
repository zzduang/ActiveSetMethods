#Importing Packages
using JuMP, Ipopt, PowerModels
println("Packages were imported successfully")


#Defining Parameters
eps=0.0001; itr_max=2



#SLP function
function slp(network)
	#Initialization
	# TODO: Add some initialization
	itr=0; err=1.0; cx=2.0; cy=3.0;
	bus_size=length(network["bus"])
	while(err>eps && itr<itr_max) itr+=1;
		lp=Model(optimizer_with_attributes(Ipopt.Optimizer, "print_level" => 0));
		@variable(lp, x[1:bus_size]>=0)
		@variable(lp, y[1:bus_size]>=0)

		@constraint(lp, [i=1:bus_size], x[i]+y[i] >= i*10);
		
		@objective(lp, Min, cx*sum(x)+cy*sum(y));
		@time JuMP.optimize!(lp);
	  	println("Objective Value: ", JuMP.objective_value(lp), "(",JuMP.termination_status(lp),")");
	end
end



#Read Network Data
network = PowerModels.parse_file("cases/case3.m");
println("Network Data was Read Successfully");

slp(network);
println("SLP Optimization was called Successfully");



