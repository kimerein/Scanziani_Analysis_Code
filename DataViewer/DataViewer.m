function varargout = DataViewer(varargin)
%
%
%
%   Created: 1/10 - SRO
%   Modified: 4/15/10 - SRO
%   Modified: 5/31/10 - BA 


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @DataViewer_OpeningFcn, ...
    'gui_OutputFcn',  @DataViewer_OutputFcn, ...
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


% --- Executes just before DataViewer is made visible.
function DataViewer_OpeningFcn(hObject, eventdata, handles, varargin)

rigdef = RigDefs;

%%% Code specific to DaqController version of DataViewer %%%

% Get handle to DaqController GUI
handles.hDaqCtlr = varargin{3};

% DataViewer GUI handle is passed to DaqController via the output function
handles.output = hObject;

% Assign DataViewer handle in base workspace
assignin('base','hDaqDataViewer',hObject);

% Hide analysis buttons if not flagged in RigDefs
if ~rigdef.DataViewer.AnalysisButtons
    set([handles.psthButton, handles.FRButton, handles.LFPButton],...
        'Enable','off','Visible','off');
end

% Get channel information from AIOBJ
global AIOBJ
handles.Channel = get(AIOBJ,'Channel');
handles.nActiveChannels = length(handles.Channel);
handles.ChannelName = handles.Channel.ChannelName;
handles.SampleRate = AIOBJ.SampleRate;
DaqCtlrData = guidata(handles.hDaqCtlr);
handles.SweepDuration = DaqCtlrData.aiparams.sweeplength;
handles.board = DaqCtlrData.board;
clear DaqCtlrData

% Store handles for text boxes displaying trigger number
setappdata(hObject,'hTriggerNum',handles.TriggerNumText);
hTriggerNum = getappdata(hObject,'hTriggerNum');
TriggerNum = AIOBJ.TriggersExecuted;
set(hTriggerNum,'String',TriggerNum);

% Set flag for Daq DataViewer
dvMode = 'Daq';

%%% End code specific to DaqController version of DataViewer %%%

handles = DataViewerHelper(handles,dvMode);

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = DataViewer_OutputFcn(hObject, eventdata, handles)

varargout{1} = handles.output;

% Position GUI
RigDef = RigDefs;
set(hObject,'Position', RigDef.DataViewer.Position ,'Units','Pixels','Visible','on');
pause(0.25)


% --- Toolbar buttons --- %

function xConstrainedZoom_ClickedCallback(hObject, eventdata, handles)

state = get(hObject,'State');
switch state
    case 'on'
        zoom xon
        set(handles.yConstrainedZoom,'State','off');
    case 'off'
        zoom off
end

function yConstrainedZoom_ClickedCallback(hObject, eventdata, handles)

state = get(hObject,'State');
switch state
    case 'on'
        zoom yon
        set(handles.xConstrainedZoom,'State','off');
    case 'off'
        zoom off
end

function DefaultZoom_OffCallback(hObject, eventdata, handles)
set(handles.xConstrainedZoom,'State','off');
set(handles.yConstrainedZoom,'State','off');

function xAutoScale_ClickedCallback(hObject, eventdata, handles)
xAutoScaleDV(handles)

function yAutoScale_ClickedCallback(hObject, eventdata, handles)
yAutoScaleDV(handles)

function togglePeakfinder_ClickedCallback(hObject, eventdata, handles, state)
setappdata(handles.hDataViewer,'usePeakfinder', state);

function toggleYAxes_Callback(hObject, eventdata, handles, state)
% state argument is 1 if on, 0 if off. 
states = {'Off', 'On'};
if getappdata(handles.hDataViewer, 'showAllYAxes') ~= state
    setappdata(handles.hDataViewer, 'showAllYAxes', state);
    UpdateDataViewer(handles);    
end

% --------------------------------------------------------------------

% --- Executes on key press with focus on hDataViewer and none of its controls.
function hDataViewer_KeyPressFcn(hObject, eventdata, handles)

Key = eventdata.Key;
switch Key  
    case 'y'
        yAutoScale(handles);
    case 't'
        xAutoScale(handles);
end






% --- Executes on button press in psthButton.
function psthButton_Callback(hObject, eventdata, handles)

if get(hObject,'Value')
    handles.psth = onlinePSTH(handles);
    setappdata(handles.hDataViewer,'psthON',1)
    guidata(hObject,handles)
elseif ~get(hObject,'Value')
    setappdata(handles.hDataViewer,'psthON',0)
end
    
function FRButton_Callback(hObject, eventdata, handles)

if get(hObject,'Value')
    handles.fr = onlineFR(handles);
    setappdata(handles.hDataViewer,'frON',1)
    guidata(hObject,handles)
elseif ~get(hObject,'Value')
    setappdata(handles.hDataViewer,'frON',0)
end


% --- Executes on button press in LFPButton.
function LFPButton_Callback(hObject, eventdata, handles)

if get(hObject,'Value')
    handles.lfp = onlineLFP(handles);
    setappdata(handles.hDataViewer,'lfpON',1)
    guidata(hObject,handles)
elseif ~get(hObject,'Value')
    setappdata(handles.hDataViewer,'lfpON',0)
end

function SRFbutton_Callback(hObject, eventdata, handles)

if get(hObject,'Value')
    handles.srf = onlineSRF(handles);
    setappdata(handles.hDataViewer,'srfON',1)
    guidata(hObject,handles)
elseif ~get(hObject,'Value')
    setappdata(handles.hDataViewer,'srfON',0)
end


% --- Executes during object creation, after setting all properties.
function axes24_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes24


% --- Executes during object creation, after setting all properties.
function hDataViewer_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hDataViewer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --------------------------------------------------------------------
function allYAxesSame_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to allYAxesSame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
yScaleAllTogether(handles);


% --------------------------------------------------------------------
function yAxesCongruent_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to yAxesCongruent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
yAxesMakeSameSize(handles);