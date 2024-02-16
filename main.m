function varargout = main(varargin)
% MAIN M-file for main.fig
%      MAIN, by itself, creates a new MAIN or raises the existing
%      singleton*.
%
%      H = MAIN returns the handle to a new MAIN or the handle to
%      the existing singleton*.
%
%      MAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAIN.M with the given input arguments.
%
%      MAIN('Property','Value',...) creates a new MAIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before main_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to main_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help main

% Last Modified by GUIDE v2.5 10-Nov-2011 16:39:53

%--------------------------------------------------------------------------
% FlyFly v2
%
% Jonas Henriksson, 2010                                   info@flyfly.se
%--------------------------------------------------------------------------

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @main_OpeningFcn, ...
    'gui_OutputFcn',  @main_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before main is made visible.
function main_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to main (see VARARGIN)

% Choose default command line output for main
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes main wait for user response (see UIRESUME)
% uiwait(handles.figure1);

addpath(cd, [cd '/' genpath('Subfunctions')], [cd '/' genpath('Stimuli')]); %Add subfuntions in separate folder
hGui = gcf;       %get handle to figure

%Initialize
navFcn(handles, 'AddHandle', hGui); %save the handle (in root)
updateFigure(handles);              % Populate the listbox
set(handles.listbox1,'Value',1);    % Default selection


%set position of window
navData   = getappdata(0, 'navData');

screenRes = get(0, 'ScreenSize');   %[1 1 screenWidth screenHeight]

set(gcf, 'Units' , 'Pixels');
posdata = get(gcf,'Position');
height = posdata(4);
width = posdata(3);
set(gcf, 'Position', [navData.windowPosition (screenRes(4)-height)/2 width height]);



% --- Outputs from this function are returned to the command line.
function varargout = main_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in next.
function next_Callback(hObject, eventdata, handles)
% hObject    handle to next (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%load data
chstimuli = getappdata(0, 'chstimuli');
navData   = getappdata(0, 'navData');

index = navData.activeStim;                         %current stim
gotoStim(handles, index+1);


function gotoStim(handles, stimNo)

%load data
chstimuli = getappdata(0, 'chstimuli');
navData   = getappdata(0, 'navData');

%update
if length(chstimuli) >= stimNo %should always be the case
    
    navData.activeStim = stimNo;                     %update index
    setappdata(0, 'navData', navData);                  %save navData
    
    %switch gui
    nextGui  = chstimuli(stimNo).fileNameGui;
    delete(gcf) %close current gui
    
    try
        eval(nextGui); %start new gui
        
    catch e
        disp(['Error evaluating ' nextGui ':']);
        disp(e.message);
        
        navData.activeStim = 1;
        setappdata(0, 'navData', navData);
        main;
    end
end

% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1


%add chosen stimuli to chstimuli
if strcmp(get(handles.figure1,'SelectionType'),'open') %check if doubleclick
    
    chstimuli = getappdata(0, 'chstimuli');
    navData   = getappdata(0, 'navData');
    
    index     = get(handles.listbox1,'Value');  %get index of selected object
    new_layer = getLayer(index);      % Chosen layer to start with
    
    write_index = length(chstimuli) +1; % Index to write to (last in list)
    
    %make new stimuli
    new_entry.name          = new_layer.name;
    new_entry.fileNameGui   = 'tableGui';
    new_entry.settingsGui   = 'settingsGui';
    new_entry.hGui          = 0;
    new_entry.layers        = new_layer;
%       new_entry.bgColor       = 255;
    new_entry.targetBgColor       = 255;
%      new_entry.beforeBgColor       = 255;
    new_entry.stimSettings  = 0;
    
    chstimuli(write_index)  = new_entry; % Add to array
    navData.numStim         = navData.numStim + 1; % Update number of stims in list
    navData.marker          = [navData.marker 1];
    
    setappdata(0, 'chstimuli', chstimuli); % save changes
    setappdata(0, 'navData',   navData);   % save changes
    
    set(handles.listbox2, 'Value', write_index); % update marker
    updateFigure(handles); %update
end


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function updateFigure(handles)

%Read appdata
chstimuli  = getappdata(0, 'chstimuli');
navData    = getappdata(0, 'navData');
screenData = getappdata(0, 'screenData');

%Update listboxes
names_avstimuli = getLayer('List');
names_chstimuli = {chstimuli.name};

set(handles.listbox1,'String',names_avstimuli);
set(handles.listbox2,'String',names_chstimuli);

%Update the next/previous buttons
navFcn(handles, 'Update');

%Update kill/init screen buttons
if screenData.isInit
    set(handles.initScreen,'Enable','off'); %grey out init button
    set(handles.killScreen,'Enable','on');  %enable kill button
    set(handles.test,'Enable','off');        %enable test button
else
    set(handles.initScreen,'Enable','on');   %grey out init button
    set(handles.killScreen,'Enable','off');  %disable kill button
    set(handles.test,'Enable','on');        %disable test button
end

%Title - Update the title so that it is correct.
set(handles.figure1, 'Name', [navData.fileName]);

% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2

%For debug purposes
if strcmp(get(handles.figure1,'SelectionType'),'open') %check if doubleclick
    
    index = get(handles.listbox2,'Value');  %get index of selected object
    
    gotoStim(handles, index);    
end


% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in moveUp.
function moveUp_Callback(hObject, eventdata, handles)
% hObject    handle to moveUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%get selected index of listbox2
index     = get(handles.listbox2,'Value');
chstimuli = getappdata(0, 'chstimuli');

if index > 2 %over 2, move up (Keep main at top)
    
    tmp = chstimuli(index);
    chstimuli(index)   = chstimuli(index-1);
    chstimuli(index-1) = tmp;
    setappdata(0, 'chstimuli', chstimuli);
    
    set(handles.listbox2,'Value',index-1);
    
    updateFigure(handles);
end


% --- Executes on button press in moveDown.
function moveDown_Callback(hObject, eventdata, handles)
% hObject    handle to moveDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%get selected index of listbox2
index = get(handles.listbox2,'Value');
chstimuli = getappdata(0, 'chstimuli');

if index < length(chstimuli) && index~= 1
    %move down if possible, keep main at top
    
    tmp = chstimuli(index);
    chstimuli(index) = chstimuli(index+1);
    chstimuli(index+1) = tmp;
    setappdata(0, 'chstimuli', chstimuli);
    
    set(handles.listbox2,'Value',index+1);
    
    updateFigure(handles);
end

% --- Executes on button press in remove.
function remove_Callback(hObject, eventdata, handles)
% hObject    handle to remove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%get selected index of listbox2
index     = get(handles.listbox2,'Value');          %to be removed
chstimuli = getappdata(0, 'chstimuli');
navData   = getappdata(0, 'navData');

%check if there are any objects to remove and disallow removing main
if ~isempty(chstimuli) && index ~= 1
    N = length(chstimuli) - index;  %number of entries needs to move
    
    for n = 0:N-1
        chstimuli(index+n) = chstimuli(index+n+1);
    end
    
    chstimuli = chstimuli(1:end-1); %remove last entry
    navData.numStim = navData.numStim - 1; %update number of stims in list
    
    setappdata(0, 'chstimuli', chstimuli); %Save changes
    setappdata(0, 'navData',   navData);
    
    if index > length(chstimuli)
        set(handles.listbox2,'Value',index-1);  %move up index
    end
    
    navData.marker = navData.marker([1:index-1 index+1:end]); %remove marker at index
    updateFigure(handles);
end

setappdata(0, 'navData', navData);

%Meny functions
%--------------------------------------------------------------------
function File_Callback(hObject, eventdata, handles)
% hObject    handle to File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function new_Callback(hObject, eventdata, handles)
% hObject    handle to new (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
menuFcn('New');

% --------------------------------------------------------------------
function open_Callback(hObject, eventdata, handles)
% hObject    handle to open (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

menuFcn('Open');

navData = getappdata(0, 'navData');
navData.activeStim = 1;
setappdata(0, 'navData', navData);

updateFigure(handles);

% --------------------------------------------------------------------
function save_as_Callback(hObject, eventdata, handles)
% hObject    handle to save_as (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

menuFcn('SaveAs');
updateFigure(handles);

% --------------------------------------------------------------------
function exit_Callback(hObject, eventdata, handles)
% hObject    handle to exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(gcf);

% --- Executes on button press in initScreen.
function initScreen_Callback(hObject, eventdata, handles)
% hObject    handle to initScreen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

screenFcn('Init');
updateFigure(handles);

% --- Executes on button press in killScreen.
function killScreen_Callback(hObject, eventdata, handles)
% hObject    handle to killScreen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

screenFcn('Kill');
updateFigure(handles);

% --- Executes on button press in test.
function test_Callback(hObject, eventdata, handles)
% hObject    handle to test (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

screenFcn('Init');

pause(2);
screenFcn('Kill');
disp('Screen Closed');

updateFigure(handles);

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure

navFcn(handles, 'Close');
delete(hObject);

% --------------------------------------------------------------------
function tools_Callback(hObject, eventdata, handles)
% hObject    handle to tools (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function settings_Callback(hObject, eventdata, handles)
% hObject    handle to settings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mainSettings;


% --- Executes on button press in copy.
function copy_Callback(hObject, eventdata, handles)
% hObject    handle to copy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%get selected index of listbox2
index     = get(handles.listbox2,'Value');          %to be copied
chstimuli = getappdata(0, 'chstimuli');
navData   = getappdata(0, 'navData');

%check if there are any objects to remove and disallow removing main
if ~isempty(chstimuli) && index ~= 1
    N = length(chstimuli) - index;  %number of entries needs to move
    
    for n = 0:N+1
        chstimuli(end+1-n) = chstimuli(end-n);
    end
    
    navData.numStim = navData.numStim + 1; %update number of stims in list
    
    setappdata(0, 'chstimuli', chstimuli); %Save changes
    setappdata(0, 'navData',   navData);
    
    
    navData.marker = navData.marker([1:index index:end]);
    updateFigure(handles);
end

setappdata(0, 'navData', navData);


% --- Executes on button press in rename.
function rename_Callback(hObject, eventdata, handles)
% hObject    handle to rename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%get selected index of listbox2
index     = get(handles.listbox2,'Value');          %to be renamed
chstimuli = getappdata(0, 'chstimuli');

newName = inputdlg({'Enter new name: '});

if ~isempty(newName)
    chstimuli(index).name = newName{1};
    setappdata(0, 'chstimuli', chstimuli);
    updateFigure(handles);
end


% --------------------------------------------------------------------
function importStim_Callback(hObject, eventdata, handles)
% hObject    handle to importStim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

menuFcn('importStim');
updateFigure(handles);


% --- Executes on button press in pushbutton12.
function pushbutton12_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
