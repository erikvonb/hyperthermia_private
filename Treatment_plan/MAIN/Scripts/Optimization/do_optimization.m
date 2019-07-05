function E_opt = do_optimization(func, Efield_objects, tumor, healthy_tissue, ...
    particle_settings, plotfilename, initial_PS_settings, use_parallel, P1)

% Cut off antennas with low power contribution in select_best
% Efield_objects = select_best(Efield_objects, nbrEfields, weight_denom, healthy_tissue);

if nargin == 9
    f = @(X) objective_function(func, X, tumor, healthy_tissue, ...
            Efield_objects, P1);
else
    f = @(X) objective_function(func, X, tumor, healthy_tissue, ...
            Efield_objects);
end
% switch func
%     case 'M1'
%         f = @(X) objective_function(func, X, tumor, healthy_tissue, ...
%             Efield_objects);
%     case 'M2'
%         f = @(X) objective_function(func, X, tumor, healthy_tissue, ...
%             Efield_objects);
%     case 'C'
%         f = @(X) objective_function(func, X, tumor, healthy_tissue, ...
%             Efield_objects, P1);
%     otherwise
%         error(['Error: Incorrect objective function name. ' ...
%                'Must be either ''M1'', ''M2'', or ''C''.'])
% end

n = length(Efield_objects);
[options, lb, ub] = create_PS_options(particle_settings, 2*n, ...
    plotfilename, initial_PS_settings);
options.UseParallel = logical(use_parallel);
[X, ~, ~, ~] = particleswarm(f, 2*n, lb, ub, options);

if nargin == 9
    [f_val, E_opt] = objective_function('C', X, tumor, healthy_tissue, ...
            Efield_objects, P1);
else
    [f_val, E_opt] = objective_function(func, X, tumor, healthy_tissue, ...
            Efield_objects);
end

% switch func
%     case 'M1'
%         [f_val, E_opt] = objective_function('M1', X, tumor, healthy_tissue, ...
%             Efield_objects);
%     case 'M2'
%         [f_val, E_opt] = objective_function('M2', X, tumor, healthy_tissue, ...
%             Efield_objects);
%     case 'C'
%         [f_val, E_opt] = objective_function('C', X, tumor, healthy_tissue, ...
%             Efield_objects, P1);
% end

disp(['Value post-optimization: ', num2str(f_val)])

end
