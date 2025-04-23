function menuFcn(Option)
%function menuFcn(Option)
%
%collection of functions used in menu

%--------------------------------------------------------------------------
% FlyFly v2
%
% Jonas Henriksson, 2010                                   info@flyfly.se
%--------------------------------------------------------------------------

    if ismac
        defaultFolder = '../../Documents/Data/'; %MAC
    else
        defaultFolder = '';  %WIN
    end
    
    switch Option
        
        case 'New'
            answer = questdlg('Start New Project? Unsaved changes will be lost and the screen closed down.');
            
            if strcmp(answer, 'Yes')
                %Close current window and launch main. Using close instead of
                %delete means that the regular close function is called, wich kills
                %any open Screen object and sets the root objects to [].
                close(gcf);
                main;
            end
            
        case 'SaveAs'
            navData    = getappdata(0, 'navData');
            chstimuli  = getappdata(0, 'chstimuli');
            screenData = getappdata(0, 'screenData');
            
            %uiputfile(string): string may be pathname (c:/folder/*.mat)
            [fileName,pathName,~] = uiputfile(strcat(defaultFolder, '*.mat'));
            
            if fileName %if press on cancel no fileName will be given
                navData.fileName = fileName;
                navData.pathName = pathName;
                navData.saved    = 1;
                
                save(strcat(pathName, fileName), 'chstimuli', 'navData', 'screenData');
            end
            
            setappdata(0, 'navData', navData);
        case 'Open'
            %remember to check if not saved!
            %uigetfile(string): string may be pathname (c:/folder/*.mat)
            [fileName,pathName] = uigetfile(strcat(defaultFolder, '*.mat'));
            
            if fileName   % FileName == false if canceled
                % Cancel annoying warnings as we already have tests later
                % on for correct data format
                warning off
                load(strcat(pathName, fileName), 'chstimuli', 'navData', 'screenData', 'stimulus', 'Stimulus', 'debugData');
                warning on
                loadedFiles = who; %names of files currently in workspace.
                %should probably be Option, chstimuli, navData, fileName,
                %loadedFiles, screenData and pathName
                
                if find(ismember(loadedFiles, 'chstimuli') == 1) %everything ok
                    try
                        if isfield(chstimuli(2).layers(1).settings(1), 'box1')
                            chstimuli = convertOldStimSettings(chstimuli);
                            disp("Old stimuli patched successfully")
                        end
                    catch ERR
                        disp("Layer settings issue, see below. Skipping patching")
                        rethrow(ERR)
                    end

                    % Check if user has a pre-4.0 stimulus
                    if isfield(screenData, 'useSplitScreen')
                        screenData.useSplitScreen = 0;
                        screenData.splitDir       = "Vertically";
                        screenData.splitPos       = 320;
                        screenData.backgroundInit = 0;
                    end
                    
                    setappdata(0, 'chstimuli', chstimuli);
                    setappdata(0, 'navData'  , navData);
                    
                    tempData = getappdata(0, 'screenData');
                    
                    % Load old screen values if no screen is currently active
                    if ~tempData.isInit
                        if ~isfield(screenData, "useRotated")
                            screenData.useRotated = 0;
                        end
                        if ~isfield(screenData, "useGuvcview")
                            screenData.useGuvcview = 0;
                        end
                        setappdata(0, 'screenData' , screenData);
                    else
                        disp('did not load screenData as the screen is already in use!')
                    end
                    
                elseif any(find(ismember(loadedFiles, 'stimulus') == 1)) || any(find(ismember(loadedFiles, 'Stimulus') == 1))
                    % In this case, where the user is loading a single
                    % parameter file, initialise just the single stimuli
                    
                    % Start by resolving annoying capitalisation issues >:(
                    if any(find(ismember(loadedFiles, 'Stimulus') == 1))
                        stimulus = Stimulus;
                    end
                    chstimuli = initFcn('InitChstimuli');
                    chstimuli(2).layers = stimulus.layers;
                    % Double check if we need to patch the stimuli
                    if isfield(chstimuli(2).layers(1).settings(1), 'box1')
                        chstimuli = convertOldStimSettings(chstimuli);
                        disp("Old stimuli patched successfully")
                    else
                        for layer = 1:length(stimulus.layers)
                            chstimuli(2).layers(layer).data = debugData.stimulus.layers(layer).data;
                            chstimuli(2).layers(layer).parameters = debugData.stimulus.layers(layer).parameters;
                        end
                    end
                    chstimuli(2).name = stimulus.name;
                    chstimuli(2).fileNameGui = 'tableGui';
                    chstimuli(2).settingsGui = 'settingsGui';
                    chstimuli(2).hGui = 0;
                    chstimuli(2).targetBgColor = stimulus.targetBgColor;
                    chstimuli(2).stimSettings = 0;

                    % Remember to save the app data!
                    setappdata(0, 'chstimuli', chstimuli);
                    % % And take out the screen settings used then
                    % tempData = getappdata(0, 'screenData');
                    % % Load old screen values if no screen is currently active
                    % screenData = debugData.screenData;
                    % if ~tempData.isInit
                    %     if ~isfield(screenData, "useGuvcview")
                    %         screenData.useGuvcview = 0;
                    %     end
                    %     setappdata(0, 'screenData' , screenData);
                    % else
                    %     disp('did not load screenData as the screen is already in use!')
                    % end
                else
                    disp('incorrect file');
                end
                
            end
            
        case 'importStim'
            
            disp('This function is not properly debugged, use with care');
            
            %uigetfile(string): string may be pathname (c:/folder/*.mat)
            [fileName,pathName] = uigetfile(strcat(defaultFolder, '*.mat'));
            
            if fileName %if press on cancel no fileName will be given
                
                load(strcat(pathName, fileName), 'chstimuli');
                loadedFiles = who; %names of files currently in workspace.
                %should probably be Option, chstimuli, navData, fileName,
                %loadedFiles, screenData and pathName
                
                if find(ismember(loadedFiles, 'chstimuli') == 1) %everything ok
                    
                    indice = inputdlg('Enter indice to use in matlab array format. Eg, [5], [2:6], [2 3 5 6] or [3:6 8 10:12]');
                    
                    if ~isempty(indice)
                        indice = indice{1};
                        
                        try
                            loadedStim = chstimuli(eval(indice));
                        catch e
                            disp('Incorrect indice') ;
                            disp(e.message);
                        end
                        
                        chstimuli   = getappdata(0, 'chstimuli');
                        navData     = getappdata(0, 'navData');
                        
                        insertIndex = inputdlg('Enter index to insert new stim in: ');
                        
                        if ~isempty(insertIndex)
                            insertIndex = str2double(insertIndex{1});
                            
                            if insertIndex == 1 %first spot reserved for main
                                insertIndex = 2;
                            end
                            
                            if insertIndex > length(chstimuli) +1 %no spaces in array
                                insertIndex = length(chstimuli) +1;
                            end
                            
                            if insertIndex == length(chstimuli) +1 %place last
                                chstimuli = [chstimuli loadedStim];
                            else
                                stimuliBefore = chstimuli(1:insertIndex-1);
                                stimuliAfter  = chstimuli(insertIndex:end);
                                
                                chstimuli = [stimuliBefore loadedStim stimuliAfter];
                            end
                            
                            navData.numStim = length(chstimuli);
                            
                            %instead of reading the correct marker values from
                            %the imported stimuli we just set all markers to
                            %point to the first layer. (lazy!)
                            navData.marker = ones(1, length(chstimuli));
                            
                            setappdata(0, 'chstimuli', chstimuli);
                            setappdata(0, 'navData', navData);
                        end
                    end
                    
                else
                    disp('incorrect file');
                end
                
            end
            
        otherwise
            disp(['menuFcn: Case does not exist (' Option ')']);
    end
end

% For older stimuli (pre-4.2), stims need to be patched to handle new
% stimuli framework. This function handles looping through all layers
function patchedStim = convertOldStimSettings(chstimulus)
    disp("This stimulus was created prior to FlyFly 4.2, please wait as we update your stimulus for compatability.")
    patchedStim = chstimulus(1);
    % Loop over all stims, layers, and settings (excluding main waindow)
    for stim = 2:length(chstimulus)
        currentStim = chstimulus(stim);
        for layer = 1:length(currentStim.layers)
            currentLayer = currentStim.layers(layer);
            for setting = 1:length(currentLayer.settings)
                % Patch the current settings file
                currentSetting = currentLayer.settings(setting);
                patchedStim(stim).layers(layer).settings(setting) = reformatSettings(currentSetting);
            end
            % If there's a params file, convert it into the current 'data' format
            if isfield(currentLayer, 'Param')
                data = struct2cell(currentLayer.Param);
                data = cell2mat(data);
                data = squeeze(data);
                patchedStim(stim).layers(layer).data = data;
                patchedStim(stim).layers(layer).parameters = fieldnames(currentLayer.Param)'; 
            else
                patchedStim(stim).layers(layer).data = currentLayer.data;
                patchedStim(stim).layers(layer).parameters = currentLayer.parameters;
            end
            % Carry over other important layer settings
            patchedStim(stim).layers(layer).name    = currentLayer.name;
            patchedStim(stim).layers(layer).fcnPrep = currentLayer.fcnPrep;
            patchedStim(stim).layers(layer).fcnDraw = currentLayer.fcnDraw;
            patchedStim(stim).layers(layer).impulse = currentLayer.impulse;
            patchedStim(stim).fileNameGui = 'tableGui';
            patchedStim(stim).settingsGui = 'settingsGui';
            patchedStim(stim).hGui = 0;
            patchedStim(stim).name = currentStim.name;
            patchedStim(stim).targetBgColor = currentStim.targetBgColor;
            patchedStim(stim).stimSettings = 0;
        end
    end
end

% This function actually patches each layer
function formattedSetting = reformatSettings(settings)
    formattedSetting.global = settings.global;
    if settings.path1{1} ~= "OFF"
        formattedSetting.path = settings.path1;
    end
    if settings.box1{1} ~= "OFF"
        for index = 1:5
            if eval("settings.box" + num2str(index) + "{1}") ~=  "OFF"
                formattedSetting.box{index} = eval("settings.box" + num2str(index));
            else
                break
            end
        end
    end
    % Is this incredibly janky? Yes, but this is needed to patch old
    % stimuli effectively :(
    if any([convertCharsToStrings(settings.edit1{1}) ~= "OFF", convertCharsToStrings(settings.edit2{1}) ~= "OFF", convertCharsToStrings(settings.edit3{1}) ~= "OFF", convertCharsToStrings(settings.edit4{1}) ~= "OFF", convertCharsToStrings(settings.edit5{1}) ~= "OFF"])
        position = 1;
        for index = 1:5
            if eval("settings.edit" + num2str(index) + "{1}") ~=  "OFF"
                formattedSetting.edit{position} = eval("settings.edit" + num2str(index));
                position = position + 1;
            end
        end
    end
end




