function update_input_to_fenics()


current_dir=pwd;
to_path=[current_dir filesep '..' filesep 'Input_to_FEniCS' filesep];
% Load modelType
fid=fopen([to_path 'modelType.txt'], 'r');
modelType=fgetl(fid);

from_path=[current_dir filesep '..' filesep '..' filesep 'Results' filesep 'Input_to_FEniCS' filesep modelType filesep];

% move perfusion matrix
load([from_path 'perfusion.mat']);
save([to_path 'perfusion_current.mat'], 'mat', '-v7.3');

% move initial perfusion matrix
load([from_path 'initial_perf.mat']);
save([to_path 'initial_perf.mat'], 'mat', '-v7.3');

% move density matrix
load([from_path 'density.mat']);
save([to_path 'density.mat'], 'mat', '-v7.3');

% move heat capaciy matrix
load([from_path 'heat_capacity.mat']);
save([to_path 'heat_capacity.mat'], 'mat', '-v7.3');


end
