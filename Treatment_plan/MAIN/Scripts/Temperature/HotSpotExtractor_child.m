function [ChangeTemp, ChangeTempHSO] = HotSpotExtractor(hstreshold, iteration, freq)
%This script is used to make a logical matrix that substitutes
%healthy_tissue in future iterations based on the generated temperature
%matrix. Set folder 
addpath ..
olddir = pwd;
filename = which('Main');
[mainpath,~,~] = fileparts(filename);

cd(mainpath)
cd Results
cd T_and_final_settings
%Load the generated temperature matrix
load 'temp_child_450MHz'
Tempmatrix=mat;

% Load the tumor file and change value for all tissue besides the tumour's to 0
% This is used to isolate the 3D position of the tumor.
load 'tissue_mat_child.mat';
ChangeIndex=data;
ChangeIndex(ChangeIndex ~= 9) = 0;


%Make sure that the future healthy tissue matrix does not include the
%tumor. Subtracting the 3D position from the tumor matrix in the
%temperature matrix makes sure the tumor is not defined as a hot spot.

ChangeTemp=Tempmatrix-20*ChangeIndex;

%Set everything that is not a hot spot to zero and set hot spots to 1 for
%future iterations

ChangeTemp(ChangeTemp <= hstreshold) = 0;
ChangeTemp(ChangeTemp >0) = 1;
%clearvars -except ChangeTemp ChangeTemp.mat freq iteration hstreshold mainpath ChangeIndex ChangeIndex.mat
save('ChangeTemp.mat');
%Reload temperature matrix to make a standardized hot spot matrix for HSO-calculations.
%This is NOT needed for future iterations.
load 'temp_child_450MHz'
Tempmatrix=mat;
ChangeTempHSO=Tempmatrix-20*ChangeIndex;
%Ta bort allt förutom hot spots, gör till logical matris
ChangeTempHSO(ChangeTempHSO <= 0.75) = 0;
ChangeTempHSO(ChangeTempHSO >0) = 1;
%Clear undesired variables for saving
clearvars -except ChangeTemp ChangeTemp.mat freq iteration hstreshold mainpath


%Make directory and store data
save 'ChangeTemp',num2str(iteration),'.mat';
save 'ChangeTempHSO.mat';
copyfile('ChangeTemp.mat', mainpath, 'f')
cd(mainpath);
end
