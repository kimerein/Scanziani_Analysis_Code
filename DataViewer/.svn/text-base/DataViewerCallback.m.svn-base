function DataViewerCallback(obj,event,hDataViewer)
% hDataViewer is the handle to the DataViewer GUI. This handle is used to
% access appdata stored in the DataViewer.
%

%   Created: 1/10 - SRO
%   Modifed: 4/5/10 - SRO

% Get information about AIOBJ (aka obj)
Trigger = obj.TriggersExecuted;
TriggerRepeat = obj.TriggerRepeat;
LoggingMode = obj.LoggingMode;
LogFileName = obj.LogFileName;
SamplesPerTrigger = obj.SamplesPerTrigger;

% Print SaveName to command line
if strcmp(LoggingMode,'Disk&Memory') && Trigger == 1
    LogFileName(1:end-4)
end

% Get stimulus information
global DIOBJ
% Reads digital ports and SAVES the result
stimconds = readDigitalPorts(DIOBJ,Trigger,TriggerRepeat,LoggingMode,LogFileName);
setappdata(hDataViewer, 'StimCondData', stimconds);

% disp('stimulus condition = ')
% disp(stimconds(2,:))
GetStimFileName(Trigger,LoggingMode,LogFileName);

% Determine whether LED being used, if so, get LED condition
bLED = getappdata(hDataViewer,'bLED');
if bLED
    % obtains the LED condition and SAVES it
    ledconds = GetLEDCond(Trigger,TriggerRepeat,LoggingMode,LogFileName);
%     disp(ledconds(2,Trigger))
else
    ledconds = NaN;
end

setappdata(hDataViewer, 'LEDCondData', ledconds);

% Redraw Y ticks    KR 3/10/11
% Put 2 ticks on y-axis
dvplot = getappdata(hDataViewer,'dvplot');
ChannelOrder = getappdata(hDataViewer,'ChannelOrder');
nPlotOn = numel(dvplot.pvOn);
kv = ismember(ChannelOrder,dvplot.pvOn);
pvOnOrdered = ChannelOrder(kv);
temp=getappdata(hDataViewer,'handlesPlot');
hAllAxes=temp(1,:);
for i = 1:nPlotOn
    k = pvOnOrdered(i);
    hAxisTemp = hAllAxes(k);
    setAxisTicks_Data(hAxisTemp);
end



% --- Subfunctions --- %

function GetStimFileName(Trigger,LoggingMode,LogFileName)
% Get name of stimulus and save to file

if strcmp(LoggingMode,'Disk&Memory')
    if Trigger == 1 ;
        global UDP_OBJ_STIM_PC % UDP object connecting to stimulus PC
        try
            temp = fscanf(UDP_OBJ_STIM_PC); % NOTE: timeout is set when declaring UDP object
            if  ~isempty(temp)
                temp = strread(temp,'%s','delimiter','*'); % Stimulus filename, condition name, and number
            end
        catch
            temp{1:3} = [];
        end
        if ~isempty(temp)
            params.sfilename = temp{1};
            params.condName = temp{2};
%            params.condNum = str2num(temp{3});  SRO not using
            temp = LogFileName;
            save([temp(1:end-4) '_SFile'],'params');
        end
    else
    end
end

