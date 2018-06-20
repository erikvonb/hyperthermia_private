function[dir] = directorymaker(hstreshold, iteration, freq, modelType, SavePath1)
olddir = pwd;
cd (SavePath1)
if exist('HTPData','dir')==7
    cd 'HTPData'
else
    mkdir(SavePath1,'HTPData');
    cd 'HTPData'
end

mkdir([num2str(hstreshold),'_degree_',modelType, num2str(freq),'MHz',num2str(iteration)])
addpath([num2str(hstreshold),'_degree_',modelType, num2str(freq),'MHz',num2str(iteration)])
cd([num2str(hstreshold),'_degree_',modelType, num2str(freq),'MHz',num2str(iteration)])
SavePath=pwd;
cd(olddir)
end