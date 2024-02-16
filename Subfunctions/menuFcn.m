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
        %OBS! Remember to ask for saving!
        
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
        [fileName,pathName,FilterIndex] = uiputfile(strcat(defaultFolder, '*.mat'));
        
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
            
            load(strcat(pathName, fileName));
            loadedFiles = who; %names of files currently in workspace.
            %should probably be Option, chstimuli, navData, fileName,
            %loadedFiles, screenData and pathName
            
            if find(ismember(loadedFiles, 'chstimuli') == 1) %everything ok
                
                setappdata(0, 'chstimuli', chstimuli);
                setappdata(0, 'navData'  , navData);
                
                tempData = getappdata(0, 'screenData');
                
                %load old screen values if no screen is currently active
                if ~tempData.isInit
                    setappdata(0, 'screenData' , screenData);
                end
                
            else
                disp('incorrect file');
            end;
            
        end
        
    case 'importStim'
        
        disp('This function is not properly debugged, use with care');
        
        %uigetfile(string): string may be pathname (c:/folder/*.mat)
        [fileName,pathName] = uigetfile(strcat(defaultFolder, '*.mat'));
        
        if fileName %if press on cancel no fileName will be given
            
            load(strcat(pathName, fileName));
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
                        insertIndex = str2num(insertIndex{1});
                        
                        if insertIndex == 1 %first spot reserved for main
                            insertIndex = 2;
                        end
                        
                        if insertIndex > length(chstimuli) +1 %no spaces in array
                            insertIndex = length(chstimuli) +1;
                        end
                        
                        if insertIndex == length(chstimuli) +1; %place last
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
            end;
            
        end
        
    otherwise
        disp(['menuFcn: Case does not exist (' Option ')']);
end
