function [varargout] = psth(spikes,binsize,hAxes,bsmooth,duration)
% function [varargout] = psth(spikes,binsize,hAxes,bsmooth,duration)
%
% INPUTS
%   spiketimes:
%   binsize:
%   hAxes:
%   bsmooth:
%   duration: trial duration
%
% OUTPUTS
%   varargout{1} = hPsth;
%   varargout{2} = hAxes;
%   varargout{3} = n;
%   varargout{4} = centers;
%   varargout{5} = edges;
%   varargout{6} = xpoints;
%   varargout{7} = ypoints;

% Created:  3/14/10 - SRO
% Modified: 5/14/10 - SRO
%           6/8/10 - SRO
%           11/3/11 - KR passes in duration

if nargin < 2
    binsize = 50; 
end

% Use current axes if hAxes not supplied
if nargin < 3
    hAxes = gca;   
end

if nargin < 4
    bsmooth = 0;
end

% Set duration and number of trials
%duration = max(spikes.info.detect.dur);     % Maybe add checking for equal sweep durations?
numtrials = length(spikes.sweeps.trials);

% Set spiketimes
spiketimes = spikes.spiketimes;

% Convert binsize from ms to s
binsize = binsize/1000;

% Get counts
edges = 0:binsize:duration;
n = histc(spiketimes,edges);
n = n/numtrials/binsize;

if all(isnan(n))
    n = 0;
end

% Compute center of bins
centers = edges + diff(edges(1:2))/2;

% Last point of n contains values falling on edge(end) -- usually zero
if bsmooth
hPsth = line('XData',centers(1:end-1),'YData',smooth(n(1:end-1),3),...
    'Parent',hAxes,'LineWidth',1.5);
    xpoints=centers(1:end-1);
    ypoints=smooth(n(1:end-1),3);
else
    hPsth = line('XData',centers(1:end-1),'YData',n(1:end-1),...
    'Parent',hAxes,'LineWidth',1.5);
    xpoints=centers(1:end-1);
    ypoints=n(1:end-1);
end

% Set default axes properties
if sum(n) == 0
    maxN = 0.1;
else
    maxN = max(n);
end
axis([0 duration 0 maxN])
set(hAxes,'TickDir','out','FontSize',8)
xlabel(hAxes,'seconds')
ylabel(hAxes,'spikes/s')

% Outputs
varargout{1} = hPsth;
varargout{2} = hAxes;
varargout{3} = n;
varargout{4} = centers;
varargout{5} = edges;
varargout{6} = xpoints;
varargout{7} = ypoints;