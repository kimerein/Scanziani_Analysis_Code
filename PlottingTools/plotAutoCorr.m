function varargout = plotAutoCorr(spikes,hAxes,range,binsize)
% function plotAutoCorr(spikes,range,binsize)
% 
% INPUT
%   spikes: spikes struct
%   range: +/- lag (default -/+ 50 ms lags)
%   binsize: binsize in ms

% Created: 10/15/10 - SRO

if nargin < 2
    hAxes = axes;
    range = 50;
    binsize = 1;
end
    
if nargin < 3
    range = 50;
    binsize = 1;
end

if nargin < 4
    binsize = 1;
end

s = spikes;

% Bin spikes in ms bins
stimes = s.unwrapped_times;
stimes = stimes*1000;
edges = 0:binsize:max(stimes);
[n,centers] = hist(stimes,edges);

% Compute autocorrelation
[c,lags] = xcorr(n,range);
c(lags == 0) = 0;

% Make bar graph
hBar = bar(hAxes,lags,c);

% Set properties
set(hBar,'FaceColor',[0.1 0.1 0.1], 'EdgeColor',[0.1 0.1 0.1]);
set(hAxes,'XLim',[min(lags) max(lags)],'YLim',[0 max(c)],'FontSize',8);
xlabel('lag (ms)'); ylabel('counts')
box off

% Outputs
varargout{1} = hBar;
varargout{2} = hAxes;



