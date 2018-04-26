function varargout = DaqSetup(varargin)
%
%
%
%   Created: 1/10 - SRO
%   Modified: 4/3/10 - SRO

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DaqSetup_OpeningFcn, ...
                   'gui_OutputFcn',  @DaqSetup_OutputFcn, ...
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


function DaqSetup_OpeningFcn(hObject, eventdata, handles, varargin)

% Get the handles struct from DaqController
handles.hDaqCtlr = varargin{3};
handles.DaqCtlrHandles = guidata(handles.hDaqCtlr);

% Initialize GUI fields to contain correct values
set(handles.edit1,'String',handles.DaqCtlrHandles.aiparams.sampleRate);
set(handles.uitable1,'Data',handles.DaqCtlrHandles.RigDef.Daq.Parameters);
set(handles.edit2,'String',1000);       % Amplifier gain
set(handles.UpdateAIOBJButton,'Enable','Off');

% Update handles structure
guidata(hObject, handles);

function varargout = DaqSetup_OutputFcn(hObject, eventdata, handles) 
% Set position of GUI
set(hObject,'Units','pixels','Position',[542 498 665 465],'Visible','on');

function uitable1_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to uitable1 (see GCBO) eventdata  structure with the
% following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited PreviousData:
%	previous data for the cell(s) edited EditData: string(s) entered by the
%	user NewData: EditData or its converted form set on the Data property.
%	Empty if Data was not changed Error: error string when failed to
%	convert EditData to appropriate value for Data

% Turn on button
set(handles.UpdateAIOBJButton,'Enable','On');
% Get updated daq parameters from table
handles.DaqCtlrHandles.RigDef.Daq.Parameters = get(handles.uitable1,'Data');
% Update GUI data for both DaqController and DaqSetup
guidata(handles.DaqCtlrHandles.hDaqController,handles.DaqCtlrHandles);
guidata(hObject,handles);


function edit1_CreateFcn(hObject, eventdata, handles, DaqCtlrHandles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function UpdateAIOBJButton_Callback(hObject, eventdata, handles)

% Declare analog input object
global AIOBJ

% If AIOBJ has channels, delete them
if length(AIOBJ.Channel) > 0
    delete(AIOBJ.Channel(:));
end

% Add channels to AIOBJ using values in parameters
DefineAIChannels(handles.DaqCtlrHandles.RigDef.Daq.Parameters);

% Get data aquisition parameters
nChns = length(AIOBJ.Channel);
Fs = handles.DaqCtlrHandles.aiparams.sampleRate;
% Set summary string in DaqController
str = strcat('Set to acquire',{' '}, num2str(nChns),' channels at',{' '},num2str(Fs/1000),' kHz');
set(handles.DaqCtlrHandles.aiStatusText,'String',str)
% Delete old DataViewer and PlotChooser, then open new ones corresponding
% to updated AIOBJ
temp = guidata(handles.DaqCtlrHandles.hDataViewer);
hPlotChooser = temp.hPlotChooser;
hDataViewer = handles.DaqCtlrHandles.hDataViewer;
delete(hPlotChooser);
delete(hDataViewer);
% Execute if using DataViewer GUI
if strcmp(handles.DaqCtlrHandles.RigDef.Daq.OnlinePlotting,'DataViewer');
    % Open Dataviewer
    handles.DaqCtlrHandles.hDataViewer = DataViewer('Visible','off',handles.DaqCtlrHandles.hDaqController); 
    % Set trigger callback function 
    handles.DaqCtlrHandles.aiparams.TriggerFcn = {@DataViewerCallback,handles.DaqCtlrHandles.hDataViewer};    % DataViewerCallback needs handle to DataViewer
    AIOBJ.TriggerFcn = handles.DaqCtlrHandles.aiparams.TriggerFcn;
end
set(handles.UpdateAIOBJButton,'Enable','Off');
% Update GUI data
guidata(hObject,handles);
guidata(handles.DaqCtlrHandles.hDaqController,handles.DaqCtlrHandles);

function edit2_Callback(hObject, eventdata, handles)

function edit2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% set(hObject,'Value',handles.DaqCtlrHandles.aiparams.AmpGain);
set(hObject,'Value',1000);

function uitable1_CreateFcn(hObject, eventdata, handles)

function SaveParamsButton_Callback(hObject, eventdata, handles)

DaqSettingsPath = [handles.DaqCtlrHandles.RigDef.Dir.Settings 'DaqSetup\'];
cd(DaqSettingsPath);
Parameters = get(handles.uitable1,'Data');
uisave('Parameters','*.mat');

function LoadParamsButton_Callback(hObject, eventdata, handles)

DaqSettingsPath = [handles.DaqCtlrHandles.RigDef.Dir.Settings 'DaqSetup\'];
cd(DaqSettingsPath);
ParameterFile = uigetfile('*.mat');
load(ParameterFile);
set(handles.uitable1,'Data',Parameters);

set(handles.UpdateAIOBJButton,'Enable','On');
handles.DaqCtlrHandles.RigDef.Daq.Parameters = get(handles.uitable1,'Data');
guidata(handles.DaqCtlrHandles.hDaqController,handles.DaqCtlrHandles);
guidata(hObject,handles);

function text4_CreateFcn(hObject, eventdata, handles)

daqinfo = daqhwinfo('nidaq');
set(hObject,'String', daqinfo.BoardNames);

function text6_CreateFcn(hObject, eventdata, handles)

function text8_CreateFcn(hObject, eventdata, handles)

daqinfo = daqhwinfo('nidaq');
set(hObject,'String', daqinfo.InstalledBoardIds);

function figure1_CreateFcn(hObject, eventdata, handles)

function pushbutton4_Callback(hObject, eventdata, handles)

DaqSettingsPath = [handles.DaqCtlrHandles.RigDef.Dir.Settings 'DaqSetup\'];
SaveName = fullfile(DaqSettingsPath,'DefaultDaqParameters');
Parameters = get(handles.uitable1,'Data');
save(SaveName, 'Parameters');


% --- Executes when selected cell(s) is changed in uitable1.
function uitable1_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to uitable1 (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
