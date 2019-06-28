function [f_val, E_opt] = objective_function(func, X, tumor, healthy_tissue, ...
    Efield_objects, P1)
% Evaluates a given objective function.
% ----INPUTS---------------------------------------------
% func:           String corresponding to the objective function, either
%                 'M1', 'M2', or 'C'.
% X:              Vector corresponding to the complex coefficients for each
%                 E-field. On the form [a1, b1, a2, b2, ..., an, bn] where
%                 ck = ak + i*bk is the k:th coefficient.
% tumor:          Binary octree indicating tumor tissue.
% healthy_tissue: Binary octree indicating healthy tissue.
% Efield_objects: E-fields to modify.
% P1:             OPTIONAL: PLD from the first frequency optimization, only
%                 used for the 'C' func value.
% ----OUTPUTS--------------------------------------------
% f_val: The resulting objective function value.
% E_opt: The sum of the modified E-fields.
% -------------------------------------------------------


% Apply coefficients
E_opt = cell(length(Efield_objects),1);
for i = 1:length(Efield_objects)
    E_opt{i} = complex(X(2*i-1), X(2*i)) .* Efield_objects{i};
end

% Calculate total E-field
E_opt_sum = E_opt{1};
for i=2:length(Efield_objects)
    E_opt_sum = E_opt_sum + E_opt{i};
end

switch func
    case 'M1'
        f_val = M1(abs_sq(E_opt_sum), tumor, healthy_tissue);
    case 'M2'
        % TODO
    case 'C'
        f_val = C(P1, abs_sq(E_opt_sum), healthy_tissue, tumor);
    otherwise
        error(['Error: Incorrect objective function name. ' ...
               'Must be either ''M1'', ''M2'', or ''C''.'])
end

end