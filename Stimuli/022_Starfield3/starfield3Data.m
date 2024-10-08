function layerData = starfield3Data()
    % Handles to the functions in this folder
    fcnPrep = @starfield3Prep2; 
    fcnDraw = @starfield3Draw;

    settingNames = {'Dot size', 'Dot density', ...
                    'Sideslip',  'Lift', 'Thrust', 'Pitch', 'Yaw', 'Roll', 'Duration'}; 
    % Data corresponds to the above setting names
    settingDefaults = [2; 1; 0; 0; 0; 0; 0; 0; 1];
    % Defaults for timing
    timingData = [60; 0; 0; 0];
    % Needed for layer settings manager to work
    settings.global = 1;

    

    layerData = struct(...
    'name',       "Starfield 3: Jumps", ...
    'fcnPrep',    fcnPrep, ...
    'fcnDraw',    fcnDraw, ...
    'parameters', {[settingNames, {'Time', 'PauseTime', 'PreStimTime', 'PostStimTime'}]}, ...
    'data',       [settingDefaults; timingData], ...
    'settings',   settings, ...
    'impulse',    false);