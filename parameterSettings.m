function varargout = parameterSettings(varargin)
% PARAMETERSETTINGS M-file for parameterSettings.fig
%      PARAMETERSETTINGS, by itself, creates a new PARAMETERSETTINGS or raises the existing
%      singleton*.
%
%      H = PARAMETERSETTINGS returns the handle to a new PARAMETERSETTINGS or the handle to
%      the existing singleton*.
%
%      PARAMETERSETTINGS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PARAMETERSETTINGS.M with the given input arguments.
%
%      PARAMETERSETTINGS('Property','Value',...) creates a new PARAMETERSETTINGS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before parameterSettings_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to parameterSettings_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help parameterSettings

% Last Modified by GUIDE v2.5 04-Oct-2010 15:47:49

%--------------------------------------------------------------------------
% FlyFly v2
%
% Jonas Henriksson, 2010                                   info@flyfly.se
%--------------------------------------------------------------------------

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @parameterSettings_OpeningFcn, ...
                   'gui_OutputFcn',  @parameterSettings_OutputFcn, ...
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


% --- Executes just before parameterSettings is made visible.
function parameterSettings_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to parameterSettings (see VARARGIN)

% Choose default command line output for parameterSettings
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes parameterSettings wait for user response (see UIRESUME)
% uiwait(handles.figure1);

%Get current settings
navData     = getappdata(0, 'navData');
chstimuli   = getappdata(0, 'chstimuli');
index       = navData.activeStim;
z           = navData.marker(index);

layer = chstimuli(index).layers(z);

tmpComplex = layer.complex;

%set layer name
set(handles.text2, 'String', layer.name);

setappdata(gcf, 'tmpComplex', tmpComplex);

updateFigure(handles);

% --- Outputs from this function are returned to the command line.
function varargout = parameterSettings_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in globalSetting.
function globalSetting_Callback(hObject, eventdata, handles)
% hObject    handle to globalSetting (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of globalSetting

% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2


% --- Executes on button press in checkbox2.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2


% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox4


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


% --- Executes on button press in ok.
function ok_Callback(hObject, eventdata, handles)
% hObject    handle to ok (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%save current values
setValues(handles);

chstimuli = getappdata(0, 'chstimuli');
navData   = getappdata(0, 'navData');
complex   = getappdata(gcf, 'tmpComplex');

index = navData.activeStim;
z     = navData.marker(index);

%save new settings
chstimuli(index).layers(z).complex = complex;

setappdata(0, 'chstimuli', chstimuli);
close(gcf);

% --- Executes on button press in cancel.
function cancel_Callback(hObject, eventdata, handles)
% hObject    handle to cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(gcf);

function updateFigure(handles)

complex = getappdata(gcf, 'tmpComplex');
k = str2num(get(handles.currentTrial, 'String'));

%set drop down list
trialList = [];

C = length(complex);
for c = 1:C
    trialList{c} = ['Trial ' num2str(c)];
    
    if c == k
        trialList{c} = strcat(trialList{c}, '*');
    end
end

set(handles.trialList, 'String', trialList);

%global
set(handles.globalSetting, 'Value', complex(k).global);

%box settings
if strcmp(complex(k).box1{1}, 'OFF')
    set(handles.checkbox1, 'Enable', 'Off');
else
    set(handles.checkbox1, 'Enable', 'On');
    set(handles.checkbox1, 'String', complex(k).box1{1});
    set(handles.checkbox1, 'Value',  complex(k).box1{2});
end

if strcmp(complex(k).box2{1}, 'OFF')
    set(handles.checkbox2, 'Enable', 'Off');
else
    set(handles.checkbox2, 'Enable', 'On');
    set(handles.checkbox2, 'String', complex(k).box1{1});
    set(handles.checkbox2, 'Value',  complex(k).box1{2});
end

if strcmp(complex(k).box3{1}, 'OFF')
    set(handles.checkbox3, 'Enable', 'Off');
else
    set(handles.checkbox3, 'Enable', 'On');
    set(handles.checkbox3, 'String', complex(k).box1{1});
    set(handles.checkbox3, 'Value',  complex(k).box1{2});
end

if strcmp(complex(k).box4{1}, 'OFF')
    set(handles.checkbox4, 'Enable', 'Off');
else
    set(handles.checkbox4, 'Enable', 'On');
    set(handles.checkbox4, 'String', complex(k).box1{1});
    set(handles.checkbox4, 'Value',  complex(k).box1{2});
end

%----------------Set Values------------------------%
function setValues(handles)

complex = getappdata(gcf, 'tmpComplex');
k        = str2num(get(handles.currentTrial, 'String'));

%global settings
complex(k).global = get(handles.globalSetting, 'Value');


%box settings
if ~strcmp(complex(k).box1{1}, 'OFF') 
    complex(k).box1{2} = get(handles.checkbox1, 'Value'); 
end

if ~strcmp(complex(k).box2{1}, 'OFF') 
    complex(k).box2{2} = get(handles.checkbox2, 'Value'); 
end

if ~strcmp(complex(k).box3{1}, 'OFF')
    complex(k).box3{2} = get(handles.checkbox3, 'Value');
end

if ~strcmp(complex(k).box4{1}, 'OFF')
    complex(k).box4{2} = get(handles.checkbox3, 'Value');
end


setappdata(gcf, 'tmpComplex', complex);
