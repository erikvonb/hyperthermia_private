function [M1_val, E_opt] = objective_function_M1(X, tumor, healthy_tissue, ...
    Efield_objects)

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

M1_val = M1(abs_sq(E_opt_sum), tumor, healthy_tissue);

end