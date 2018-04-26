function varargout = DaqController(varargin)
%
%
%   Created: 1/10 - SRO
%   Modified: 5/10/10 - SRO


% Begin initialization code - DO NOT EDIT
% This code is generated via the GUIDE program used to generate this GUI
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @DaqController_OpeningFcn, ...
    'gui_OutputFcn',  @DaqController_OutputFcn, ...
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


% --- Executes just before DaqController is made visible.
function DaqController_OpeningFcn(hObject, eventdata, handles, varargin)

% Set DaqController handle as appdata
setappdata(hObject,'hDaqCtlr',hObject);

% DaqController handle is output
handles.output = hObject;

% Assign DaqController handle in base workspace
assignin('base','hDaqController',hObject);

% Rig specific defaults
RigDef = RigDefs;
handles.RigDef = RigDef;

% Determine which board is being used, and how many ai channels
handles.board.ID = RigDef.equipment.board.ID;
handles.board.numAnalogInputCh = RigDef.equipment.board.numAnalogInputCh;

% Determine whether board allows TriggerType, 'HwAnalogChannel'; if not, use
% 'Software' trigger
aiTemp = analoginput('nidaq',RigDef.equipment.board.device);
temp = propinfo(aiTemp,'TriggerType');
temp = strcmp(temp.ConstraintValue,'HwAnalogChannel');
if any(temp)
    handles.board.TriggerType = 'HwAnalogChannel';
else
    handles.board.TriggerType = 'Software';
end
delete(aiTemp); clear aiTemp; 

% Enable/disable Analog GUI button
if RigDef.led.Enable == 0
    set(handles.hAnalogSetupButton,'Enable','off')
end

% Create digital input object for receiving coded stimulus conditions from stimulus PC
createdi()

% Create UDP object for sending and receiving stimulus file name
global UDP_OBJ_STIM_PC
RHOST = handles.RigDef.StimPC_IP;
UDP_OBJ_STIM_PC = udp(RHOST, 9094,'LocalPort', 9093,'Timeout',0.9);     % Address of stimulus PC

% Set analog input default parameters
handles.aiparams.pathname = RigDef.Dir.Data;
handles.aiparams.savefile_header = [RigDef.SaveNamePrefix datestr(now,29) '_1'];
handles.aiparams.sampleRate = RigDef.Daq.SampleRate;
handles.aiparams.LogFileName = [handles.aiparams.pathname handles.aiparams.savefile_header];
handles.aiparams.sweeplength = RigDef.Daq.SweepLength;
handles.aiparams.TriggerRepeat = RigDef.Daq.TriggerRepeat ;
handles.aiparams.SamplesAcquiredFcnCount = handles.aiparams.sweeplength*handles.aiparams.sampleRate;
handles.aiparams.LogToDiskMode = 'index';
handles.aiparams.LoggingMode = 'Memory';
handles.aiparams.TriggerType = 'External';
handles.aiparams.TriggerFcn = RigDef.Daq.TriggerFcn;
handles.aiparams.TimerFcn =  RigDef.Daq.TimerFcn;
handles.aiparams.SamplesAcquiredFcn = RigDef.Daq.SamplesAcquiredFcn;
handles.aiparams.StopFcn = RigDef.Daq.StopFcn;

% Initialize GUI fields to contain correct values
set(handles.ed1_TimePerTrig,'String',num2str(handles.aiparams.sweeplength));
set(handles.ed2_NTrig,'String',num2str(handles.aiparams.TriggerRepeat));
set(handles.ed4_savefilename,'String',handles.aiparams.LogFileName);
set(handles.popupmenu1_TrigType,'Value',2);         % 1 = Immdediate, 2 = Hardware
set(handles.chbx1_savedata,'Value',0);
set(handles.exptTag,'String','');

% Initialize the global analog input object, AIOBJ
handles = createai(handles);

% Execute if using DataViewer GUI. Can be modified to use different online
% plotting method and/or callback.
if strcmp(RigDef.Daq.OnlinePlotting,'DataViewer');
    % Update guidata so DataViewer has access to updated info
    guidata(hObject,handles);
    % Create the DataViewer GUI
    handles.hDataViewer = DataViewer('Visible','off',handles.hDaqController);
    % Set the trigger function
    handles.aiparams.TriggerFcn = {@DataViewerCallback,handles.hDataViewer};    % DataViewerCallback needs handle to DataViewer
    handles.aiparams.SamplesAcquiredFcn = {@DataViewerSamplAcqCallback,handles.hDataViewer};    % DataViewerCallback needs handle to DataViewer
end

handles = updateAIOBJ(handles);

% Set SaveName callback function
handles.SaveNameFcn = @ed4_savefilename_Callback;

% Set ExptName as appdata for use by other GUIs
[ExptPath ExptName] = fileparts(handles.aiparams.LogFileName);
setappdata(handles.hDaqController,'ExptName',ExptName);

% Use ExptTableNew to generate new experiment
guidata(hObject,handles);
handles.hExptTable = ExptTableNew(handles.hDaqController);

% Add flag to Analog Setup button
setappdata(handles.hAnalogSetupButton,'bLED',0)

% Update the handles structure
guidata(hObject,handles);


% --- Outputs from this function are returned to the command line.
function varargout = DaqController_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;
RigDef = RigDefs;
set(hObject,'Units','Pixels','Position',[RigDef.Daq.Position 439 172],'Visible','on');
pause(0.25)

function createdi()
% The Conditition line is used to receive the coded stimulus condition from
% the stimulus computer. The bitLine is not currently used, but could be
% used to trigger data acquistion (hwline = addline(DIOBJ,0:1,2,'in',
% 'bitLine'). Triggering is currently accomplished via an analog input
% channel on the NIDAQ board.
global DIOBJ;
RigDef = RigDefs;
DIOBJ = digitalio('nidaq',RigDef.equipment.board.device);
addline(DIOBJ,0:7,'in','Condition');

function handles = createai(handles)
global AIOBJ

AIOBJ = analoginput('nidaq',handles.RigDef.equipment.board.device);
AIOBJ.InputType = 'SingleEnded';    % NonReferencedSingleEnded, pseudodifferential, or SingleEnded
DefineAIChannels(handles.RigDef.Daq.Parameters);
handles.aiparams.nChn = length(AIOBJ.Channel);
Fs = handles.aiparams.sampleRate;
str = strcat('Set to acquire',{' '}, num2str(handles.aiparams.nChn),' channels at',{' '},num2str(Fs/1000),' kHz');
set(handles.aiStatusText,'String',str)

function handles = updateAIOBJ(handles)

handles.aiparams.sweeplength = str2num(get(handles.ed1_TimePerTrig,'String'));
handles.aiparams.TriggerRepeat = str2num(get(handles.ed2_NTrig,'String'));
handles.aiparams.LogFileName = get(handles.ed4_savefilename,'String');
if get(handles.chbx1_savedata,'Value') == 1;
    handles.aiparams.LoggingMode = 'Disk&Memory';
else
    handles.aiparams.LoggingMode = 'Memory';
end
if get(handles.checkbox2_AutoRestart,'Value') == 1;
    handles.aiparams.StopFcn = {@start};
else
    handles.aiparams.StopFcn = {@toggleStartDAQ,0,handles};
end

handles = TrigTypeHelper(get(handles.popupmenu1_TrigType,'Value'),handles);
handles = changeai(handles);

function handles = changeai(handles)
% Changes AIOBJ based on parameters in handles.aiparams.
global AIOBJ

if strcmp(AIOBJ.Running,'Off') % only change these when not running
    AIOBJ.LogToDiskMode = handles.aiparams.LogToDiskMode;
    AIOBJ.LoggingMode = handles.aiparams.LoggingMode;
    AIOBJ.TriggerType = handles.aiparams.TriggerType;
    AIOBJ.LogFileName = handles.aiparams.LogFileName;
    AIOBJ.SamplesPerTrigger = handles.aiparams.sweeplength*handles.aiparams.sampleRate;
    AIOBJ.TriggerRepeat = max(handles.aiparams.TriggerRepeat-1,0);
    handles.aiparams.Ts = setverify(AIOBJ,'SampleRate',handles.aiparams.sampleRate);
    if strcmp(AIOBJ.TriggerType,'Software') && strcmp(handles.board.TriggerType,'Software')
        trigCh = AIOBJ.Channel(1);
        set(AIOBJ,'TriggerChannel',trigCh)
        set(AIOBJ,'TriggerCondition','Rising')
    end
    set(AIOBJ,'TriggerConditionValue',2)
end

set(AIOBJ,'StopFcn',handles.aiparams.StopFcn)
AIOBJ.TimerFcn = handles.aiparams.TimerFcn;
AIOBJ.TriggerFcn = handles.aiparams.TriggerFcn;
AIOBJ.SamplesAcquiredFcn= handles.aiparams.SamplesAcquiredFcn;
handles.aiparams.SamplesAcquiredFcnCount = AIOBJ.SamplesPerTrigger;
if handles.aiparams.SamplesAcquiredFcnCount == inf;
    handles.aiparams.SamplesAcquiredFcnCount = handles.aiparams.sampleRate;
end % because can't be inf
AIOBJ.SamplesAcquiredFcnCount = handles.aiparams.SamplesAcquiredFcnCount;

function StartDAQ_Callback(hObject, eventdata, handles)
handles = toggleStartDAQ([],[],get(hObject,'Value'),handles);
guidata(hObject,handles);

function handles = toggleStartDAQ(aiobj,event,status,handles)
global AIOBJ
global UDP_OBJ_STIM_PC;
if status == 1 % Start data acquisition and disable other GUI elements
    set(handles.StartDAQ,'String','Stop DAQ');
    set(handles.StartDAQ,'Value',1);
    set(handles.StartDAQ,'BackgroundColor',[1 0 0]);
    set(handles.ed1_TimePerTrig,'Enable','Off');
    set(handles.ed2_NTrig,'Enable','Off');
    set(handles.ed4_savefilename,'Enable','Off');
    set(handles.chbx1_savedata,'Enable','Off');
    set(handles.ButtonDaqSetup,'Enable','Off');
    % per Bass' request we can now open analog setup when daq is ongoing (WB)
    %set(handles.hAnalogSetupButton,'Enable','Off');
    set(handles.exptTag,'Enable','Off');
    if strcmp(AIOBJ.LoggingMode,'Disk&Memory');
        AIOBJ.LogFileName = checkIfFileExists(AIOBJ.LogFileName);
        set(handles.ed4_savefilename,'String',AIOBJ.LogFileName);
        handles.aiparams.LogFileName = AIOBJ.LogFileName;
    end
    set(handles.popupmenu1_TrigType,'Enable','Off');
    % KR - Added check to see whether fopen succeeds or fails 6/30/10
    % The implicit assumption here is that if fopen doesn't work, UDP
    % object already open
    try 
        fopen(UDP_OBJ_STIM_PC);     
    catch me
        disp(me.message);
    end
    % KR 7/9/10 - Wait for AO object to be ready
    while strcmp(get(AIOBJ,'Running'),'On')
        pause(0.005);
    end
    start(AIOBJ);
elseif status == 0
    if get(handles.checkbox2_AutoRestart,'Value') == 1;
        set(handles.checkbox2_AutoRestart,'Value',0);
        handles.aiparams.StopFcn={@toggleStartDAQ,0,handles};
        set(AIOBJ,'StopFcn',handles.aiparams.StopFcn)
    end
    if get(handles.checkbox4_HardStop,'Value') == 1;
        stop(AIOBJ);
    else
        while strcmp(AIOBJ.Running,'On')
            pause(0.05);
        end
        stop(AIOBJ);
    end
    fclose(UDP_OBJ_STIM_PC);
    if strcmp(AIOBJ.LoggingMode,'Disk&Memory'); % update filename
        AIOBJ.LogFileName = checkIfFileExists(AIOBJ.LogFileName);
        set(handles.ed4_savefilename,'String',AIOBJ.LogFileName);
        handles.aiparams.LogFileName = AIOBJ.LogFileName;
    end
    set(handles.StartDAQ,'String','Start DAQ');
    set(handles.StartDAQ,'Value',0);
    set(handles.StartDAQ,'BackgroundColor',[0 0.498 0]);
    set(handles.ed1_TimePerTrig,'Enable','On');
    set(handles.ed2_NTrig,'Enable','On');
    set(handles.ed4_savefilename,'Enable','On');
    set(handles.chbx1_savedata,'Enable','On');
    set(handles.popupmenu1_TrigType,'Enable','On');
    set(handles.ButtonDaqSetup,'Enable','On');
    set(handles.hAnalogSetupButton,'Enable','On');
    set(handles.exptTag,'Enable','On');
    handles = updateAIOBJ(handles);
end

function ed1_TimePerTrig_Callback(hObject, eventdata, handles)
handles.aiparams.sweeplength = str2double(get(hObject,'String'));
handles = changeai(handles);
hDV = guidata(handles.hDataViewer);
set(hDV.hAllAxes,'XLim',[0 handles.aiparams.sweeplength]);
guidata(hObject,handles);

function ed2_NTrig_Callback(hObject, eventdata, handles)
handles.aiparams.TriggerRepeat = str2double(get(hObject,'String'));
handles = changeai(handles);
guidata(hObject,handles);

function ed4_savefilename_Callback(hObject, eventdata, handles)
handles.aiparams.LogFileName = get(hObject,'String');
handles = changeai(handles);
[ExptPath ExptName] = fileparts(handles.aiparams.LogFileName);
setappdata(handles.hDaqController,'ExptName',ExptName);
guidata(hObject,handles);

function chbx1_savedata_Callback(hObject, eventdata, handles)
global AIOBJ

if get(hObject,'Value');
    handles.aiparams.LoggingMode = 'Disk&Memory';
    set(handles.ed4_savefilename,'Enable','On');
    set(handles.ed4_savefilename,'String',AIOBJ.LogFileName);
else   handles.aiparams.LoggingMode = 'Memory';
    set(handles.ed4_savefilename,'Enable','Off');
end
handles = changeai(handles);
guidata(hObject,handles);

function popupmenu1_TrigType_Callback(hObject, eventdata, handles)
handles = TrigTypeHelper(get(hObject,'Value'),handles);
handles = changeai(handles);
guidata(hObject,handles);

function fname = checkIfFileExists(fname)
while ~isempty(dir(fname)) % augment filename by 1 until a file of the same name doesn't exist
    tmp = findstr(fname,'_'); tmp2 = findstr(fname,'.');
    if isempty(tmp2); stmp2 = ''; else stmp2 = fname(tmp2:end); end
    if isempty(tmp)       fname = [fname(1:tmp2-1) '_1' stmp2];
    elseif tmp+1==tmp2;  fname = [fname(1:tmp2-2) '_1' stmp2];
    else    fname = [fname(1:tmp(end)) num2str(str2num(fname(tmp(end)+1:tmp2-1))+1) stmp2]; end
end

function handles = TrigTypeHelper(value,handles)
switch(value)
    case 1
        handles.aiparams.TriggerType = 'Immediate';
    otherwise
        handles.aiparams.TriggerType = handles.board.TriggerType;
end
guidata(handles.output,handles);

function checkbox2_AutoRestart_Callback(hObject, eventdata, handles)
handles = updateAIOBJ(handles);
guidata(hObject,handles);

function AI_Channel_Setup_Callback(hObject, eventdata, handles)
DaqControllerHandles = handles;
DaqSetup(DaqControllerHandles);

function checkbox4_HardStop_Callback(hObject, eventdata, handles)


function ButtonDaqSetup_Callback(hObject, eventdata, handles)

DaqSetup('Visible','off',handles.hDaqController);

function hAnalogSetupButton_Callback(hObject, eventdata, handles)

aoGUI('Visible','off',handles.hDataViewer,handles.hDaqController);

function exptTag_Callback(hObject, eventdata, handles)
RigDef = RigDefs;
tag = get(hObject,'String');
exptName = [RigDef.SaveNamePrefix '_' datestr(now,29) '_' tag];
set(handles.ed4_savefilename,'String',...
    [handles.aiparams.pathname exptName '_1']);
ed4_savefilename_Callback(handles.ed4_savefilename,eventdata,handles)

% Set experiment name in ExptTable
h = handles.hExptTable;
ExptTable = get(h.table,'Data');
% Determine row, then set name
iRow = strcmp(ExptTable(:,1),'Experiment name');
if any(iRow)
    ExptTable{iRow,2} = exptName;
    set(h.table,'Data',ExptTable)
    set(h.save,'Enable','on','FontWeight','bold','ForegroundColor',[1 0 0]);
end


% --- Create functions --- %
function hDaqController_CreateFcn(hObject, eventdata, handles)
function chbx1_savedata_CreateFcn(hObject, eventdata, handles)
function ed1_TimePerTrig_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function ed2_NTrig_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popupmenu1_TrigType_CreateFcn(hObject, eventdata, handles)
function ed4_savefilename_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function exptTag_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- End create functions --- %


function hDaqController_DeleteFcn(hObject, eventdata, handles)
% global AIOBJ DIOBJ

% if isvalid(AIOBJ)
%     delete(AIOBJ);
%     clear AIOBJ
% end
% if isvalid(DIOBJ)
%     delete(DIOBJ);
%     clear DIOBJ
% end
closedaq

function hDaqController_CloseRequestFcn(hObject, eventdata, handles)
% global AIOBJ;
% try % In case not defined
%     stop(AIOBJ); delete(AIOBJ); clear AIOBJ;
%     stop(DIOBJ); delete(DIOBJ); clear DIOBJ;
% catch
% end
% delete(hObject);
closedaq
