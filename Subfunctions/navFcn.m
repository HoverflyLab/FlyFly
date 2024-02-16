function navFcn(handles, Action, Input)
% handles    structure with handles and user data (see GUIDATA)
% Action     what action to perform
% Input      user input: handle to gui when action AddHandle is called 
%            (optional)

%Possible Actions:
%
% Close
% AddHandle
% Update

%--------------------------------------------------------------------------
% FlyFly v2
%
% Jonas Henriksson, 2010                                   info@flyfly.se
%--------------------------------------------------------------------------


if nargin < 3
    Input = [];
end

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
        navData   = getappdata(0, 'navData');    %Load navigation data
        
        %check if chstimuli is an empty array
        %(If chstimuli/navData does not exist, create them)
        if isempty(chstimuli)
            
            %Initialize data
            chstimuli           = initFcn('InitChstimuli');
            screenData          = initFcn('InitScreenData');
            navData             = initFcn('InitNavData');
                   
            navData.emstimuli   = chstimuli;            
            chstimuli(1).hGui   = Input;
            
            setappdata(0, 'chstimuli', chstimuli); 
            setappdata(0, 'navData'  , navData);   
            setappdata(0, 'screenData', screenData);   
            
        else
            %disp('no init needed!')
            index = navData.activeStim;                     %Find index of current fig
            
            chstimuli(index).hGui = Input;                  %Store handle
            setappdata(0, 'chstimuli', chstimuli);          %Save handle
        end
        
    case 'Update'
        %------------------------------------------------------------------
        % --- Executes when a GUI updates
        
        %Navigation buttons - if running as singleton exception will be
        %thrown when we try to access the nonexistant figures. Grey out
        %buttons.
        try
            navData   = getappdata(0, 'navData');    %Load navigation data
            chstimuli = getappdata(0, 'chstimuli');
            
            %disable naviation if screen is in use
            if navData.screenInUse
                set(handles.next,    'Enable','off');
                set(handles.previous,'Enable','off');
            else
                
                %Previous
                % if first stim, disable prev, else enable
                if navData.activeStim == 1
                    %disp('Prev: first stim');
                    set(handles.previous,'Enable','off');
                else
                    %disp('Prev: stim exist');
                    set(handles.previous,'Enable','on');
                end
                
                %Next
                % if last stim, disable next, else enable
                if  navData.activeStim == navData.numStim %|| ~navData.screenIsInit
                    %disp('Next: last stim OR screen disabled');
                    set(handles.next,'Enable','off');
                else
                    %disp('Next: stim exist');
                    set(handles.next,'Enable','on');
                end
            end
            
        catch
            %disp('NavFcn: Catch(update, nav buttons)');
        end
        
        %Runbutton - Exception will be thrown if it does not exist (like
        %in mainGui).
        try
            %Enable "Run" when screen is initialized
            if navData.screenIsInit
                set(handles.run, 'Enable', 'on');
            else
                set(handles.run, 'Enable', 'off');
            end
        catch
            %disp('NavFcn: Catch(update, run button)')
        end
        
    otherwise
        disp('navFcn: Invalid action string');
end
