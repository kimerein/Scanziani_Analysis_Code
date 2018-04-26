function overviewFig(expt,fileInd,b,handles)
% function overviewFig(expt,fileInd,b)
% INPUT
%   expt: expt struct
%   fileInd: Struct with file indices for each stimulus type; .overview,
%   .orientation, .contrast, .srf, .other
%   b: Struct with flags for saving, printing etc. (b.pause, b.save,
%   b.print, b.close)
%

% Created: 10/15/10 - SRO


if nargin < 4
    b.pause = 0;
    b.save = 0;
    b.print = 0;
    b.close = 0;
end

% Rig defaults
rigdef = RigDefs;

% Set cond struct
cond = expt.analysis.overview.cond;

% Set time window struct
w = expt.analysis.overview.windows;

% Temporary color
if isempty(cond.color)
    cond.color = {[0.1 0.1 0.1],[1 0.25 0.25],[0 0 1],[1 0 0],[1 0 1],[0.3 0.3 0.3],[0.7 0.7 0.7]};
end
gray = [0.6 0.6 0.6];
green = [0 1 0];
blue = [0 120/255 200/255];
red = [1 0.25 0.25];

% Figure layout
h.fig = portraitFigSetup;
set(h.fig,'Visible','off','Position',[469 113 855 988])

% Set expt struct as appdata
setappdata(h.fig,'expt',expt);
setappdata(h.fig,'figText','OverviewFig');

% Add save figure button
addSaveFigTool(h.fig);

% Load spikes from trodes 1-4 (these are the default trodes)
for i = 1:4
    temp = loadvar(fullfile(rigdef.Dir.Spikes,expt.sort.trode(i).spikesfile));
    % Set LED NaNs to 0 (led = NaN when led is not being used)
   
    temp.led(isnan(temp.led)) = 0;
    temp.sweeps.led(isnan(temp.sweeps.led)) = 0;
    % Add maxch for sorting spikes according to the channel they occurred on
    temp.maxch = addMaxChField(temp);
 
    s(i) = temp;
end

% Make 16-D spikes struct, where each dimension is a different electrode
% site. The index in s(ind) maps onto channel order, such that the first
% site on trode 1 is s(1). The channel this corresponds to will vary
% according to the probe used.
temp = s; clear s
ind = 1;
for m = 1:4     % Loop through trodes
    trodeInd = temp(m).info.trodeInd;
    sites = expt.probe.trode.sites{trodeInd};
    for n = 1:length(sites)     % Loop through sites on trode
        s(ind) = filtspikes(temp(m),0,'maxch',n);
        ind = ind + 1;
    end
end

% Add .time to spikes.sweeps
for i = 1:length(s)
    if ~isfield(s(i).sweeps,'time')
        s(i).sweeps = addTimeToSweeps(s(i).sweeps,expt,s(i));
    end
    % Add .time as dummy field spikes. Temp workaround
    s(i).time = zeros(size(s(i).spiketimes));
end


% Filter on files
for i = 1:length(s)
    s(i) = filtspikes(s(i),0,'fileInd',fileInd.overview);
end
    
% Get stimulus paramaters

% Set plots to be shown
plotType = {'lfp','frvt','psth','srf'};
srfFileInd = get(handles.srfFilesEdit,'String');
srfFileInd = str2num(srfFileInd);
if isempty(srfFileInd)
    plotType = plotType(1:3);
end


% --- Compute average LFP --- %

% Compute average raw trace
Fs = expt.files.Fs(1);
channels = expt.probe.channelorder + 1;  % Trigger channel offset +1
for j = 1:length(cond.values)
    if strcmp(cond.type,'led')
        % Add temp field to expt.sweeps
        expt.sweeps.temp = expt.sweeps.led;
        expt.sweeps.temp = compareDouble(expt.sweeps.temp,cond.values{j});
    elseif strcmp(cond.type,'all')
        expt.sweeps.temp = ones(size(expt.sweeps.fileInd));
    end
    % Choose which trials to use
    if ~isempty(fileInd.orientation)        % First try orientation
        avgFileInd = fileInd.orientation(2);
    elseif ~isempty(fileInd.contrast)       % Next try contrast
        avgFileInd = fileInd.contrast(2);
    else
        avgFileInd = fileInd.overview(2);
    end
    
    [avgData(:,:,j) xtime] = avg(expt,channels,0,'temp',1,'fileInd',avgFileInd);
end

% High-pass at 0.5 Hz
for i = 1:size(avgData,3)
    avgData(:,:,i) = filtdata(avgData(:,:,i),Fs,0.5,'high');
end

% % Low-pass at 200 Hz
% for i = 1:size(avgData,3)
%     avgData(:,:,i) = filtdata(avgData(:,:,i),Fs,200,'low');
% end

% Plot sweeps
channelOrder = channels - 1;
for m = 1:size(avgData,2) % m is the number of channels
    h.lfp.ax(channelOrder(m)) = axes;
    
    for n = 1:size(avgData,3)   % n is the number of conditions
        h.lfp.l(channelOrder(m),n) = line('XData',xtime,'YData',avgData(:,m,n),'Parent',h.lfp.ax(channelOrder(m)));
    end
end

% Add handles to appropriate condition field (e.g. h.off and h.on; these
% will contain all handles to lines for a particular condition, making it
% easy to change properties of all lines within a condition easily in one
% step).
for n = 1:size(avgData,3)
    h.(cond.tags{n}) = [];
    h.(cond.tags{n}) = [h.(cond.tags{n}); h.lfp.l(:,n)];
end

% Set axes properties
hTemp = reshape(h.lfp.ax,numel(h.lfp.ax),1);
for i = 1:length(hTemp)
    setAxisTicks(hTemp(i))
end
defaultAxes(hTemp,0.5,0.18)
ymax = setSameYmax(hTemp,30,1);

set(hTemp,'YColor',gray,'XColor',gray,'XLim',[0 1.25]);
% Remove axis ticks and labels from all but bottom plot
removeInd = 1:length(hTemp);
keepInd = 16;
removeAxesLabels(hTemp(setdiff(removeInd,keepInd)))
% Add axes labels
xlabel(hTemp(keepInd),'seconds')
ylabel(hTemp(keepInd),'mV')

% Stimulus and LED bar
for i = 1:length(h.lfp.ax)
    addStimulusBar(h.lfp.ax(i),[w.stim ymax*0.95],'',[0.3 0.3 0.3],1.5);
    if strcmp(cond.type,'led')
        addStimulusBar(h.lfp.ax(i),[w.ledon ymax*0.91],'',red,1.5);
    end
end

% --- Compute firing rate versus time --- %

for i = 1:length(s)
    h.frvt.ax(i) = axes;
    windows = {'spont','stim'};
    for n = 1:length(windows)
        wTemp =  expt.analysis.overview.windows.(windows{n});
        h.frvt.l(i,n) = plotSpikesPerTrial(s(i),h.frvt.ax(i),11,wTemp);
    end
    xlabel('trial','FontSize',8); ylabel('spikes/trial','FontSize',8);
end

% Set line markers
set(h.frvt.l,'LineStyle','none','Marker','o','MarkerSize',0.5);

% Add bars indicating where stimululi are given
analysisTypes = {'orientation','contrast','srf','other'};
analysisStr = {'ori','rg','srf',''};
barColor = {[0.2 0.2 0.2],[0.6 0.6 0.6]};
cInd = 0;
ymax = setSameYmax(h.frvt.ax(1),15);
for i = 1:length(analysisTypes)
    if ~isempty(fileInd.(analysisTypes{i}));
        xtime = getStimBlockTime(expt,fileInd.(analysisTypes{i}));
        cInd = cInd + 1;
        for t = 1:length(xtime)
            temp = barColor{mod(cInd-1,2)+1};
            addStimulusBar(h.frvt.ax(1),[xtime{t} ymax],analysisStr{i},temp,1.5);
        end
    end
end

% Set axes properties
hTemp = reshape(h.frvt.ax,numel(h.frvt.ax),1);
for i = 1:length(hTemp)
    setAxisTicks(hTemp(i))
end
defaultAxes(hTemp,0.5,0.13)
set(hTemp,'YColor',gray,'XColor',gray);
% Remove axis ticks and labels from all but bottom plot
rm.xl = 1;
rm.yl = 1;
rm.xtl = 1;
rm.ytl = 0;
removeAxesLabels(hTemp(1:15),rm)
% Add axes labels
xlabel(hTemp(16),'minutes')
ylabel(hTemp(16),'spikes/s')
% Set line colors
set(h.frvt.l(:,1),'Color',green)
set(h.frvt.l(:,2),'Color',blue)


% --- Compute PSTH --- %

for m = 1:length(s)
    h.psth.ax(m) = axes;
    for n = 1:length(cond.values)
        if strcmp(cond.type,'led')
            temp = makeTempField(s(m),'led',cond.values{n});
            temp = filtspikes(temp,0,'temp',1);
        elseif strcmp(cond.type,'all')
            temp = s(m);
        else
            temp = filtspikes(s(m),0,cond.type,cond.values{n});
        end
        h.psth.l(m,n) = psth(temp,25,h.psth.ax(m));
    end
end
h.psth.ax = h.psth.ax';

% Add handles to appropriate condition field
for n = 1:size(h.psth.l,2)
    h.(cond.tags{n}) = [h.(cond.tags{n}); h.psth.l(:,n)];
end

% Set PSTH axes properties
hTemp = reshape(h.psth.ax,numel(h.psth.ax),1);
for i = 1:length(h.psth.ax)
    ymax = setSameYmax(hTemp(i),25);
    setAxisTicks(hTemp(i));
    addStimulusBar(h.psth.ax(i),[w.stim ymax*0.95],'',[0.3 0.3 0.3],1.5);
    if strcmp(cond.type,'led')
        addStimulusBar(h.psth.ax(i),[w.ledon ymax*0.91],'',red,1.5);
    end
end

% Remove labels but leave ticks on y-axis
rm.xl = 1;
rm.yl = 1;
rm.xtl = 1;
rm.ytl = 0;
removeAxesLabels(hTemp(1:15),rm)
defaultAxes(hTemp,0.5,0.12)
set(hTemp,'YColor',gray,'XColor',gray);
% Set line thickness
set(h.psth.l,'LineWidth',1.25)

% --- Compute average spontaneous and evoked rate --- %
psthXdata = get(h.psth.l(1,1),'XData');
spontPts = psthXdata >= w.spont(1) & psthXdata <= w.spont(2);
stimPts = psthXdata >= w.stim(1) & psthXdata <= w.stim(2);
for m = 1:size(h.psth.l,1) % Channels
    temp = get(h.psth.l(m,1),'YData');
    spontR(m) = mean(temp(spontPts));
    stimR(m) = mean(temp(stimPts));
end

% Normalize response
stimR = stimR - spontR;
stimR = stimR/max(max(stimR));
spontR = spontR/max(max(spontR));

for i = 1:length(stimR)
    h.bar.ax(i) = axes('Parent',h.fig,'Visible','off');
    h.bar.l(i,2) = line('XData',[0 0],'YData',[0 stimR(i)],'Parent',h.bar.ax(i));
    h.bar.l(i,1) = line('XData',[0.37 0.37],'YData',[0 spontR(i)],'Parent',h.bar.ax(i));
end

% Set limits
set(h.bar.ax,'YLim',[0 1]); set(h.bar.ax,'XLim',[-0.5 1.5]);

% Set color and thicknes
set(h.bar.l(:,2),'Color',blue);
set(h.bar.l(:,1),'Color',green);
set(h.bar.l,'LineWidth',3.75);


% --- Compute SRF --- %
srfFileInd = get(handles.srfFilesEdit,'String');
srfFileInd = str2num(srfFileInd);

if ~isempty(srfFileInd)
    for i = 1:length(s)
        h.srf.ax(i) = axes;
        h.srf.im(i) = computeSRF(s(i),expt,srfFileInd,h.srf.ax(i));
    end
end

% --- Format figure --- %
leftMargin = 0.08;
rightMargin = 0.02;
topMargin = 0.015;
bottomMargin = 0.05;
interColumnSpace = 0.05;

% Make position matrices for 4 types of plots
columnWidth = (1-leftMargin-rightMargin-3*interColumnSpace)/4 + 0.03;
columnHeight = 1-topMargin-bottomMargin;
% plotType = {'lfp','frvt','psth','srf'};
for i = 1:length(plotType)
    left = leftMargin + (i-1)*(columnWidth+interColumnSpace);
    pos = [left topMargin columnWidth columnHeight];
    h.(plotType{i}).params.matpos = pos;            % [left top width height]
    h.(plotType{i}).params.figmargin = [0 0 0 0];   % [left right top bottom]
    h.(plotType{i}).params.matmargin = [0 0 0 0];   % [left right top bottom]
    h.(plotType{i}).params.cellmargin = [0 0 0.01 0.01];  % [left right top bottom]
    
    if strcmp(plotType{i},'srf')
        h.(plotType{i}).params.matpos(1) = h.(plotType{i}).params.matpos(1)-0.087;
    end
    
end


% Set position of bar graph
h.bar.params.matpos(1) = h.psth.params.matpos(1) + h.psth.params.matpos(3);
h.bar.params.matpos(2) = h.psth.params.matpos(2);
h.bar.params.matpos(4) = h.psth.params.matpos(4);
h.bar.params.matpos(3) = 0.05;
h.bar.params.figmargin = [0 0 0 0];   % [left right top bottom]
h.bar.params.matmargin = [0 0 0 0];   % [left right top bottom]
h.bar.params.cellmargin = [0 0 0.01 0.01];  % [left right top bottom]
plotType{end+1} = 'bar';

% Position axes
for i = 1:length(plotType)
    nrow = length(h.(plotType{i}).ax);
    ncol = 1;
    ind = 1:length(h.(plotType{i}).ax);
    setaxesOnaxesmatrix(h.(plotType{i}).ax,nrow,ncol,ind,h.(plotType{i}).params);
end

% Set colors
for i = 1:length(cond.tags)
    set(h.(cond.tags{i}),'Color',cond.color{i})
end

colormap gray

% Add channel number annotation
chOrder = expt.probe.channelorder;
xpos = 0.989;
for i = 1:length(chOrder)
    ypos = (1-0.02) - (i-1)*(1-topMargin-bottomMargin)/length(chOrder);
    str = strvcat(['Ch' num2str(chOrder(i))],num2str(expt.probe.sitedepth(i),4));
    h.ch.text(i) = addText(h.fig,[xpos ypos],str);
end

set(h.ch.text,'Color',[0.4 0.4 0.4]);

% Add expt name
h.Ann = addExptNameToFig(h.fig,expt);

% Make figure visible
set(h.fig,'Visible','on')


% Save
if b.save
    sdir = [rigdef.Dir.Fig expt.name '\'];
    if ~isdir(sdir)
        mkdir(sdir);
    end
    sname = [sdir expt.name '_OverviewFig'];
    disp(['Saving' ' ' sname])
    saveas(h.fig,sname,'pdf')
    saveas(h.fig,sname,'fig')
    saveas(h.fig,sname,'epsc')
    sname = [sname '.epsc'];
    temp = sname;
    export_fig temp
end


% --- Subfunctions --- %

function xtime = getStimBlockTime(expt,fileInd)

temp = diff(fileInd);
k = find(temp > 1);
if isempty(k)
    startInd = fileInd(1);
    endInd = fileInd(end);
else
    for i = 1:length(k)
        if i == 1
            startInd(i) = fileInd(1);
        else
            startInd(i) = fileInd(k(i+1));
        end
        endInd(i) = fileInd(k(i));
    end
end

for i = 1:length(startInd)
    sw = filtsweeps(expt.sweeps,0,'fileInd',startInd(i):endInd(i));
    xtime{i} = [min(sw.time) max(sw.time)];
end



function h = computeSRF(spikes,expt,fileInd,hAxis)

if nargin < 4
    hAxis = axes;
end

% Set stimulus struct
stimulus = expt.stimulus(fileInd(1));

% Set params struct for first file
params = expt.stimulus(fileInd(1)).params;

% Determine number of rows and columns
nrows = params.rows;
ncols = params.columns;
nloc = nrows*ncols;

% Determine number of orientations
nori = length(params.oriValues);

% Determine number of contrasts
ncontrast = length(params.contrastValues);

% Determine number of stimuli
nstim = nrows*ncols*nori*ncontrast;

% Predefine vector for holding number of spikes
nspikes = zeros(nloc,1);

% Compute total number of spikes for each location
for i = 1:nstim
    locInd = mod(i-1,nloc)+1;
    temp = filtspikes(spikes,0,'stimcond',i);
    nspikes(locInd) = nspikes(locInd) + length(temp.spiketimes);
end

nspikes = reshape(nspikes,nrows,ncols);

% Make intensity plot
h = imagesc(nspikes,[min(min(nspikes)) max(max(nspikes))]);

% Remove axes, add box
removeAxesLabels(hAxis)
set(hAxis,'XTick',[],'YTick',[]);
set(hAxis,'box','on')

% Make SRF cdata map have square aspect ratio
set(hAxis,'PlotBoxAspectRatio',[ncols nrows 1])








