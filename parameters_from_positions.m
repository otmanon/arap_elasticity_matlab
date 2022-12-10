function  p = parameters_from_positions(V)
%PARAMETERS_FROM_POSITIONS Summary of this function goes here
%   Detailed explanation goes here
    b = size(V, 1);
    p = zeros(b*6, 1);
     for i=1:b
            topI = [i; i + 2*b; i + 4*b];
            botI = [i + b; i + 3*b; i + 5*b];
            
            p(topI) = [1; 0; V(i, 1)];
            p(botI) = [0; 1; V(i, 2)];
     end
end

