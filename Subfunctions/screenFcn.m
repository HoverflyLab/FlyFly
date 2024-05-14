function screenFcn(Action)
%function screenFcn(Action)
%
% Functions to ease use of screen
%
% Init, Kill, DrawGrid, Clear, ShowFlyPos
%

%--------------------------------------------------------------------------
% FlyFly v2
%
% Jonas Henriksson, 2010                                   info@flyfly.se
%--------------------------------------------------------------------------

try
    %Read appdata
    navData    = getappdata(0, 'navData');
    screenData = getappdata(0, 'screenData');
    chstimuli  = getappdata(0, 'chstimuli');
    
    index    = navData.activeStim;
    
catch
    disp('Catch: Reading appdata (screenFcn)')
end

switch Action
    case 'Init'
        %Screen
        rgbWhite = [255 255 255];
        rgbBlack = [0 0 0];
        screenPartial = screenData.partial;
        screenNumber  = screenData.screenNumber;

        % Check if recording video data
        recording    = screenData.recording;
        videoAdaptor = screenData.videoAdaptor;
        useGuv       = screenData.useGuvcview;

        %If required by user, rotate screen 90 degrees
        if screenData.useRotated == 1
            PsychImaging('PrepareConfiguration');
            PsychImaging('AddTask', 'General', 'UseDisplayRotation', -90);
        end

        % If user wants defaults, check for connected cameras
        if ~useGuv
            if recording == 1 && videoAdaptor == "Default"
                adaptor = 0;
                disp("Searching for default camera")
                imaqreset
                % Loop over all adaptors to find connected cameras
                for adaptorIndex = 1:length(imaqhwinfo().InstalledAdaptors)
                    testAdaptor = imaqhwinfo().InstalledAdaptors{adaptorIndex};
                    if isempty(imaqhwinfo(testAdaptor).DeviceIDs) == 1, continue; end
                    % If camera found, break from loop
                    adaptor = testAdaptor;
                    break
                end
                % Verify connection to camera
                if adaptor
                    screenData.videoAdaptor = adaptor;
                    disp("The camera adaptor has defaulted to: " + adaptor);
                % If no cameras connected, don't record and warn user
                else 
                    warning("No video device detected! Recording settings have been turned off. Re-enable them and re-initialise screen after device has been connected.")
                    screenData.recording = 0;
                end
            elseif recording == 1 && isempty(imaqhwinfo(videoAdaptor).DeviceIDs) == 1
                % If user has selected an adaptor, double check there's a
                % camera connected
                warning("No video device detected! Recording settings have been turned off. Re-enable them and re-initialise screen after device has been connected.")
                screenData.recording = 0;
            end
        end


        
        AssertOpenGL; %Check if openGL is available
        try
            oldLevel = Screen('Preference', 'Verbosity', 1); % 1 = critical errors only
            
            InitializeMatlabOpenGL;

            %use screenPartial for a non full screen
            if screenData.usePartial
                if screenData.useRotated
                    temp = screenPartial(3);
                    screenPartial(3) = screenPartial(4);
                    screenPartial(4) = temp;
                end
                [wPtr,~] = PsychImaging('OpenWindow', screenNumber, chstimuli(index).targetBgColor, screenPartial, ...
                    [], [], [], [], kPsychNeedFastOffscreenWindows);
            else
                [wPtr,~] = PsychImaging('OpenWindow', screenNumber, chstimuli(index).targetBgColor, ...
                    [], [], [], [], [], kPsychNeedFastOffscreenWindows);%fullscreen
            end

            screenData.bgColor = chstimuli(index).targetBgColor;
            gammatable = rgbCal(repmat([0:255]',1,3), screenData.gamma)/255;

            Screen('LoadNormalizedGammaTable', screenNumber, gammatable);
            disp(['Gamma table loaded with γ=' num2str(screenData.gamma)]);
            disp('If this value is incorrect, kill screen and change it');

            screenData.hz     = Screen('FrameRate', wPtr); %screenData.hz
%             disp('Determining monitor flip interval. This can take a while...');
%             [monitorFlipInterval nrValidSamples stddev] = Screen('GetFlipInterval', wPtr, 25);
%             screenData.ifi    = monitorFlipInterval;
%             disp(sprintf('Over %d samples the mean flip interval was %.2f ms (%.2f Hz), stddev=%.2f us', ...
%                 nrValidSamples, monitorFlipInterval*1000, 1/monitorFlipInterval, stddev*1000000));
            screenData.ifi    = Screen('GetFlipInterval', wPtr);   % Estimate monitor flip interval
            
            screenData.isInit         = 1;
            screenData.inUse          = 0;
            screenData.screenOldlevel = oldLevel;
            screenData.wPtr           = wPtr;      %pointer to screen
            
            Screen('FillRect', wPtr, screenData.triggerRGBoff, screenData.triggerPos); %trigger off
            Screen('Flip', wPtr);
            
            setappdata(0, 'screenData', screenData);
            
            disp('Screen Initialized');
        catch e
            disp('Error in screen initialization. Please try again.')
            disp(e.message)
            
            if screenNumber > max(Screen('Screens')) || screenNumber < min(Screen('Screens'))
                disp('(Invalid screen number)')
            end
        end
        
    case 'Kill'
        try
            gammatable = repmat([0:255]',1,3)./255;
            Screen('LoadNormalizedGammaTable', screenData.wPtr, gammatable);
            
            %Closing
            Screen('CloseAll');                                      %Close Screen
            Screen('Preference', 'Verbosity', screenData.oldlevel);  %Enable warnings
        catch
            disp("No screen to close, resetting appData")
        end
        
        screenData.isInit = 0;
        screenData.inUse  = 0;
        screenData.bgColor       = -1;   
        screenData.beforeBgColor = -1;
        setappdata(0, 'screenData', screenData);
        
    case 'DrawGrid'
        
        if screenData.isInit
            
            partial = screenData.partial;
            k = 0;
            while k < max(partial(4), partial(3)) %bright lines
                Screen('DrawLine', screenData.wPtr, [235 235 235], 0, k, partial(3), k);
                Screen('DrawLine', screenData.wPtr, [235 235 235], k, 0, k, partial(4));
                k = k + 10;
            end
            
            k = 0;
            while k < max(partial(4), partial(3)) %bright lines
                Screen('DrawLine', screenData.wPtr, [200 200 200], 0, k, partial(3), k);
                Screen('DrawLine', screenData.wPtr, [200 200 200], k, 0, k, partial(4));
                k = k + 50;
            end
            k = 0;
            while k < max(partial(4), partial(3)) %dark lines
                Screen('DrawLine', screenData.wPtr, [0 0 0], 0, k, partial(3), k);
                Screen('DrawLine', screenData.wPtr, [0 0 0], k, 0, k, partial(4));
                k = k + 100;
            end
            
            y = 0;
            Screen('TextSize', screenData.wPtr, 7);
            while y < partial(4) %rows
                
                x = 0;
                while x < partial(3) %cols
                    Screen('DrawText', screenData.wPtr, ['(' num2str(x) ',' num2str(y) ')'], x, y);
                    x = x + 100;
                end
                y = y + 100;
            end
            
            Screen('FillRect', screenData.wPtr, screenData.triggerRGBoff, screenData.triggerPos); %trigger off
        else
            disp('Screen not initialized')
        end
        
    case 'Clear'
        
        if screenData.isInit
            
            Screen('FillRect', screenData.wPtr, [255 255 255]);
            Screen('FillRect', screenData.wPtr, screenData.triggerRGBoff, screenData.triggerPos); %trigger off
            Screen(screenData.wPtr, 'Flip');
           
        else
            disp('Screen not initialized')
        end
        
    case 'ShowFlyPos'
        
        flyPos(1)     = screenData.flyPos(1);
        flyPos(2)     = screenData.flyPos(2);
        
        wPtr = screenData.wPtr;
        partial = screenData.partial;
        
        Screen('DrawLine', wPtr, [200 200 200], 0, flyPos(2), partial(3), flyPos(2));
        Screen('DrawLine', wPtr, [200 200 200], flyPos(1), 0, flyPos(1), partial(4));
        Screen('FillOval', wPtr, [200 200 200], [flyPos(1)-3  flyPos(2)-3  flyPos(1)+3  flyPos(2)+3]);
                
        %Screen('FillRect', navData.screenWptr, [255 255 255]);
        Screen('FillRect', screenData.wPtr, screenData.triggerRGBoff, screenData.triggerPos); %trigger off
        Screen(screenData.wPtr, 'Flip');
        
        disp(['Fly mark one: ' num2str(flyPos(1)) 'x, ' num2str(flyPos(2)) 'y']);
        
    otherwise
        disp(['screenFcn: Incorrect Action string (' Action ')']);
end
