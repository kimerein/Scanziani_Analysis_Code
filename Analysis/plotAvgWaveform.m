function varargout = plotAvgWaveform(spikes,allChannels,hAxes)
%
%
%
%
%

% Created: 6/21/10 - SRO
% Modified: 11/1/11 - KR - if allChannels==1, show waveforms on 
% all channels, else just show waveform on channel where it is
% biggest

if nargin < 3
    hAxes = axes;
end

[avgwv maxch] = computeAvgWaveform(spikes.waveforms);
if allChannels
    avgwv = reshape(avgwv,numel(avgwv),1);
else
    avgwv=avgwv(:,maxch);
end
xdata = 1:length(avgwv);

hLine = line('Parent',hAxes,'XData',xdata,'YData',avgwv,'Color',[0.2 0.2 0.2]);
%set(hAxes,'XLim',[0 max(xdata)*1.3],'YLim',[min(avgwv) max(avgwv)])
set(hAxes,'XLim',[0 max(xdata)],'YLim',[min(avgwv) max(avgwv)])

varargout{1} = hLine;
varargout{2} = hAxes;
varargout{3} = maxch;