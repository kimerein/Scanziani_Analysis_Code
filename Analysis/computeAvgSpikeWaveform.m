function [avgwv xtime maxch] = computeAvgSpikeWaveform(spikes,expt,w,n)
% INPUT
%   spikes: spikes struct
%   expt: expt struct
%   w: 2 element vector setting time in ms before and after spike peak
%   ([before after])
%   n: Number of spikes to use
%
% OUTPUT
%   avgwv:
%   xtime: 
%

% Created: 10/25/10 - SRO

if nargin < 3
    w = [1 1.5];
    n = 500;
end

s = spikes;

% Set rig defaults
rigdef = RigDefs;

% Set sweep duration
duration = min(expt.files.duration);

% Set sample rate
Fs = expt.files.Fs(1);

% Set channels to extract data from
%chns = sort(expt.probe.channelorder) + 1; % Add 1 because trigger channel
%offset -- only for Shawn
chns = sort(expt.probe.channelorder); 

% Determine unique file indices
fileInd = unique(s.fileInd);

% Choose subset of files to use
if length(fileInd) > 3
    temp = randperm(length(fileInd));
    fileInd = fileInd(temp(1:3));    % Use 3 files
end

% Filter s on fileInd
s = filtspikes(s,0,'fileInd',fileInd);

% Spikes must occur at times > w(1) and < w(2)
w = w/1000;     % Convert to ms
s.temp = zeros(size(s.spiketimes));
s.temp((s.spiketimes > w(1)) & (s.spiketimes < (duration - w(2)))) = 1;
s.sweeps.temp = ones(size(s.sweeps.trials));
s = filtspikes(s,0,'temp',1);

% Sample n spikes
numspikes = length(s.spiketimes);
if numspikes < n
    n = numspikes;
end
spikeInd = randperm(numspikes);
s.temp = zeros(size(s.spiketimes));
s.temp(spikeInd(1:n)) = 1;

s = filtspikes(s,0,'temp',1);

% Number of spikes
nspikes = length(s.spiketimes);

% Convert w from ms to samples
w = round(w*Fs);

% Preallocate matrix
tempdata = nan(sum(w)+1,nspikes,length(chns));

c_fileInd = 0;

for i = 1:nspikes
    
    % Convert spike time to sample number
    sample = ceil(s.spiketimes(i)*Fs);
    
    fileInd = s.fileInd(i);
    trigger = s.trigger(i);
    
    % Load daq file if not loaded yet
    if ~(fileInd == c_fileInd)
        % Get file name
        fname = [rigdef.Dir.Data expt.files.names{fileInd}];
        
        daqdata = daqread(fname,'Channels',chns);
        
        daqdata = MakeDataMat(daqdata,expt.files.triggers(fileInd), ...
            expt.files.Fs(fileInd),expt.files.duration(fileInd));
        c_fileInd = fileInd; % Update current file status
    end

      % Extract data in window +/- lfp_range
     startPt = sample - w(1);
     endPt = sample + w(2);
     % KR handling 
     if startPt<1
         continue
     elseif endPt>size(daqdata,1)
         continue
     else
         if trigger>size(daqdata,2)
             continue
         end
         tempdata(:,i,:) = daqdata(startPt:endPt,trigger,:); 
     end
    
end

data = tempdata;

% Band-pass filter data
for n = 1:size(data,3)
    data(:,:,n) = filtdata(data(:,:,n),Fs,[],'band',[500 10000],[300 12000]);
end


% Average across spikes
avgwv = mean(data,2);
avgwv = squeeze(avgwv);

% Make time vector
xtime = (1:size(avgwv,1))*1/Fs*1000;        % in ms

% Determine max channel
temp = min(min(avgwv));
k = find(min(avgwv) == temp);
maxch = k;
