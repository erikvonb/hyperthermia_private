% MAIN
% This script contains all necessary steps to complete a hyperthermia
% treatment plan. 

% Run all or run in sections
% Current directory sould be MAIN !
% ------------------------------------------------------------------------

% Inputs and compilation
diary off
clear all
addpath ..
olddir = pwd;
filename = which('Main');
[mainpath,~,~] = fileparts(filename);

% Set up log directory
c = clock;
logpath = [mainpath filesep 'Logs'];
logfoldername = ['logs_' num2str(c, '%d_%d_%d_%d_%d_%2.0f')];
mkdir(logpath, logfoldername);
logpath = [logpath filesep logfoldername];
cmd_logname = 'cmd_window_output.txt';
diary([logpath filesep cmd_logname]);
fid = fopen([mainpath filesep 'currentlogname'], 'w');
fprintf(fid, logfoldername);
fclose(fid);

cd(mainpath)
addpath([mainpath filesep 'Scripts' filesep 'Optimization'])
addpath([mainpath filesep 'Scripts'])

[modelType, nbrEfields, PwrLimit, objective_func, iteration, hsthreshold, ...
    SavePath1, particle_settings, freq, initial_PS_settings_files, ...
    freq_combs, use_parallel] = main_input_dialog();
hyp_compile
hyp_init

%% Optimization
fclose('all');
save ('iteration','iteration');
cd(mainpath);
directorymaker(hsthreshold, iteration, freq, modelType, SavePath1);
SavePath = [SavePath1 filesep 'HTPData' filesep num2str(hsthreshold) '_degree_' modelType num2str(freq) 'MHz' num2str(iteration)];

if length(freq) == 1
    % TODO: make single work
    EF_optimization_single(freq, nbrEfields, modelType, objective_func, particle_settings, iteration)
elseif length(freq) == 2
    freq_opt = EF_optimization_double_C(freq, nbrEfields, modelType, ...
        objective_func, particle_settings, ...
        initial_PS_settings_files, freq_combs, use_parallel);
elseif length(freq) > 2
    error('Optimization does not currently work for more than two frequencies. Prehaps combine_single can be of use?')
end

%% Generate FEniCS Parameters
% fclose('all');
% cd(mainpath)
% message1 = msgbox('Optimization finished! Generating FEniCS parameters. ','Success');
% t = timer('ExecutionMode', 'singleShot', 'StartDelay',3,'TimerFcn',@(~,~)close(message1));
% start(t);
% isopath = [mainpath filesep '..' filesep 'Libs' filesep 'iso2mesh'];
% fenicspath = [mainpath filesep 'Scripts' filesep 'Prep_FEniCS']; 
% preppath = [fenicspath filesep 'Mesh_generation'];
% addpath(isopath, fenicspath, preppath) 
% 
% generate_fenics_parameters(modelType, freq_opt, true)
% generate_amp_files(modelType, freq_opt, nbrEfields, PwrLimit)
% cd(olddir)
% 
% %% Temperature
% temppath = [mainpath filesep 'Scripts' filesep 'Temperature'];
% addpath(temppath);
% evaluate_temp(modelType, freq, true, hsthreshold, iteration);
% save_scaled_settings(modelType, freq, nbrEfields);
% disp('Finished, storing temperature files and settings...')
% HotSpotExtractor_child(hsthreshold, iteration, freq);
% copyfile('Results', SavePath, 'f');
% 
% message4 = msgbox('You have now finished the optimization and temperature transformation. You rock!', 'Hot stuff!');
% u = timer('ExecutionMode', 'singleShot', 'StartDelay',5,'TimerFcn',@(~,~)close(message4));
% start(u);
% LocateLeo = [mainpath filesep 'Scripts'];
% GoodJob = [LocateLeo filesep 'Leonardo-DiCaprio-Clap.gif'];
% fig = figure;
% gifplayer(GoodJob,0.1);
% r = timer('ExecutionMode', 'singleShot', 'StartDelay',1.5,'TimerFcn',@(~,~)close(fig));
% start(r);
% cd(olddir)
% iteration=iteration+1;
% fclose('all');
diary off
delete currentlogname
