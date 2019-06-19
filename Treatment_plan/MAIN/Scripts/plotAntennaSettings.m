function plotAntennaSettings(settings_file_path, plotfilename)

% filepath = 'C:\Users\Erik\Documents\hyperthermia_repo\settings_testmod_420MHz.txt';
settings_file_path = 'C:\Users\Erik\Documents\hyperthermia_repo\Treatment_plan\MAIN\Results\T_and_final_settings\settings_child_450MHz.txt';
% settings_file_path = 'C:\Users\Erik\Documents\hyperthermia_repo\Treatment_plan\MAIN\Results\P_and_unscaled_settings\settings_duke_400500MHz.txt';
figures = [];
freqs = [];
% Read settings file and extract amplitudes/phases
f = readmatrix(settings_file_path);
% If more than one frequency was used in the optimization
if size(f,2) > 2
    num_antennas = size(f,1) - 1;
    fileID = fopen(settings_file_path);
    fgetl(fileID);
    line = fgetl(fileID);
    fclose(fileID);
    freqs = str2num(line(13:end));
    
    for i=1:2
        amplitudes = f(1:end-1, 2*i-1);
        % Convert amplitudes to relative amplitudes and make bar plot
        rel_amps = amplitudes / sum(amplitudes);
        fig = figure('visible', 'off');
        bar(rel_amps, 'barwidth', 0.7);
        labels = arrayfun(@(x) sprintf('%3.1f%%',x), 100*rel_amps, ...
            'UniformOutput', false);
        text(1:num_antennas, rel_amps, labels, ...
             'horizontalalignment', 'center', ...
             'verticalalignment', 'bottom', ...
             'fontsize', 7);
        ylim([0 1])
        pbaspect([20 3 1])
        xticks([])
        yticks([])
        title([num2str(freqs(i)) ' MHz'])
        figures = [figures, fig];
    end
    
else  % If only one frequency was used
    disp(f)
    num_antennas = size(f,1) - 2;
    fileID = fopen(settings_file_path);
    line = fgetl(fileID);
    freq = line(11:end);
    freqs = str2num(freq);
    
    amplitudes = f(2:end-1,1);
    % Convert amplitudes to relative effects(?) and make bar plot
    rel_amps = amplitudes / sum(amplitudes);
    fig = figure('visible', 'off');
    bar(rel_amps, 'barwidth', 0.7);
    labels = arrayfun(@(x) sprintf('%3.1f%%',x), 100*rel_amps, ...
        'UniformOutput', false);
    text(1:num_antennas, rel_amps, labels, ...
         'horizontalalignment', 'center', ...
         'verticalalignment', 'bottom', ...
         'fontsize', 7);
    ylim([0 1])
    pbaspect([20 3 1])
    xticks([])
    yticks([])
    title([num2str(freq) ' MHz'])
    figures = fig;
end

% Save as .eps and .png
for i = 1:length(figures)
    fig = figures(i);
    freq = freqs(i);
    thisfile = which('plotAntennaSettings');
    [thispath,~,~] = fileparts(thisfile);
    save_path = [thispath filesep '..' filesep 'Figures'];
    saveas(fig, [save_path filesep plotfilename '_' num2str(freq) 'MHz'], 'eps')
    saveas(fig, [save_path filesep plotfilename '_' num2str(freq) 'MHz'], 'png')
end

end