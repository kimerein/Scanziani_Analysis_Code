function varargout = plotSpikesPerTrial(spikes,hAxes,smoothwin,sumWindow)
% function varargout = plotSpikesPerTrial(spikes,hAxes,smoothwin,sumWindow)
%
%
% INPUT
%   spikes: spikes struct
%   hAxes: handles to plot axis
%   smoothwin: Assign value > 0 for smoothing with window of N points.
%   sumWindow: Window in sweep for counting spikes.
%
% OUTPUT
%   varargout{1} = hLine
%   varargout{2} = hAxes
%   varargout{3} = spikesPerTrial
%   varargout{4} = xtime

% Created: 5/16/10 - SRO
% Modified: 10/20/10 - SRO

if nargin < 2
    smoothwin = 0;
    hAxes = axes;
    sumWindow = spikes.info.detect.dur(1);
end

if nargin < 3
    smoothwin = 0;
    sumWindow = spikes.info.detect.dur(1);
end

if nargin < 4
    sumWindow = spikes.info.detect.dur(1);
end

if isempty(hAxes)
    hAxes = axes;
end

% Filter spikes based on sumWindow
spikes.temp = spikes.spiketimes >= sumWindow(1) & spikes.spiketimes <= sumWindow(2);
spikes.sweeps.temp = ones(size(spikes.sweeps.trials));
spikes = filtspikes(spikes,0,'temp',1);

% Compute number of spikes per trial
ntrials = length(spikes.sweeps.trials);
spikesPerTrial = zeros(size(spikes.sweeps.trials));
for i = 1:length(spikes.sweeps.trials)
    spikesPerTrial(i) = length(find(spikes.trials == i));
end
% Put spikesPerTrial in units of spikes/s
spikesPerTrial = spikesPerTrial/diff(sumWindow);

% Compute time of each sweep
if isfield(spikes.sweeps,'time')
    xtime = spikes.sweeps.time;
else
    xtime = 1:length(spikes.sweeps.trials);  
end

% Start time from zero
xtime = xtime - min(xtime);

% Plot line
hLine = line('Parent',hAxes,'XData',xtime,'YData',spikesPerTrial, ...
    'Marker','none','Color',[0.15 0.15 0.15]);
maxspikes = max(spikesPerTrial);
if maxspikes == 0
    maxspikes = 1;
end
set(hAxes,'XLim',[0 max(xtime)],'YLim',[0 maxspikes]);

% Output
varargout{1} = hLine;
varargout{2} = hAxes;
varargout{3} = spikesPerTrial;
varargout{4} = xtime;