function layerData = sineGratingRfData()
    % Handles to the functions in this folder
    fcnPrep = @sineGratingRfPrep;
    fcnDraw = @sineGratingRfDraw;

    settingNames = {'Wavelength', 'Temporal Freq', 'Starting Direction', 'Steps' ...
                    'PatchHeight', 'patchWidth', 'Patch Xpos', 'Patch Ypos', 'Contrast'}; 
    % Data corresponds to the above setting names
    settingDefaults = [ 20; 2; 0; 16; 200; 200; 100; 100; 1];
    % Defaults for timing
    timingData = [60; 0; 0; 0];
    
    % Needed for layer settings manager to work
    settings.global = 1;
    settings.box{1}   = {'Counter Clockwise', 0};
    

    layerData = struct(...
    'name',       'Sine Grating RF', ...
    'fcnPrep',    fcnPrep, ...
    'fcnDraw',    fcnDraw, ...
    'parameters', {[settingNames, {'Time', 'PauseTime', 'PreStimTime', 'PostStimTime'}]}, ...
    'data',       [settingDefaults; timingData], ...
    'settings',   settings, ...
    'impulse',    false);