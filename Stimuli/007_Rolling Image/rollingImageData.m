function layerData = rollingImageData()
    % Handles to the functions in this folder
    fcnPrep = @rollingImagePrep;
    fcnDraw = @rollingImageDraw;

    settingNames = {'Speed', 'Direction', 'Xpos', 'Ypos',...
                    'Height', 'Width', 'Offset', 'Contrast'};
    % Data corresponds to the above setting names
    settingDefaults = [10; 0; 320; 240; 480; 640; 0; 1];
    % Defaults for timing
    timingData = [60; 0; 0; 0];
    % Needed for layer settings manager to work
    settings.global = 1;
    settings.path     = {'Image Path', 'Images/defaultImage.png', '*.png'};
    settings.boxes{1} = {'Keep Offset', 0};
    settings.boxes{2} = {'DLP  mode', 0};
    settings.boxes{3} = {'Generate image', 0};
    settings.boxes{4} = {'Horizontal bars', 0};
    settings.edit{3}  = {'(width)','640'};
    settings.edit{4}  = {'(height)','480'};

    

    layerData = struct(...
    'name',       "Rolling Image", ...
    'fcnPrep',    fcnPrep, ...
    'fcnDraw',    fcnDraw, ...
    'parameters', {[settingNames, {'Time', 'PauseTime', 'PreStimTime', 'PostStimTime'}]}, ...
    'data',       [settingDefaults; timingData], ...
    'settings',   settings, ...
    'impulse',    false);