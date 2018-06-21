%This is a part 1 of the spliced version of the main function to be used in 
%CompletePennes.py

%Temperature
temppath = [mainpath filesep 'Scripts' filesep 'Temperature'];
addpath(temppath);
evaluate_temp(modelType, freq, true, hstreshold, iteration);
save_scaled_settings(modelType, freq, nbrEfields);
disp('Finished, storing temperature files and settings...')
HotSpotExtractor_child(hstreshold, iteration, freq);
copyfile('Results', SavePath, 'f');

   
message4 = msgbox('You have now finished the optimization and temperature transformation. You rock!', 'Hot stuff!');
u = timer('ExecutionMode', 'singleShot', 'StartDelay',5,'TimerFcn',@(~,~)close(message4));
start(u);
LocateLeo = [mainpath filesep 'Scripts'];
GoodJob = [LocateLeo filesep 'Leonardo-DiCaprio-Clap.gif'];
fig = figure;
gifplayer(GoodJob,0.1);
r = timer('ExecutionMode', 'singleShot', 'StartDelay',1.5,'TimerFcn',@(~,~)close(fig));
start(r);0
cd(olddir)
iteration=iteration+1
fclose('all');
