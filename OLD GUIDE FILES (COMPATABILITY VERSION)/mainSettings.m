function varargout = mainSettings(varargin)
% MAINSETTINGS M-file for mainSettings.fig
%      MAINSETTINGS, by itself, creates a new MAINSETTINGS or raises the existing
%      singleton*.
%
%      H = MAINSETTINGS returns the handle to a new MAINSETTINGS or the handle to
%      the existing singleton*.
%
%      MAINSETTINGS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAINSETTINGS.M with the given input arguments.
%
%      MAINSETTINGS('Property','Value',...) creates a new MAINSETTINGS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mainSettings_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mainSettings_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mainSettings

% Last Modified by GUIDE v2.5 17-Mar-2020 09:23:16

%--------------------------------------------------------------------------
% FlyFly v2
%
% Jonas Henriksson, 2010                                   info@flyfly.se
%--------------------------------------------------------------------------

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @mainSettings_OpeningFcn, ...
    'gui_OutputFcn',  @mainSettings_OutputFcn, ...
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


% --- Executes just before mainSettings is made visible.
function mainSettings_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mainSettings (see VARARGIN)

% Choose default command line output for mainSettings
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes mainSettings wait for user response (see UIRESUME)
% uiwait(handles.figure1);

screenRes = get(0, 'ScreenSize'); %[1 1 screenWidth screenHeight]

navData = getappdata(0, 'navData');

set(gcf, 'Units' , 'Pixels');
posdata = get(gcf,'Position');
height = posdata(4);
width = posdata(3);
set(gcf, 'Position', [navData.windowPosition (screenRes(4)-height)/2 width height]);


%Get current settings
screenData   = getappdata(0, 'screenData');
navData   = getappdata(0, 'navData');

triggerPos = screenData.triggerPos;

width      = triggerPos(3)-triggerPos(1);
height     = triggerPos(4)-triggerPos(2);
xpos       = triggerPos(1);
ypos       = triggerPos(2);

screenNum  = screenData.screenNumber;
gamma      = screenData.gamma;

widthPartial   = screenData.partial(3);
heightPartial  = screenData.partial(4);

% New variables
dlp         = screenData.dlp;
monitorHeight= screenData.monitorHeight;
flyDistance = screenData.flyDistance;

saveParameters = navData.saveParameters;

%OLOF ADDED
x1=screenData.flyPos(1);
y1=screenData.flyPos(2);
x2=screenData.flyPos(3);
y2=screenData.flyPos(4);

%Set values
set(handles.width,     'String', num2str(width));
set(handles.height,    'String', num2str(height));
set(handles.xpos,      'String', num2str(xpos));
set(handles.ypos,      'String', num2str(ypos));
set(handles.screenNum, 'String', num2str(screenNum));
set(handles.gamma,     'String', num2str(gamma));

set(handles.widthPartial, 'String', num2str(widthPartial));
set(handles.heightPartial,'String', num2str(heightPartial));

%OLOF ADDED
set(handles.x1,'String', num2str(x1));
set(handles.y1,'String', num2str(y1));
set(handles.x2,'String', num2str(x2));
set(handles.y2,'String', num2str(y2));

%set current pathaname
set(handles.pathName, 'String', navData.saveDataPathName);

%write out available screens
set(handles.screens, 'String', ['Available screen numbers: ' num2str(Screen('Screens'))]);

if screenData.usePartial
    set(handles.fullScreen, 'Value', 0);
    set(handles.partial,    'Value', 1);
else
    set(handles.fullScreen, 'Value', 1);
    set(handles.partial,    'Value', 0);
end

set(handles.saveParameters, 'Value', saveParameters);

set(handles.chkDlpmode, 'Value', dlp);
set(handles.monitorHeight,'String', num2str(monitorHeight));
set(handles.flyDistance,'String', num2str(flyDistance));

% --- Outputs from this function are returned to the command line.
function varargout = mainSettings_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in ok.
function ok_Callback(hObject, eventdata, handles)
% hObject    handle to ok (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

navData    = getappdata(0, 'navData');
screenData = getappdata(0, 'screenData');

%get values
width  = str2double(get(handles.width,  'String'));
height = str2double(get(handles.height, 'String'));

xpos  = str2double(get(handles.xpos,  'String'));
ypos  = str2double(get(handles.ypos,  'String'));

screenNum     = round(str2double(get(handles.screenNum, 'String')));
gamma         = str2double(get(handles.gamma,           'String'));
widthPartial  = str2double(get(handles.widthPartial,    'String'));
heightPartial = str2double(get(handles.heightPartial,   'String'));

%bgColor = str2double(get(handles.bgColorTextbox,   'String'));
%OLOF ADDED
x1 =str2double(get(handles.x1,             'String'));
y1 =str2double(get(handles.y1,             'String'));
x2 =str2double(get(handles.x2,             'String'));
y2 =str2double(get(handles.y2,             'String'));


pathName = get(handles.pathName, 'String');

choice = 'Yes';
if screenNum > max(Screen('Screens')) || screenNum < min(Screen('Screens'))
    choice = questdlg('Warning: The chosen screen number doesn�t seem to exist. Continue?', 'Yes', 'No');
end

if strcmp(choice, 'Yes')
    
    %set values
    screenData.triggerPos    = [xpos ypos xpos + width ypos + height];
    screenData.partial = [0 0 widthPartial heightPartial];
    screenData.screenNumber  = screenNum;
    screenData.gamma         = gamma;
    % New variabels
    screenData.dlp           = get(handles.chkDlpmode,  'Value');
    screenData.flyDistance   = str2double(get(handles.flyDistance,  'String'));
    screenData.monitorHeight  = str2double(get(handles.monitorHeight,  'String'));
    %screenData.bgColor      = bgColor;
    %OLOF ADDED
    screenData.flyPos = [x1 y1 x2 y2];
    
    
    navData.saveDataPathName = pathName;
    
    %Partial Screen
    if get(handles.partial, 'Value');
        screenData.usePartial = true;
    else
        screenData.usePartial = false;
    end
    
    %Disable data
    if get(handles.saveParameters, 'Value');
        navData.saveParameters = true;
    else
        navData.saveParameters = false;
    end
    
    setappdata(0, 'navData',    navData);
    setappdata(0, 'screenData', screenData);
    
    close(gcf); %Close window
end

% --- Executes on button press in cancel.
function cancel_Callback(hObject, eventdata, handles)
% hObject    handle to cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close(gcf); %Close window

function height_Callback(hObject, eventdata, handles)
% hObject    handle to height (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of height as text
%        str2double(get(hObject,'String')) returns contents of height as a double


% --- Executes during object creation, after setting all properties.
function height_CreateFcn(hObject, eventdata, handles)
% hObject    handle to height (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function width_Callback(hObject, eventdata, handles)
% hObject    handle to width (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of width as text
%        str2double(get(hObject,'String')) returns contents of width as a double


% --- Executes during object creation, after setting all properties.
function width_CreateFcn(hObject, eventdata, handles)
% hObject    handle to width (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function xpos_Callback(hObject, eventdata, handles)
% hObject    handle to xpos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xpos as text
%        str2double(get(hObject,'String')) returns contents of xpos as a double


% --- Executes during object creation, after setting all properties.
function xpos_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xpos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ypos_Callback(hObject, eventdata, handles)
% hObject    handle to ypos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ypos as text
%        str2double(get(hObject,'String')) returns contents of ypos as a double


% --- Executes during object creation, after setting all properties.
function ypos_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ypos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in change.
function change_Callback(hObject, eventdata, handles)
% hObject    handle to change (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pathName = uigetdir(cd);
if pathName ~= 0 %cancel returns 0
    set(handles.pathName, 'String', pathName);
end


% --- Executes on button press in saveParameters.
function saveParameters_Callback(hObject, eventdata, handles)
% hObject    handle to saveParameters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of saveParameters



function widthPartial_Callback(hObject, eventdata, handles)
% hObject    handle to widthPartial (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of widthPartial as text
%        str2double(get(hObject,'String')) returns contents of widthPartial as a double


% --- Executes during object creation, after setting all properties.
function widthPartial_CreateFcn(hObject, eventdata, handles)
% hObject    handle to widthPartial (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function heightPartial_Callback(hObject, eventdata, handles)
% hObject    handle to heightPartial (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of heightPartial as text
%        str2double(get(hObject,'String')) returns contents of heightPartial as a double


% --- Executes during object creation, after setting all properties.
function heightPartial_CreateFcn(hObject, eventdata, handles)
% hObject    handle to heightPartial (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function screenNum_Callback(hObject, eventdata, handles)
% hObject    handle to screenNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of screenNum as text
%        str2double(get(hObject,'String')) returns contents of screenNum as a double


% --- Executes during object creation, after setting all properties.
function screenNum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to screenNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in setFlyPos.
function setFlyPos_Callback(hObject, eventdata, handles)
% hObject    handle to setFlyPos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

screenData = getappdata(0, 'screenData');

if screenData.isInit
    
    [x1 y1 x2 y2] = setFlyPos(screenData);
    screenData.flyPos = [x1 y1 x2 y2];
    
    setappdata(0, 'screenData', screenData);
    
    
    %OLOF ADDED
    set(handles.x1,'String', num2str(x1));
    set(handles.y1,'String', num2str(y1));
    set(handles.x2,'String', num2str(x2));
    set(handles.y2,'String', num2str(y2));
    
    
else
    disp('Screen not initialized');
end


% --- Executes on button press in showFlyPos.
function showFlyPos_Callback(hObject, eventdata, handles)
% hObject    handle to showFlyPos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

screenData = getappdata(0, 'screenData');

if screenData.isInit
    screenFcn('ShowFlyPos');
else
    disp('Screen not initialized');
end


function gamma_Callback(hObject, eventdata, handles)
% hObject    handle to gamma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gamma as text
%        str2double(get(hObject,'String')) returns contents of gamma as a double


% --- Executes during object creation, after setting all properties.
function gamma_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gamma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in testInit.
function testInit_Callback(hObject, eventdata, handles)
% hObject    handle to testInit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

disp(' ');
disp('This function will perform a test of the screen flip interval and then automatically close the window.');
disp('Use to make sure you don�t cover GUI by accident.');

screenNumber  = str2double(get(handles.screenNum, 'String'));

h = str2double(get(handles.heightPartial, 'String'));
w = str2double(get(handles.widthPartial,  'String'));

a = 0; 
b = 0;
screenPartial = [a b a+w b+h];

disp('Open')

if get(handles.partial, 'Value')
    [wPtr,rect] = Screen('OpenWindow', screenNumber, [255 255 255], screenPartial);
else
    [wPtr,rect] = Screen('OpenWindow', screenNumber, [255 255 255]); %fullscreen
end

[monitorFlipInterval nrValidSamples stddev] = Screen('GetFlipInterval', wPtr, 25);
Screen('Close', wPtr);

disp(sprintf('Over %d samples the mean flip interval was %.2f ms (%.2f Hz), stddev=%.2f us', ...
    nrValidSamples, monitorFlipInterval*1000, 1/monitorFlipInterval, stddev*1000000));
disp('Close')



function x1_Callback(hObject, eventdata, handles)
% hObject    handle to x1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of x1 as text
%        str2double(get(hObject,'String')) returns contents of x1 as a double


% --- Executes during object creation, after setting all properties.
function x1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to x1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function y1_Callback(hObject, eventdata, handles)
% hObject    handle to y1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of y1 as text
%        str2double(get(hObject,'String')) returns contents of y1 as a double


% --- Executes during object creation, after setting all properties.
function y1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to y1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function x2_Callback(hObject, eventdata, handles)
% hObject    handle to x2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of x2 as text
%        str2double(get(hObject,'String')) returns contents of x2 as a double


% --- Executes during object creation, after setting all properties.
function x2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to x2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function y2_Callback(hObject, eventdata, handles)
% hObject    handle to y2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of y2 as text
%        str2double(get(hObject,'String')) returns contents of y2 as a double


% --- Executes during object creation, after setting all properties.
function y2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to y2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in chkDlpmode.
function chkDlpmode_Callback(hObject, eventdata, handles)
% hObject    handle to chkDlpmode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkDlpmode



function flyDistance_Callback(hObject, eventdata, handles)
% hObject    handle to flyDistance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of flyDistance as text
%        str2double(get(hObject,'String')) returns contents of flyDistance as a double


% --- Executes during object creation, after setting all properties.
function flyDistance_CreateFcn(hObject, eventdata, handles)
% hObject    handle to flyDistance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function monitorHeight_Callback(hObject, eventdata, handles)
% hObject    handle to monitorHeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of monitorHeight as text
%        str2double(get(hObject,'String')) returns contents of monitorHeight as a double


% --- Executes during object creation, after setting all properties.
function monitorHeight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to monitorHeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function bgColorTextbox_Callback(hObject, eventdata, handles)
% hObject    handle to bgColorTextbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bgColorTextbox as text
%        str2double(get(hObject,'String')) returns contents of bgColorTextbox as a double


% --- Executes during object creation, after setting all properties.
function bgColorTextbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bgColorTextbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
