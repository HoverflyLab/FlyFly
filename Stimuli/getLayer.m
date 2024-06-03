function layer = getLayer(Name)
%--------------------------------------------------------------------------
% FlyFly v2
%
% Jonas Henriksson, 2010                                   info@flyfly.se
%--------------------------------------------------------------------------
% getLayer obtains relevant layer information and stores it for when 

    % Default settings for all objects
    settings.global = 1;
    settings.path1  = {'OFF', 0};
    settings.box1   = {'OFF', 0};
    settings.box2   = {'OFF', 0};
    settings.box3   = {'OFF', 0};
    settings.box4   = {'OFF', 0};
    settings.box5   = {'OFF', 0};
    settings.edit1  = {'OFF', 0};
    settings.edit2  = {'OFF', 0};
    settings.edit3  = {'OFF', 0};
    settings.edit4  = {'OFF', 0};
    settings.edit5  = {'OFF', 0};

    % Get directory to stimulus folder and extract folder names
    stimDirectory = which('getLayer');
    stimDirectory = strsplit(stimDirectory, 'getLayer');
    stimDirectory = stimDirectory{1};

    fileNames = dir(fullfile(stimDirectory));

    % Loop over all file names to find stimuli folders, remove all other
    % names from the array
    stims = cellfun(@(x) getValidLayerNames(x), fileNames);
    stims = stims(~cellfun('isempty', stims));
    
    % Chop off the number from the stimuli folder to get just the stimuli name
    experiment_names = cellfun(@(x) x(5:end), stims);                                                    % 19
            
    % common_data = the default timing data
    common_data = [60; 0; 0; 0];
    % If individual stimuli require something other than the default, modify
    % timing_data instead of common_data
    timing_data = common_data;
    
    switch Name
        
        case 'List' %return list of available draw functions
            layer = experiment_names;
            
        otherwise
            switch Name
            end
            
            %set layer
            
            layer = struct(...
                'name',       experiment_names{Name}, ...
                'fcnPrep',    fcnPrep, ...
                'fcnDraw',    fcnDraw, ...
                'parameters', {[rowNames, {'Time', 'PauseTime', 'PreStimTime', 'PostStimTime'}]}, ...
                'data',       [data; timing_data], ...
                'settings',   settings, ...
                'impulse',    false);
    end

end

function layerName = getValidLayerNames(fileName)
    layerName = "";
    if str2double(fileName(1:3))
        layerName = fileName;
    end


end
