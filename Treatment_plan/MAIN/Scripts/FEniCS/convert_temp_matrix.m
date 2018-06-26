function temp_mat=convert_temp_matrix()

current_dir=pwd;
addpath([current_dir filesep '..' filesep 'Temperature' filesep])
temppath= [current_dir filesep '..' filesep 'FEniCS_results'];
temp_file=('temperature.h5');
temp= [temppath filesep temp_file];
load([temppath filesep 'tissue_mat.mat'])

% Find size
[a,b,c] = size(tissue_Matrix);
temp_mat = read_temperature(temp,1,1,1,a,b,c);
%save('')
end