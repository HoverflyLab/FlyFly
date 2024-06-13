function layerData = colorFillData()
    % Handles to the functions in this folder
    fcnPrep = @colorFillPrep;
    fcnDraw = @colorFillDraw;

    settingNames = {'Brightness'}; 
    % Data corresponds to the above setting names
    settingDefaults = 127;
    % Defaults for timing
    timingData = [60; 0; 0; 0];
    % Needed for layer settings manager to work
    settings.global = 1;

    layerData = struct(...
    'name',       'Color Fill', ...
    'fcnPrep',    fcnPrep, ...
    'fcnDraw',    fcnDraw, ...
    'parameters', {[settingNames, {'Time', 'PauseTime', 'PreStimTime', 'PostStimTime'}]}, ...
    'data',       [settingDefaults; timingData], ...
    'settings',   settings, ...
    'impulse',    false);