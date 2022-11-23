function K = tetrahedron_gradient(V, F)
%TETRAHEDRON_GRADIENT Summary of this function goes here
%   Detailed explanation goes here
    n = size(V, 1);
    numt = size(F, 1);
    B = [-1 -1; 1 0; 0 1];
    i = []; j = []; v = [];
    for t = 1:numt
        X = [V(F(t, 1), :); V(F(t, 2), :);V(F(t, 3), :)]';
        k = B * inv(X * B);      
        for ci = 1:size(k, 2)
            for cj = 1:size(F, 2)
                % do for first index
                v_ind = F(t, cj);
                i = [i; 2*(t-1) + numt*(ci-1)*2 + 1; 2*(t-1) + numt*(ci-1)*2 + 2];
                j = [j; v_ind + 0; v_ind + n];
                v = [v; k(cj, ci); k(cj, ci)];
            end
        end
    end
    
    K = sparse(i, j, v, numt*4, 2*n);
    
        
end

