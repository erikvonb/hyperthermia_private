function create_initial_perf_nonlin()

% Function that generates a matrix of the perfusion used for calculating
% the very first temperature in CompletePennes. Here, the intial
% temperature is assumed to be 37 deg C.

% NOTE: tissue_mat, modelType.txt and perfusion_original.mat needs to be provided
% in ../Scripts/Input_to_FEniCS 

% Model for modifying the perfusion for muscle, fat and tumor is obtained
% from "Impact of Nonlinear Heat Transfer on Temperature Control in
% Regional Hyperthermia" by Lang, Erdmann, Seebass

T=37; %assume initial temp

% load perfusion (not extrapolated)
current_dir=pwd;
datapath=[current_dir filesep '..' filesep 'Input_to_FEniCS' filesep]; 
addpath([current_dir filesep '..' filesep '..' filesep '..' filesep ]);
addpath([datapath filesep '..' filesep 'Prep_FEniCS' filesep]);

% load matrix for constant perfusion
load([datapath 'perfusion_original.mat']);
% load modelType
fid=fopen([datapath 'modelType.txt'], 'r');
modelType=fgetl(fid);
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

% Estimate perfusion according to model in report, using values for 37C
perf_muscle= 0.45+3.55*exp(-((T-45)^2)/12);
perf_fat= 0.36+0.36*exp(-((T-45)^2)/12);
perf_tumor= 0.833-((T-37)^4.8)/(5.438*10^3);

initial_perf_mat=perfusion;

%update values for each tissue
if startsWith(modelType, 'duke')
    index_muscle = find(tissue_mat==48);
    index_fat = find(tissue_mat==27);
    index_tumor = find(tissue_mat==80);
    
    initial_perf_mat(index_muscle)=perf_muscle;
    initial_perf_mat(index_fat)=perf_fat;
    initial_perf_mat(index_tumor)=perf_tumor;
    
elseif startsWith(modelType, 'child')
    index_muscle = find(tissue_mat==3);
    index_fat = find(tissue_mat==8); % Obs this is WM, cant find fat 
    index_tumor = find(tissue_mat==9);
    
    initial_perf_mat(index_muscle)=perf_muscle;
    initial_perf_mat(index_fat)=perf_fat;
    initial_perf_mat(index_tumor)=perf_tumor;  
end

% define indeces needed for extrapolation
if startsWith(modelType, 'duke') == 1
    water_ind = 81;
    ext_air_ind = 1;
elseif startsWith(modelType,'child') == 1
    water_ind = 30;
    ext_air_ind = 1;
end

% save matrices, both extrapolated and non-extrapolated
initial_perf_mat=initial_perf_mat(tissue_mat);
addpath([current_dir filesep '..' filesep] )
save(get_path('initial_perf_mat'), 'initial_perf_mat', '-v7.3');

interior_mat = tissue_mat ~= water_ind & tissue_mat ~= ext_air_ind;
[~,nearest_points] = Extrapolation.meijster(interior_mat);
save([current_dir filesep '..' filesep 'Prep_FEniCS' filesep 'tmp' filesep 'Stage2' filesep 'initial_perf'], 'initial_perf_mat', '-v7.3');
finalize('initial_perf_mat', nearest_points, modelType);

save([datapath 'initial_perf_mat_nonextrapolated'], 'initial_perf_mat', '-v7.3');


end
