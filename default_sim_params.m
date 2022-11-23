function p = default_sim_params(V, F, o)
%ARAP_CD_PARAMS Summary of this function goes here
%   Detailed explanation goes here

arguments
    V; F;
    o.ym = ones(size(F, 1), 1);
    o.pr = zeros(size(F, 1), 1);
    o.h = 1e-2;
   
    o.do_inertia = true;

    o.Aeq = [];
end
p = {};

ym = o.ym;
pr = o.pr;
%% Handle case where user wants homogeneous material fast.
if (size(ym, 1) == 1)
    ym = ym *ones(size(F, 1), 1);
end
if(size(pr, 1) == 1)
    pr = pr *ones(size(F, 1), 1);
end

p.mu = ym/2;

p.do_inertia = o.do_inertia;
p.h = o.h;
p.invh2 = 1 / (o.h*o.h);

%equality constraints
p.Aeq = o.Aeq;
p.X = V;
p.F = F;
end

