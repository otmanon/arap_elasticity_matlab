function [V, s, t] = scale_and_center_mesh(V, h, dc)
%SCALE_AND_CENTER Scale mesh to have desired height height, and to be
%centered around desirec_center
%   Detailed explanation goes here

s = (max(V(:, 2)) - min(V(:, 2)))/h;
V = V/s;
t =  mean(V) - dc;
V = V - t; 
end

