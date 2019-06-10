function handles = UpdateDataViewer(handles)
%
% INPUT
%   handles: This should be the DataViewer handles
%
%
%   Created: 4/5/10 - SRO
%   Modified: 7/7/10 - KR - removed support for threshold sliders

% Get updated plot vectors from DataViewer appdata
dvplot = getappdata(handles.hDataViewer,'dvplot');
nPlotOn = numel(dvplot.pvOn);

% Turn off plots and threshold objects
set(handles.hAllAxes(dvplot.pvOff),'Visible','off');
set(handles.hPlotLines(dvplot.pvOff),'Visible','off');
set(handles.hLabels(dvplot.pvOff),'Visible','off');
set(handles.hRaster(dvplot.rvOff),'Visible','off');
set(handles.hThresh(dvplot.rvOff),'Visible','off');

% Find out if we're showing all the Y-Axes or not
showAllYAxes = getappdata(handles.hDataViewer, 'showAllYAxes');

% Compute axes positions
if isfield(handles,'ExptDataViewer')
    margins = [0.05 0.035 0.042 0.08];
else
    margins = [0.05 0.035 0.042 0.035];
end
if(nPlotOn ~= 0)
    if(showAllYAxes)
        interAxisSpace = 0.005; % WB fixit remove hardcode (right now must keep in sync w/ InitializeDataViewerPlots.m)
        axPos = dvAxesPosition(nPlotOn,margins,interAxisSpace);
    else
        axPos = dvAxesPosition(nPlotOn,margins);
    end
else
    axPos = 0;
end


% altColor = [0.25 0.75 0.25; 0.145 0.145 1];                               % green, blue
altColor = [0.4 0.4 0.4; 0.145 0.145 1];                                    % gray, blue

% Get channel order
ChannelOrder = getappdata(handles.hDataViewer,'ChannelOrder');
Probe = getappdata(handles.hDataViewer,'Probe');

% Adjust channel order of visible plots and threshold objects
kv = ismember(ChannelOrder,dvplot.pvOn);
pvOnOrdered = ChannelOrder(kv);
RasterOn = ismember(pvOnOrdered,dvplot.rvOn);

% Add axes for displaying stimulus and LED bar
if isfield(handles,'ExptDataViewer')
       PlotObj = getappdata(handles.hDataViewer,'PlotObj');
    str = ['F' num2str(PlotObj.FileIndex) 'T' num2str(PlotObj.Trigger)];
    axes(handles.barAxis);
    handles.barAxisFileTriggerText = text(0,0.4,str);
    set(handles.barAxisFileTriggerText,'FontSize',8,'Color',[0.85 0.85 0.85]);
end

for i = 1:nPlotOn
    k = pvOnOrdered(i);
    hAxisTemp = handles.hAllAxes(k);
    set(hAxisTemp,'Position',axPos{i},'Visible','on', ...
        'YColor',[0.85 0.85 0.85],'XColor',[0.85 0.85 0.85],'YTickLabel',[],'XTickLabel',[]);
    set(get(hAxisTemp,'YLabel'),'String',[]);
    set(get(hAxisTemp,'XLabel'),'String',[]);
    
    if showAllYAxes
        set(hAxisTemp,'YColor',[0.5 0.5 0.5]);
        set(get(hAxisTemp,'YLabel'),'String','','Units','normalized',...
            'Position',[-0.030 0.5]);
        
        % Put 2 ticks on y-axis
        setAxisTicks_Data(hAxisTemp);
        
    else
        set(hAxisTemp, 'YTickLabel', []);
    end
    
    if i == nPlotOn         % Corresponds to bottom plot
        set(hAxisTemp,'XColor',[0.5 0.5 0.5],'XTickMode','auto','XTickLabelMode','auto');
        set(get(hAxisTemp,'XLabel'),'String','sec');
    end
    
    set(handles.hPlotLines(k),'Color',altColor(mod(i,2)+1,:),'Visible','on');
    set(handles.hLabels(k),'Color',altColor(mod(i,2)+1,:),'Visible','on');
    if RasterOn(i) == 1
        set(handles.hThresh(k),'Visible','on');
        set(handles.hRaster(k),'Color',altColor(mod(i,2)+1,:),'Visible','on');
        yLimTemp = get(hAxisTemp,'YLim');
    end
    
    RigDef=RigDefs();
    % Set trigger and photodiode to light gray
    if (k == RigDef.Daq.TriggerChannel || k == RigDef.Daq.PhotodiodeChannel)
        lightGray = [0.75 0.75 0.75];
        set(handles.hPlotLines(k),'Color',lightGray);
        set(handles.hRaster(k),'Color',lightGray);
        set(handles.hLabels(k),'Color',lightGray);
    end
    
    % If using tetrodes, color by tetrode
    if any(strcmp(Probe,{'16 Channel 2x2','16 Channel 4x1'}))
        if any(k == ChannelOrder(1:4) | k == ChannelOrder(9:12))
            set(handles.hPlotLines(k),'Color',altColor(1,:));
            set(handles.hRaster(k),'Color',altColor(1,:));
            set(handles.hLabels(k),'Color',altColor(1,:));
        elseif any(k == ChannelOrder(5:8) | k == ChannelOrder(13:16))
            set(handles.hPlotLines(k),'Color',altColor(2,:));
            set(handles.hRaster(k),'Color',altColor(2,:));
            set(handles.hLabels(k),'Color',altColor(2,:));
        end
    end
end

%handles = updateStimulusLedBars(handles);

guidata(handles.hDataViewer,handles)