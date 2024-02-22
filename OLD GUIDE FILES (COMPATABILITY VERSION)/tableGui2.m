function varargout = tableGui2(varargin)
% TABLEGUI2 M-file for tableGui2.fig
%      TABLEGUI2, by itself, creates a new TABLEGUI2 or raises the existing
%      singleton*.
%
%      H = TABLEGUI2 returns the handle to a new TABLEGUI2 or the handle to
%      the existing singleton*.
%
%      TABLEGUI2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TABLEGUI2.M with the given input arguments.
%
%      TABLEGUI2('Property','Value',...) creates a new TABLEGUI2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before tableGui2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to tableGui2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help tableGui2

% Last Modified by GUIDE v2.5 04-Apr-2017 15:09:19

%--------------------------------------------------------------------------
% FlyFly v2
%
% Jonas Henriksson, 2010                                   info@flyfly.se
%--------------------------------------------------------------------------

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @tableGui2_OpeningFcn, ...
    'gui_OutputFcn',  @tableGui2_OutputFcn, ...
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


% --- Executes just before tableGui2 is made visible.
function tableGui2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to tableGui2 (see VARARGIN)

% Choose default command line output for tableGui2
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes tableGui2 wait for user response (see UIRESUME)
% uiwait(handles.figure1);

navData   = getappdata(0, 'navData');

screenRes = get(0, 'ScreenSize'); %[1 1 screenWidth screenHeight]

set(gcf, 'Units' , 'Pixels');
posdata = get(gcf,'Position');
height = posdata(4);
width = posdata(3);
set(gcf, 'Position', [navData.windowPosition (screenRes(4)-height)/2 width height]);

%enable subfunctions
addpath Subfunctions

%Save handle to this figure
hGui = gcf;
navFcn(handles, 'AddHandle', hGui);

%disp('tableGui2 started')
updateFigure(handles);


% --- Updates the figure
function updateFigure(handles)
navFcn(handles, 'Update'); %Updates the previous and next buttons
updateTable(handles);
drawnow;


% --- Outputs from this function are returned to the command line.
function varargout = tableGui2_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in previous.
function previous_Callback(hObject, eventdata, handles)
% hObject    handle to previous (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

navData   = getappdata(0, 'navData');    %navigation data
index     = navData.activeStim;          %index of current gui

gotoStim(handles, index - 1)

% --- Executes on button press in next.
function next_Callback(hObject, eventdata, handles)
% hObject    handle to next (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%load data
navData   = getappdata(0, 'navData');
index     = navData.activeStim;                         %current stim

gotoStim(handles, index+1);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure

navFcn(handles, 'Close'); % clean up
delete(hObject);


% --- Executes on button press in run.
function run_Callback(hObject, eventdata, handles)
% hObject    handle to run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

navData    = getappdata(0, 'navData');
screenData = getappdata(0, 'screenData');
chstimuli  = getappdata(0, 'chstimuli');

index      = navData.activeStim;

if ~screenData.isInit %if screen is not init, initialize and close after run
    disp(' ');
    disp('Initilizing screen for single experiment...')
    screenFcn('Init');
    screenData  = getappdata(0, 'screenData');
    closeScreen = 1;
else
    closeScreen = 0;
end

%Screen is now in use, update navData and figure
screenData.inUse = 1;

setappdata(0, 'screenData', screenData);
updateFigure(handles);

[~, C]  = size(chstimuli(index).layers(1).data); %same number of trials in all layers

if get(handles.trialSubset, 'Value') %cut down data set
    trialSubset = get(handles.trials, 'String');
    
    if isempty(trialSubset)
        trialSubset = 1:C;
    else
        trialSubset = eval(strrep(trialSubset,'end',num2str(C)));
        % automatically clip values larger than the number of trials
        trialSubset = min(C,trialSubset);
    end

else
    trialSubset = 1:C;
end

%
% --RUN STIMULUS HERE--

screenData = getappdata(0, 'screenData');
missed = animationLoop(chstimuli(index), screenData, navData, trialSubset);

%
%

navData.skippedLatest = missed;
navData.skippedFrames = navData.skippedFrames + missed;

screenData.inUse   = 0;

setappdata(0, 'screenData', screenData);
setappdata(0, 'navData',    navData);

updateFigure(handles);

if closeScreen
    screenFcn('Kill');
end


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


function numRuns_Callback(hObject, eventdata, handles)
% hObject    handle to numRuns (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of numRuns as text
%        str2double(get(hObject,'String')) returns contents of numRuns as a double


% --- Executes during object creation, after setting all properties.
function numRuns_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numRuns (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when entered data in editable cell(s) in uitable1.
function uitable1_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to uitable1 (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: chosenRow and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

%Update edited data
chstimuli = getappdata(0, 'chstimuli');
navData   = getappdata(0, 'navData');

index     = navData.activeStim;
z         = navData.marker(index);

newData   = get(handles.uitable1, 'Data');
chstimuli(index).layers(z).data = newData;
setappdata(0, 'chstimuli', chstimuli);


% --- Executes on button press in numRunsOk.
function numRunsOk_Callback(hObject, eventdata, handles)
% hObject    handle to numRunsOk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%
chstimuli = getappdata(0, 'chstimuli');
navData   = getappdata(0, 'navData');

index    = navData.activeStim;
numRuns  = round(abs(str2num(get(handles.numRuns, 'String'))));

if isempty(numRuns)
    numRuns = 1;
end

numLayers = length(chstimuli(index).layers);

for z = 1:numLayers
    
    data     = chstimuli(index).layers(z).data;
    settings = chstimuli(index).layers(z).settings;
    %complex  = chstimuli(index).layers(z).complex;
    [tmp, C]   = size(data);
    
    if numRuns > C %add more columns
        for c = 1:(numRuns-C)
            data(:, C+c)     = data(:, C);
            settings(:, C+c) = settings(:, C);
            %complex(:, C+c)  = complex(:, C);
        end
    elseif numRuns < C && numRuns > 0 %remove columns
        for c = 1:(C-numRuns)
            data(:, C-c+1)     = [];
            settings(:, C-c+1) = [];
            %complex(:, C+c)    = [];
        end
    end
    
    chstimuli(index).layers(z).data     = data;
    chstimuli(index).layers(z).settings = settings;
    %chstimuli(index).layers(z).complex  = complex;
end

setappdata(0, 'chstimuli', chstimuli);
updateTable(handles);


function chosenRow_Callback(hObject, eventdata, handles)
% hObject    handle to chosenRow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of chosenRow as text
%        str2double(get(hObject,'String')) returns contents of chosenRow as a double


% --- Executes during object creation, after setting all properties.
function chosenRow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chosenRow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in rowLin.
function rowLin_Callback(hObject, eventdata, handles)
% hObject    handle to rowLin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Interpolate from start to stop values linearly
if get(handles.allRows, 'Value')
    
    chstimuli = getappdata(0, 'chstimuli');
    navData   = getappdata(0, 'navData');
    index     = navData.activeStim;
    z         = navData.marker(index);
    
    data      = chstimuli(index).layers(z).data;
    [R, tmp, tmp] = size(data);
    
    for r = 1:R
        rowInterp(handles, r, 'LIN');
    end
else
    row = str2num(get(handles.chosenRow, 'String'));
    rowInterp(handles, row, 'LIN');
end
updateFigure(handles);

% --- Executes on button press in rowLog.
function rowLog_Callback(hObject, eventdata, handles)
% hObject    handle to rowLog (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Interpolate from start to stop values logarithmicly
if get(handles.allRows, 'Value')
    
    chstimuli = getappdata(0, 'chstimuli');
    navData   = getappdata(0, 'navData');
    index     = navData.activeStim;
    z         = navData.marker(index);
    
    data      = chstimuli(index).layers(z).data;
    [R, ~, ~] = size(data);
    
    for r = 1:R
        rowInterp(handles, r, 'LOG');
    end
else
    row = str2num(get(handles.chosenRow, 'String'));
    rowInterp(handles, row, 'LOG');
end
updateFigure(handles);


% --- Executes on button press in rowShuffle.
function rowShuffle_Callback(hObject, eventdata, handles)
% hObject    handle to rowShuffle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(handles.allRows, 'Value')
    
    chstimuli = getappdata(0, 'chstimuli');
    navData   = getappdata(0, 'navData');
    index     = navData.activeStim;
    z         = navData.marker(index);
    
    data      = chstimuli(index).layers(z).data;
    [R, ~, ~] = size(data);
    
    for r = 1:R
        rowShuffle(handles, r);
    end
else
    row = str2num(get(handles.chosenRow, 'String'));
    rowShuffle(handles, row);
end
updateFigure(handles);


% --- Executes on button press in editName.
function editName_Callback(hObject, eventdata, handles)
% hObject    handle to editName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

chstimuli = getappdata(0, 'chstimuli');
navData   = getappdata(0, 'navData');
index     = navData.activeStim;

newName = inputdlg({'Enter new name: '}, '', 1, {chstimuli(index).name});

if ~isempty(newName)
    chstimuli(index).name = newName{1};
    setappdata(0, 'chstimuli', chstimuli);
    
    updateTable(handles);
end

% --------------------------------------------------------------------
function file_Callback(hObject, eventdata, handles)
% hObject    handle to file (see GCBO)
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
updateFigure(handles);

% --------------------------------------------------------------------
function saveAs_Callback(hObject, eventdata, handles)
% hObject    handle to saveAs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
menuFcn('SaveAs');
updateTable(handles);

% --------------------------------------------------------------------
function exit_Callback(hObject, eventdata, handles)
% hObject    handle to exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(gcf);


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


% --- Executes on button press in stimSettings.
function stimSettings_Callback(hObject, eventdata, handles)
% hObject    handle to stimSettings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

settings;


% --- Executes on button press in trialSubset.
function trialSubset_Callback(hObject, eventdata, handles)
% hObject    handle to trialSubset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of trialSubset

if get(hObject,'Value') %Use single trial
    set(handles.trials, 'Enable', 'on');
else
    set(handles.trials, 'Enable', 'off');
end


function trials_Callback(hObject, eventdata, handles)
% hObject    handle to trials (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of trials as text
%        str2double(get(hObject,'String')) returns contents of trials as a double


% --- Executes during object creation, after setting all properties.
function trials_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trials (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in resetMissed.
function resetMissed_Callback(hObject, eventdata, handles)
% hObject    handle to resetMissed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
navData = getappdata(0, 'navData');

navData.skippedFrames = 0;

disp('Total number of skipped frames reset');

setappdata(0, 'navData', navData);
updateTable(handles);


% --- Executes when selected cell(s) is changed in uitable1.
function uitable1_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to uitable1 (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)


index = eventdata.Indices;
try
    set(handles.chosenRow, 'String', num2str(index(1)));
    set(handles.chosenCol, 'String', num2str(index(2)));
end


% --- Executes on key press with focus on uitable1 and none of its controls.
function uitable1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to uitable1 (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

% Paste data into sequencer table
if length(eventdata.Modifier) == 1 && strcmp(eventdata.Modifier{:},'control') && ... 
        strcmp(eventdata.Key,'v')
    import = importdata('-pastespecial');

    chstimuli = getappdata(0, 'chstimuli');
    navData   = getappdata(0, 'navData');

    index    = navData.activeStim;
    z        = navData.marker(index);

    data     = chstimuli(index).layers(z).data;

    selectedRow = str2num(get(handles.chosenRow, 'String'));
    selectedCol = str2num(get(handles.chosenCol, 'String'));

    [r c] = size(import);   % size of data in clipboard
    [R C] = size(data);     % size of current data

    endRow = selectedRow+r-1;
    endRow = min(R,endRow);

    endCol = selectedCol+c-1;
    endCol = min(C,endCol);

    for i = selectedRow:endRow
        for j = selectedCol:endCol
            value = import(i-selectedRow+1, j-selectedCol+1);
            if isnumeric(value)
                data(i,j) = value;
            end
        end
    end

    chstimuli(index).layers(z).data = data;
    setappdata(0, 'chstimuli', chstimuli);

end
updateFigure(handles);


function trialStop_Callback(hObject, eventdata, handles)
% hObject    handle to trialStop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of trialStop as text
%        str2double(get(hObject,'String')) returns contents of trialStop as a double


% --- Executes during object creation, after setting all properties.
function trialStop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trialStop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function updateTable(handles)
%------------------------------------------------------------------
% --- Executes when the tableGui2 is updated

navData     = getappdata(0, 'navData');  %Load navigation data
screenData  = getappdata(0, 'screenData');  %Load navigation data
chstimuli   = getappdata(0, 'chstimuli');

%Read parameters to set (default values of chstimuli(index))
index      = navData.activeStim;
Z          = length(chstimuli(index).layers);
z          = navData.marker(index);

if z > Z
    z = Z;
    navData.marker(index) = Z; %if we lowered the number of objects
end

data  = chstimuli(index).layers(z).data;
names = chstimuli(index).layers(z).parameters;
impulse = chstimuli(index).layers(z).impulse;

[tmp, C] = size(data);

% Check or uncheck impulse
set(handles.impulse, 'Value', impulse);

%Set the table data
set(handles.uitable1, 'Data', data);

%Set row names
set(handles.uitable1, 'RowName', names);

%Make table editable
columnEditable  = true(1, C);
set(handles.uitable1, 'ColumnEditable', columnEditable);

columnFormat = cell(1,C);
columnFormat = cellfun(@(x) 'numeric', columnFormat, 'UniformOutput', false);
set(handles.uitable1, 'ColumnFormat',columnFormat);

%Set columnnames and width
for c = 1:C
    columnName{c} = strcat('Trial_', num2str(c));
    columnWidth{c} = navData.colWidth;
end
set(handles.uitable1, 'ColumnName',  columnName);
set(handles.uitable1, 'ColumnWidth', columnWidth);

%set numRuns
set(handles.numRuns, 'String', num2str(C));

%Title - Update the title so that it is correct.
set(handles.stimName,  'String', chstimuli(index).name);

%layername
set(handles.layerName,  'String', ['Layer ' num2str(z) ':' chstimuli(index).layers(z).name]);

%Update project name
set(handles.figure1, 'Name', ['FlyFly 3.0: ' navData.fileName]);

%set info label
if screenData.isInit
    newInfo{1} = ['Screen: ' num2str(screenData.rect(3)) 'x' ...
        num2str(screenData.rect(4)) ' px, ' ...
        num2str(screenData.hz) ' Hz'];
else
    newInfo{1} = 'Screen: Not initialized';
end

newInfo{2} = ['Skipped frames: ' num2str(navData.skippedLatest)];
newInfo{3} = ['Skipped total: '  num2str(navData.skippedFrames)];

set(handles.info, 'String', newInfo);

%set drop down list (stimuli)
[tmp, C, Z] = size(chstimuli);
stimList = [];
for c = 1:C
    stimList{c} = [chstimuli(c).name];
    if c == navData.activeStim
        stimList{c} = strcat(stimList{c}, '*');
    end
end
set(handles.stimList, 'String', stimList);
set(handles.stimList, 'Value', index);

%set drop down list (layer)
[tmp, C, Z] = size(chstimuli(index).layers);
layerList = [];

for c = 1:C
    layerList{c} = [chstimuli(index).layers(c).name];
    
    if c == z
        layerList{c} = strcat(layerList{c}, '*');
    end
end
set(handles.layerList, 'String', layerList);
set(handles.layerList, 'Value', z);

% % %disable run button
% % if screenData.inUse || ~screenData.isInit
% %     set(handles.run, 'Enable', 'off');
% % else
% %     set(handles.run, 'Enable', 'on');
% % end

%disable "next" button
if index == length(chstimuli)
    set(handles.next, 'Visible', 'Off');
else
    set(handles.next, 'Visible', 'On');
end

function rowShuffle(handles, Row)

%Interpolate from start to stop values linearly
chstimuli = getappdata(0, 'chstimuli');
navData   = getappdata(0, 'navData');

index    = navData.activeStim;
z        = navData.marker(index);

data     = chstimuli(index).layers(z).data;

[R C]    = size(data);

if Row <= R && Row >= 1
    
    data(Row,:) = Shuffle(data(Row,:));
    
    chstimuli(index).layers(z).data = data;
    setappdata(0, 'chstimuli', chstimuli);
end

function rowInterp(handles, Row, Mode)

%Interpolate from start to stop values linearly
chstimuli = getappdata(0, 'chstimuli');
navData   = getappdata(0, 'navData');

index    = navData.activeStim;
z        = navData.marker(index);

data     = chstimuli(index).layers(z).data;

[R C]  = size(data);

if Row <= R && Row >= 1
    
    firstVal = data(Row, 1);
    lastVal  = data(Row, C);
    
    switch Mode
        case 'LIN'
            data(Row, 1:end) = linspace(firstVal, lastVal, C);
        case 'LOG'
            data(Row, 1:end) = logspace(log10(firstVal), log10(lastVal), C);
        otherwise
            disp(['Incorrect case(rowInterp: ' Mode ')']);
    end
    
    chstimuli(index).layers(z).data = data;
    setappdata(0, 'chstimuli', chstimuli);
end

% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in shuffleTrials.
function shuffleTrials_Callback(hObject, eventdata, handles)
% hObject    handle to shuffleTrials (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of shuffleTrials


% --- Executes on selection change in stimList.
function stimList_Callback(hObject, eventdata, handles)
% hObject    handle to stimList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns stimList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from stimList

%get new selection
stim        = get(hObject,'Value'); %index of chosen stim
gotoStim(handles, stim)

function gotoStim(handles, stimNO)

chstimuli  = getappdata(0, 'chstimuli');
navData    = getappdata(0, 'navData');
index      = navData.activeStim;

%dont change if press on current stim or if last stim in list
if index ~= stimNO && stimNO <= length(chstimuli)
    %update
    navData.activeStim = stimNO;                     %update index
    setappdata(0, 'navData', navData);               %save navData
    
    %If the next gui belongs to the same template class we only change
    %the content of the gui. If the template differs we need to open
    %(eval) a new gui.
    if strcmp(chstimuli(index).fileNameGui, chstimuli(stimNO).fileNameGui)
        updateFigure(handles);
    else
        %switch gui
        nextGui  = chstimuli(stimNO).fileNameGui;
        
        delete(gcf)    %close current gui
        eval(nextGui); %start new gui
    end
end

% --- Executes during object creation, after setting all properties.
function stimList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stimList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in useValue1.
function useValue1_Callback(hObject, eventdata, handles)
% hObject    handle to useValue1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

chstimuli = getappdata(0, 'chstimuli');
navData   = getappdata(0, 'navData');

row = str2num(get(handles.chosenRow, 'String'));
col = str2num(get(handles.chosenCol, 'String'));

numVal = str2num(get(handles.valNum, 'String'));

index    = navData.activeStim;
z        = navData.marker(index);

data     = chstimuli(index).layers(z).data;

[tmp, C] = size(data);
if get(handles.allRows, 'Value')
    
    for c = 1:C
        if mod(c-col, numVal) == 0
            data(:,c) = data(:,col);
        end
    end
    
else
    for c = 1:C
        if mod(c-col, numVal) == 0
            data(row,c) = data(row,col);
        end
    end
end

chstimuli(index).layers(z).data  = data;
setappdata(0, 'chstimuli', chstimuli);
updateTable(handles);


% --- Executes on button press in allRows.
function allRows_Callback(hObject, eventdata, handles)
% hObject    handle to allRows (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of allRows


% --- Executes on button press in grid.
function grid_Callback(hObject, eventdata, handles)
% hObject    handle to grid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
screenData = getappdata(0, 'screenData');

if screenData.isInit
    screenFcn('DrawGrid');
    Screen(screenData.wPtr, 'Flip');
    
    screenData.inUse = 0;
    setappdata(0, 'screenData', screenData);
    updateFigure(handles);
end

% --- Executes on button press in clear.
function clear_Callback(hObject, eventdata, handles)
% hObject    handle to clear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
screenFcn('Clear');

screenData = getappdata(0, 'screenData');
screenData.inUse = 0;
setappdata(0, 'screenData', screenData);
updateFigure(handles);


function chosenCol_Callback(hObject, eventdata, handles)
% hObject    handle to chosenCol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of chosenCol as text
%        str2double(get(hObject,'String')) returns contents of chosenCol as a double


% --- Executes during object creation, after setting all properties.
function chosenCol_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chosenCol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function valNum_Callback(hObject, eventdata, handles)
% hObject    handle to valNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of valNum as text
%        str2double(get(hObject,'String')) returns contents of valNum as a double


% --- Executes during object creation, after setting all properties.
function valNum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to valNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in layerManager.
function layerManager_Callback(hObject, eventdata, handles)
% hObject    handle to layerManager (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

layerManager(@updateTable, handles);

% --- Executes on selection change in layerList.
function layerList_Callback(hObject, eventdata, handles)
% hObject    handle to layerList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns layerList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from layerList

%get new selection
layer        = get(hObject,'Value'); %index of chosen stim
gotoLayer(handles, layer)

function gotoLayer(handles, layerNO)

chstimuli  = getappdata(0, 'chstimuli');
navData    = getappdata(0, 'navData');
index      = navData.activeStim;
z          = navData.marker(index);

if z ~= layerNO %dont change if press on current layer
    
    %update
    navData.marker(index) = layerNO;                 %update index
    setappdata(0, 'navData', navData);               %save navData
    
    updateTable(handles);
end

% --- Executes during object creation, after setting all properties.
function layerList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to layerList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in editLayerName.
function editLayerName_Callback(hObject, eventdata, handles)
% hObject    handle to editLayerName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

chstimuli = getappdata(0, 'chstimuli');
navData   = getappdata(0, 'navData');
index    = navData.activeStim;

newName = inputdlg({'Enter new layer name: '}, '', 1, {chstimuli(index).layers(navData.marker(index)).name});

if ~isempty(newName)
    
    chstimuli(index).layers(navData.marker(index)).name = newName{1};
    setappdata(0, 'chstimuli', chstimuli);
    
    updateTable(handles);
end


% --------------------------------------------------------------------
function importStim_Callback(hObject, eventdata, handles)
% hObject    handle to importStim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

menuFcn('importStim');
updateFigure(handles);


function edit15_Callback(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit15 as text
%        str2double(get(hObject,'String')) returns contents of edit15 as a double


% --- Executes during object creation, after setting all properties.
function edit15_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton37.
function pushbutton37_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton37 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton38.
function pushbutton38_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton38 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton39.
function pushbutton39_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton39 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in checkbox7.
function checkbox7_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox7


% --- Executes on button press in pushbutton40.
function pushbutton40_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton40 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit16_Callback(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit16 as text
%        str2double(get(hObject,'String')) returns contents of edit16 as a double


% --- Executes during object creation, after setting all properties.
function edit16_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit17_Callback(hObject, eventdata, handles)
% hObject    handle to edit17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit17 as text
%        str2double(get(hObject,'String')) returns contents of edit17 as a double


% --- Executes during object creation, after setting all properties.
function edit17_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function uitable1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to uitable1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function shiftColumn(step, handles)
% shift entire column by step

chstimuli = getappdata(0, 'chstimuli');
navData   = getappdata(0, 'navData');

index    = navData.activeStim;
z        = navData.marker(index);

data     = chstimuli(index).layers(z).data;

selectedCol = str2num(get(handles.chosenCol, 'String'));

[R C] = size(data);     % size of current data

moveToCol = min(max(selectedCol+step,1),C);

if moveToCol~=selectedCol

    temp = data(:,moveToCol);
    data(:,moveToCol) = data(:,selectedCol);
    data(:,selectedCol) = temp;

    chstimuli(index).layers(z).data = data;
    setappdata(0, 'chstimuli', chstimuli);

    set(handles.chosenCol, 'String', num2str(moveToCol));
    
    updateFigure(handles);
    
end


% --- Executes on button press in shiftColLeft.
function shiftColLeft_Callback(hObject, eventdata, handles)
% hObject    handle to shiftColLeft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

shiftColumn(-1,handles);

% --- Executes on button press in shiftColRight.
function shiftColRight_Callback(hObject, eventdata, handles)
% hObject    handle to shiftColRight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

shiftColumn(1,handles);


% --- Executes on button press in impulse.
function impulse_Callback(hObject, eventdata, handles)
% hObject    handle to impulse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of impulse

chstimuli = getappdata(0, 'chstimuli');
navData   = getappdata(0, 'navData');
index     = navData.activeStim;
z         = navData.marker(index);

chstimuli(index).layers(z).impulse = get(hObject,'Value');

setappdata(0, 'chstimuli', chstimuli);


% --- Executes on button press in mseq.
function mseq_Callback(hObject, eventdata, handles)
% hObject    handle to mseq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

param = inputdlg({'Base value: ','N:', 'Shift:', 'Which sequence:'}, 'm-sequence', 1, {'2','6','1','1'});
if ~isempty(param)
    baseVal = str2num(param{1});
    p = str2num(param{2});
    shift = str2num(param{3});
    which = str2num(param{4});
    if isnumeric(baseVal) && isnumeric(p) && isnumeric(shift) && isnumeric(which)
        change = str2num(get(handles.mseqChange, 'String'));
        sequence = change*mseq(baseVal,p,shift,which);
        
        chstimuli = getappdata(0, 'chstimuli');
        navData   = getappdata(0, 'navData');   

        index    = navData.activeStim;
        z        = navData.marker(index);

        data     = chstimuli(index).layers(z).data;
        chstimuli(index).layers(z).name = ...
            sprintf('%s (mseq: %d,%d,%d,%d)',chstimuli(index).layers(z).name,baseVal,p,shift,which);

        [R C]  = size(data);
        row = str2num(get(handles.chosenRow, 'String'));
        
        start = str2num(get(handles.mseqStart, 'String'));
        % extend sequence if it is too short
        sequence = repmat(sequence,ceil(C/length(sequence)),1);
        if get(handles.useCumsum, 'Value')
            data(row, 1:end) = start+cumsum(sequence(1:C));
        else
            data(row, 1:end) = start+sequence(1:C);
        end

        chstimuli(index).layers(z).data = data;
        setappdata(0, 'chstimuli', chstimuli);
        
        updateFigure(handles);
    end
end



function mseqChange_Callback(hObject, eventdata, handles)
% hObject    handle to mseqChange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mseqChange as text
%        str2double(get(hObject,'String')) returns contents of mseqChange as a double


% --- Executes during object creation, after setting all properties.
function mseqChange_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mseqChange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function mseqStart_Callback(hObject, eventdata, handles)
% hObject    handle to mseqStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mseqStart as text
%        str2double(get(hObject,'String')) returns contents of mseqStart as a double


% --- Executes during object creation, after setting all properties.
function mseqStart_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mseqStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --------------------------------------------------------------------
function Roelshuff_Callback(hObject, eventdata, handles)
% hObject    handle to Roelshuff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.allRows, 'Value')
    chstimuli = getappdata(0, 'chstimuli');
    navData   = getappdata(0, 'navData');
    index     = navData.activeStim;
    z         = navData.marker(index);
    
    data      = chstimuli(index).layers(z).data;
    [R, tmp, tmp] = size(data);
    
    for r = 1:R 
        RoelrowShuffle(handles, r);
        RoelrowShuffle(handles, r+2);
    end
else
    row = str2num(get(handles.chosenRow, 'String'));
    RoelrowShuffle(handles, row);
end

updateFigure(handles);



function edit22_Callback(hObject, eventdata, handles)
% hObject    handle to edit22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit22 as text
%        str2double(get(hObject,'String')) returns contents of edit22 as a double


% --- Executes during object creation, after setting all properties.
function edit22_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit23_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function special_Callback(hObject, eventdata, handles)
% hObject    handle to special (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function avimovie_Callback(hObject, eventdata, handles)
% hObject    handle to avimovie (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
navData    = getappdata(0, 'navData');
screenData = getappdata(0, 'screenData');
chstimuli  = getappdata(0, 'chstimuli');

index      = navData.activeStim;

if screenData.isInit
    
    [~, C]  = size(chstimuli(index).layers(1).data); %same number of trials in all layers
    
    if get(handles.trialSubset, 'Value') %cut down data set
        trialSubset = get(handles.trials, 'String');
    
        if isempty(trialSubset)
            trialSubset = 1:C;
        else
            trialSubset = eval(strrep(trialSubset,'end',num2str(C)));
            % automatically clip values larger than the number of trials
            trialSubset = min(C,trialSubset);
        end

    else
        trialSubset = 1:C;
    end
    
    fps = inputdlg({'Framerate to record in:'}, 'FPS', 1, {num2str(screenData.hz)});
    fps = str2num(fps{1});
    
    fprintf('Creating AVI file...\n');
    imageArray = getStimImages(chstimuli(index), screenData, navData, trialSubset, fps);
    
    [filename, pathname] = uiputfile('*.avi', 'Save stimulus movie to...');
    if isequal(filename,0) || isequal(pathname,0)
        disp('File NOT saved!');
    else
        disp('Working...');
        fn = fullfile(pathname, filename);
        aviobj = VideoWriter(fn);
        aviobj.FrameRate = fps;
        open(aviobj);
        for k = 1:length(imageArray)
            currframe = im2frame(imageArray{k});
            writeVideo(aviobj,currframe);
        end
        close(aviobj);
        fprintf('AVI file saved to %s!\n',fn);
    end
else
    disp('Screen is not initialized');
end

% --------------------------------------------------------------------
function imsequence_Callback(hObject, eventdata, handles)
% hObject    handle to imsequence (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
navData    = getappdata(0, 'navData');
screenData = getappdata(0, 'screenData');
chstimuli  = getappdata(0, 'chstimuli');

index      = navData.activeStim;

if screenData.isInit
    
    [~, C]  = size(chstimuli(index).layers(1).data); %same number of trials in all layers
    
    if get(handles.trialSubset, 'Value') %cut down data set
        trialSubset = get(handles.trials, 'String');
    
        if isempty(trialSubset)
            trialSubset = 1:C;
        else
            trialSubset = eval(strrep(trialSubset,'end',num2str(C)));
            % automatically clip values larger than the number of trials
            trialSubset = min(C,trialSubset);
        end

    else
        trialSubset = 1:C;
    end
    
    fps = inputdlg({'Framerate to record in:'}, 'FPS', 1, {num2str(screenData.hz)});
    fps = str2num(fps{1});
    disp('Creating image sequence...')
    imageArray = getStimImages(chstimuli(index), screenData, navData, trialSubset, fps);
    
    name = inputdlg({'Name sequence '}, 'Name', 1, {chstimuli(navData.activeStim).name});
    if ~isempty(name) %empty if press on cancel
        dir_name = uigetdir(cd,'Set target directory');
        if ischar(dir_name)
            ID    = datestr(now, 0);
            ID    = regexprep(ID, ':', '_'); %exchange ':' with '_' 
            for k = 1:length(imageArray)
                imwrite(imageArray{k}, fullfile(dir_name,sprintf('%s %s_%04.f.png',name{1},ID,k))); 
            end
            fprintf('Sequence saved to %s!\n',dir_name);
        else
            disp('Image sequence NOT saved!');
        end
    else
        disp('Image sequence NOT saved!');
    end
else
    disp('Screen is not initialized');
end


% --- Executes on button press in useCumsum.
function useCumsum_Callback(hObject, eventdata, handles)
% hObject    handle to useCumsum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of useCumsum


% --------------------------------------------------------------------
function recordStimulus_Callback(hObject, eventdata, handles)
% hObject    handle to recordStimulus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------


% if isempty(impset)
%     impset=struct('impSeries',1,'timeSeries',300,'stepsizes',{0,10,'log'},'frequency',40);
% end



function edit28_Callback(hObject, eventdata, handles)
% hObject    handle to edit28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit28 as text
%        str2double(get(hObject,'String')) returns contents of edit28 as a double


% --- Executes during object creation, after setting all properties.
function edit28_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit29_Callback(hObject, eventdata, handles)
% hObject    handle to edit29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit29 as text
%        str2double(get(hObject,'String')) returns contents of edit29 as a double


% --- Executes during object creation, after setting all properties.
function edit29_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit30_Callback(hObject, eventdata, handles)
% hObject    handle to edit30 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit30 as text
%        str2double(get(hObject,'String')) returns contents of edit30 as a double


% --- Executes during object creation, after setting all properties.
function edit30_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit30 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit31_Callback(hObject, eventdata, handles)
% hObject    handle to edit31 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit31 as text
%        str2double(get(hObject,'String')) returns contents of edit31 as a double


% --- Executes during object creation, after setting all properties.
function edit31_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit31 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in loadImpSet.
function loadImpSet_Callback(hObject, eventdata, handles)
% hObject    handle to loadImpSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if exist(fullfile(pwd,'curr_ImpSet.m'),'file')==2
    ImpSet=load(fullfile(pwd,'curr_ImpSet.mat'));
    setappdata(0,'ImpSet',ImpSet)
else warndlg('No file ''curr_Impset'' in current file directory.')
end


% --- Executes on button press in change.
function change_Callback(hObject, eventdata, handles)
% hObject    handle to change (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ImpSet=getappdata(0,'ImpSet');
if exist(fullfile(pwd,'curr_ImpSet.mat'),'file')==2
    if (isdir(fullfile(pwd,'oldImpSets')))==0
        mkdir(fullfile(pwd,'oldImpSets'))
    end
    currImpSets=load('curr_ImpSet.mat');
    c=clock;
    save( fullfile(pwd,'oldImpSets',['\ImpSet_',num2str(c(1)),'_',num2str(c(2)),'_',num2str(c(3)),'_',num2str(c(4)),'_',num2str(c(5))]), 'currImpSets');
end
save( fullfile(pwd,'curr_ImpSet.mat'),'ImpSet') 

% --- Executes on button press in createImpStim.
function createImpStim_Callback(hObject, eventdata, handles)
numRuns  = round(abs(str2num(get(handles.numSeries, 'String'))));
numSeqs     = get(handles.numSeqs, 'String');
timeSeq     = get(handles.time, 'String');

% hObject    handle to createImpStim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on key press with focus on numRunsOk and none of its controls.
function numRunsOk_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to numRunsOk (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on key press with focus on numRuns and none of its controls.
function numRuns_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to numRuns (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)



function time_Callback(hObject, eventdata, handles)
% hObject    handle to time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of time as text
%        str2double(get(hObject,'String')) returns contents of time as a double


% --- Executes during object creation, after setting all properties.
function time_CreateFcn(hObject, eventdata, handles)
% hObject    handle to time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function numSeqs_Callback(hObject, eventdata, handles)
% hObject    handle to numSeqs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of numSeqs as text
%        str2double(get(hObject,'String')) returns contents of numSeqs as a double


% --- Executes during object creation, after setting all properties.
function numSeqs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numSeqs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit35_Callback(hObject, eventdata, handles)
% hObject    handle to edit35 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit35 as text
%        str2double(get(hObject,'String')) returns contents of edit35 as a double


% --- Executes during object creation, after setting all properties.
function edit35_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit35 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit36_Callback(hObject, eventdata, handles)
% hObject    handle to edit36 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit36 as text
%        str2double(get(hObject,'String')) returns contents of edit36 as a double


% --- Executes during object creation, after setting all properties.
function edit36_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit36 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit37_Callback(hObject, eventdata, handles)
% hObject    handle to edit37 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit37 as text
%        str2double(get(hObject,'String')) returns contents of edit37 as a double


% --- Executes during object creation, after setting all properties.
function edit37_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit37 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton49.
function pushbutton49_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton49 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if exist(fullfile(pwd,'curr_ImpSet.m'),'file')==2
    ImpSet=load(fullfile(pwd,'curr_ImpSet.mat'));
    setappdata(0,'ImpSet',ImpSet)
else warndlg('No file ''curr_Impset'' in current file directory.')
end



% --- Executes on button press in pushbutton50. CHANGE IMPSET
function pushbutton50_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton50 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ImpSet=getappdata(0,'ImpSet');
if exist(fullfile(pwd,'curr_ImpSet.mat'),'file')==2
    if (isdir(fullfile(pwd,'oldImpSets')))==0
        mkdir(fullfile(pwd,'oldImpSets'))
    end
    currImpSets=load('curr_ImpSet.mat');
    c=clock;
    save( fullfile(pwd,'oldImpSets',['\ImpSet_',num2str(c(1)),'_',num2str(c(2)),'_',num2str(c(3)),'_',num2str(c(4)),'_',num2str(c(5))]), 'currImpSets');
end
save( fullfile(pwd,'curr_ImpSet.mat'),'ImpSet')






function edit38_Callback(hObject, eventdata, handles)
% hObject    handle to edit38 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit38 as text
%        str2double(get(hObject,'String')) returns contents of edit38 as a double


% --- Executes during object creation, after setting all properties.
function edit38_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit38 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit39_Callback(hObject, eventdata, handles) %# IMP SEQUENCES
% hObject    handle to edit39 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit39 as text
%        str2double(get(hObject,'String')) returns contents of edit39 as a double


% --- Executes during object creation, after setting all properties.
function edit39_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit39 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit40_Callback(hObject, eventdata, handles)
% hObject    handle to edit40 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit40 as text
%        str2double(get(hObject,'String')) returns contents of edit40 as a double


% --- Executes during object creation, after setting all properties.
function edit40_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit40 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ImpFreq_Callback(hObject, eventdata, handles)
% hObject    handle to ImpFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ImpFreq as text
%        str2double(get(hObject,'String')) returns contents of ImpFreq as a double


% --- Executes during object creation, after setting all properties.
function ImpFreq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ImpFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function impFreq_Callback(hObject, eventdata, handles)
% hObject    handle to impFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of impFreq as text
%        str2double(get(hObject,'String')) returns contents of impFreq as a double


% --- Executes during object creation, after setting all properties.
function impFreq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to impFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ImpRange1_Callback(hObject, eventdata, handles)
% hObject    handle to ImpRange1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ImpRange1 as text
%        str2double(get(hObject,'String')) returns contents of ImpRange1 as a double


% --- Executes during object creation, after setting all properties.
function ImpRange1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ImpRange1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ImpRange2_Callback(hObject, eventdata, handles)
% hObject    handle to ImpRange2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ImpRange2 as text
%        str2double(get(hObject,'String')) returns contents of ImpRange2 as a double


% --- Executes during object creation, after setting all properties.
function ImpRange2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ImpRange2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ImpRangeMethod_Callback(hObject, eventdata, handles)
% hObject    handle to ImpRangeMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ImpRangeMethod as text
%        str2double(get(hObject,'String')) returns contents of ImpRangeMethod as a double


% --- Executes during object creation, after setting all properties.
function ImpRangeMethod_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ImpRangeMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton51.
function pushbutton51_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton51 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


chstimuli=getappdata(0,'chstimuli');
settings = chstimuli(1,2).layers.settings;

%STIMULI
numSequences  = 10;     %number of displayed msequences []
trPerSeq      = 255;    %length of msequence []
y_ImpRange1   = 0.01; % min yaw stepsize [degrees]
y_ImpRange2   = 10;   % max yaw stepsize [degrees]
y_numSteps    = 15;    % number of different yaw stepsizes []
s_ImpRange1   = 0.01; % min sideslip stepsize [cm]
s_ImpRange2   = 10;      %max sideslip stepsize [cm]
s_numSteps    = 15;    % number of different sideslip stepsizes []
ImpFreq       = 60;     % impulse frequency [Hz]

% Logarithmic distribution of yaw and sideslip stepsizes and conversion to
% velocities (flyfly definition: velocity = Frequency*jumpsize)
yaw_range       = 120* logspace(log10(y_ImpRange1),log10(y_ImpRange2),y_numSteps); % [degrees/s]
sideslip_range  = 120* logspace(log10(s_ImpRange1),log10(s_ImpRange2),s_numSteps); % [cm/s]

% create data dummie 
dotSize=5;
numDots=5000;
sideslip=0; %will be changed in loop [cm/s]
lift=0;
thrust=0;
pitch=0;
yaw=0; %will be changed in loop [deg/s]
roll=0;
time=120/ImpFreq; %how frames the image will be rendered [frames]
pause=40;        %will be changed once for every sequence
prestim=120; %will be changed once for every sequence
poststim=120; %will be changed once for every sequence
data=repmat([dotSize;numDots;sideslip;lift;thrust;pitch;yaw;roll;time;0;0;0],1,255*numSequences);

mSeqPar=[]; %save msequence parameers: [shift , which; ...]

for sequence=1:numSequences
    %randomly choose yaw/sideslip and stepsize
    if (rand>0.5) 
        row=7;%yaw
        stepsize = yaw_range(ceil(rand*y_numSteps));
    else 
        row =3;%sideslip
        stepsize = sideslip_range(ceil(rand*s_numSteps));
    end
    
    %create m-sequence
    baseVal=2; p=8; shift=round(rand*255); which=round(rand*5);
    msequence= mseq(baseVal,p,shift,which);
    mSeqPar(end+1,1:2)=[shift,which];
    
    %change data
    data(row, (sequence-1)*trPerSeq+1 : sequence*trPerSeq) = msequence*stepsize; 
    data(11, (sequence-1)*trPerSeq+1)                      = prestim;
    data(12,                            sequence*trPerSeq) = poststim;
    data(10,                            sequence*trPerSeq) = pause;
end
if size(settings,2)<255*numSequences
    settings(:, 2:255*numSequences) = settings(:, 1);
end
save([date,'_mSeqPar.mat'],'mSeqPar');
chstimuli(1,2).layers.data=data;
chstimuli(1,2).layers.settings=settings;
setappdata(0, 'chstimuli', chstimuli);
updateFigure(handles);

function numStepSizes_Callback(hObject, eventdata, handles)
% hObject    handle to numStepSizes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of numStepSizes as text
%        str2double(get(hObject,'String')) returns contents of numStepSizes as a double


% --- Executes during object creation, after setting all properties.
function numStepSizes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numStepSizes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
