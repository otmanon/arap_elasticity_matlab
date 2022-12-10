function  C = positions_from_parameters(p)
%PARAMETERS_FROM_POSITIONS Summary of this function goes here
%   Detailed explanation goes here
    b = size(p, 1)/6;
    C = zeros(b, 2);
     for i=1:b
            topI = [i; i + 2*b; i + 4*b];
            botI = [i + b; i + 3*b; i + 5*b];
            A = [p(topI)'; p(botI)'];
            C(i, :) = A(:, 3)';
     end
end

