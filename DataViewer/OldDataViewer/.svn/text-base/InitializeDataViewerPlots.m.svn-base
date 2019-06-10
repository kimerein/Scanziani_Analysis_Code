function handles = InitializeDataViewerPlots(handles)

rigdef = RigDefs;

% Get dvplot struct from DataViewer
dvplot = getappdata(handles.hDataViewer,'dvplot');
nPlotOn = numel(dvplot.pvOn);

% find out if we're showing all the Y-Axes or not
showAllYAxes = getappdata(handles.hDataViewer, 'showAllYAxes');

% Compute axes positions
if isfield(handles,'ExptDataViewer')
    margins = [0.05 0.035 0.042 0.08];   % [Left Right Bottom Top]
else
    margins = [0.05 0.035 0.042 0.035];
end
if(nPlotOn ~= 0)
    if(showAllYAxes)
        interAxisSpace = 0.005; % WB fixit remove hardcode (right now must keep in sync w/ DataViewerUpdate.m)
        axPos = dvAxesPosition(nPlotOn,margins,interAxisSpace);
    else
        axPos = dvAxesPosition(nPlotOn,margins);
    end
else
    axPos = 0;
end

% altColor = [0.25 0.75 0.25; 0.145 0.145 1];            	% green, blue
altColor = [0.4 0.4 0.4; 0.145 0.145 1];                    % gray, blue

try
    delete(handles.hPlotLines);
    delete(handles.hLabels);
    delete(handles.hThresh);
    delete(handles.hRaster);
catch
    
end

% Get channel order
ChannelOrder = getappdata(handles.hDataViewer,'ChannelOrder');
Probe = getappdata(handles.hDataViewer,'Probe');


if isequal(length(ChannelOrder),length(dvplot.pvOn))
    % Adjust channel order
    k = ismember(ChannelOrder,dvplot.pvOn);
    pvOnOrdered = ChannelOrder(k);
else
    display('length of ChannelOrder does not match number of channels plotted')
    pvOnOrdered = dvplot.pvOn;
end

% BA initialize sliders to thresholds already determined
if isfield(handles,'expt') % Make compatible with DaqDataViewer
    Thresholds = handles.expt.sort.manualThresh;
end

% Add axes for displaying stimulus and LED bar
if isfield(handles,'ExptDataViewer')
    barAxPos = [0.05 0.92 0.9150 0.0438];
    handles.barAxis = axes('Parent',handles.hDataViewer,'Position',barAxPos,...
        'XLim',[0 handles.SweepDuration],'YLim',[0 1]);
    axis(handles.barAxis,'off')
    PlotObj = getappdata(handles.hDataViewer,'PlotObj');
    str = ['F' num2str(PlotObj.FileIndex) 'T' num2str(PlotObj.Trigger)];
    axes(handles.barAxis);
    handles.barAxisFileTriggerText = text(0,0.4,str);
    set(handles.barAxisFileTriggerText,'FontSize',8,'Color',[0.65 0.65 0.65]);
end

for i = 1:nPlotOn
    k = pvOnOrdered(i);
    
    % Position and format axes
    hAxisTemp = handles.hAllAxes(k);
    set(hAxisTemp,'Position',axPos{i},'Visible','on','XLim',[0 handles.SweepDuration], ...
        'YColor',[0.85 0.85 0.85],'XColor',[0.85 0.85 0.85],'TickDir','in','FontSize',7,'YTickLabel',[], ...
        'XAxisLocation','bottom','TickLength',[0.003 0.01],'XTickLabel',[]);
    YTickLabel = get(hAxisTemp,'YTickLabel');
    XTickLabel = get(hAxisTemp,'XTickLabel');
    
    % Generate lines and labels
    hPlotLines(k) = line([0 handles.SweepDuration],[-1 -1],'Parent',hAxisTemp,'Color',altColor(mod(i,2)+1,:));
    hRaster(k) = line([0 handles.SweepDuration],[1 1],'Parent',hAxisTemp,'Color',altColor(mod(i,2)+1,:),...
        'Marker','s','LineStyle','none','MarkerSize',2,'Visible','off','MarkerFaceColor',altColor(mod(i,2)+1,:));
    hLabels(k) = text('Parent',hAxisTemp,'String',handles.ChannelName(k),'Units','normalized', ...
        'Position',[1.035 0.5],'Color',altColor(mod(i,2)+1,:),'FontSize',7,'HorizontalAlignment','right');
    
    % Initialize slider line
    if isfield(handles,'expt')  % Make compatible with DaqDataViewer
        if ~isempty(Thresholds)
            yTemp = Thresholds(k);
        else
            yTemp = rigdef.ExptDataViewer.DefaultThreshold;
        end
    else
        yTemp = rigdef.ExptDataViewer.DefaultThreshold;
    end
    
    hThresh(k) = line([0 handles.SweepDuration],[1 1].*yTemp,'Parent',hAxisTemp,'Color',[1 0.7 0.7],'LineStyle','-', ...
        'Visible','off','ButtonDownFcn','');
    
    if showAllYAxes
        set(hAxisTemp, 'YTickLabelMode', 'auto','YColor',[0.5 0.5 0.5]);
        set(get(hAxisTemp,'YLabel'),'String','','Units','normalized',...
            'Position',[-0.030 0.5]);
        % Put 2 ticks on y-axis
        setAxisTicks(hAxisTemp);
    else
        set(hAxisTemp, 'YTickLabel', []);
    end
    
    if i == nPlotOn         % Corresponds to bottom plot
        set(hAxisTemp,'XColor',[0.5 0.5 0.5],'XTickMode','auto','XTickLabelMode','auto');
        set(get(hAxisTemp,'XLabel'),'String','sec');
    end
                
    % If using tetrodes, color by tetrode
    if any(strcmp(Probe,{'16 Channel 2x2','16 Channel 4x1'}))
        if any(k == ChannelOrder(1:4) | k == ChannelOrder(9:12))
            set(hPlotLines(k),'Color',altColor(1,:));
            set(hRaster(k),'Color',altColor(1,:));
            set(hLabels(k),'Color',altColor(1,:));
        elseif any(k == ChannelOrder(5:8) | k == ChannelOrder(13:16))
            set(hPlotLines(k),'Color',altColor(2,:));
            set(hRaster(k),'Color',altColor(2,:));
            set(hLabels(k),'Color',altColor(2,:));
        end
    end
end

% Update handles struct
handles.hPlotLines = hPlotLines;
handles.hLabels = hLabels;
handles.hRaster = hRaster;
handles.hThresh = hThresh;

for i = 1:length(handles.hThresh)
    set(handles.hThresh(i),'ButtonDownFcn',{@startDragFcn,handles,get(handles.hThresh(i),'Parent'),i});
end

% For thresholding
set(handles.hDataViewer,'WindowButtonUpFcn',{@stopDragFcn,handles});

% Link axes properties
handles.linkAxes = linkprop([handles.hAllAxes, handles.barAxis],'XLim');
key = 'graphics_linkprop';
setappdata(handles.hAllAxes(1),key,handles.linkAxes);           % Store link object in first axis

% Set handles for all figure objects in DataViewer appdata
setappdata(handles.hDataViewer,'handlesPlot',[handles.hAllAxes; handles.hPlotLines; handles.hRaster]);


guidata(handles.hDataViewer,handles);

function startDragFcn(hObject, eventdata, handles, lineAxes, axInd)
set(handles.hDataViewer,'WindowButtonMotionFcn',{@draggingFcn,handles,lineAxes,axInd});

function draggingFcn(hObject, eventdata, handles, lineAxes, axInd)
pt = get(lineAxes,'CurrentPoint');
set(handles.hThresh(axInd),'Ydata',pt(3)*[1 1]);

function stopDragFcn(hObject, eventdata, handles)
% Get newest handles
handles = guidata(handles.hDataViewer);
set(handles.hDataViewer,'WindowButtonMotionFcn','');
% Update thresholds
for i = 1:length(handles.hThresh)
    handles = GetLineThreshValues(handles);
    guidata(handles.hDataViewer,handles);
end



