function aoCallback(aoobj,event)
%
%
%
%   Created: 3/24/10 - SRO
%   Modified: 4/3/10 - SRO

tic

global AIOBJ
ledObj = get(aoobj,'UserData');
aiTrigger = AIOBJ.TriggersExecuted;
TriggerPeriod = ledObj.TriggerPeriod;

% Set trigger state
TriggerState = mod(aiTrigger,TriggerPeriod);    % TriggerState = 0 when aiTrigger is multiple of TriggerPeriod
if ~TriggerState
    for i = 1:length(ledObj)
        ledObj(i).Output = 'on';
    end
else
    for i = 1:length(ledObj)
        ledObj(i).Output = 'off';
    end
end

% Update amplitude index
for i = 1:length(ledObj)
    tempInd = ledObj(i).AmplitudeInd + 1;
    ledObj(i).AmplitudeInd = mod(tempInd-1,length(ledObj(i).Amplitude))+1;  
end

% Generate output waveform
allWaveforms = [];
engagedLED = getEngagedLED(ledObj);
for i = 1:length(engagedLED)
    if engagedLED(i)
        ledObj(i).Waveform = MakeOutputWaveform(ledObj(i));
        allWaveforms = [allWaveforms ledObj(i).Waveform];
    end
end

set(aoobj,'UserData',ledObj);
putdata(aoobj,allWaveforms);

start(aoobj)

% disp('Time to put data in analog out engine');
% disp(toc);

function engagedLED = getEngagedLED(ledObj)

for i = 1:length(ledObj)
    engagedLED(i) = strcmp(ledObj(i).Engaged,'yes');
end
engagedLED = logical(engagedLED);

