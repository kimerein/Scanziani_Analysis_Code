function [avgwv ci] = spikeTrigLFP(expt,spikes,lfp_range,sw_window,ch,LP_cutoff)
% function avgwv = spikeTrigLFP(expt,spikes,lfp_range,sw_window,LP_cutoff) 
%
% INPUT
%   expt: The expt struct
%   spikes: The spikes struct
%   lfp_range: Window before and after LFP data to extract in seconds. E.g.
%   lfp_range = 0.1 will extract 100 ms before and after spike.
%   sw_window: Window within the sweep from which spikes will be drawn
%   LP_cutoff: Frequency cutoff for low-pass filtering of LFP

% Created: 6/19/10 - SRO
% Modified: 6/29/10 - SRO
% Heavily modified - WB 06-11/2010


% If sweep window not supplied, use shortest sweep duration
if nargin < 6
    LP_cutoff = 100;
elseif nargin < 5
    sw_window = [0 min(expt.files.duration)];
    LP_cutoff = 100;
end
% Set rig defaults
rigdef = RigDefs;
if(nargin < 7)
    datadir = rigdef.Dir.Data;
end

% Set sweep duration
duration = min(expt.files.duration);

% Set sample rate
Fs = expt.files.Fs(1);

% Abbreviate spikes
s = spikes;

% Set channels to extract data from
chns = sort(expt.info.probe.channelorder) + 1; % Add 1 because trigger channel offset

% Spikes must occur at time > lfp_range after beginning of trial, and time
% < t_range before ending of trial. Make temp field in spikes that can be
% used for filtering spiketimes using filtspikes.
s.temp = zeros(size(s.spiketimes));
s.temp((s.spiketimes > lfp_range) & (s.spiketimes < (duration-lfp_range))) = 1;
[s sortvector_logical] = filtspikes(s,0,'temp',1);

% Extract spikes falling in sw_window
s.temp = zeros(size(s.spiketimes));
s.temp((s.spiketimes >= sw_window(1)) & (s.spiketimes <= sw_window(2))) = 1;
[s sortvector2_logical] = filtspikes(s,0,'temp',1);
sortvector = find(sortvector_logical);
sortvector = sortvector(sortvector2_logical);

% Number of spikes
nspikes = length(s.spiketimes);

% Convert lfp_range to samples
lfp_range = floor(lfp_range*Fs); % must floor or samples - lfp_range can be < 0 in some fringe cases

% Preallocate matrix
wv = nan(2*lfp_range+1,nspikes,length(chns));

c_fileInd = 0;
for i = 1:nspikes
    %daqdata = MakeDataMat(daqdata,numTriggersEmpirical, ...
%        Fs,duration);
    
    % Convert spike time to sample number
    sample = round(s.spiketimes(i)*Fs);

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
     startPt = sample - lfp_range;
     endPt = sample + lfp_range;
     tempdata(:,i,:) = daqdata(startPt:endPt,trigger,:); 
     
     % Need to consider down-sampling
     
end


% band-pass filter data
for n = 1:size(data,3)
    data(:,:,n) = filtdata(data(:,:,n),Fs,100,'low');
    data(:,:,n) = filtdata(data(:,:,n),Fs,20,'high');
end

% Average across spikes
temp = data(:,:,ch);
temp = mean(temp,3);
avgwv = mean(temp,2);

% Bootstrap confidence interval
matlabpool local
tic
parfor i = 1:size(temp,1)
    ci(:,i) = bootci(300,@mean,temp(i,:));
end
matlabpool close
toc


ci = ci';
     
    

