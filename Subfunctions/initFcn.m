function init = initFcn(Option)
%function init = initFcn(Option)
%
% handles initialization of chstimuli, avstimuli and navdata.

%--------------------------------------------------------------------------
% FlyFly v2
%
% Jonas Henriksson, 2010                                   info@flyfly.se
%--------------------------------------------------------------------------

switch Option
    case 'InitChstimuli'
        %data of main window
        layer = struct( ...
            'data',       [], ...
            'parameters', {'No parameter table in main window!'});

        init = struct( ...
            'name', {'Main'}, ...            
            'fileNameGui', {'main'}, ...            
            'settingsGui', {'mainSettings'} ,...
            'hGui', {0}, ...
            'layers', layer, ...
            'targetBgColor', 255, ...
            'stimSettings', {0});

    case 'InitNavData'
        
        navData.fileName   = 'New Project'; %name of this current project
        navData.pathName   = '';            %path name of project file
        navData.saved      = 0;             %if the project has been saved
        
        navData.activeStim = 1;             %current selected stim
        navData.marker     = 1;
        navData.numStim    = 1;
        navData.saveParameters   = 1;       %save parameters after each run
        
        navData.skippedFrames    = 0;       %skipped frames during last run
        navData.skippedLatest    = 0;       %total skipped frames all runs
        
        % SETTINGS - THESE VALUES CAN BE CHANGED
        if ismac
            navData.windowPosition   = 700;           %pixels to right from left border
            navData.colWidth         = 45;            %pixels in each table column
        else
            navData.windowPosition   = 200;           %pixels to right from left border
            navData.colWidth         = 75;            %pixels in each table column
        end
                
        navData.saveDataPathName = strcat(cd, '/Saved Data'); %default pathname to save data into
        
        init = navData; % Return new values
        
    case 'InitScreenData'
        %screen data
        screenData.isInit         = 0;         %is the screen initialized?
        screenData.inUse          = 0;         %is the screen in use atm?        
        screenData.wPtr           = 0;         %pointer to screen
        screenData.hz             = 0;         %monitor update frequency (nominal)
        screenData.ifi            = 0;         %monitor frame length (measured)
        screenData.gamma          = 1;       %gamma value of monitor
        % New variables
        screenData.useGuvcview    = 1;
        screenData.useRotated     = 0;
        screenData.useSplitScreen = 0;
        screenData.backgroundInit = 0;
        screenData.splitDir       = "Vertically";
        screenData.splitPos       = 320;
        screenData.monitorHeight  = 27.5;
        screenData.flyDistance    = 14;
        
        screenData.oldlevel       = Screen('Preference', 'Verbosity', 1); %critical errors only
        screenData.screenNumber   = 0; %best guess of which monitor to use
        
        screenData.usePartial     = false;            %use full screen or partial
        screenData.partial        = [0 0 640 480];   %size of partial screen
        screenData.triggerRGBon   = 255;             %color of trigger active (white)
        screenData.triggerRGBoff  = 0;               %color of trigger deactive (black)
        screenData.bgColor        = -1;   
        screenData.beforeBgColor = -1;
        screenData.triggerPos     = [0 430 50 480];    %size of trigger, width, height
        screenData.flyPos         = [320 240]; %fly position in from of monitor
        
        init = screenData; %return new values
        
    otherwise
        disp(['initFcn: Case does not exist (' Option ')']);
end