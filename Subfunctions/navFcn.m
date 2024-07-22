function navFcn(app, Action)
% handles    structure with handles and user data (see GUIDATA)
% Action     what action to perform
% Input      user input: handle to gui when action AddHandle is called 
%            (optional)

%Possible Actions:
% Close
% AddHandle
% Update

%--------------------------------------------------------------------------
% FlyFly v2
%
% Jonas Henriksson, 2010                                   info@flyfly.se
%--------------------------------------------------------------------------

switch Action

    case 'Close'
        %------------------------------------------------------------------
        % --- Executes on close action
        %     Checks if any other windows are open and closes them
        %     also kills screen if its running
        
        try
            
            screenData = getappdata(0, 'screenData');
            
            %Closing
            if screenData.isInit
                screenFcn('Kill'); %Kill open screen
            end
            
            rmappdata(0, 'chstimuli');   %Remove appdata from root
            rmappdata(0, 'navData');     %Remove appdata from root
            rmappdata(0, 'screenData');  %Remove appdata from root
            
        catch e
            disp('Error while closing window');
            disp(e.message);
        end
         
    case 'AddHandle'
        %------------------------------------------------------------------
        %     Executes when a GUI first starts
        %     Adds the hGUI to the struct chstimuli if it exist
        %     Initialize chstimuli and navData if neccesary
        
        % Does these exist? If yes, add handle to this figure in struct
        % chstimuli, if no save handle in root
        
        chstimuli = getappdata(0, 'chstimuli');  %Load list of chosen stims
        
        %check if chstimuli is an empty array
        %(If chstimuli/navData does not exist, create them)
        if isempty(chstimuli)
            
            %Initialize data
            chstimuli           = initFcn('InitChstimuli');
            screenData          = initFcn('InitScreenData');
            navData             = initFcn('InitNavData');
                   
            navData.emstimuli   = chstimuli;      
            
            setappdata(0, 'chstimuli', chstimuli); 
            setappdata(0, 'navData'  , navData);   
            setappdata(0, 'screenData', screenData);   
            
        else
            setappdata(0, 'chstimuli', chstimuli);          %Save handle
        end
        
    case 'Update'
        % ------------------------------------------------------------------
        % --- Executes when a GUI updates, updates 'next' and 'run' buttons
        
        navData    = getappdata(0, 'navData');    % Load navigation data
        screenData = getappdata(0, 'screenData'); % Load screen data

        % Next
        % if last stim, disable next, else enable
        if  navData.activeStim == navData.numStim
            app.next.Enable = 'Off';
        else
            app.next.Enable = 'On';
        end
        
        % If screen does not have run button, leave function here
        if ~isfield(app, "run")
            return
        end

        %Enable "Run" when screen is initialized
        if screenData.isInit
            app.run.Enable = 'On';
        else
            app.run.Ennable = 'Off';
        end
        
    otherwise
        % Informs us if we made a type when using navFcn
        disp('navFcn: Invalid action string');
end
