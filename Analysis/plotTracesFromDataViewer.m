function handles = plotTracesFromDataViewer(handles,matPosFlag)
%
%
%
%

% SRO  10/12/10

% Get experiment struct
expt = handles.expt;

if ~isfield(handles,'plotTracesFig')
    % Make new figure
    hFig = makeNewFig(handles);
else
    if ishandle(handles.plotTracesFig)
        hFig = handles.plotTracesFig;
    else
        % Make new figure
        hFig = makeNewFig(handles);
    end
end

set(hFig,'Position',[-1416 319 712 804])

% Try to delete previous axes
if matPosFlag == 2 || matPosFlag == 3
    try
        delete(handles.plotTracesAxNew{1});
    end
end
if matPosFlag == 1
    try
        delete(handles.plotTracesAxNew{2});
    end
    try
        delete(handles.plotTracesAxNew{3});
    end
end

try
    delete(handles.plotTracesAxNew{matPosFlag});
end

% Add experiment name bottom of figure
try
    delete(handles.plotTracesAnn)
end
handles.plotTracesAnn = addExptNameToFig(hFig,expt);

% Copy axes from DataViewer to figure
hAxNew = copyobj(handles.hAllAxes,hFig);
hBarAxNew = copyobj(handles.barAxis,hFig);

% Get updated plot vectors from DataViewer appdata
dvplot = getappdata(handles.hDataViewer,'dvplot');
dvOn = dvplot.pvOn;
nPlotOn = numel(dvplot.pvOn);

% Get channel order
ChannelOrder = getappdata(handles.hDataViewer,'ChannelOrder');

% Only keep axes that are on
deleteAx = setdiff(ChannelOrder,dvOn);
hAxNew(deleteAx) = [];

% Set position of axes
ncol = 1;
ind = ChannelOrder;
for i = 1:length(deleteAx)
    ind(ind == deleteAx(i)) = [];
end
ind(:,2) = 1:length(ind);
ind = sortrows(ind);
ind = ind(:,2)+1;
ind(end+1) = 1;
hAxNew(end+1) = hBarAxNew;
nrow = length(hAxNew);

% Set position
switch matPosFlag
    case 1
        params.matpos = [0.08 0 0.85 0.93];               % [left top width height]
    case 2
        params.matpos = [0.08 0 0.85 0.465];               % [left top width height]
    case 3
        params.matpos = [0.08 0.492 0.85 0.465];               % [left top width height]
end
params.figmargin = [0 0 0 0];                        % [left right top bottom]
params.matmargin = [0 0 0 0];                        % [left right top bottom]
params.cellmargin = [0 0 0.001 0];                   % [left right top bottom]

setaxesOnaxesmatrix(hAxNew,nrow,ncol,ind,params,hFig);

handles.plotTracesAxNew{matPosFlag} = hAxNew;
handles.plotTracesFig = hFig;


% --- Subfunctions --- %

function hFig = makeNewFig(handles)
hFig = portraitFigSetup;
currentTrace = getappdata(handles.hDataViewer,'currentTrace');
figText = ['Trace' currentTrace];
setappdata(hFig,'figText',figText);
setappdata(hFig,'expt',handles.expt);
addSaveFigTool(hFig);


