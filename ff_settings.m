function varargout = settings(varargin)
% SETTINGS M-file for settings.fig
%      SETTINGS, by itself, creates a new SETTINGS or raises the existing
%      singleton*.
%
%      H = SETTINGS returns the handle to a new SETTINGS or the handle to
%      the existing singleton*.
%
%      SETTINGS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SETTINGS.M with the given input arguments.
%
%      SETTINGS('Property','Value',...) creates a new SETTINGS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before settings_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to settings_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help settings

% Last Modified by GUIDE v2.5 24-Nov-2011 17:54:10

%--------------------------------------------------------------------------
% FlyFly v2
%
% Jonas Henriksson, 2010                                   info@flyfly.se
%--------------------------------------------------------------------------

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @settings_OpeningFcn, ...
    'gui_OutputFcn',  @settings_OutputFcn, ...
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


% --- Executes just before settings is made visible.
function settings_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to settings (see VARARGIN)

% Choose default command line output for settings
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes settings wait for user response (see UIRESUME)
% uiwait(handles.figure1);

%Get current settings
navData     = getappdata(0, 'navData');
chstimuli   = getappdata(0, 'chstimuli');
index       = navData.activeStim;
z           = navData.marker(index);

layer = chstimuli(index).layers(z);

tmpSettings = layer.settings;

%set layer name
set(handles.layerName, 'String', layer.name);

setappdata(gcf, 'tmpSettings', tmpSettings);

updateFigure(handles);

% --- Outputs from this function are returned to the command line.
function varargout = settings_OutputFcn(hObject, eventdata, handles)
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

%save current values
setValues(handles);

chstimuli = getappdata(0, 'chstimuli');
navData   = getappdata(0, 'navData');
settings  = getappdata(gcf, 'tmpSettings');

index = navData.activeStim;
z     = navData.marker(index);

%save new settings
chstimuli(index).layers(z).settings = settings;

setappdata(0, 'chstimuli', chstimuli);
close(gcf);

% --- Executes on button press in cancel.
function cancel_Callback(hObject, eventdata, handles)
% hObject    handle to cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(gcf);

% --- Executes on button press in globalSetting.
function globalSetting_Callback(hObject, eventdata, handles)
% hObject    handle to globalSetting (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of globalSetting


% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1


% --- Executes on selection change in trialList.
function trialList_Callback(hObject, eventdata, handles)
% hObject    handle to trialList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns trialList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from trialList

newTrial = get(hObject,'Value'); %index of chosen trial

setValues(handles);

set(handles.currentTrial, 'String', num2str(newTrial));
updateFigure(handles);


% --- Executes during object creation, after setting all properties.
function trialList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trialList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in change.
function change_Callback(hObject, eventdata, handles)
% hObject    handle to change (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Get current settings
navData     = getappdata(0, 'navData');
chstimuli   = getappdata(0, 'chstimuli');
index       = navData.activeStim;
z           = navData.marker(index); %chosen layer
k     = str2num(get(handles.currentTrial, 'String'));
layer = chstimuli(index).layers(z);

if length(layer.settings(k).path1) > 2
    FilterSpec = layer.settings(k).path1{3};
    [FileName,PathName,FilterIndex] = uigetfile(FilterSpec);
else
    [FileName,PathName,FilterIndex] = uigetfile();
end

if FileName ~= 0
    set(handles.path1, 'String', [PathName FileName]);
end

setValues(handles);
updateFigure(handles);

function path1_Callback(hObject, eventdata, handles)
% hObject    handle to path1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of path1 as text
%        str2double(get(hObject,'String')) returns contents of path1 as a double


% --- Executes during object creation, after setting all properties.
function path1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to path1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function updateFigure(handles)

settings = getappdata(gcf, 'tmpSettings');
k = str2num(get(handles.currentTrial, 'String'));

%set drop down list
trialList = [];

C = length(settings);
for c = 1:C
    trialList{c} = ['Trial ' num2str(c)];
    
    if c == k
        trialList{c} = strcat(trialList{c}, '*');
    end
end

set(handles.trialList, 'String', trialList);

%global
set(handles.globalSetting, 'Value', settings(k).global);

%path settings
if strcmp(settings(k).path1{1}, 'OFF')
    set(handles.lable1, 'String', ' ');
    set(handles.path1,  'Enable', 'Off');
    set(handles.change, 'Enable', 'Off');
else
    set(handles.lable1, 'String', settings(k).path1{1});
    set(handles.path1,  'Enable', 'On');
    set(handles.path1,  'String', settings(k).path1{2});
    set(handles.change, 'Enable', 'On');
end

%box settings
if strcmp(settings(k).box1{1}, 'OFF')
    set(handles.checkbox1, 'Visible', 'Off');
else
    set(handles.checkbox1, 'Visible', 'On');
    set(handles.checkbox1, 'String', settings(k).box1{1});
    set(handles.checkbox1, 'Value',  settings(k).box1{2});
end

if strcmp(settings(k).box2{1}, 'OFF')
    set(handles.checkbox2, 'Visible', 'Off');
else
    set(handles.checkbox2, 'Visible', 'On');
    set(handles.checkbox2, 'String', settings(k).box2{1});
    set(handles.checkbox2, 'Value',  settings(k).box2{2});
end

if strcmp(settings(k).box3{1}, 'OFF')
    set(handles.checkbox3, 'Visible', 'Off');
else
    set(handles.checkbox3, 'Visible', 'On');
    set(handles.checkbox3, 'String', settings(k).box3{1});
    set(handles.checkbox3, 'Value',  settings(k).box3{2});
end

if strcmp(settings(k).box4{1}, 'OFF')
    set(handles.checkbox4, 'Visible', 'Off');
else
    set(handles.checkbox4, 'Visible', 'On');
    set(handles.checkbox4, 'String', settings(k).box4{1});
    set(handles.checkbox4, 'Value',  settings(k).box4{2});
end

if strcmp(settings(k).box5{1}, 'OFF')
    set(handles.checkbox5, 'Visible', 'Off');
else
    set(handles.checkbox5, 'Visible', 'On');
    set(handles.checkbox5, 'String', settings(k).box5{1});
    set(handles.checkbox5, 'Value',  settings(k).box5{2});
end

%text settings
if strcmp(settings(k).edit1{1}, 'OFF')
    set(handles.edit1,      'Visible', 'Off');
    set(handles.edit_text1, 'Visible', 'Off');
else
    set(handles.edit1,      'Visible', 'On');
    set(handles.edit_text1, 'String',  settings(k).edit1{1});
    set(handles.edit1,      'String',  settings(k).edit1{2});
end

if strcmp(settings(k).edit2{1}, 'OFF')    
    set(handles.edit2,      'Visible', 'Off');
    set(handles.edit_text2, 'Visible', 'Off');
else
    set(handles.edit2,      'Visible', 'On');
    set(handles.edit_text2, 'String',  settings(k).edit2{1});
    set(handles.edit2,      'String',  settings(k).edit2{2});
end

if strcmp(settings(k).edit3{1}, 'OFF')
    set(handles.edit3,      'Visible', 'Off');
    set(handles.edit_text3, 'Visible', 'Off');
else
    set(handles.edit3,      'Visible', 'On');
    set(handles.edit_text3, 'String',  settings(k).edit3{1});
    set(handles.edit3,      'String',  settings(k).edit3{2});
end

if strcmp(settings(k).edit4{1}, 'OFF')
    set(handles.edit4,      'Visible', 'Off');
    set(handles.edit_text4, 'Visible', 'Off');
else
    set(handles.edit4,      'Visible', 'On');
    set(handles.edit_text4, 'String',  settings(k).edit4{1});
    set(handles.edit4,      'String',  settings(k).edit4{2});
end

if strcmp(settings(k).edit5{1}, 'OFF')
    set(handles.edit5,      'Visible', 'Off');
    set(handles.edit_text5, 'Visible', 'Off');
else
    set(handles.edit5,      'Visible', 'On');
    set(handles.edit_text5, 'String',  settings(k).edit5{1});
    set(handles.edit5,      'String',  settings(k).edit5{2});
end

%----------------Set Values------------------------%
function setValues(handles)

settings = getappdata(gcf, 'tmpSettings');
k        = str2num(get(handles.currentTrial, 'String'));

%global settings
for n = 1:length(settings)
    settings(n).global = get(handles.globalSetting, 'Value');
end

%path settings
if ~strcmp(settings(k).path1{1}, 'OFF')   
    settings(k).path1{2} = get(handles.path1, 'String');
end

%box settings
if ~strcmp(settings(k).box1{1}, 'OFF') 
    settings(k).box1{2} = get(handles.checkbox1, 'Value'); 
end

if ~strcmp(settings(k).box2{1}, 'OFF') 
    settings(k).box2{2} = get(handles.checkbox2, 'Value'); 
end

if ~strcmp(settings(k).box3{1}, 'OFF')
    settings(k).box3{2} = get(handles.checkbox3, 'Value');
end

if ~strcmp(settings(k).box4{1}, 'OFF')
    settings(k).box4{2} = get(handles.checkbox4, 'Value');
end

if ~strcmp(settings(k).box5{1}, 'OFF')
    settings(k).box5{2} = get(handles.checkbox5, 'Value');
end

%text settings
if ~strcmp(settings(k).edit1{1}, 'OFF') 
    settings(k).edit1{2} = get(handles.edit1, 'String'); 
end

if ~strcmp(settings(k).edit2{1}, 'OFF') 
    settings(k).edit2{2} = get(handles.edit2, 'String'); 
end

if ~strcmp(settings(k).edit3{1}, 'OFF')
    settings(k).edit3{2} = get(handles.edit3, 'String');
end

if ~strcmp(settings(k).edit4{1}, 'OFF')
    settings(k).edit4{2} = get(handles.edit4, 'String');
end

if ~strcmp(settings(k).edit5{1}, 'OFF')
    settings(k).edit5{2} = get(handles.edit5, 'String');
end

setappdata(gcf, 'tmpSettings', settings);



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox4



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox5.
function checkbox5_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox5



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function ok_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ok (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
