function layerData = rectTargetData()
    % Handles to the functions in this folder
    fcnPrep = @rectTargetPrep;
    fcnDraw = @rectTargetDraw;

    settingNames = {'Height', 'Width', 'Xpos', 'Ypos',...
                    'Velocity', 'Direction', 'Brightness'};
    % Data corresponds to the above setting names
    settingDefaults = [ 5; 5; 100; 100; 60; 0; 0];
    % Defaults for timing
    timingData = [60; 0; 0; 0];
    % Needed for layer settings manager to work
    settings.global = 1;

    

    layerData = struct(...
    'name',       'Rect Target', ...
    'fcnPrep',    fcnPrep, ...
    'fcnDraw',    fcnDraw, ...
    'parameters', {[settingNames, {'Time', 'PauseTime', 'PreStimTime', 'PostStimTime'}]}, ...
    'data',       [settingDefaults; timingData], ...
    'settings',   settings, ...
    'impulse',    false);