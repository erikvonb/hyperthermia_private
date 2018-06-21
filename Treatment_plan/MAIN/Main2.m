%This is a part 2 of the spliced version of the main function to be used in 
%CompletePennes.py
%% Optimization
%Ändrat
fclose('all');
save ('iteration','iteration');
cd(mainpath);
directorymaker(hstreshold, iteration, freq, modelType, SavePath1);
SavePath=[SavePath1 filesep 'HTPData' filesep num2str(hstreshold),'_degree_',modelType, num2str(freq),'MHz',num2str(iteration)]
%Färdigändrat
if length(freq) ==1 
    EF_optimization_single(freq, nbrEfields, modelType, goal_function, particle_settings,hstreshold, iteration, SavePath)
elseif length(freq) ==2
    EF_optimization_double(freq, nbrEfields, modelType, goal_function, particle_settings)
elseif length(freq) >2
    error('Optimization does not currently work for more than two frequencies. Prehaps combine_single can be of use?')
end
