function layerData = matSequenceData()
    % Handles to the functions in this folder
    fcnPrep = @matSequencePrep;
    fcnDraw = @matSequenceDraw;

    settingNames = {'Fps', 'Xpos', 'Ypos'};
    % Data corresponds to the above setting names
    settingDefaults = [160; 320; 240];
    % Defaults for timing
    timingData = [60; 0; 0; 0];
    % Needed for layer settings manager to work
    settings.global   = 0;
    settings.path     = {'.Mat path: ', [cd '/Mat sequences/out.mat'], '*.mat'};
    settings.box{1} = {'Use fullscreen', 0};
    

    layerData = struct(...
    'name',       ".Mat Sequence", ...
    'fcnPrep',    fcnPrep, ...
    'fcnDraw',    fcnDraw, ...
    'parameters', {[settingNames, {'Time', 'PauseTime', 'PreStimTime', 'PostStimTime'}]}, ...
    'data',       [settingDefaults; timingData], ...
    'settings',   settings, ...
    'impulse',    false);