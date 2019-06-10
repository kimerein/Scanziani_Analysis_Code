function yAutoScaleDV(handles)
%
%
%   Created: 4/5/10 - SRO
%   Modified: 

% Get handles for DataViewer plot objects
temp = getappdata(handles.hDataViewer,'handlesPlot');
hAllAxes = temp(1,:);
hPlotLines = temp(2,:);
hRasters = temp(3,:);
dvplot = getappdata(handles.hDataViewer,'dvplot');
PlotVectorOn = dvplot.pvOn;

% Display data
for i = PlotVectorOn'  % Must be row vector for this notation to work
    temp = get(hPlotLines(i),'YData');
    if min(temp) == max(temp)
        break
    end
    yLim = [min(temp) max(temp)];
    set(hAllAxes(i),'YLim',yLim);
    % Update ticks
    setAxisTicks(hAllAxes(i));
end