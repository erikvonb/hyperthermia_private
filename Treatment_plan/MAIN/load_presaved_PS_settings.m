function vec = load_presaved_PS_settings(settings_file_path, n)

if strcmp(settings_file_path, 'NONE')
    vec = zeros(1, 2*n);
    vec(1:2:end) = 1;
    return
end

f = readmatrix(settings_file_path);
amplitudes = f(2:end-1, 1);
phases = f(2:end-1, 2);
re = cos(deg2rad(phases)).*amplitudes;
im = sin(deg2rad(phases)).*amplitudes;
set = [re im];
set = set';
vec = set(:);
vec = vec';

end
