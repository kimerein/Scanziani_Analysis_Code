function waveform = MakeOutputWaveform(ledObj)
% 
% INPUT
%   ledObj:
%
% OUTPUT
%   waveform:
%
%   Created: 2/10 - SRO
%   Modified: 2/3/2012 - KR - allowed hard-coding of LED outputs over many
%   trials


Fs = ledObj.SampleRate;
Duration = ledObj.Duration;
TimeOffset = ledObj.TimeOffset;
NumSamples = ledObj.NumSamples;
LEDOffset = ledObj.LEDOffset;
TimeOffset = ledObj.TimeOffset;
Amplitude = ledObj.Amplitude;
Width = ledObj.Width;
AmplitudeInd = ledObj.AmplitudeInd;
Amplitude = Amplitude(AmplitudeInd);

% disp(Amplitude)

% KR - hard-coding
ledObj.WaveformType='hardcode';

% Create output wavform
waveform = zeros(NumSamples,1);
switch ledObj.Output
    case 'on'
        switch ledObj.WaveformType
            case 'square'
                StartPt = round(TimeOffset*Fs) + 1;
                EndPt = StartPt + Width*Fs -1;
                waveform(StartPt:EndPt) = Amplitude;
            case 'ramp'
                % Plateau
                StartPt = round(TimeOffset*Fs) + 1;
                EndPt = StartPt + Width*Fs -1;
                waveform(StartPt:EndPt) = Amplitude;   
                % Rising phase
                riseX = 1:StartPt-1;
                riseY = (Amplitude-LEDOffset*0.95)*((riseX-1)/length(riseX))+LEDOffset*0.95;
                waveform(riseX) = riseY;
                % Falling phase
                fallX = EndPt+1:length(waveform);
                fallY = (Amplitude-LEDOffset*0.95)*(-(fallX-EndPt)/length(fallX)+1)+LEDOffset*0.95;
                waveform(fallX) = fallY;
            case 'sine'
        end
    case 'off'
        waveform = zeros(NumSamples,1);
end
