function layer = getLayer(layerName)
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
stims = cell(1,length(fileNames));
for name = 3:length(fileNames) % Start from 3 to ignore the hidden files '.' and '..'
    % Check that the beginning of the file is a 3 digit number
    if ~isnan(str2double(fileNames{name}(1:3)))
        stims{name} = fileNames{name};
    end
end
stims = stims(~cellfun('isempty', stims));

% Chop off the number from the stimuli folder to get just the stimuli name
experimentNames = cellfun(@(x) x(5:end), stims, 'UniformOutput', false);

% If needing to initalise the main GUI, stop here
if layerName == "List"
    layer = experimentNames;
    return
end

% Search through all folders to grab the correct stimulus folder
fin = cellfun(@(x) regexp(x, layerName), fileNames, 'UniformOutput', false);
for index = 1:length(fin)
    if ~isempty(fin{index})
        chosenStim = index;
        break
    end
end

% Get a list of all files in the desired stimulus folder
stimFiles = dir(fullfile([stimDirectory, fileNames{chosenStim}]));
stimFiles = {stimFiles.name};

% Search through the stimulus folder to grab the correct data script
fin = cellfun(@(x) regexp(x, 'Data'), stimFiles, 'UniformOutput', false);
for index = 1:length(fin)
    if ~isempty(fin{index})
        stimData = index;
        break
    end
end
clear fin

% Run the data script and get the layer data
stimDataScript = stimFiles{stimData};
stimDataScript = strsplit(stimDataScript, '.m');
layer = eval(stimDataScript{1});
