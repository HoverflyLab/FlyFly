function layerData = starfieldFlickerData()
    % Handles to the functions in this folder
    fcnPrep = @starfieldFlickerPrep; 
    fcnDraw = @starfieldFlickerDraw; 

    settingNames = {'Dot size', 'Dot density', ...
                    'Sideslip',  'Lift', 'Thrust', 'Pitch', 'Yaw', 'Roll', ...
                    'Background Noise', 'RetainIntoNextTrial', ...
                    'Contrast1', 'Contrast2', 'FlickerFramesPerCycle'};
    % Data corresponds to the above setting names
    settingDefaults = [2; 1; 0; 0; 0; 0; 0; 0; 0; 0; 1; -1; 0];
    % Defaults for timing
    timingData = [60; 0; 0; 0];
    % Needed for layer settings manager to work
    settings.global = 1;

    layerData = struct(...
    'name',       "Starfield Flicker", ...
    'fcnPrep',    fcnPrep, ...
    'fcnDraw',    fcnDraw, ...
    'parameters', {[settingNames, {'Time', 'PauseTime', 'PreStimTime', 'PostStimTime'}]}, ...
    'data',       [settingDefaults; timingData], ...
    'settings',   settings, ...
    'impulse',    false);