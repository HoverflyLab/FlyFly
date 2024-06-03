function layerData = rollingImageM2Data()
    % Handles to the functions in this folder
    fcnPrep = @rollingImageM2Prep;
    fcnDraw = @rollingImageM2Draw;

    settingNames = {'Direction', 'Xpos', 'Ypos',...
                    'Height', 'Width', 'Contrast'}; 
    % Data corresponds to the above setting names
    settingDefaults = [0; 100; 100; 200; 200; 1];
    % Defaults for timing
    timingData = [60; 0; 0; 0];
    
    % Needed for layer settings manager to work
    settings.global   = 1;
    settings.path     = {'Image Path', 'Images/defaultImage.png', '*.png'};
    settings.boxes{1} = {'Image offset = ', 1};
    settings.boxes{2} = {'X pos = Xpos + ', 0};
    settings.boxes{3} = {'Y pos = Ypos + ', 0};
    settings.boxes{4} = {'Generate image', 0};
    settings.boxes{5} = {'Horizontal bars', 0};
    
    %T: Total experiment time
    %t: Time in current trial
    %n: Number of frames in total
    %k: Current trial
    settings.edit{1} = {'(internal roll)', '100*abs(2*(n/1 - floor(n/1+0.5)))'}; %period 1s
    settings.edit{2} = {'(patch movement)', '100*sin(n)'};
    settings.edit{3} = {'(patch movement)', '100*cos(n)'};
    settings.edit{4} = {'(width)','640'};
    settings.edit{5} = {'(height)','480'};
    

    layerData = struct(...
    'name',       "Rolling Image MII", ...
    'fcnPrep',    fcnPrep, ...
    'fcnDraw',    fcnDraw, ...
    'parameters', {[settingNames, {'Time', 'PauseTime', 'PreStimTime', 'PostStimTime'}]}, ...
    'data',       [settingDefaults; timingData], ...
    'settings',   settings, ...
    'impulse',    false);