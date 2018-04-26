function h = onlinePSTH(dvHandles)
%
% INPUT
%   dvHandles: DataViewer handles
%
% OUTPUT
%   h: guidata for the PSTH figure
%
%   Created: SRO 4/30/10
%   Modified: KR 6/30/10

% Rig defaults
rigdef = RigDefs;
h.FigDir = rigdef.Dir.FigOnline;   
h.FigType = 'PSTH';
h.ExptName = getappdata(dvHandles.hDaqCtlr,'ExptName');

% by default inherit 'showAllYAxes' status from dataviewer (which inherits
% from RigDefs)
showAllYAxes = getappdata(dvHandles.hDataViewer, 'showAllYAxes');

% Get updated plot vectors from DataViewer appdata
dvplot = getappdata(dvHandles.hDataViewer,'dvplot');
nPlotOn = numel(dvplot.pvOn);
h.nPlotOn = nPlotOn;
h.rvOn = dvplot.rvOn;

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

% Compute bin size
h.binsize = 0.1;  % s
numEdges = ceil(h.sweeplength/h.binsize + 1);
h.edges = linspace(0,h.sweeplength,numEdges);
h.xloc = h.binsize/2:h.binsize:h.edges(end)-h.binsize/2;

% Make figure
h.psthFig = figure('Visible','off','Color',[1 1 1], ...
    'Position',[365 121 172 1023],'Name','PSTH','NumberTitle','off');

% Modify toolbar and menu
removeToolbarButtons(h.psthFig);
h.hSave = tb_saveFig(h.psthFig);
h.hSaveDisp = tb_saveFigDisp(h.psthFig);
h.hToggleYAxes = tb_addToolbarButton(h.psthFig, 'file_save.png', 'toggle', @toggleYAxesButton_ClickedCallback);

% Make gui objects
h.headerPanel = uipanel('Parent',h.psthFig,'Units','Normalized', ...
    'Position',[-0.005 0.965 1.01 0.035]);
h.resetButton = uicontrol('Parent',h.headerPanel,'Style','pushbutton','String','reset', ...
    'Units','normalized','Position',[0.02 0.15 0.25 0.65],'Tag','resetButton');
h.condButton = uicontrol('Parent',h.headerPanel,'Style','pushbutton','String','cond', ...
    'Units','normalized','Position',[0.3 0.15 0.25 0.65],'Tag','condButton');
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
    h.axs(i) = axes('Parent',h.psthFig,'Visible','off');
    defaultAxes(h.axs(i),0.35,0.2);
    removeAxesLabels(h.axs(i));
    xlim([0 h.sweeplength]);
end

% Initialize psthData
h.nCond = 1;
h.psthData = cell(h.nPlotOn,h.nCond);
for m = 1:size(h.psthData,1)
    for n = 1:size(h.psthData,2)
        h.psthData{m,n} = zeros(size(h.xloc))';
    end
end

% Initialize condition struct
h.cond.engage = 'off';
h.cond.type = '';
h.cond.value = [];

% Set colors for lines
h.colors{1} = [0 0 0];
h.colors{2} = [1 0 0];
h.colors{3} = [0 0 1];
h.colors{4} = [1 0 1];
h.colors{5} = [0 0.6 0];
h.colors{6} = [0.5 0.5 0.5];

% Make lines
for m = 1:size(h.psthData,1)
    for n = 1:size(h.psthData,2)
        tempColor = get(dvHandles.hPlotLines(m),'Color');
        h.lines(m,n) = line('Parent',h.axs(m),'Color',tempColor,'Visible','off', ...
            'XData',h.xloc,'YData',h.psthData{m,n});
    end
end

% Position axes
for i = 1:h.nPlotOn
    k = pvOnOrdered(i);
    set(h.axs(k),'Position',axPos{i});
    if ~isempty(RasterOn)
        if k == RasterOn(end)
            AddAxesLabels(h.axs(k),'sec','spikes/sec')
        end
    end
end

% Add callbacks to buttons
set(h.resetButton,'Callback',{@resetButton_Callback});
set(h.condButton,'Callback',{@condButton_Callback});
set(h.newButton,'Callback',{@newButton_Callback,dvHandles,h.psthFig});

% sync 'toggle Y axes' button w/ rest 
states = {'Off', 'On'};
set(h.hToggleYAxes, 'State', states{showAllYAxes+1});

% Initialize trial counter
h.trialcounter = zeros(size(h.psthData));

% Make PSTHs visible
psthOn(h,h.rvOn)

% Add ticks
for i = 1:nPlotOn
    if showAllYAxes
        % Put 2 ticks on y-axis
        setAxisTicks(h.axs(i));
    end
end

% Make figure visible
set(h.psthFig,'Visible','on');

% Save guidata
guidata(h.psthFig,h);



% --- Subfunctions --- %

function psthOn(h,k)
set(h.axs(k),'Visible','on')
set(h.lines(k,:),'Visible','on')

function newButton_Callback(hObject,eventdata,handles,psthFigH)
% Added KR 6/30/10
% This callback remakes entire figure, so newly threshold-ed channels are included
% onlinePSTH queries DaqPlotChooser for channels with Threshold ON

% Close this figure
close(psthFigH);
handles.psth=[];

% Remake figure
handles.psth = onlinePSTH(handles);
guidata(handles.hDataViewer,handles);

function resetButton_Callback(hObject,eventdata)
% Get guidata
h = guidata(hObject);
% Delete lines
delete(h.lines)
% Initialize psthData
h.psthData = cell(h.nPlotOn,h.nCond);
% Initialize lines
for m = 1:size(h.psthData,1)
    for n = 1:size(h.psthData,2)
        tempColor = h.colors{mod(n-1,length(h.colors))+1};
        h.lines(m,n) = line('Parent',h.axs(m),'Color',tempColor,'Visible','off', ...
            'XData',h.xloc,'YData',h.psthData{m,n});
    end
end
% Set data
for m = 1:size(h.psthData,1)
    for n = 1:size(h.psthData,2)
        h.psthData{m,n} = zeros(size(h.xloc))';
        set(h.lines(m,n),'XData',h.xloc,'YData',h.psthData{m,n});
    end
end
% Make PSTHs visible
psthOn(h,h.rvOn)

% Initialize trial counter
h.trialcounter = zeros(size(h.psthData));

guidata(h.psthFig,h)

function condButton_Callback(hObject,eventdata)
% Get guidata
h = guidata(hObject);

% Dialog to set conditions
prompt = {'led or stim','values'};
answer = inputdlg(prompt,'Enter',1);

% Set condition struct
h.cond.engage = 'on';
h.cond.type = answer{1};
h.cond.value = str2num(answer{2});

% Update psthData
h.nCond = length(h.cond.value);
h.psthData = cell(h.nPlotOn,h.nCond);

% Update lines
delete(h.lines)
for m = 1:size(h.psthData,1)
    for n = 1:size(h.psthData,2)
        tempColor = h.colors{mod(n-1,length(h.colors))+1};
        h.lines(m,n) = line('Parent',h.axs(m),'Color',tempColor,'Visible','off', ...
            'XData',h.xloc,'YData',h.psthData{m,n});
    end
end

% Initialize data in lines
for m = 1:size(h.psthData,1)
    for n = 1:size(h.psthData,2)
        h.psthData{m,n} = zeros(size(h.xloc))';
        set(h.lines(m,n),'XData',h.xloc,'YData',h.psthData{m,n});
    end
end

% Make PSTHs visible
psthOn(h,h.rvOn)

% Initialize trial counter
h.trialcounter = zeros(size(h.psthData));

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
