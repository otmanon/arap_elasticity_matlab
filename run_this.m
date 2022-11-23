clear;
close all;
warning('off','all');

[V, F] = readOBJ("./data/bingby/lbs_rig/bingby.obj");
V = V(:, 1:2);
V = scale_and_center_mesh(V, 1, [0 0] )
%% Experiment Parameters
ym = 100              % change this to adjust stiffness
max_steps = 400;    % how many timesteps
sim_params = default_sim_params(V, F, ym=ym);
%sim_params.do_inertia = false;      %toggle this to disable inertia
solver_params = default_local_global_solver_params();


%% Creates elastodynamic simulation with ARAP elastic energy
sim = arap_sim(sim_params, solver_params);


%% Display 
clf;
hold on;
% pad = 0.25;
% min_win = [min(V(:, 1))-pad, min(V(:, 1))-pad];
% max_win = [max(V(:, 1))+pad, max(V(:, 1))+pad];
% minmax_win = [min_win(1) max_win(1) min_win(2) max_win(2)];
axis equal;
% axis([min_win(1), max_win(1), min_win(2) max_win(2)]);
face_alpha = 0.5;
edge_alpha = 0.1;
% axis(minmax_win);
t = tsurf(F,V, 'FaceAlpha', face_alpha, 'EdgeAlpha', edge_alpha);
drawnow;


%% Control Functions and Vertices
control_scalars = readDMAT("./data/bingby/lbs_rig/W.DMAT");
rightI = control_scalars(:, 1) > 0.99;
leftI = control_scalars(:, 2) > 0.99;
ind = rightI+ leftI;


u = zeros(size(V, 1)*size(V, 2), 1);
u_curr = u; u_prev = u; u_hist = u;
%% Simulation Loop
for step=0:max_steps
    u_hist = 2*u_curr - u_prev; % displacement history for inertia
    % read a new frame 
    f_ext = force_func(step, u_hist, rightI, leftI);
    u_next = sim.step(u_curr, u_hist, f_ext);
  
    % update state of simulation
    u_prev = u_curr;
    u_curr = u_next;           
    
    U = reshape(u_curr, size(u_curr, 1)/2, 2);
    
    t.Vertices = U + V;
    drawnow;
      
end


% Feel free to change these force/constraint functions

% a function the simulation calls each timestep to prescribe a force. 
% This force will provide a downward horizontal force to vertex indices rightI and
% leftI. 
function f = force_func(step, u_hist, rightI, leftI)
    n = size(u_hist, 1)/2;
    if step < 2
        f = repmat([-1, 0], [n, 1]) .* rightI;
        f = f +  repmat([1, 0], [n, 1]) .* leftI;
        f = 0.01*f(:);
    else
        f = zeros(size(u_hist, 1), 1);
    end
end

