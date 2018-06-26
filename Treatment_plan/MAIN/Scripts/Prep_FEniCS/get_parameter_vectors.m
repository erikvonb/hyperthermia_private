function [thermal_conductivity, perf_cap, modified_perf_cap, heat_trans, temp_out, density, heat_capacity, perf] =...
          get_parameter_vectors(keyword, modelType)
% [thermal_conductivity, perf_cap, modified_perf_cap, heat_trans, temp_out] = GET_PARAMETER_VECTORS(path_name)
% Loads the data from a file specific type of file created by
% reload_parameters.m and outputs the four collums as arrays.

%% Load data from .m files

% Gets the boundrary conditions
heat_trans = boundary_condition();

% Sets the values for the temperatures in the same order as heat_trans
temp_out = temperature();

%% Load data from .txt file
% Reads the file with material properties
% In the read data the values for the tumor is incorrect
path = get_path(keyword, modelType);
paramMat = caseread(path);
paramMat(end,:)= []; % Removes the last two rows
[name, ~, heat_cap, thermal_conductivity, perf, modified_perf, dens] =...
strread(paramMat', '%s %d %f %f %f %f %f', 'whitespace', '\t');

% Finds the index of blood
%if startsWith(modelType, 'duke')
index_blood = strfind(name, 'BloodA');
index_blood = find(not(cellfun('isempty', index_blood)));
%end

% Multiplies the heat capacity and density of blood with the perfusion and
% density of other materials
%if startsWith(modelType, 'duke')
density=dens;
heat_capacity=heat_cap;
perfusion=perf;
if startsWith(modelType, 'duke')
    perf_cap = heat_cap(index_blood) .* perf .* dens .* dens(index_blood);
    modified_perf_cap = heat_cap(index_blood) .* modified_perf .* dens .* dens(index_blood);
elseif startsWith(modelType, 'child')
    perf_cap = 3617 .* perf .* dens .* 1040;
    modified_perf_cap = 3617 .* modified_perf .* dens .* 1040; 
end
%elseif startsWith(modelType, 'child')
   % dens
   % heat_capacity_const = 3617; %Use duke values to model blood perfusion since child does not have blood in model
  %  density_const = 1040; % Use duke values...
  %  perf_cap = heat_capacity .* perf .* density_const .* density_const;
 %   perfusion=perf;
%    modified_perf_cap = heat_cap_const .* modified_perf .* density_const .* density_const;
%end