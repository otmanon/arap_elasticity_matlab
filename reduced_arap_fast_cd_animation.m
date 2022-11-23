function reduced_arap_fast_cd_animation(V, F, W, J, B, o)
arguments
    V, F; W; J; B; 
    o.sim_params = default_sim_params(V, F);

    o.rig_func = @(step)(rotate_rig(step, 1, 0, num_b=1, C=[0, 0]));
    o.Aeq = [];
    o.constraint_func = @(step) ([]);
    o.force_func = @(step)([]);

    o.plot_name="Sim"; o.experiment_dir="results/default/";

    o.save_videos=false;
    o.max_steps = 300;
    o.minmax_win = [-1 1 -1 1];
    o.color = [144, 210, 236]/255; % Derek Blue

    o.cI = []; % constrained indices. if nonzero will draw these
    o.init_z = zeros(size(B, 2), 1);
    o.face_alpha = 1;
    o.edge_alpha = 0;

    o.UV = [];
    o.TT = [];

    o.Q = zeros(size(V, 1)*size(V, 2), size(V, 1)*size(V, 2));

    o.cdata = [];
    o.cmap = "parula";
    o.text_string="";
    o.text_pos = [0 0]

    o.rs_projection = false;
    o.show_energy = true;
end

n = size(V, 1);
d = size(V, 2);

use_texture = true;
if (size(o.UV, 1) == 0 || size(o.TT, 1) == 0)
    use_texture = false;
end;

num_modes = size(B,2);


%% full cd sim params

solver_p = default_local_global_solver_params();

%% Simulation Precomputations
reduced_sim = reduced_arap_cd_sim(V, F, B, [], J, o.Aeq, o.sim_params, Q=o.Q);
spre = reduced_arap_cd_static_precompute(reduced_sim);


z = o.init_z;
z0 = z; z_prev = z; z_curr = z; z_hist = z;
p0  = o.rig_func(0); 
p_prev = p0; p_curr = p_prev; p = p0;   
 U = reshape(J*p0, n, 2);
      
%% Display 
clf;
hold on;
%figure('Renderer', 'painters', 'Position', [10 10 900 600])

if (~use_texture)
    if (size(o.cdata, 1) > 1)
        if (size(o.cdata, 1) == size(F, 1))
            t = tsurf(F,U, 'FaceAlpha', o.face_alpha, 'EdgeAlpha', o.edge_alpha, 'CData', o.cdata);
        elseif (size(o.cdata, 1) == size(V, 1))
            t = tsurf(F,U, 'FaceAlpha', o.face_alpha, 'EdgeAlpha', o.edge_alpha, 'CData', o.cdata, fphong);
        end
        colormap(o.cmap);
    elseif (size(o.cdata, 1) == 1)
        t = tsurf(F,U, 'FaceAlpha', o.face_alpha, 'EdgeAlpha', o.edge_alpha);
        t.FaceColor = o.cdata(1, :);
    else
        t = tsurf(F,U, 'FaceAlpha', o.face_alpha, 'EdgeAlpha', o.edge_alpha);
        t.FaceColor = o.color;
    end
end

%colorbar;
axis equal;
axis(o.minmax_win);
title(strcat(o.plot_name));
axis manual;
set(gca,'Position',[0 0 1 1],'Visible','off');
set(gcf,'Color','w');
text(o.text_pos(1), o.text_pos(2), o.text_string);
if (size(o.cI, 1) > 0)
    s = scatter(V(o.cI, 1), V(o.cI, 2), 'filled',  'CData', o.cdata(1, :)/2)
    s.SizeData = 50;
end
drawnow;
arap_txt = text(-1, -3, strcat("ARAP Energy : ", string(arap_energy(V, F, U))));

%% Simulation Loop
for ai=0:o.max_steps
    z_hist = 2*z_curr - z_prev;
    p_hist = 2*p_curr - p_prev;
    % read a new frame
    p  = o.rig_func(ai); 
    bc = o.constraint_func(ai);
    f_ext = o.force_func(ai, z, p, z_hist, p_hist);
    z_next = reduced_sim.step(z_curr, z_hist, p, p_hist, f_ext, bc, o.sim_params, spre, solver_p);
   
     p_prev = p_curr;
     p_curr = p;
      
     z_prev = z_curr;
     z_curr = z_next;           
   
     ur = J*p;
     u = ur + B*z_next;
     U = reshape(u, size(u, 1)/2, 2);
     if (o.rs_projection)
        bI = [1, 1+size(V, 1)]; 
        bc = U(1, :)';
        U = interpolate_rs(V, F, U-V, bI = [1, 1+size(V, 1)], bc=bc);
     end
    
     t.Vertices = U;
    
     if (size(o.cI, 1) > 0)
         s.XData = U(o.cI, 1);
         s.YData = U(o.cI, 2);
     end

     if (o.show_energy)
         delete(arap_txt)
         arap_txt = text(2, -4, strcat("ARAP Energy : ", string(arap_energy(V, F, U))));
     end
     drawnow;
      
     if(o.save_videos)
        if(use_texture)
            [IO, AA] = apply_texture_map(t, o.UV, o.TT);
             imwrite(IO,sprintf(strcat(o.experiment_dir, '%04d.png'),ai),'Alpha',1*AA);
        else
            saveas(gca, sprintf(strcat(o.experiment_dir, '%04d.png'),ai));
        end
     end
end




end