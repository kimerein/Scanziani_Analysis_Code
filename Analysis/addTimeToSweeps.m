function sweeps = addTimeToSweeps(sweeps,expt,spikes)
% function sweeps = addTimeToSweeps(sweeps,expt,spikes)
%
% INPUT:
%   sweeps: sweeps struct from either expt or spikes struct
%   expt: expt struct
%   varargin: spikes struct

% Created: 10/20/10 - SRO


% Set flag for working with expt or spikes struct
if nargin < 3
    structType = 'expt';
elseif nargin == 3
    structType = 'spikes';
end

switch structType
    case 'expt'
        fileInd = 1:length(expt.files.names);
    case 'spikes'
        fileInd = unique(spikes.sweeps.fileInd);
end

% Add time field to sweeps
sweeps.time = nan(size(sweeps.fileInd));

% Set trigger times for first trigger in each file
for i = 1:length(fileInd)
    % Set initial trigger time for this file
    firstTrigTime{i} = expt.files.daqinfo(fileInd(i)).ObjInfo.InitialTriggerTime;
end

% Compute elapsed time between each first trigger
for i = 1:length(fileInd)
    relTrigTime(i) = etime(firstTrigTime{i},firstTrigTime{1});
end

% Put relative trigger time in units of minutes
relTrigTime = relTrigTime/60;

trigInd = 1;
for i = 1:length(fileInd)
    
    % inter-sweep interval this this file
    p = expt.stimulus(fileInd(i)).params;
    interSweepInterval = (p.delay + p.duration + p.wait)/60;     % minutes
    
    % Loop through triggers in this file
    for t = 1:expt.files.triggers(fileInd(i))
        sweeps.time(trigInd) = relTrigTime(i) + (t-1)*interSweepInterval;
        trigInd = trigInd + 1;
    end
      
end



