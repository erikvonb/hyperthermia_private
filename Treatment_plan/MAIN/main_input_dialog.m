function [modelType, nbrEfields, pwrLimit, objective_f, iteration, ...
    hsthreshold, data_path, particle_settings, freq_vec, ...
    settings_files] = main_input_dialog()

cumulative_height = 0;
models = ["duke", "child"];
objectives = ["M1-M1", "M1-C", "M1-HTQ", "M2-M2"];
default_o1 = 'M1';
default_o2 = 'M1';
default_f1 = 500;
default_f2 = 0;
% Save these return values early to use in various functions.
modelType = 'duke';
objective_f = [default_o1 '-' default_o2];
freq_vec = [default_f1, default_f2];

total_width = 600;
sub_width = total_width/2 - 20;
sub_height = 18;
total_height = 500;

settings_files = containers.Map(["o1-f1", "o1-f2", "o2-f1", "o2-f2"], ...
    {find_settings_file('o1-f1'), ...
     find_settings_file('o1-f2'), ...
     find_settings_file('o2-f1'), ...
     find_settings_file('o2-f2')});

res = get(0, 'screensize');
l_main_pos = (res(3) - total_width) / 2;
b_main_pos = (res(4) - total_height) / 2;

f_main = uifigure('name', 'Input data', ...
    'position', [l_main_pos, b_main_pos, total_width, total_height]);
p_left = uipanel(f_main, ...
    'position', [0, 0, total_width/2, total_height], ...
    'title', 'Main settings');
p_right = uipanel(f_main, ...
    'position', [total_width/2, 0, total_width/2, total_height], ...
    'title', 'Load pre-saved settings');

make_control(p_left, 'text', 'Model type:', []);
mtype_h = make_control(p_left, 'dropdown', models, [], ...
    'valuechangedfcn', @(h, ~) update_var(h, 'model type'));
make_control(p_left, 'text', 'Number of E-fields:', []);
n_Ef_h = make_control(p_left, 'editnum', 16, []);
make_control(p_left, 'text', 'Antenna power limit (% of 150W):', []);
pwr_lim_h = make_control(p_left, 'editnum', 1, []);
make_control(p_left, 'text', 'Objective function:', []);
obj_f_h = make_control(p_left, 'dropdown', objectives, [], ...
    'valuechangedfcn', @(h, ~) update_text_right_panel(1, h));
make_control(p_left, 'text', 'Iteration number:', []);
it_num_h = make_control(p_left, 'editnum', 1, []);
make_control(p_left, 'text', 'Hotspot threshold:', []);
hs_t_h = make_control(p_left, 'editnum', 2, []);
make_control(p_left, 'text', 'Path to data folder:', []);
d_path_h = make_control(p_left, 'edittxt', get_path('data'), []);
make_control(p_left, 'text', 'Particle swarm size:', []);
ps_size_h = make_control(p_left, 'editnum', 2, []);
make_control(p_left, 'text', 'Max iterations:', []);
ps_max_iter_h = make_control(p_left, 'editnum', 1, []);
make_control(p_left, 'text', 'Max stall iterations:', []);
ps_stall_iter_h = make_control(p_left, 'editnum', 5, []);
% n_Ef_h = make_control(p_left, 'text', ...
%     sprintf('%s\n%s', 'Frequency(ies) (in MHz), ', 'one per row:'));
make_control(p_left, 'text', 'First frequency:', []);
freq_1_h = make_control(p_left, 'editnum', default_f1, [], ...
    'valuechangedfcn', @(h, ~) update_text_right_panel(2, h, 1));
make_control(p_left, 'text', 'Second frequency (0 if none):', []);
freq_2_h = make_control(p_left, 'editnum', default_f2, [], ...
    'valuechangedfcn', @(h, ~) update_text_right_panel(2, h, 2));

cumulative_height = 0;

h = make_settings_finder(p_right, ...
    [default_o1, ' ', num2str(default_f1), 'MHz'], 'o1-f1');
ox_fy_text_h{1} = h{1};
settings_file_checkbox_h{1} = h{3};
settings_path_text_h{1} = h{4};

h = make_settings_finder(p_right, ...
    [default_o1, ' ', num2str(default_f2), 'MHz'], 'o1-f2');
ox_fy_text_h{2} = h{1};
settings_file_checkbox_h{2} = h{3};
settings_path_text_h{2} = h{4};

h = make_settings_finder(p_right, ...
    [default_o2, ' ', num2str(default_f1), 'MHz'], 'o2-f1');
ox_fy_text_h{3} = h{1};
settings_file_checkbox_h{3} = h{3};
settings_path_text_h{3} = h{4};

h = make_settings_finder(p_right, ...
    [default_o2, ' ', num2str(default_f2), 'MHz'], 'o2-f2');
ox_fy_text_h{4} = h{1};
settings_file_checkbox_h{4} = h{3};
settings_path_text_h{4} = h{4};

make_control_no_advancement(f_main, 'button', 'OK', [10, 10, 40, 20], ...
    'buttonpushedfcn', @(~,~) closebutton());

uiwait(f_main)

if freq_vec(2) == 0
    freq_vec = freq_vec(1);
end

function update_var(h, varname)
    switch varname
        case 'model type'
            modelType = h.Value;
            update_settings_files();
        otherwise
            error('Invalid variable name identifier')
    end
end

function update_settings_files()
    i = 1;
    for str = ["o1-f1", "o1-f2", "o2-f1", "o2-f2"]
        if get(settings_file_checkbox_h{i}, 'Value') == 1
            settings_files(str) = find_settings_file(str);
            text = settings_files(str);
            tail_ind = max(1, length(text)-28);
            set(settings_path_text_h{i}, 'text', text(tail_ind:end));
        else
            settings_files(str) = 'NONE';
            set(settings_path_text_h{i}, 'text', 'NONE');
        end
        i = i + 1;
    end
end

function path = find_settings_file(str)
    funcs = strsplit(objective_f, '-');
    switch str
        case 'o1-f1'
            func = funcs{1};
            freq = freq_vec(1);
        case 'o1-f2'
            func = funcs{1};
            freq = freq_vec(2);
        case 'o2-f1'
            func = funcs{2};
            freq = freq_vec(1);
        case 'o2-f2'
            func = funcs{2};
            freq = freq_vec(2);
    end
    try_path = [get_path('data') filesep ...
        'settings_' modelType '_' func '_' num2str(freq) 'MHz.txt'];
    if exist(try_path, 'file') == 2
        path = try_path;
    else
        path = 'NONE';
    end
end

function choose_settings_file(str)
    % Opens file dialog, then saves the chosen file in settings_files(ind).
    [file, path] = uigetfile('*.txt', 'Choose settings file', ...
        get_path('data'));
    full_path = [path file];
    settings_files(str) = full_path;
    figure(f_main);
    tail_ind = max(1, length(full_path) - 28);
    switch str
        case 'o1-f1'
            set(settings_path_text_h{1}, 'text', full_path(tail_ind:end));
        case 'o1-f2'
            set(settings_path_text_h{2}, 'text', full_path(tail_ind:end));
        case 'o2-f1'
            set(settings_path_text_h{3}, 'text', full_path(tail_ind:end));
        case 'o2-f2'
            set(settings_path_text_h{4}, 'text', full_path(tail_ind:end));
    end
end

function update_text_right_panel(n, new_h, f_n)
    % Inputs:
    % n:      1 to update objective function names, 2 to update frequency
    % newval: the new objective function or frequency handle
    % f_n:    the frequency number (either 1 or 2)
    switch n
        case 1  % Change objective function text displayed
            str = new_h.Value;
            % Update return value early, for use in find_settings_file()
            objective_f = str;
            % Update text in right panel
            for i = 1:length(ox_fy_text_h)
                % str is the value of the objective function dropdown
                % value, e.g. 'M1-M1'.
                obj_funcs = strsplit(str, '-');
                text_h = ox_fy_text_h{i};
                strings = strsplit(get(text_h, 'Text'));
                new_string = [obj_funcs{ceil(i/2)}, ' ', strings{2}];
                set(text_h, 'Text', new_string);
            end
        case 2  % Change frequency text displayed
            f = new_h.Value;
            % Update return value early, for use in find_settings_file()
            if f_n == 1
                freq_vec(1) = f;
            else
                if f > 0
                    freq_vec(2) = f;
                end
            end
            % Update text in right panel
            for i = f_n:2:length(ox_fy_text_h)
                % f is the value of frequency number f_n.
                text_h = ox_fy_text_h{i};
                strings = strsplit(get(text_h, 'Text'));
                new_string = [strings{1}, ' ', num2str(f), 'MHz'];
                set(text_h, 'Text', new_string);
            end
    end
    update_settings_files();
end

function objs = make_settings_finder(p, content_text, ...
        func_freq_combo)
    path = settings_files(func_freq_combo);
    posvec_1 = [10, ...
                total_height - cumulative_height - 40, ...
                round(0.4 * sub_width), ...
                sub_height];
    posvec_2 = [10 + round(0.4 * sub_width), ...
                total_height - cumulative_height - 40, ...
                round((1-0.4)  * sub_width) - 20, ...
                sub_height];
    posvec_3 = [sub_width - 5, ...
                total_height - cumulative_height - 40, ...
                20, ...
                sub_height];
    posvec_4 = [10, ...
                total_height - cumulative_height - 40 - sub_height, ...
                sub_width, ...
                sub_height];
    
    objs{1} = make_control_no_advancement(p, 'text', content_text, posvec_1);
    objs{2} = make_control_no_advancement(p, 'button', 'Choose file', ...
        posvec_2, ...
        'buttonpushedfcn', @(~,~) choose_settings_file(func_freq_combo));
    objs{3} = uicheckbox(p, 'value', 1, ...
        'position', posvec_3, ...
        'text', '', ...
        'valuechangedfcn', @(~,~) update_settings_files());
    tail_ind = max(1, length(path)-28);
    objs{4} = make_control_no_advancement(p, ...
        'text', ['...' path(tail_ind:end)], ...
        posvec_4);
    
    cumulative_height = cumulative_height + 2 * sub_height;
end

function obj = make_control(p, type, content, posvec, varargin)
    % Adds a ui control to the parent and advances the cumulative height
    % variable, to automatically adjust the position of future control
    % elements.
    obj = make_control_no_advancement(p, type, content, posvec, varargin{:});
    cumulative_height = cumulative_height + sub_height;
end

function obj = make_control_no_advancement(p, type, content, posvec, varargin)
    % Adds a ui control element to the parent. Varargin is treaed as extra
    % name-value-pairs.
    if isempty(posvec)
        posvec = [10, total_height - cumulative_height - 40, ...
            sub_width, sub_height];
    end
    
    switch type
        case 'dropdown'
            obj = uidropdown(p, ...
                'items', content, ...
                'position', posvec);
        case 'text'
            posvec(4) = sub_height * (1 + floor(length(content)/33));
            posvec(2) = posvec(2) - sub_height * floor(length(content)/33);
            obj = uilabel(p, ...
                'text', content, ...
                'position', posvec);
        case 'editnum'
            obj = uieditfield(p, 'numeric', ...
                'value', content, ...
                'horizontalalignment', 'left', ...
                'position', posvec);
        case 'edittxt'
            obj = uieditfield(p, ...
                'value', content, ...
                'horizontalalignment', 'left', ...
                'position', posvec);
        case 'button'
            obj = uibutton(p, ...
                'text',  content, ...
                'position', posvec);
        otherwise
            error('Invalid UI control type');
    end
    
    for i = 1:2:length(varargin)
        set(obj, varargin{i}, varargin{i+1})
    end
end

function closebutton()
    collectInput()
    close(f_main)
end

function collectInput()
    modelType   = mtype_h.Value;
    nbrEfields  = n_Ef_h.Value;
    pwrLimit    = pwr_lim_h.Value;
    objective_f = obj_f_h.Value;
    iteration   = it_num_h.Value;
    hsthreshold = hs_t_h.Value;
    data_path   = d_path_h.Value;
    particle_settings(1) = ps_size_h.Value;
    particle_settings(2) = ps_max_iter_h.Value;
    particle_settings(3) = ps_stall_iter_h.Value;
    freq_vec(1) = freq_1_h.Value;
    freq_vec(2) = freq_2_h.Value;
end

end
