function layerData = flickerRectData()
    % Handles to the functions in this folder
    fcnPrep = @flickerRectPrep;
    fcnDraw = @flickerRectDraw;

    settingNames = {'Height', 'Width', 'Xpos', 'Ypos',...
                    'FramesPerFlicker', 'Brightness 1', 'Brightness 2'}; 
    
    % Data corresponds to the above setting names
    settingDefaults = [100; 80; 320; 240; 2; 0; 255];
    % Defaults for timing
    timingData = [60; 0; 0; 0];
    % Needed for layer settings manager to work
    settings.global = 1;
    settings.box{1} = {'Offset X function', 0};
    settings.box{2} = {'Offset Y function', 0};
    settings.edit{1}  = {'X function: ', '100*sin(2*pi/3 *(n-1)*ifi)'};
    settings.edit{2}  = {'Y function: ', '100*cos(2*pi/3 *(n-1)*ifi)'};

    layerData = struct(...
    'name',       'Flicker Rect', ...
    'fcnPrep',    fcnPrep, ...
    'fcnDraw',    fcnDraw, ...
    'parameters', {[settingNames, {'Time', 'PauseTime', 'PreStimTime', 'PostStimTime'}]}, ...
    'data',       [settingDefaults; timingData], ...
    'settings',   settings, ...
    'impulse',    false);