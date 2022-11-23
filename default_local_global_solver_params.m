function p = local_global_solver_params()
%LOCAL_GLOBAL_SOLVER_PARAMS Configures parameters used in a general local
%global solver. 
p= {};
p.to_convergence = false;
p.convergence_threshold = 1e-3;
p.max_iters = 10;


end

