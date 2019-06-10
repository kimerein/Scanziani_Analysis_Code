function varargout = PlotChooser(varargin)
%
%
%
%   Began: 1/10 - SRO
%   Modified: 4/5/10 - SRO

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @PlotChooser_OpeningFcn, ...
    'gui_OutputFcn',  @PlotChooser_OutputFcn, ...
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

function PlotChooser_OpeningFcn(hObject, eventdata, handles, varargin)
RigDef = RigDefs;

% AIOBJ is the analog input object created in DaqController
global AIOBJ

% PlotChooser GUI handle is passed to DataViewer
handles.output = hObject;

% Assign PlotChooser handle in base workspace
assignin('base','hDaqPlotChooser',hObject);

% Set PlotChooser handle as appdata
setappdata(hObject,'hPlotChooser',hObject);

% Get DataViewer handle 
handles.hDataViewer = varargin{3};

% Set list of user probes and set value to user default
set(handles.ProbePopUp,'String',RigDef.Probe.UserProbes);
value = strcmp(RigDef.Probe.UserProbes,RigDef.Probe.Default);
set(handles.ProbePopUp,'Value',find(value == 1));

% Get guidata from DataViewer and set channel information
dvHandles = guidata(handles.hDataViewer);       % 'dv' indicates DataViewer
handles.board = dvHandles;
handles.nActiveChannels = dvHandles.nActiveChannels;
handles.hAllAxes = dvHandles.hAllAxes;
ChannelInfo = dvHandles.Channel;
ChannelInfo = [ChannelInfo.Index, ChannelInfo.ChannelName, ChannelInfo.HwChannel];
handles.ChannelInfo = ChannelInfo;

% Set up GUI
handles = PlotChooserHelper(handles);

% Use this callback to set channel order as appdata in ExptDataViewer
ProbePopUp_Callback(handles.ProbePopUp, [], handles);

% Update handles structure
guidata(hObject, handles);

function varargout = PlotChooser_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;
RigDef = RigDefs;
%150210 set(hObject,'Units','pixels','Position',[RigDef.PlotChooser.Position 439 356])
set(hObject,'Units','pixels','Position',[RigDef.PlotChooser.Position 480 530])
set(hObject,'Visible','on'); pause(0.25)

function ProbePopUp_Callback(hObject, eventdata, handles)
RigDef = RigDefs;

% Get channel order
value = get(handles.ProbePopUp,'Value');
ChannelOrder = RigDef.ChannelOrder{value};
Probe = RigDef.Probe.UserProbes{value};

ChannelOrder = ChannelOrder';
setappdata(handles.hDataViewer,'ChannelOrder',ChannelOrder);
setappdata(handles.hDataViewer,'Probe',Probe);
dvHandles = guidata(handles.hDataViewer);
if isfield(guidata(handles.hDataViewer) ,'hPlotLines')
    UpdateDataViewer(dvHandles);
end

function HPedit_Callback(hObject, eventdata, handles)
setappdata(handles.hDataViewer,'HPCutoff',str2num(get(hObject,'String')));

function LPedit_Callback(hObject, eventdata, handles)
setappdata(handles.hDataViewer,'LPCutoff',str2num(get(hObject,'String')));

function hSelectAllPlot_Callback(hObject, eventdata, handles)

set(handles.hTglPlotAll(1:handles.nActiveChannels),'Value',1);
for i = 1:handles.nActiveChannels
    handles = TogglePlotCallback(handles.hTglPlotAll(i),handles);
end
guidata(hObject,handles);

function hDeselectPlot_Callback(hObject, eventdata, handles)

set(handles.hTglPlotAll(1:handles.nActiveChannels),'Value',0);
for i = 1:handles.nActiveChannels
    handles = TogglePlotCallback(handles.hTglPlotAll(i),handles);
end
guidata(hObject,handles);

function hSelectAllHP_Callback(hObject, eventdata, handles)

for i = 1:handles.nActiveChannels
    if ~strcmp(get(handles.hTglHP(i),'Enable'),'off')
        set(handles.hTglHP(i),'Value',1);
        handles = HPCallback(handles.hTglHP(i),eventdata,handles);
    end  
end
guidata(hObject,handles);

function hDeselectHP_Callback(hObject, eventdata, handles)

for i = 1:handles.nActiveChannels
    if ~strcmp(get(handles.hTglHP(i),'Enable'),'off')
        set(handles.hTglHP(i),'Value',0);
        handles = HPCallback(handles.hTglHP(i),1,handles);
    end  
end
guidata(hObject,handles);

function hSelectAllLP_Callback(hObject, eventdata, handles)

for i = 1:handles.nActiveChannels
    if ~strcmp(get(handles.hTglLP(i),'Enable'),'off')
        set(handles.hTglLP(i),'Value',1);
        handles = LPCallback(handles.hTglLP(i),eventdata,handles);
    end
end
guidata(hObject,handles);

function hDeselectLP_Callback(hObject, eventdata, handles)

for i = 1:handles.nActiveChannels
    if ~strcmp(get(handles.hTglLP(i),'Enable'),'off')
        set(handles.hTglLP(i),'Value',0);
        handles = LPCallback(handles.hTglLP(i),1,handles);
    end
end
guidata(hObject,handles);

function hSelectAllThr_Callback(hObject, eventdata, handles)

for i = 1:handles.nActiveChannels
    if ~strcmp(get(handles.hTglThr(i),'Enable'),'off');
        set(handles.hTglThr(i),'Value',1);
        handles = ThreshCallback(handles.hTglThr(i),eventdata,handles);
    end
end
guidata(hObject,handles);

function hDeselectThr_Callback(hObject, eventdata, handles)

for i = 1:handles.nActiveChannels
    if ~strcmp(get(handles.hTglThr(i),'Enable'),'off');
        set(handles.hTglThr(i),'Value',0);
        handles = ThreshCallback(handles.hTglThr(i),eventdata,handles);
    end
end
guidata(hObject,handles);

% --- Toggle buttons --- %
function TglPlot1_Callback(hObject, eventdata, handles)
handles = TogglePlotCallback(hObject,handles);
guidata(hObject,handles);
function TglPlot2_Callback(hObject, eventdata, handles)
handles = TogglePlotCallback(hObject,handles);
guidata(hObject,handles);
function TglPlot3_Callback(hObject, eventdata, handles)
handles = TogglePlotCallback(hObject,handles);
guidata(hObject,handles);
function TglPlot4_Callback(hObject, eventdata, handles)
handles = TogglePlotCallback(hObject,handles);
guidata(hObject,handles);
function TglPlot5_Callback(hObject, eventdata, handles)
handles = TogglePlotCallback(hObject,handles);
guidata(hObject,handles);
function TglPlot6_Callback(hObject, eventdata, handles)
handles = TogglePlotCallback(hObject,handles);
guidata(hObject,handles);
function TglPlot7_Callback(hObject, eventdata, handles)
handles = TogglePlotCallback(hObject,handles);
guidata(hObject,handles);
function TglPlot8_Callback(hObject, eventdata, handles)
handles = TogglePlotCallback(hObject,handles);
guidata(hObject,handles);
function TglPlot9_Callback(hObject, eventdata, handles)
handles = TogglePlotCallback(hObject,handles);
guidata(hObject,handles);
function TglPlot10_Callback(hObject, eventdata, handles)
handles = TogglePlotCallback(hObject,handles);
guidata(hObject,handles);
function TglPlot11_Callback(hObject, eventdata, handles)
handles = TogglePlotCallback(hObject,handles);
guidata(hObject,handles);
function TglPlot12_Callback(hObject, eventdata, handles)
handles = TogglePlotCallback(hObject,handles);
guidata(hObject,handles);
function TglPlot13_Callback(hObject, eventdata, handles)
handles = TogglePlotCallback(hObject,handles);
guidata(hObject,handles);
function TglPlot14_Callback(hObject, eventdata, handles)
handles = TogglePlotCallback(hObject,handles);
guidata(hObject,handles);
function TglPlot15_Callback(hObject, eventdata, handles)
handles = TogglePlotCallback(hObject,handles);
guidata(hObject,handles);
function TglPlot16_Callback(hObject, eventdata, handles)
handles = TogglePlotCallback(hObject,handles);
guidata(hObject,handles);
function TglPlot17_Callback(hObject, eventdata, handles)
handles = TogglePlotCallback(hObject,handles);
guidata(hObject,handles);
function TglPlot18_Callback(hObject, eventdata, handles)
handles = TogglePlotCallback(hObject,handles);
guidata(hObject,handles);
function TglPlot19_Callback(hObject, eventdata, handles)
handles = TogglePlotCallback(hObject,handles);
guidata(hObject,handles);
function TglPlot20_Callback(hObject, eventdata, handles)
handles = TogglePlotCallback(hObject,handles);
guidata(hObject,handles);
function TglPlot25_Callback(hObject, eventdata, handles)
handles = TogglePlotCallback(hObject,handles);
guidata(hObject,handles);
function TglPlot26_Callback(hObject, eventdata, handles)
handles = TogglePlotCallback(hObject,handles);
guidata(hObject,handles);
function TglPlot27_Callback(hObject, eventdata, handles)
handles = TogglePlotCallback(hObject,handles);
guidata(hObject,handles);
function TglPlot28_Callback(hObject, eventdata, handles)
handles = TogglePlotCallback(hObject,handles);
guidata(hObject,handles);
function LPedit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function Table1Header_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function HPedit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function Table2Header_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function ProbePopUp_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function uipanel1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uipanel1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in TglPlot29.
function TglPlot29_Callback(hObject, eventdata, handles)
% hObject    handle to TglPlot29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of TglPlot29


% --- Executes on button press in TglPlot30.
function TglPlot30_Callback(hObject, eventdata, handles)
% hObject    handle to TglPlot30 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of TglPlot30


% --- Executes on button press in TglPlot31.
function TglPlot31_Callback(hObject, eventdata, handles)
% hObject    handle to TglPlot31 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of TglPlot31


% --- Executes on button press in TglPlot32.
function TglPlot32_Callback(hObject, eventdata, handles)
% hObject    handle to TglPlot32 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of TglPlot32
