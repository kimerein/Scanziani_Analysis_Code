function varargout = aoGUI(varargin)
%
%
%
%
%   Created: 2/10 - SRO
%   Modified: 7/28/10 - SRO

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @aoGUI_OpeningFcn, ...
    'gui_OutputFcn',  @aoGUI_OutputFcn, ...
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



function aoGUI_OpeningFcn(hObject, eventdata, handles, varargin)

global AIOBJ
global ao

RigDef = RigDefs;

figure(hObject); % needed so any axes drawn will be in the right figure

% Set handles for DataViewer and DaqController
handles.hDataViewer = varargin{3};
handles.hDaqController = varargin{4};

% Populate LED pull-down with LEDs in RigDefs
set(handles.ledID,'String',RigDef.led.ID,'Value',1);

% Set strings on LED toggles
set(handles.led1Tg,'String',RigDef.led.ID{1});
set(handles.led2Tg,'String',RigDef.led.ID{2});
set(handles.led3Tg,'String',RigDef.led.ID{3});


% Try to get ledObj from previous analog output object
try
    ledObj = get(ao,'UserData');
end

% % Delete analog output object if it exists
% try
%     delete(ao);
%     clear ao;
% end

% If ledObj exists, use its data to set defaults in GUI
noLedObj = 0;
try
    if isstruct(ledObj)
        handles.ledObj = ledObj;
        handles = setGuiValues(handles);
    else
        noLedObj = 1;
    end
catch
    noLedObj = 1;
end

% If ledObj doesn't exist, set default GUI values
if noLedObj
    set(handles.ledID,'Value',1);
    set(handles.TriggerPeriod,'String',2);
    set(handles.TimeOffset,'String',0);
    set(handles.NumPulses,'String',1);
    set(handles.Width,'String',1.5);
    set(handles.Amplitude,'String',5);
    set(handles.LEDOffset,'String',RigDef.led.Offset{1});
end

% Store analog output parameters in ledObj
for i = 1:length(RigDef.led.ID)
    handles.ledObj(i).OutputRange = 5;        % V
    handles.ledObj(i).LEDOffset = RigDef.led.Offset{i};
    handles.ledObj(i).SampleRate = AIOBJ.SampleRate;
    handles.ledObj(i).Duration = AIOBJ.SamplesPerTrigger/AIOBJ.SampleRate;
    handles.ledObj(i).NumSamples = AIOBJ.SampleRate*handles.ledObj(i).Duration;
    handles.ledObj(i).Output = 'on';
    handles.ledObj(i).Engaged = 'no';
    handles.ledObj(i).ID = RigDef.led.ID{i};
    handles.ledObj(i).HwChannel = RigDef.led.HwChannel{i};
    handles.ledObj(i).TriggerPeriod = 2;
    handles.ledObj(i).TimeOffset = 0;
    handles.ledObj(i).NumPulses = 1;
    handles.ledObj(i).Width = 1.5;
    handles.ledObj(i).Amplitude = 5;
    handles.ledObj(i).AmplitudeInd = 1;
    handles.ledObj(i).AmplitudeSeries = 0;
    handles.ledObj(i).WaveformType = 'square';
end

% Set min and max slider values
handles = updateSliders(handles);

% Set default slider positions
set(handles.AmplitudeSlider,'Value',handles.ledObj(1).Amplitude);
set(handles.OffsetSlider,'Value',0);

% Make waveform lines
for i = 1:length(RigDef.led.ID)
    handles.hLine(i) = line([0 1],[0 1],'Parent',handles.axes1,'Visible','off');
    set(handles.axes1,'YLim',[0 5.1],'XLim',[0 handles.ledObj(i).Duration]);
    switch i
        case 1
            set(handles.hLine(i),'Color',[0 0 0.85])
        case 2
            set(handles.hLine(i),'Color',[0.85 0 0])
        case 3
            set(handles.hLine(i),'Color',[0 0.85 0])
    end
end

% Engage first toggle
set(handles.led1Tg,'Value',1);
handles.ledObj(1).Engaged = 'yes';

% Display 
DisplayWaveform(handles);
defaultAxes(handles.axes1);

% Update handles structure
guidata(hObject, handles);

assignin('base','h',handles)

function varargout = aoGUI_OutputFcn(hObject, eventdata, handles)
set(hObject,'Units','Pixels','Visible','on'); pause(0.2)

function TriggerPeriod_Callback(hObject, eventdata, handles)
handles = GetGuiValues(handles);
DisplayWaveform(handles);

function TimeOffset_Callback(hObject, eventdata, handles)
handles = GetGuiValues(handles);
DisplayWaveform(handles)

function NumPulses_Callback(hObject, eventdata, handles)
handles = GetGuiValues(handles);
DisplayWaveform(handles)

function Amplitude_Callback(hObject, eventdata, handles)
handles = GetGuiValues(handles);
DisplayWaveform(handles)

function LEDOffset_Callback(hObject, eventdata, handles)
handles = GetGuiValues(handles);
DisplayWaveform(handles)

function MakeAOobject_Callback(hObject, eventdata, handles)
global AIOBJ
global ao

try
    stop(ao)
end

% Delete analog output object if it exists
try
    delete(ao);
end

ledObj = handles.ledObj;

% Make analog output object using parameters in ledObj
ledObj = MakeAnalogOut(ledObj);

% Store ledObj in analog output object
set(ao,'UserData',ledObj);

% Add updated ledObj to handles and update handles
handles.ledObj = ledObj;

% Add LED flag to DataViewer
setappdata(handles.hDataViewer,'bLED',1)
h = guidata(handles.hDaqController);
set(h.hAnalogSetupButton,'ForegroundColor',[0 0 0.85]);

guidata(hObject,handles)

function Width_Callback(hObject, eventdata, handles)
handles = GetGuiValues(handles);
DisplayWaveform(handles)

function CloseButton_Callback(hObject, eventdata, handles)
delete(handles.aoGUI)

function AmplitudeSlider_Callback(hObject, eventdata, handles)
% Set new value in edit box and display wave
set(handles.Amplitude,'String',num2str(get(hObject,'Value')));
handles = GetGuiValues(handles);
DisplayWaveform(handles)

function OffsetSlider_Callback(hObject, eventdata, handles)
% Set new value in edit box and display wave
set(handles.TimeOffset,'String',num2str(get(hObject,'Value')));
handles = GetGuiValues(handles);
DisplayWaveform(handles)

function ledID_Callback(hObject, eventdata, handles)
ledID = get(handles.ledID,'Value');
handles = setGuiValues(handles,ledID);
guidata(hObject,handles)



function Waveform_Callback(hObject, eventdata, handles)
handles = GetGuiValues(handles);
DisplayWaveform(handles)


% --- Subfunctions --- %

function DisplayWaveform(handles)

ledObj = handles.ledObj;
% Get indices of engaged LEDs
engagedLED = getEngagedLED(handles);
for i = 1:length(engagedLED)
    if engagedLED(i)
        waveform = MakeOutputWaveform(ledObj(i));
        dt = 1/ledObj(i).SampleRate;
        t = 0:dt:ledObj(i).Duration-dt;
        set(handles.hLine(i),'XData',t,'YData',waveform,'LineWidth',1.5);
        set(handles.hLine(i),'Visible','on')
    elseif ~engagedLED(i)
        set(handles.hLine(i),'Visible','off')
    end
end

% ylabel('Volts');
xlabel('seconds');
defaultAxes(handles.axes1);

function handles = GetGuiValues(handles)

i = get(handles.ledID,'Value');

handles.ledObj(i).TriggerPeriod = str2num(get(handles.TriggerPeriod,'String'));
handles.ledObj(i).TimeOffset = str2num(get(handles.TimeOffset,'String'));
handles.ledObj(i).NumPulses = str2num(get(handles.NumPulses,'String'));
handles.ledObj(i).Width = str2num(get(handles.Width,'String'));
handles.ledObj(i).Amplitude = str2num(get(handles.Amplitude,'String'));
handles.ledObj(i).LEDOffset = str2num(get(handles.LEDOffset,'String'));

% Don't allow amplitude to go below LED offset
if handles.ledObj(i).Amplitude < handles.ledObj(i).LEDOffset
    handles.ledObj(i).Amplitude = handles.ledObj(i).LEDOffset;
    set(handles.Amplitude,'String',num2str(handles.ledObj(i).Amplitude));
end

% LED ID
ledIDstrings = get(handles.ledID,'String');
value = get(handles.ledID,'Value');
handles.ledObj(i).ledID = ledIDstrings{value};
% Waveform
waveStrings = get(handles.Waveform,'String');
value = get(handles.Waveform,'Value');
handles.ledObj(i).WaveformType = waveStrings{value};
% Set sliders
set(handles.OffsetSlider,'Value',handles.ledObj(i).TimeOffset);
AmplitudeInd = handles.ledObj(i).AmplitudeInd;
Amplitude = handles.ledObj(i).Amplitude(AmplitudeInd);
set(handles.AmplitudeSlider,'Value',Amplitude);

guidata(handles.aoGUI,handles)

function handles = setGuiValues(handles,i)
% i is the index to a particular LED. Uses values in ledObj to set values
% in GUI.

if nargin < 2
    i = 1;
end

ledObj = handles.ledObj;

set(handles.TriggerPeriod,'String',num2str(ledObj(i).TriggerPeriod));
set(handles.TimeOffset,'String',num2str(ledObj(i).TimeOffset));
set(handles.NumPulses,'String',num2str(ledObj(i).NumPulses));
set(handles.Width,'String',num2str(ledObj(i).Width));
set(handles.LEDOffset,'String',num2str(ledObj(i).LEDOffset));
tempAmplitude = num2str(ledObj(i).Amplitude);
AmplitudeInd = ledObj(i).AmplitudeInd;
set(handles.Amplitude,'String',num2str(tempAmplitude(AmplitudeInd))) ;


function engagedLED = getEngagedLED(handles)

engagedLED(1) = get(handles.led1Tg,'Value');
engagedLED(2) = get(handles.led2Tg,'Value');
engagedLED(3) = get(handles.led3Tg,'Value');
engagedLED = logical(engagedLED);

function handles = ledTgCallback(hObject,handles)
value = get(hObject,'Value');
guidata(hObject,handles)

function handles = updateSliders(handles)
% Get slider range for active LED
LedOffset = str2double(get(handles.LEDOffset,'String'));
maxAmp = 5;
set(handles.AmplitudeSlider,'Min',LedOffset,'Max',maxAmp);

minOffset = 0;
maxOffset = handles.ledObj(1).Duration;
set(handles.OffsetSlider,'Min',minOffset,'Max',maxOffset);

% Set slider values
set(handles.AmplitudeSlider,'Value',str2double(get(handles.Amplitude)));
set(handles.OffsetSlider,'Value',str2double(get(handles.TimeOffset)));


% --- Create functions --- %
function AmplitudeSlider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
function axes1_CreateFcn(hObject, eventdata, handles)
function ledID_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function Waveform_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function TimeOffset_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function TriggerPeriod_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function Width_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function LEDOffset_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function Amplitude_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function NumPulses_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end








% --- Executes during object creation, after setting all properties.
function OffsetSlider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function deleteAOobject_Callback(hObject, eventdata, handles)
global ao
% Delete analog output object if it exists
try
    stop(ao)
    delete(ao)
    clear ao
end

% Remove LED flag from DataViewer
setappdata(handles.hDataViewer,'bLED',0)
h = guidata(handles.hDaqController);
set(h.hAnalogSetupButton,'ForegroundColor',[0 0 0]);


% --- Executes on button press in led1Tg.
function led1Tg_Callback(hObject, eventdata, handles)
engaged = get(handles.led1Tg,'Value');
if engaged
    handles.ledObj(1).Engaged = 'yes';
else
    handles.ledObj(1).Engaged = 'no';
end
guidata(hObject,handles)
DisplayWaveform(handles)


% --- Executes on button press in led2Tg.
function led2Tg_Callback(hObject, eventdata, handles)
engaged = get(handles.led1Tg,'Value');
if engaged
    handles.ledObj(2).Engaged = 'yes';
else
    handles.ledObj(2).Engaged = 'no';
end
guidata(hObject,handles)
DisplayWaveform(handles)

% --- Executes on button press in led3Tg.
function led3Tg_Callback(hObject, eventdata, handles)
engaged = get(handles.led1Tg,'Value');
if engaged
    handles.ledObj(3).Engaged = 'yes';
else
    handles.ledObj(3).Engaged = 'no';
end
guidata(hObject,handles)
DisplayWaveform(handles)
