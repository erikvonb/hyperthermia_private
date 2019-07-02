function E_opt = OptimizeM1_new(Efield_objects, tumor, healthy_tissue, ...
    particle_settings, plotfilename)

% Cut off antennas with low power contribution in select_best
% Efield_objects = select_best(Efield_objects, nbrEfields, weight_denom, healthy_tissue);

f = @(X) objective_function_M1(X, tumor, healthy_tissue, ...
    Efield_objects);

n = length(Efield_objects);
[options, lb, ub] = create_PS_options(particle_settings, 2*n, plotfilename);
[X, ~, ~, ~] = particleswarm(f, 2*n, lb, ub, options);

[M1_val, E_opt] = objective_function_M1(X, tumor, healthy_tissue, ...
    Efield_objects);
disp(['Value post-optimization: ', num2str(M1_val)])

end