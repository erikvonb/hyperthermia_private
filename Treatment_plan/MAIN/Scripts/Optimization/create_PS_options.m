function [options, lb, ub]=create_PS_options(particle_settings, n, ...
    plotfilename, initial_PS_settings)
% Function that creates boundary conditions for particleswarm.
% ----INPUTS---------------------------------------------
% particle_settings: vector with [swarmsize, max_iterations, stall_iterations]
%                    for particleswarm.
% n:                 number of variables in optimization problem
% ----OUTPUTS-------------------------------------------
% options:           optimoptions for particleswarm
% lb:                lower boundary
% ub:                upper boundary
% -------------------------------------------------------

lb = -ones(particle_settings(1)-1,n);
ub = ones(particle_settings(1)-1,n);
% initialVec=zeros(1,n);
% initialVec(1:2:end-1)=1;
initialVec = initial_PS_settings;
% Initialize the first particle with 1 amplitudes and reference phase
% Initialize the rest of the particles with random numbers between -1 and 1
initialSwarmMat=[initialVec;
                 lb + (-lb + ub) .* rand(particle_settings(1)-1, n)];
plotfunc = @(ov,s) plotPSIterations(ov, s, plotfilename);

options = optimoptions('particleswarm','SwarmSize',particle_settings(1),...
    'PlotFcn',@(ov,s)plotfunc(ov,s), 'MaxIterations', particle_settings(2), ...
    'MaxStallIterations', particle_settings(3), ...
    'InitialSwarmMatrix', initialSwarmMat);

lb=lb(1,:)';
ub=ub(1,:)';
end