function layer = getLayer(Name)
%--------------------------------------------------------------------------
% FlyFly v2
%
% Jonas Henriksson, 2010                                   info@flyfly.se
%--------------------------------------------------------------------------
% getLayer obtains relevant layer information and stores it 


    % Get directory to stimulus folder and extract folder names
    stimDirectory = which('getLayer');
    stimDirectory = strsplit(stimDirectory, 'getLayer');
    stimDirectory = stimDirectory{1};

    fileNames = dir(fullfile(stimDirectory));
    fileNames = {fileNames.name}; % We only care about the names themselves

    % Loop over all file names to find stimuli folders, remove all other
    % names from the array
    stims = cellfun(@(x) getValidLayerNames(x), fileNames);
    stims = stims(~cellfun('isempty', stims));
    
    % Chop off the number from the stimuli folder to get just the stimuli name
    experimentNames = cellfun(@(x) x(5:end), stims);

    % If needing to initalise the main GUI, stop here
    if Name == "list"
        layer = experimentNames;
        return
    end
    


end

function layerName = getValidLayerNames(fileName)
    layerName = "";
    if str2double(fileName(1:3))
        layerName = fileName;
    end


end
