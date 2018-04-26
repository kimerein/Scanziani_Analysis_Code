function yAxesMakeSameSize(handles)
%
%
%   Created: 4/5/10 - KR
%   Modified: 

% Get handles for DataViewer plot objects
temp = getappdata(handles.hDataViewer,'handlesPlot');
hAllAxes = temp(1,:);
hPlotLines = temp(2,:);
hRasters = temp(3,:);
dvplot = getappdata(handles.hDataViewer,'dvplot');
PlotVectorOn = dvplot.pvOn;

% Display data
RigDef=RigDefs();
allDiffs=zeros(size(PlotVectorOn,1),1);
for i=1:size(PlotVectorOn,1)
    k=PlotVectorOn(i);
    % Ignore non-physiology channels
    if ~ismember(k,RigDef.Daq.PhysiologyChannels)  || k==15
        allDiffs(i)=NaN;
    else
        temp=get(hPlotLines(k),'YData');
        allDiffs(i)=abs(diff([max(temp) min(temp)]));
    end
end
maxDiff=max(allDiffs);
for i=PlotVectorOn'
    % Ignore non-physiology channels
    if ismember(i,RigDef.Daq.PhysiologyChannels)  && k~=15
        temp=get(hPlotLines(i),'YData');
        yLim=[mean([min(temp) max(temp)]) mean([min(temp) max(temp)])]+[-(maxDiff/2) (maxDiff/2)];
        set(hAllAxes(i),'YLim',yLim);
        % Update ticks
        setAxisTicks_Data(hAllAxes(i));
    end
end