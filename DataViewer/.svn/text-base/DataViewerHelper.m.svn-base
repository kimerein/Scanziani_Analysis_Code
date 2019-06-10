function handles = DataViewerHelper(handles,dvMode)
% This function is called by both DataViewer (used during data acquisition)
% and ExptDataViewer (used to viewer data following acquisition).
%
%
%   Created: 4/3/10 - SRO
%   Modified: 7/7/10 - KR - lines instead of sliders for thresholding

% Set position of header panel
set(handles.hDataViewer,'Units','Pixels');
set(handles.headerPanel,'Position',[-0.005 0.965 1.01 0.035]);

% Set DataViewer handle as appdata
setappdata(handles.hDataViewer,'hDataViewer',handles.hDataViewer);

% Set rig defaults
RigDef = RigDefs;
handles.RigDef = RigDef;

% Make vector containing all axes handles (handles.hAllAxes)
for i = 1:length(handles.Channel)
    s = ['handles.hAllAxes(' num2str(i) ') = handles.axes' num2str(i) ';'];
    eval(s);
end

% Delete axes for inactive channels
if length(handles.hAllAxes) > handles.nActiveChannels
    try
        delete(handles.hAllAxes(handles.nActiveChannels+1:end));
    end
    handles.hAllAxes(handles.nActiveChannels+1:end) = [];
end

% Set on and off plot vectors (default is all active channels)
dvplot.pvOn = (1:handles.nActiveChannels)';
dvplot.pvOff = [];

% Set filter and threshold vectors (default is no filtering or threshold)
dvplot.lpvOn = []; 
dvplot.hpvOn = [];
dvplot.rvOn = [];
dvplot.rvOff = [];

% Set plot vectors as appdata in DataViewer
setappdata(handles.hDataViewer,'dvplot',dvplot)

% Initialize and open PlotChooser. The DataViewer handle is passed
% to PlotChooser, and vice versa.
guidata(handles.hDataViewer, handles);
switch dvMode
    case 'Daq'
        handles.hPlotChooser = PlotChooser('Visible','off',handles.hDataViewer);
        usePeakfinder = RigDef.DataViewer.UsePeakfinder;
        showAllYAxes = RigDef.DataViewer.ShowAllYAxes;
    case 'Expt'
        handles.hPlotChooser = ExptPlotChooser('Visible','off',handles.hDataViewer);
        usePeakfinder = RigDef.ExptDataViewer.UsePeakfinder;
        showAllYAxes = RigDef.ExptDataViewer.ShowAllYAxes;
end

% Must be above InitializeDataViewerPlots call
setappdata(handles.hDataViewer, 'showAllYAxes', showAllYAxes)

% WB -- set default for whether to use peakfinder algorithm or hard threshold
% and update the state of the button on dataviewer to default
setappdata(handles.hDataViewer, 'usePeakfinder', usePeakfinder);
states = {'Off', 'On'};
dvHandles = guidata(handles.hDataViewer);
set(dvHandles.togglePeakfinder,'State',states{usePeakfinder+1});

% Initialize plots
handles = InitializeDataViewerPlots(handles);

% WB -- set default for whether to show all Y axes on dataviewer plots
% this must be after initialize plots 
if ~strcmpi(get(dvHandles.toggleYAxes, 'State'), states{showAllYAxes+1})
    set(dvHandles.toggleYAxes, 'State', states{showAllYAxes+1});
end
% -----

% Initialize spikeHist and spikeMean

% Get slider values for spike detection
handles = GetLineThreshValues(handles);




