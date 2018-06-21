function temp_mat=convert_temp_matrix(temp, tissue_mat)

% Find size
[a,b,c] = size(tissue_mat);

current_dir=pwd;
scriptpath= [current_dir filesep '..' filesep 'Temperature'];
addpath(scriptpath);
temp_mat = read_temperature(temp,1,1,1,a,b,c);

end