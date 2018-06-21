%This is a part 3 of the spliced version of the main function to be used in 
%CompletePennes.py
fclose('all');
cd Results\Input_to_FEniCS\child;
delete *.mat *.txt *.xml *.obj;
cd(mainpath)
message1 = msgbox('Optimization finished! Generating FEniCS parameters. ','Success');
t = timer('ExecutionMode', 'singleShot', 'StartDelay',3,'TimerFcn',@(~,~)close(message1));
start(t);
isopath = [mainpath filesep '..' filesep 'Libs' filesep 'iso2mesh'];
fenicspath = [mainpath filesep 'Scripts' filesep 'Prep_FEniCS']; 
preppath = [fenicspath filesep 'Mesh_generation'];
addpath(isopath, fenicspath, preppath) 

generate_fenics_parameters(modelType, freq, true)
generate_amp_files(modelType, freq, nbrEfields, PwrLimit)
cd(olddir)
