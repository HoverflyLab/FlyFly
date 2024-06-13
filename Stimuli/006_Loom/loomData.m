function layerData = loomData()
    % Handles to the functions in this folder
    fcnPrep = @loomPrep;
    fcnDraw = @loomDraw;

    settingNames = {'L_HalfDiameter_m', 'V_Velocity_m_per_s', ...
                    'XPos', 'YPos', 'StopSize_pixels', 'LoomTime', ...
                    'Contrast1', 'Contrast2', 'FlickerFramesPerCycle'}; 
    % Data corresponds to the above setting names
    settingDefaults = [10; 10; 200; 200; 100; 0; 1; -1; 0];
    % Defaults for timing
    timingData = [60; 0; 0; 0];
    % Needed for layer settings manager to work
    settings.global = 1;
    settings.path  = {'Image Path', 'Images/circle_black.png', '*.*'};
    

    layerData = struct(...
    'name',       'Loom', ...
    'fcnPrep',    fcnPrep, ...
    'fcnDraw',    fcnDraw, ...
    'parameters', {[settingNames, {'Time', 'PauseTime', 'PreStimTime', 'PostStimTime'}]}, ...
    'data',       [settingDefaults; timingData], ...
    'settings',   settings, ...
    'impulse',    false);