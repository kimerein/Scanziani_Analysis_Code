function h = onlineSRF(dvHandles)
% function onlineSRF()
% Creates a figure for computing and displaying spatial receptive fields
% online.
%
%
% INPUT
%   dvHandles: DataViewer handles
%
% OUTPUT
%   h: guidata for the LFP figure

% Created: 6/4/10 - SRO
% Modified: 7/21/10 - SRO

% Rig defaults
rigdef = RigDefs;
h.FigDir = rigdef.Dir.FigOnline;
h.FigType = 'SRF';
h.ExptName = getappdata(dvHandles.hDaqCtlr,'ExptName');

% Set matrix size (currently hard-coded)
% h.matrix = [7 11];
% h.matrix = [5 8];
h.matrix = [3 4];

% Get updated plot vectors from DataViewer appdata
h.hDataViewer = dvHandles.hDataViewer;
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

% Make figure
h.srfFig = figure('Visible','off','Color',[1 1 1], ...
    'Position',[8 121 172 1023],'Name','Spatial RF','NumberTitle','off');

% Modify toolbar and menu
removeToolbarButtons(h.srfFig);
h.hSave = tb_saveFig(h.srfFig);
h.hSaveDisp = tb_saveFigDisp(h.srfFig);

% Make gui objects
h.headerPanel = uipanel('Parent',h.srfFig,'Units','Normalized', ...
    'Position',[-0.005 0.965 1.01 0.035]);
h.resetButton = uicontrol('Parent',h.headerPanel,'Style','pushbutton','String','reset', ...
    'Units','normalized','Position',[0.02 0.15 0.25 0.65],'Tag','resetButton');
h.matrixButton = uicontrol('Parent',h.headerPanel,'Style','pushbutton','String','window', ...
    'Units','normalized','Position',[0.3 0.15 0.35 0.65],'Tag','matrixButton');

% Make axes
margins = [0.25 0.15 0.042 0.035];
axPos = dvAxesPosition(nPlotOn,margins);
for i = 1:nPlotOn  %
    h.axs(i) = axes('Parent',h.srfFig,'Visible','off','YDir','reverse',...
        'Box','on','XTick',[],'YTick',[],'YLim',[0.49 (h.matrix(1))+0.51],...
        'XLim',[0.49 (h.matrix(2))+0.51]);
    defaultAxes(h.axs(i),0.35,0.2);
    removeAxesLabels(h.axs(i));
end

% Initialize spatial receptive field data
h.srfData = cell(h.nPlotOn,1);
for i = 1:size(h.srfData,1)
    h.srfData{i} = zeros([h.matrix 3]);  % D1 = stimulus spikes; D2 = spont spikes; D3 = trials
end

% Make image object
for i = 1:size(h.srfData)
    h.images(i) = imagesc('Parent',h.axs(i),'CData',h.srfData{i}(:,:,1),...
        'Visible','off');
    colormap(gray)
end

% Position axes
for i = 1:nPlotOn
    k = pvOnOrdered(i);
    set(h.axs(k),'Position',axPos{i});
    if ~isempty(RasterOn)
        
    end
end

% Add callbacks to buttons
set(h.resetButton,'Callback',{@resetButton_Callback})
set(h.matrixButton,'Callback',{@windowButton_Callback})

% Make SRFs visible
srfOn(h,h.rvOn)

% Make figure visible
set(h.srfFig,'Visible','on')

% Save guidata
guidata(h.srfFig,h)

assignin('base','h',h)

% --- Subfunctions --- %

function srfOn(h,k)
set(h.axs(k),'Visible','on')
set(h.images(k),'Visible','on')

function resetButton_Callback(hObject,eventdata)
% Get guidata
h = guidata(hObject);
% Delete lines
delete(h.images)
% Initialize srfData
h.srfData = cell(h.nPlotOn);
for i = 1:size(h.srfData,1)
    h.srfData{i} = zeros([h.matrix 3]);
end
% Make images
for i = 1:size(h.srfData)
    h.images(i) = imagesc('Parent',h.axs(i),'CData',h.srfData{i}(:,:,1),...
        'Visible','off');
    colormap(gray)
%     axis tight
end
% set(h.axs,'CLim',[0 1]);
% Make SRFs visible
srfOn(h,h.rvOn)


guidata(h.srfFig,h)








