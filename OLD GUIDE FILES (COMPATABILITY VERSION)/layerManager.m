function varargout = layerManager(varargin)
% LAYERMANAGER M-file for layerManager.fig
%      LAYERMANAGER, by itself, creates a new LAYERMANAGER or raises the existing
%      singleton*.
%
%      H = LAYERMANAGER returns the handle to a new LAYERMANAGER or the handle to
%      the existing singleton*.
%
%      LAYERMANAGER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LAYERMANAGER.M with the given input arguments.
%
%      LAYERMANAGER('Property','Value',...) creates a new LAYERMANAGER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before layerManager_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to layerManager_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help layerManager

% Last Modified by GUIDE v2.5 08-Sep-2010 16:03:58

%--------------------------------------------------------------------------
% FlyFly v2
%
% Jonas Henriksson, 2010                                   info@flyfly.se
%--------------------------------------------------------------------------

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @layerManager_OpeningFcn, ...
                   'gui_OutputFcn',  @layerManager_OutputFcn, ...
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


% --- Executes just before layerManager is made visible.
function layerManager_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to layerManager (see VARARGIN)

% Choose default command line output for layerManager
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes layerManager wait for user response (see UIRESUME)
% uiwait(handles.figure1);

setappdata(gcf, 'updateCaller', varargin);
updateFigure(handles);


% --- Outputs from this function are returned to the command line.
function varargout = layerManager_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in chlayers.
function chlayers_Callback(hObject, eventdata, handles)
% hObject    handle to chlayers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns chlayers contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chlayers


% --- Executes during object creation, after setting all properties.
function chlayers_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chlayers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in avlayers.
function avlayers_Callback(hObject, eventdata, handles)
% hObject    handle to avlayers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns avlayers contents as cell array
%        contents{get(hObject,'Value')} returns selected item from avlayers


%add chosen layers to chlayers
if strcmp(get(handles.figure1,'SelectionType'),'open') %check if doubleclick


    chstimuli = getappdata(0, 'chstimuli');
    navData   = getappdata(0, 'navData');
    
    index        = get(handles.avlayers,'Value');  %get index of selected object

    
    [tmp, numRuns] = size(chstimuli(navData.activeStim).layers(1).data);
    
    new_layer    = getLayer(index);     % Chosen stimuli to add
    data         = new_layer.data;
    settings     = new_layer.settings;
    [tmp, C]       = size(data);
    
    if C < numRuns
        for c = 1:(numRuns-C)
            data(:,c+1)     = data(:,c);
            settings(:,c+1) = settings(:,c);
        end
    end
    
    new_layer.data     = data;  
    new_layer.settings = settings;
    write_index        = length(chstimuli(navData.activeStim).layers) +1; % Index to write to (last in list)    
    
    chstimuli(navData.activeStim).layers(write_index) = new_layer; % Add to array
    
        
    setappdata(0, 'chstimuli', chstimuli); % save changes
    setappdata(0, 'navData',   navData);   % save changes
    
    set(handles.chlayers,'Value',write_index);    % update marker
    
    updateFigure(handles); %update
end


% --- Executes during object creation, after setting all properties.
function avlayers_CreateFcn(hObject, eventdata, handles)
% hObject    handle to avlayers (see GCBO)
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
index     = get(handles.chlayers, 'Value');
chstimuli = getappdata(0, 'chstimuli');
navData   = getappdata(0, 'navData');

layers = chstimuli(navData.activeStim).layers;

if index > 1 %over 1, move up
    
    tmp = layers(index);
    layers(index)   = layers(index-1);
    layers(index-1) = tmp;
    
    chstimuli(navData.activeStim).layers = layers;
    setappdata(0, 'chstimuli', chstimuli);
    
    set(handles.chlayers,'Value',index-1);    
    updateFigure(handles);
end

% --- Executes on button press in moveDown.
function moveDown_Callback(hObject, eventdata, handles)
% hObject    handle to moveDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%get selected index of listbox2
index     = get(handles.chlayers, 'Value');
chstimuli = getappdata(0, 'chstimuli');
navData   = getappdata(0, 'navData');

layers = chstimuli(navData.activeStim).layers;

if index < length(layers)
    
    tmp = layers(index);
    layers(index)   = layers(index+1);
    layers(index+1) = tmp;
    
    chstimuli(navData.activeStim).layers = layers;
    setappdata(0, 'chstimuli', chstimuli);
    
    set(handles.chlayers,'Value',index+1);    
    updateFigure(handles);
end


% --- Executes on button press in remove.
function remove_Callback(hObject, eventdata, handles)
% hObject    handle to remove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%get selected index of listbox2
index     = get(handles.chlayers, 'Value');          %to be removed
chstimuli = getappdata(0, 'chstimuli');
navData   = getappdata(0, 'navData');

layers = chstimuli(navData.activeStim).layers;

%check if there are any objects to remove and disallow removing main
if length(layers) == 1
    disp(' -Need at least 1 layer!');
else
    
    N = length(layers) - index;  %number of entries needs to move
    
    for n = 0:N-1
        layers(index+n) = layers(index+n+1);
    end
    layers = layers(1:end-1); %remove last entry    
    
    if navData.marker(navData.activeStim) > length(layers)
        navData.marker(navData.activeStim) = navData.marker(navData.activeStim) -1;
    end
    
    chstimuli(navData.activeStim).layers = layers;
    
    setappdata(0, 'chstimuli', chstimuli); %Save changes
    setappdata(0, 'navData',   navData);
    
    if index > length(layers)
        set(handles.chlayers,'Value',index-1);  %move up index
    end
    
    updateFigure(handles);
end

% --- Executes on button press in ok.
function ok_Callback(hObject, eventdata, handles)
% hObject    handle to ok (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

updateCaller   = getappdata(gcf, 'updateCaller');
updateFunction = updateCaller{1};
updateHandles  = updateCaller{2};
updateFunction(updateHandles);

close(gcf);


% --- Executes on button press in cancel.
function cancel_Callback(hObject, eventdata, handles)
% hObject    handle to cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function updateFigure(handles)

avstimuli  = getLayer('List');
chstimuli  = getappdata(0, 'chstimuli');
navData    = getappdata(0, 'navData');
screenData = getappdata(0, 'screenData');

index = navData.activeStim;

%Update listboxes
names_avlayers = avstimuli;
names_chlayers = {chstimuli(index).layers.name};

set(handles.avlayers,'String',names_avlayers);
set(handles.chlayers,'String',names_chlayers);


% --- Executes on button press in copy.
function copy_Callback(hObject, eventdata, handles)
% hObject    handle to copy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%get selected index of listbox2
index     = get(handles.chlayers, 'Value');          %to be copied
chstimuli = getappdata(0, 'chstimuli');
navData   = getappdata(0, 'navData');

layers    = chstimuli(navData.activeStim).layers;

%check if there are any objects to copy and disallow removing main
if ~isempty(layers)
    
    N = length(layers) - index;  %number of entries needs to move
    
    for n = 0:N+1
        layers(end+1-n) = layers(end-n);
    end
        
    chstimuli(navData.activeStim).layers = layers;
    
    setappdata(0, 'chstimuli', chstimuli); %Save changes    
        
    updateFigure(handles);
end
