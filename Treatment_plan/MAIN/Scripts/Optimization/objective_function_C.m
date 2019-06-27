function [C_val, E_opt] = objective_function_C(X, tumor, healthy_tissue, ...
    Efield_objects, P1)

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

C_val = C(P1, abs_sq(E_opt_sum), healthy_tissue, tumor);

end