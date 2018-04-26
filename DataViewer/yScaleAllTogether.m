function yScaleAllTogether(handles)
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
RigDef=RigDefs();
allMins=zeros(size(PlotVectorOn,1),1);
allMaxs=zeros(size(PlotVectorOn,1),1);
for i=1:size(PlotVectorOn,1)
    k=PlotVectorOn(i);
    % Ignore non-physiology channels
    if ~ismember(k,RigDef.Daq.PhysiologyChannels) || k==15
        allMins(i)=NaN;
        allMaxs(i)=NaN;
    else
        temp=get(hPlotLines(k),'YData');
        allMins(i)=min(temp);
        allMaxs(i)=max(temp);
    end
end
yLim=zeros(1,2);
yLim(1)=min(allMins);
yLim(2)=max(allMaxs);
for i=PlotVectorOn'
    % Ignore non-physiology channels
    if ismember(i,RigDef.Daq.PhysiologyChannels) && k~=15
        set(hAllAxes(i),'YLim',yLim);
        % Update ticks
        setAxisTicks_Data(hAllAxes(i));
    end
end