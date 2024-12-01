set_up_julia_project:  # adding for reference
	julia --project=. -e 'using Pkg; Pkg.activate("."); Pkg.instantiate()' 

install_default_packages:  # adding for reference
	julia --project=. -e 'using Pkg; Pkg.add(["Test", "DataStructures", "JSON", "CSV", "DotEnv", "HTTP"])'

ex_run_command:  # adding for reference
	julia --project=. utils.jl
