function h = updateOnlineLFP(h,data,cond)
%
% INPUT
%   h: guidata for the PSTH figure
%   data: 
%   cond: 
%
% OUTPUT

%   Created: SRO 5/4/10
%   Modifed:

% Extract data in window
data = data(h.windowPts(1):h.windowPts(2),:);

% Low-pass filter
data = fftFilter(data,32000,300,1);

% Update and display LFP lines
switch h.cond.engage
    case 'off'
        n = 1;
        for m = 1:size(h.lfpData,1)
            h = lfpComputeUpdate(h,data,m,n);
        end
    case 'on'
        switch h.cond.type
            case 'led'
                n = find(h.cond.value == cond.led);
                for m = 1:size(h.lfpData,1)
                   h = lfpComputeUpdate(h,data,m,n);
                end
            case 'stim'
        end
end

% Update ticks
for i = 1:h.nPlotOn
    % Put 2 ticks on y-axis
    currChannelSpiketimes=h.pvOnOrdered(i);
    hAxis=h.axs(currChannelSpiketimes);
    %setAxisTicks(h.axs(currChannelSpiketimes));
    tempYLim = get(hAxis,'YLim');
    adj = 0.25*diff(tempYLim);
    tempYLim = tempYLim + [adj -adj];
    if diff(tempYLim)
        set(hAxis,'YTick',tempYLim,'YTickLabel',num2cell(tempYLim));
    else
        tempYLim = tempYLim + [-1.1 1.1].*tempYLim;
        if any(tempYLim)
            set(hAxis,'YTick',tempYLim,'YTickLabel',num2cell(tempYLim))
        else
            set(hAxis,'YTick',tempYLim(1),'YTickLabel',num2cell(tempYLim(1)))
        end
    end
end

guidata(h.lfpFig,h)


% --- Subfunctions --- %

function h = lfpComputeUpdate(h,data,m,n)
% Update trial counter
h.trialcounter(m,n) = h.trialcounter(m,n) + 1;

% Add data to lfpData
currChannelSpiketimes=h.pvOnOrdered(m);
h.lfpData{m,n} = sum([h.lfpData{m,n} data(:,currChannelSpiketimes)],2);

% Update LFP line
set(h.lines(m,n),'XData',h.xdata,'YData',h.lfpData{m,n}/h.trialcounter(m,n));

axis tight

guidata(h.lfpFig,h)


