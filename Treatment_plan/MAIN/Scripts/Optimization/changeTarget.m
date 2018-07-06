function [modtumor_oct] = changeTarget(modelType, freq)
%This script intends to change the target area of the tumor, in order to
%change focus point of the E-field.
%The output of this file is ready to be used as an input to in OptimizeM1/M2 
%instead of tumor_oct. Eg. se EF_optimization_single.m row 105.
%
%The target of the tumor is changed by exploiting the temperature generated
%in FEniCS. The target can also be changed by using the PLD-matrix with a
%new threshold, but this in not implemented.

filename = which('changeTarget');
[path,~,~] = fileparts(filename);
datapath = [path filessep 'Data']; %path to Data
resultpath = [path filesep Results]; %path to results
addpath([path filesep '..']); %package path

if startsWith(modelType,'duke') == 1
    tumor_ind = 80;
elseif startsWith(modelType,'child') == 1
    tumor_ind = 9;
end
%load the tissue matrix
tissue_mat = Yggdrasil.Utils.load([datapath filesep 'tissue_mat_' modelType '.mat']);
tumor_mat = tissue_mat == tumor_ind; %take out the tumor

%load temperature matrix
temp_mat = Extrapolation.load([resultpath filesep 'T_and_final_settings' filesep 'temp_' modelType '_' freq 'MHz.mat']);

%extract tumor temperature
tumor_temp = temp_mat(tumor_mat);
%exclude tumor parts that has large upptake of energy
% maximum raise is set to 2 degrees raise in temperature, can be changed e.g. depending on what T10, T50 is in previous simmulation
new_target = tumor_temp <= 2; 
modtumor_oct = Yggdrasil.Octree(single(new_target)); %this is input the new input in Optimize functions
end

