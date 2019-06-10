function h = updateOnlineFR(h,spiketimes)
%
% INPUT
%   h: guidata for the FR figure
%   spiketimes:
%
% OUTPUT

%   Created: SRO 4/30/10
%   Modifed:

% Get time of sweep relative to first sweep
if isempty(h.time)
    h.starttime = clock;
    h.time(1) = 0;
else
    h.time(end+1) = etime(clock,h.starttime)/60; % In minutes
end


for m = 1:size(h.frData,1)
    
    for n = 1:size(h.frData,2)
        
        % Compute
        window = h.windows{n};
        k = ((spiketimes{m} >= window(1)) & (spiketimes{m} <= window(2)));
        h.frData{m,n} = [h.frData{m,n} sum(k)];
       
        % Update plot
        set(h.lines(m,n),'XData',h.time,'YData',h.frData{m,n});
        
        if max(h.time) > 0
            set(h.axs,'XLim',[0 max(h.time)])
        end
    end
    
end

% Update ticks
for i = 1:h.nPlotOn
    % Put 2 ticks on y-axis
    setAxisTicks(h.axs(i));
end

guidata(h.frFig,h)