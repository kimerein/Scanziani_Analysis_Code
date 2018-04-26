function setAxisTicks_Data(hAxis)
% 
% Adds 2 ticks to y-axis at 25% and 75% of yLim.
%
%

% Created: 8/13/10 - SRO
% Modified: 3/10/11 - KR for LFP rather than PSTH data

tempYLim = get(hAxis,'YLim');
adj = 0.25*diff(tempYLim);
tempYLim = tempYLim + [adj -adj];

if diff(tempYLim)
    set(hAxis,'YTick',tempYLim,'YTickLabel',num2cell(tempYLim));
elseif ~diff(tempYLim)
    tempYLim = tempYLim + [-1.1 1.1].*tempYLim;
    if any(tempYLim)
        if tempYLim(2)>tempYLim(1) % KR check
            set(hAxis,'YTick',tempYLim,'YTickLabel',num2cell(tempYLim))
        end
    else
        if tempYLim(2)>tempYLim(1) % KR check
            set(hAxis,'YTick',tempYLim(1),'YTickLabel',num2cell(tempYLim(1)))
        end
    end
    
end
