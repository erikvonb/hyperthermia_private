function E_opt = OptimizeC(Efield_objects, tumor, healthy_tissue, ...
    particle_settings, plotfilename, P1)

% Cut off antennas with low power contribution in select_best
% Efield_objects = select_best(Efield_objects, nbrEfields, weight_denom, healthy_tissue);

f = @(X) objective_function_C(X, tumor, healthy_tissue, ...
    Efield_objects, P1);

n = length(Efield_objects);
[options, lb, ub] = create_boundaries(particle_settings, 2*n, plotfilename);
[X, ~, ~, ~] = particleswarm(f, 2*n, lb, ub, options);

[C_val, E_opt] = objective_function_C(X, tumor, healthy_tissue, ...
    Efield_objects, P1);
disp(['Value post-optimization: ', num2str(C_val)])


end