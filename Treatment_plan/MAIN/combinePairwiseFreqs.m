% freqs_to_combine = 400:25:500;
freqs_to_combine = [400, 500];

for i = 1:(length(freqs_to_combine)-1)
    for j = (i+1):length(freqs_to_combine)
        clearvars -except freqs_to_combine i j
        modelType = 'duke';
        nbrEfields = 16;
        PwrLimit = 1;
        goal_function = 'M1-C';
        iteration = 1;
        hsthreshold = 2;
%         particle_settings = [20, 20, 10];
        particle_settings = [2, 0, 10];
        thisfile = which('combinePairwiseFreqs');
        [thispath,~,~] = fileparts(thisfile);
        SavePath1 = [thispath filesep 'Data'];        
        
        freq = [freqs_to_combine(i), freqs_to_combine(j)];
        Main_notemp_nodialog;
    end
end