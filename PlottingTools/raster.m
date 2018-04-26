function [varargout] = raster(spikes,hAxes,bAppend,showBursts,duration)
% function [varargout] = raster(spikes,hAxes,bAppend,showBursts)
% INPUTS
%   spikes: The spikes struct. This function requires that spikes contain
%   only the following fields:
%       - .spiketimes: Vector of spike times
%       - .trials: Vector indicating trial in which each spike occurred
%   hAxes: Handles to axes;
%   bAppend: 1, append to trials already displayed; 0, use absolute trials in spikes struct 
%   showBursts: 1, plot "burst spiks" (ISIs < 4 ms)
%
% OUTPUTS
%   varargout(1) = hRaster, handle to raster
%   varargout(2) = hAxes, handle to axes
%

% Created: 5/11/10 - SRO
% Modified: 11/3/11 - KR passes in trial duration

if nargin < 2
    hAxes = axes;
    bAppend = 0;
    showBursts = 0;
end

if bAppend == 0
    useTrials = 1;
else
    useTrials = 0;
end

% Set trial duration
% KR passes in

% Set spiketimes
spiketimes = spikes.spiketimes;

% Set trial numbers
if isfield(spikes,'trialsInFilter') && ~useTrials
    trials = spikes.trialsInFilter;
else
    trials = spikes.trials;
end

% Get previous trial information
t = get(hAxes,'UserData');
if ~isempty(trials)
    
    if isempty(t)
        if isfield(spikes.sweeps,'trialsInFilter')
            t.min = min(spikes.sweeps.trialsInFilter);
            t.max = max(spikes.sweeps.trialsInFilter);
        else
            t.min = min(spikes.sweeps.trials);
            t.max = max(spikes.sweeps.trials);
        end
    else
        if bAppend == 1
            % Offset by max trial number already on plot
            trials = trials + max(t.max);
        end
        t.min(end+1) = min(trials);
        t.max(end+1) = max(trials);
    end
else
    if ~isempty(t)
        if bAppend == 1
            % Offset by max trial number already on plot
            trials = 0;
            trials = trials + max(t.max);
        end
        t.min(end+1) = min(trials);
        t.max(end+1) = max(trials);
        spiketimes = NaN;
        trials = NaN;
    else
            t.min = 0;
            t.max = 1;
            spiketimes = NaN;
            trials = NaN;
    end
end

% Store trial information as UserData in hAxes
set(hAxes,'UserData',t)

% Make raster on hAxes
set(gcf,'CurrentAxes',hAxes)
hRaster = linecustommarker(spiketimes,trials);

% Set default raster properties
numtrials = length(spikes.sweeps.trials);
offset = numtrials*0.03;
ymin = (min(t.min)-offset);
ymax = (max(t.max)+offset);
set(hAxes,'TickDir','out','YDir','reverse','FontSize',9, ...
    'YLim',[ymin ymax],'XLim',[0 duration])
xlabel(hAxes,'seconds')
ylabel(hAxes,'trials')

% Find bursts and plot

if showBursts
    [bTimes bTrials] = findBursts(spiketimes,trials);
    hBurst = linecustommarker(bTimes,bTrials);
    set(hBurst,'Color',[0 1 0]);
%     hBurst = line('XData',bTimes,'YData',bTrials,'LineStyle','none',...
%         'Color',[0 1 0],'Marker','o','MarkerSize',2);
else
    hBurst = [];
end

% Outputs
varargout{1} = hRaster;
varargout{2} = hAxes;
varargout{3} = hBurst;




