function ledConds = GetLEDCond(Trigger,TriggerRepeat,LoggingMode,LogFileName)
%
%
%   Created: 3/10 - SRO
%   Modified: 4/5/10 - SRO
%   Modified: 8/6/10 - WB

global ao
persistent LEDCond SaveName
led = get(ao,'UserData');


if Trigger == 1;
    LEDCond = [];
    SaveName = LogFileName;
    SaveName = SaveName(1:end-4);
    LEDCond = nan(2,TriggerRepeat+1);
end
if strcmp(led(1).Output,'on')
    LEDCond(:,Trigger) = [now led(1).Amplitude(led(1).AmplitudeInd)];
elseif strcmp(led(1).Output,'off')
    LEDCond(:,Trigger) = [now 0];
end
if(strcmpi(LoggingMode, 'Disk&Memory'))
    save([SaveName '_LEDCond'],'LEDCond');
end
%ledSwCond = round(LEDCond(2,Trigger)); % passing entire block now
ledConds = LEDCond;



