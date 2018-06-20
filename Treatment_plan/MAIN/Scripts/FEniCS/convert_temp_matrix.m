function temp_mat=convert_temp_matrix(tmp, tissue_mat)

% Find size
[a,b,c] = size(tissue_mat);

temp_mat = read_temperature(tmp,1,1,1,a,b,c);

end