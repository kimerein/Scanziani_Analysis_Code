function varargout = ExptPlotChooser(varargin)
%
%
%
%   Created: 1/10 - SRO
%   Modified: 4/5/10 - SRO

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @ExptPlotChooser_OpeningFcn, ...
    'gui_OutputFcn',  @ExptPlotChooser_OutputFcn, ...
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

function ExptPlotChooser_OpeningFcn(hObject, eventdata, handles, varargin)

% PlotChooser GUI handle is passed to DataViewer
handles.output = hObject;

% Set PlotChooser handle as appdata
setappdata(hObject,'hPlotChooser',hObject);

% Get ExptDataViewer handles
handles.hDataViewer = varargin{3};
dvHandles = guidata(handles.hDataViewer);

% Get channel information from daq file to be opened
handles.nActiveChannels = dvHandles.nActiveChannels;
handles.hAllAxes = dvHandles.hAllAxes;
handles.ChannelInfo = dvHandles.daqinfo.ObjInfo.Channel;
handles.ChannelInfo = [{handles.ChannelInfo.Index}', {handles.ChannelInfo.ChannelName}', ...
    {handles.ChannelInfo.HwChannel}'];
disp('Here are the channel mappings: Index, ChName in Viewer, HW channel');
disp(handles.ChannelInfo);

% Set up GUI
handles = PlotChooserHelper(handles);

% Set channel order based on probe configuration
temp = guidata(handles.hDataViewer);
expt = temp.expt; clear temp
configuration = expt.probe.configuration;
configList = get(handles.ProbePopUp,'String');
% Find match and set probe pop-up
for i = 1:length(configList)
    temp = findstr(configList{i},configuration);
    if ~isempty(temp)
        set(handles.ProbePopUp,'Value',i)
    end
end

% Use this callback to set channel order as appdata in ExptDataViewer
ProbePopUp_Callback(handles.ProbePopUp, [], handles);

% Update handles structure
guidata(hObject, handles);

function varargout = ExptPlotChooser_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;
RigDef = RigDefs;
set(hObject,'Units','pixels','Position',[RigDef.PlotChooser.Position 480 530])
set(hObject,'Visible','on'); pause(0.25)

function ProbePopUp_Callback(hObject, eventdata, handles)
% Hints: contents = get(hObject,'String') returns ProbePopUp contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ProbePopUp

RigDef=RigDefs();
contents = get(hObject,'String');
string = contents{get(hObject,'Value')};
% Fixed by Kim to query RigDefs rather than having this hard-coded in the
% function
probeIndex=find(strcmp(string,RigDef.Probe.UserProbes));
ChannelOrder=RigDef.ChannelOrder{probeIndex};
% switch string
%     case '[1:16] Channel in order'
%         ChannelOrder = [1:16];       
%     case '16 Channel 1x16'
%         ChannelOrder = RigDef.ChannelOrder{probeIndex};       
%     case '16 Channel 2x2'
%         ChannelOrder = RigDef.ChannelOrder{probeIndex}; 
%     case '16 Channel 4x1'
%         ChannelOrder = RigDef.ChannelOrder{probeIndex}; 
%     case 'Glass electrode'
%         ChannelOrder = RigDef.ChannelOrder{probeIndex}; 
%     case 'Other'
%         ChannelOrder = inputdlg('Enter channel order');
%         ChannelOrder = str2mat(ChannelOrder);
% end

ChannelOrder = ChannelOrder';
setappdata(handles.hDataViewer,'ChannelOrder',ChannelOrder);
setappdata(handles.hDataViewer,'Probe',string);
dvHandles = guidata(handles.hDataViewer);
if isfield(handles.hDataViewer ,'hPlotLines')
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

function DoneButton_Callback(hObject, eventdata, handles)
delete(handles.hPlotChooser);

function bwFiltToggle_Callback(hObject, eventdata, handles)
status = get(hObject,'Value');
if status == 1
    set(hObject,'BackgroundColor',[0.2 0.2 1]);
elseif status == 0
    set(hObject,'BackgroundColor',[0.8 0.8 0.8]);
end


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
function TglPlot21_Callback(hObject, eventdata, handles)
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
function HPedit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function ProbePopUp_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function Table2Header_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function LPedit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Table1Header_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in TglPlot29.
function TglPlot29_Callback(hObject, eventdata, handles)
% hObject    handle to TglPlot29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of TglPlot29


% --- Executes on button press in TglPlot18.
function togglebutton41_Callback(hObject, eventdata, handles)
% hObject    handle to TglPlot18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of TglPlot18


% --- Executes on button press in TglPlot27.
function togglebutton42_Callback(hObject, eventdata, handles)
% hObject    handle to TglPlot27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of TglPlot27


% --- Executes on button press in TglPlot28.
function togglebutton43_Callback(hObject, eventdata, handles)
% hObject    handle to TglPlot28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of TglPlot28


% --- Executes on button press in TglPlot29.
function togglebutton44_Callback(hObject, eventdata, handles)
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


% --- Executes on button press in TglPlot26.
function togglebutton49_Callback(hObject, eventdata, handles)
% hObject    handle to TglPlot26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of TglPlot26
