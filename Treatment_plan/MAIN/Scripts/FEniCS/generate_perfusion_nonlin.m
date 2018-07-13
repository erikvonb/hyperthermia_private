function perfusion_mat=generate_perfusion_nonlin()
% Generates a perfusion matrix based on the constant perfusion matrix but the values
% for fat, muscle and tumor are modified according to a non-linear model. 
% The model for estimating the perfusion of fat, muscle and tumor is obtained from the
% report "Impact of Nonlinear Heat Transfer on Temperature Control in
% Regional Hyperthermia" by Lang, Erdmann, Seebass

% define paths
current_dir=pwd;
datapath=[current_dir filesep '..' filesep 'Input_to_FEniCS' filesep];
% load tissue mat
clear ans data
load([datapath 'tissue_mat.mat']);
if exist('tissue_Matrix')
    tissue_mat=tissue_Matrix;
elseif exist('data')
    tissue_mat=data;
elseif exist('ans') 
    tissue_mat=ans;
end
% load modelType
fid=fopen([datapath 'modelType.txt'], 'r');
modelType=fgetl(fid);
% load current perfusion
load([datapath 'initial_perf_mat_nonextrapolated.mat']);
if exist('perf_mat')
    perfusion_mat=perf_mat;
elseif exist('initial_perf_mat')
    perfusion_mat=initial_perf_mat;
else 
    disp("Perfusion matrix not loaded correctly");
end

% load current temperature
load([datapath 'temp_current.mat']);

% define indeces for tissues needed
if startsWith(modelType, 'duke')
    index_muscle = 48;
    index_fat = 27;
    index_tumor = 80;  
    water_ind = 81;
    ext_air_ind = 1;
elseif startsWith(modelType, 'child')
    index_muscle = 3;
    index_fat = 8; % Obs this is WM, cant find fat in tissue_file
    index_tumor = 9;
    water_ind = 30;
    ext_air_ind = 1;
end

% Change perfusion for the tumor -------------------
tumor=(tissue_mat==index_tumor);

% If temp in tumor < 37C
temp_lower_37=(temp_mat<37);
index_tumor_cold= find(temp_lower_37==tumor & temp_lower_37==1);
perfusion_mat(index_tumor_cold)=0.833; 

% If 37C <= temp in tumor <= 42C
temp_leq_42=(temp_mat<=42);
temp_geq_37=(temp_mat>=37);
index_tumor_middle= find(temp_leq_42==tumor & temp_geq_37==temp_leq_42 & temp_leq_42==1);
perfusion_mat(index_tumor_middle)=0.833-(((temp_mat(index_tumor_middle)-37).^4.8)/(5.438*10^3)); 

% If temp in tumor > 42C
temp_higher_42=(temp_mat>42);
index_tumor_hot= find(temp_higher_42==tumor & temp_higher_42==1);
perfusion_mat(index_tumor_hot)=0.416; 


% Change perfusion for muscle -----------------------
muscle=(tissue_mat==index_muscle);

% If temp in muscle <= 45C 
temp_leq_45=(temp_mat<=45);
index_muscle_less= find(temp_leq_45==muscle & temp_leq_45==1);
perfusion_mat(index_muscle_less)=0.45+3.55*exp(-((temp_mat(index_muscle_less)-45).^2)/12); 


% If temp in muscle > 45C
temp_higher_45=(temp_mat>45);
index_muscle_hot=find(temp_higher_45==muscle & temp_higher_45==1);
perfusion_mat(index_muscle_hot)=4;

% Change perfusion for fat --------------------------
fat=(tissue_mat==index_fat);

% If temp in fat <= 45C
index_fat_less=find(temp_leq_45==fat & temp_leq_45==1);
perfusion_mat(index_fat_less)=0.36+0.36*exp(-((temp_mat(index_fat_less)-45).^2)/12);

% If temp in fat > 45C
index_fat_hot=find(temp_higher_45==fat & temp_higher_45==1);
perfusion_mat(index_fat_hot)=0.72;

%-----------------------------------------------------

% save
perf_mat=perfusion_mat;
addpath([current_dir filesep '..' filesep] )
save(get_path('perfusion_mat'), 'perf_mat', '-v7.3');

% extrapolate to a form suitable to the python code and save 
interior_mat = tissue_mat ~= water_ind & tissue_mat ~= ext_air_ind;
[~,nearest_points] = Extrapolation.meijster(interior_mat);
finalize('perfusion_mat', nearest_points, modelType);

end


