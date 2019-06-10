function h = onlineFR(dvHandles)
%
% INPUT
%   dvHandles: DataViewer handles
%
% OUTPUT
%   h: guidata for the FR figure
%
%   Created: SRO 4/30/10
%   Modified: SRO 5/10/10

% Rig defaults
rigdef = RigDefs;
h.FigDir = rigdef.Dir.FigOnline;   
h.FigType = 'FR';
h.ExptName = getappdata(dvHandles.hDaqCtlr,'ExptName');

% by default inherit 'showAllYAxes' status from dataviewer (which inherits
% from RigDefs)
showAllYAxes = getappdata(dvHandles.hDataViewer, 'showAllYAxes');

% Get updated plot vectors from DataViewer appdata
dvplot = getappdata(dvHandles.hDataViewer,'dvplot');
nPlotOn = numel(dvplot.pvOn);
h.nPlotOn = nPlotOn;

% Get channel order
ChannelOrder = getappdata(dvHandles.hDataViewer,'ChannelOrder');

% Get adjusted channel order
kv = ismember(ChannelOrder,dvplot.pvOn);
pvOnOrdered = ChannelOrder(kv);
RasterOn = ismember(pvOnOrdered,dvplot.rvOn);
RasterOn = pvOnOrdered(RasterOn);

% Get sweep length
temp = guidata(dvHandles.hDaqCtlr);
h.sweeplength = temp.aiparams.sweeplength;

% Set default windows for computing avg firing rate
h.windows = {[0 0.25] [0.25 2] [2 h.sweeplength]};  % Default values if 'cancel' is pushed

% Make figure
h.frFig = figure('Visible','off','Color',[1 1 1], ...
    'Position',[187  121  172  1023],'Name','Firing rate','NumberTitle','off');

% Modify toolbar and menu
removeToolbarButtons(h.frFig);
h.hSave = tb_saveFig(h.frFig);
h.hSaveDisp = tb_saveFigDisp(h.frFig);
h.hToggleYAxes = tb_addToolbarButton(h.frFig, 'file_save.png', 'toggle', @toggleYAxesButton_ClickedCallback);

% Make gui objects
h.headerPanel = uipanel('Parent',h.frFig,'Units','Normalized', ...
    'Position',[-0.005 0.965 1.01 0.035]);
h.resetButton = uicontrol('Parent',h.headerPanel,'Style','pushbutton','String','reset', ...
    'Units','normalized','Position',[0.02 0.15 0.25 0.65],'Tag','resetButton');
h.windowsButton = uicontrol('Parent',h.headerPanel,'Style','pushbutton','String','windows', ...
    'Units','normalized','Position',[0.3 0.15 0.25 0.65],'Tag','windowsButton');
h.newButton = uicontrol('Parent',h.headerPanel,'Style','pushbutton','String','new', ...
    'Units','normalized','Position',[0.58 0.15 0.25 0.65],'Tag','newButton');

% Make axes
margins = [0.25 0.15 0.042 0.035];

if showAllYAxes
    interAxisSpace = 0.005;
    axPos = dvAxesPosition(nPlotOn,margins, interAxisSpace); %WB FIXIT hardcoded interAxisSpace
else
    axPos = dvAxesPosition(nPlotOn,margins);
end

for i = 1:nPlotOn
    h.axs(i) = axes('Parent',h.frFig,'Visible','off');
    defaultAxes(h.axs(i),0.35,0.2);
    removeAxesLabels(h.axs(i));
end

% Initialize firing rate data
nWind = length(h.windows);
h.frData = cell(nPlotOn,nWind);
h.time = [];

% Make lines
colors = {[0.5 0.5 0.5] [0 0 1] [0 127/255 0]};
for m = 1:size(h.frData,1)
    for n = 1:size(h.frData,2)
        h.lines(m,n) = line('Parent',h.axs(m),'Color',colors{n},'Visible','off', ...
            'XData',[],'YData',h.frData{m,n},'Marker','o','MarkerFaceColor',colors{n}, ...
            'MarkerEdgeColor',colors{n},'LineStyle','none','MarkerSize',2);
    end
end

% Position axes
for i = 1:nPlotOn
    k = pvOnOrdered(i);
    set(h.axs(k),'Position',axPos{i});    
    if ~isempty(RasterOn) % must check if empty or "RasterOn(end)" will throw an error (since evals to RasterOn(0) )
        if k == RasterOn(end)
            AddAxesLabels(h.axs(k),'minutes','spikes/s')
        end
    end
end

% Make axes and lines visible
frOn(h,dvplot.rvOn)

% Add callbacks buttons
set(h.resetButton,'Callback',{@resetButton_Callback});
set(h.windowsButton,'Callback',{@windowsButton_Callback});
set(h.newButton,'Callback',{@newButton_Callback,dvHandles,h.frFig});

% sync 'toggle Y axes' button w/ rest 
states = {'Off', 'On'};
set(h.hToggleYAxes, 'State', states{showAllYAxes+1});

% Add ticks
for i = 1:nPlotOn
    if showAllYAxes
        % Put 2 ticks on y-axis
        setAxisTicks(h.axs(i));
    end
end

% Save guidata
guidata(h.frFig,h); 

% Make figure visible
set(h.frFig,'Visible','on'); pause(0.05)


% --- Subfunctions --- %

function frOn(h,k)
set(h.axs(k),'Visible','on')
set(h.lines(k,:),'Visible','on')

function newButton_Callback(hObject,eventdata,handles,figH)
% Added KR 6/30/10
% This callback remakes entire figure, so newly threshold-ed channels are included
% onlinePSTH queries DaqPlotChooser for channels with Threshold ON

% Close this figure
close(figH);
handles.fr=[];

% Remake figure
handles.fr = onlineFR(handles);
guidata(handles.hDataViewer,handles);

function resetButton_Callback(hObject,eventdata)
h = guidata(hObject);

% Initialize firing rate data
nWind = length(h.windows);
h.frData = cell(h.nPlotOn,nWind);
h.time = [];
for m = 1:size(h.frData,1)
    for n = 1:size(h.frData,2)
        % Update plot
        set(h.lines(m,n),'XData',h.time,'YData',h.frData{m,n});
    end     
end

guidata(h.frFig,h)

function windowsButton_Callback(hObject,eventdata)
h = guidata(hObject);

% Enter window for computing spike rate
prompt = {'Spontaneous window (s)','Stimulus window (s)','Off window (s)'};
answer = inputdlg(prompt,'Enter',1);
for i = 1:length(answer)
    h.windows{i} = str2num(answer{i});
end

resetButton_Callback(h.resetButton,eventdata)

guidata(hObject,h)

function toggleYAxesButton_ClickedCallback(hObject, eventdata)
h = guidata(hObject);
state = get(hObject, 'State');
showAllYAxes = strcmpi(state, 'on');    

for i = 2:h.nPlotOn   
    if showAllYAxes
        set(h.axs(i), 'YTickLabelMode', 'auto');        
    else
        set(h.axs(i), 'YTickLabel', []);
    end
end
