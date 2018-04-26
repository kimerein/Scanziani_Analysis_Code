function ledObj = MakeAnalogOut(ledObj)
%
% INPUT:
%   ledObj:
%
% OUTPUT:
%   ledObj:
%
%
%   Created: 2/10 - SRO
%   Modified: 4/3/10 - SRO

global AIOBJ        % Analog input object
global ao           % Analog output object

% Determine engaged LEDs
for i = 1:length(ledObj)
    engagedLED(i) = strcmp(ledObj(i).Engaged,'yes');
end
engagedLED = find(engagedLED == 1);

% Define AO object
ao = analogoutput('nidaq','Dev1');
ao.SampleRate = AIOBJ.SampleRate;
ActualRate = get(ao,'SampleRate');
for i = 1:length(engagedLED)
    ledInd = engagedLED(i);
    OutputRange = ledObj(ledInd).OutputRange;
    aochans(i) = addchannel(ao,ledObj(ledInd).HwChannel);
    aochans(i).OutputRange = [-1 1].*OutputRange;
    ledObj(ledInd).SampleRate = ActualRate;
end

% Define Trigger
TriggerType = 'HwDigital';
switch TriggerType
    case 'Manual'
        duration = 10;
        ao.RepeatOutput = 0;
        ao.TriggerType = 'Manual';
    case 'HwDigital'
        ao.RepeatOutput = 0;
        AIOBJ.ExternalTriggerDriveLine = 'RTSI0';       % RTSI bus line 0 is pulsed when data acquisition begins
        ao.TriggerType = 'HwDigital';           
        ao.HwDigitalTriggerSource = 'RTSI0';            % RTSIO triggers analog out
        ao.TriggerCondition = 'PositiveEdge';
end

% Define callback functions
ao.TriggerFcn = '';
ao.SamplesOutputFcn = '';
ao.StopFcn = @aoCallback;

% Generate output waveform
allWaveforms = [];
for i = 1:length(engagedLED)
    ledInd = engagedLED(i);
    ledObj(i).Waveform = MakeOutputWaveform(ledObj(i));
    allWaveforms = [allWaveforms ledObj(i).Waveform];
end

% Put waveform in ao
putdata(ao,allWaveforms)
start(ao)

% Store ledObj in UserData in analog output object
set(ao,'UserData',ledObj);



