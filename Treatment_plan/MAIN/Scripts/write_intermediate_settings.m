function write_intermediate_settings(path, E_fields, model_func, freq)

% Calculate settings for each Efield
wave_opt = E_fields.C.values; %Complex amplitudes
ant_opt = E_fields.C.keys; %Corresponding antennas
amplitudes = abs(wave_opt)';
phases = rad2deg(angle(wave_opt))';

settings = [amplitudes, phases, ant_opt']; %For first frequency
settings = sortrows(settings,3);
settings(:,3)=[];

writeSettings(path, settings, model_func, freq);

end