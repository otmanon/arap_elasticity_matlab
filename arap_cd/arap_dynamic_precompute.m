function dpre = arap_dynamic_precompute(z_hist, sim_params, spre, f_ext)
%ARAP_DYNAMIC_PRE Summary of this function goes here
%   Detailed explanation goes here

arguments
    z_hist;
    sim_params; spre;
    f_ext = zeros(size(z_hist));
end
dpre = {};

dpre.f_ext = -f_ext;

dpre.My =spre.M*z_hist;

end

