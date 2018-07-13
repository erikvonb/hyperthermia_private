function change_water_bolus_temp(new_temp)
% This function is used to change the temperatue in the water bolus
% according to the temperature given as input. 

% Add necessary paths
current_dir=pwd;
addpath([current_dir filesep '..' filesep '..' filesep '..' filesep '..' filesep 'General_data' filesep 'Prep_FEniCS' filesep]);
datapath=[current_dir filesep '..' filesep 'Input_to_FEniCS' filesep];
addpath([current_dir filesep '..' filesep 'Prep_FEniCS' filesep]);
addpath([current_dir filesep '..' filesep '..' filesep '..' ]);
addpath([current_dir filesep '..' filesep ]);
import Extrapolation.*

clear ans data

% Load tissue_mat
load([datapath 'tissue_mat.mat']);
if exist('tissue_Matrix')
    tissue_mat=tissue_Matrix;
elseif exist('data')
    tissue_mat=data;
elseif exist('ans') 
    tissue_mat=ans;
end

% Load modelType
fid=fopen([datapath 'modelType.txt'], 'r');
modelType=fgetl(fid);

% Get water index depending on modelType
if startsWith(modelType, 'duke') == 1
    water_ind = 81;
elseif startsWith(modelType,'child') == 1
    water_ind = 30;
end

% Get boundary conditions
bnd_heat_trans=boundary_condition();

% Create new temperature vector
bnd_temp=temperature(new_temp);


% Mark the skin surface boundary with body/air/water
[surface_inner, surface_outer] = fetch_surface(tissue_mat, water_ind);

% Create and save new boundary matrices
bnd_heat_trans_mat = bnd_heat_trans(surface_inner);
bnd_temp_mat =  bnd_temp(surface_outer);
bnd_temp_times_ht_mat = bnd_heat_trans_mat .* bnd_temp_mat;

save(get_path('bnd_heat_transfer_mat', modelType), 'bnd_heat_trans_mat', '-v7.3');
save(get_path('bnd_temp_mat', modelType), 'bnd_temp_mat', '-v7.3');
save(get_path('bnd_temp_times_ht_mat', modelType), 'bnd_temp_times_ht_mat', '-v7.3');

% Move generated files to the right input folder for python code
from_path=([current_dir filesep '..' filesep '..' filesep 'Results' filesep 'Input_to_FEniCS' filesep modelType filesep]);
to_path=([current_dir filesep '..' filesep 'Input_to_FEniCS' filesep]);

load([from_path 'bnd_heat_transfer.mat']);
save([to_path 'bnd_heat_transfer.mat'], 'bnd_heat_trans_mat', '-v7.3');

load([from_path 'bnd_temp_times_ht.mat']);
save([to_path 'bnd_temp_times_ht.mat'], 'bnd_temp_times_ht_mat', '-v7.3');

load([from_path 'bnd_temp.mat']);
save([to_path 'bnd_temp.mat'], 'bnd_temp_mat', '-v7.3');

end