function unitTuningFigNew(expt,unitTag,fileInd,b)
% function unitTuningFigNew(expt,unitTag,fileInd,b)
%
% INPUT
%   expt: Experiment struct
%   unitTag:
%   fileInd: Vector of file indices to be included in analysis.
%   cond: **** Need to add this ****
%       - cond.type: String with condition for filtering spikes struct( e.g. 'led','hM4D', etc)
%       - cond.value: List of values for filtering spikes struct
%   b: Flag structure with field b.save, b.print, b.pause, b.close

% Created: 5/13/10 - SRO
% Modified: 5/16/10 - SRO


if nargin < 4
    b.pause = 0;
    b.save = 0;
    b.print = 0;
    b.close = 0;
end

% Rig defaults
rigdef = RigDefs;

% Set cond struct
cond = expt.analysis.orientation.cond;

% Set time window struct
w = expt.analysis.orientation.windows;

% Temporary color
if isempty(cond.color)
    cond.color = {[0 0 1],[1 0 0],[0 1 0],[1 0 1],[0.3 0.3 0.3]};
end

% Figure layout
h.fig = landscapeFigSetup;
set(h.fig,'Visible','off','Position',[792 399 1056 724])

% Get tetrode number and unit index from unit tag
loc = strfind(unitTag,'_');
trodeNum = str2num(unitTag(loc-1));
unitInd = str2num(unitTag(loc+1:end));

% Get spikes from tetrode number and unit index
load(fullfile(rigdef.Dir.Spikes,expt.sort.trode(trodeNum).spikesfile))

% Extract spikes for unit and files
spikes = filtspikes(spikes,0,'assigns',unitInd,'fileInd',fileInd);

% Get stimulus parameters
varparam = expt.stimulus(fileInd(1)).varparam(1);
stim.type = varparam.Name;
stim.values = expt.stimulus(fileInd(1)).params.oriValues;

for i = 1:length(stim.values)
    stim.code{i} = i;
end

% % Kluge for SRO_2010-05-06_M1D990
% vals = 1:3:3*length(stim.values);
% for i = 1:length(vals)
%     stim.code{i} = vals(i):vals(i)+2;
% end

% % Kluge for SRO_2010-05-06_M1D990
% vals = 1:12;
% for i = 1:length(vals)
%     stim.code{i} = [vals(i) vals(i)+8 vals(i)+16];
% end

% If using all trials
if strcmp(cond.type,'all')
    spikes.all = ones(size(spikes.spiketimes));
    cond.values = {1};
end

% Make spikes substruct for each stimulus value and condition value
for m = 1:length(stim.values)
    for n = 1:length(cond.values)
        cspikes(m,n) = filtspikes(spikes,0,'stimcond',stim.code{m},cond.type,cond.values{n});
    end
end

% --- Make raster plot for each cspikes substruct
for m = 1:size(cspikes,1)       % m is number of stimulus values
    h.r.ax(m) = axes;
    defaultAxes(h.r.ax(m));    
    for n = 1:size(cspikes,2)   % n is number of conditions
        h.r.l(m,n) = raster(cspikes(m,n),h.r.ax(m),1);
    end
end
h.r.ax = h.r.ax';
set(h.r.ax,'Box','on')

% Add handles to appropriate condition field
for n = 1:size(cspikes,2)
    h.(cond.tags{n}) = [];
    h.(cond.tags{n}) = [h.(cond.tags{n}); h.r.l(:,n)];
end

% Set axes properties
hTemp = reshape(h.r.ax,numel(h.r.ax),1);
ymax = setSameYmax(hTemp);
removeAxesLabels(hTemp)
defaultAxes(hTemp)
gray = [0.85 0.85 0.85];
set(hTemp,'YColor',gray,'XColor',gray,'XTick',[],'YTick',[]);

% Set stimulus condition as title
for i = 1:length(stim.values)
    temp{i} = round(stim.values(i));
end
set(cell2mat(get(h.r.ax,'Title')),{'String'},temp','Position',[1 0 1]);  %'Position',[1.4983 0 1]

% --- Make PSTH for each cspikes substruct
for m = 1:size(cspikes,1)
    h.psth.ax(m) = axes;
    for n = 1:size(cspikes,2)
        [h.psth.l(m,n)] = psth(cspikes(m,n),50,h.psth.ax(m),1);
    end
end
h.psth.ax = h.psth.ax';

% Add handles to appropriate condition field
for n = 1:size(cspikes,2)
    h.(cond.tags{n}) = [h.(cond.tags{n}); h.psth.l(:,n)];
end

% Set axes properties
setRasterPSTHpos(h)
hTemp = reshape(h.psth.ax,numel(h.psth.ax),1);
ymax = setSameYmax(hTemp,15);
for i = 1:length(h.psth.ax)
    addStimulusBar(h.psth.ax(i),[w.stim ymax]);
end
removeInd = 1:length(hTemp);
keepInd = ceil(length(hTemp)/2) + 1;
removeAxesLabels(hTemp(setdiff(removeInd,keepInd)))
defaultAxes(hTemp,0.25,0.1)

% --- Compute average response as a function oriention
[allfr nallfr] = computeResponseVsStimulus(spikes,stim,cond,w);

% --- Make orientation tuning plots
h.ori.ax = axes('Parent',h.fig); ylabel('spikes/s','FontSize',8)
h.nori.ax = axes('Parent',h.fig); 
theta = stim.values';
h.ori.l = plotOrientTuning(allfr.stim,theta,h.ori.ax);
h.nori.l = plotOrientTuning(nallfr.stim,theta,h.nori.ax);
defaultAxes([h.ori.ax h.nori.ax],0.18,0.1);
xlabel('orientation','FontSize',8)
setTitle(h.ori.ax,'stim window',8); 
setTitle(h.nori.ax,'normalized',8); 

% Add handles to appropriate condition field
for n = 1:size(cspikes,2)
    h.(cond.tags{n}) = [h.(cond.tags{n}); h.ori.l(:,n); h.nori.l(:,n)];
end

% --- Make polar plots
polplots = {'stim','on','off'};
for i = 1:length(polplots)
    win = polplots{i};
    [h.pol.(win).l, h.pol.(win).ax] = polarOrientTuning(allfr.(win),theta);
    set(get(gca,'Title'),'String',win,'Visible','on');
end
[h.npol.l, h.npol.ax] = polarOrientTuning(nallfr.stim,theta); 
set(get(gca,'Title'),'String','norm','Visible','on');

% Add handles to appropriate condition field
for n = 1:size(cspikes,2)
    for i = 1:length(polplots)
        win = polplots{i};
        h.(cond.tags{n}) = [h.(cond.tags{n}); h.pol.(win).l(n)];
    end
    h.(cond.tags{n}) = [h.(cond.tags{n}); h.npol.l(n)];
end

% --- Compute average waveform
[h.avgwv.l h.avgwv.ax] = plotAvgWaveform(spikes);
axis off

% --- Make autocorrelation plot
h.autocorr.ax = axes;
axis off

% --- Plot firing rate vs time
[h.frvt.l h.frvt.ax] = plotSpikesPerTrial(spikes,[],0);
defaultAxes(h.frvt.ax,0.22,0.14);
xlabel('trial','FontSize',8); ylabel('spikes/trial','FontSize',8);

% --- Plot average PSTH across all stimulus conditions
[h.allp.l h.allp.ax] = allStimPSTH(spikes,cond.type,cond.values,w);
defaultAxes(h.allp.ax,0.22,0.12);

% Add handles to appropriate condition field
for n = 1:size(cspikes,2)
    h.(cond.tags{n}) = [h.(cond.tags{n}); h.allp.l(:,n)];
end

% --- Compute average firing rate (spontaneous, evoked, on-transient, off)
for i = 1:length(cond.values)
    tempspikes = filtspikes(spikes,0,cond.type,cond.values{i});
    wnames = fieldnames(w);
    for n = 1:length(wnames)
        temp = wnames{n};
        fr.(temp)(i) = computeFR(tempspikes,w.(temp));
    end
end
clear tempspikes

% Make category plot for each time window
for i = 1:length(wnames)
    temp = wnames{i};
    [h.avgfr.(temp).l h.avgfr.(temp).ax] = plotCategories(fr.(temp),cond.tags,'');
    setTitle(gca,temp,7);
end
defaultAxes(h.avgfr.spont.ax,0.1,0.48);

% --- Define locations in respective axes matrix
h.mat(1).params.matpos = [0 0.68 0.49 0.35];                % [left top width height]
h.mat(1).params.figmargin = [0.00 0 0 0.05];                % [left right top bottom]
h.mat(1).params.matmargin = [0 0 0 0];                      % [left right top bottom]
h.mat(1).params.cellmargin = [0.05 0.035 0.05 0.05];        % [left right top bottom]
h.mat(1).ncol = 3;
h.mat(1).nrow = 2;
h.mat(1).h(1) = h.autocorr.ax;
h.mat(1).h(2) = h.frvt.ax;
h.mat(1).h(3) = h.ori.ax;
h.mat(1).h(4) = h.avgwv.ax;
h.mat(1).h(5) = h.allp.ax;
h.mat(1).h(6) = h.nori.ax;

h.mat(2).params.matpos = [0.49 0.68 0.18 0.28];
h.mat(2).params.figmargin = [0 0 0 0];
h.mat(2).params.matmargin = [0 0 0 0];
h.mat(2).params.cellmargin = [0.03 0.03 0.02 0.02];
h.mat(2).ncol = 2;
h.mat(2).nrow = 2;
h.mat(2).h(1) = h.pol.stim.ax;
h.mat(2).h(2) = h.pol.on.ax;
h.mat(2).h(3) = h.npol.ax;
h.mat(2).h(4) = h.pol.off.ax;

h.mat(3).params.matpos = [0.67 0.68 0.15 0.31];
h.mat(3).params.figmargin = [0 0 0 0];
h.mat(3).params.matmargin = [0 0 0 0];
h.mat(3).params.cellmargin = [0.03 0.03 0.05 0.05];
h.mat(3).ncol = 2;
h.mat(3).nrow = 2;
h.mat(3).h(1) = h.avgfr.spont.ax;
h.mat(3).h(2) = h.avgfr.stim.ax;
h.mat(3).h(3) = h.avgfr.on.ax;
h.mat(3).h(4) = h.avgfr.off.ax;

% --- Place axes on axesmatrix
for i = 1:length(h.mat)
    ind = 1:length(h.mat(i).h);
    setaxesOnaxesmatrix(h.mat(i).h,h.mat(i).nrow,h.mat(i).ncol,ind, ...
        h.mat(i).params,h.fig);   
end

% --- Set colors
for i = 1:length(cond.tags)
    set(h.(cond.tags{i}),'Color',cond.color{i})
end


% --- Display unit tags
ind = findstr(expt.name,'_');
ann = [expt.name((max(ind)+1):end) ' ' unitTag];
hText = annotation('textbox',[0.8 0 0.2 0.05],'String',ann,...
    'EdgeColor','none','HorizontalAlignment','right','Interpreter',...
    'none','Color',[0.2 0.2 0.2],'FontSize',9);

% --- Make info table


% Make figure visible
set(h.fig,'Visible','on')

if b.pause
    reply = input('Do you want to print? y/n [n]: ', 's');
    if isempty(reply)
        reply = 'n';
    end
    if strcmp(reply,'y')
        b.print = 1;
    end
end

sname = [rigdef.Dir.Fig expt.name((max(ind)+1):end) '_' unitTag '_Ori'];
if b.save  
    disp(['Saving' ' ' sname])
    saveas(h.fig,sname,'pdf')
    saveas(h.fig,sname,'fig') 
end

if b.print
    print('-dwinc',h.fig)
    disp(['Printing' ' ' sname])
end

if b.close
    close(h.fig)
end



% --- Subfunctions --- %

function setRasterPSTHpos(h)

nstim = length(h.r.ax);
ncol = ceil(nstim/2);
rrelsize = 0.65;                      % Relative size PSTH to raster
prelsize = 1-rrelsize;

% Set matrix position
margins = [0.05 0.02 0.05 0.005];
matpos = [margins(1) 1-margins(2) 0.37 1-margins(4)];  % Normalized [left right bottom top]

% Set space between plots
s1 = 0.003;
s2 = 0.035;
s3 = 0.02;

% Compute heights
rowheight = (matpos(4) - matpos(3))/2;
pheight = (rowheight-s1-s2)*prelsize;
rheight = (rowheight-s1-s2)*rrelsize;

% Compute width
width = (matpos(2)-matpos(1)-(ncol-1)*s3)/ncol;

% Row positions
p1bottom = matpos(3) + rowheight;
p2bottom = matpos(3);
r1bottom = p1bottom + pheight + s1;
r2bottom = p2bottom + pheight + s1;

% Compute complete positions
for i = 1:nstim
    if i <= ncol
        col = matpos(1)+(width+s3)*(i-1);
        p{i} = [col p1bottom width pheight];
        r{i} = [col r1bottom width rheight];
    elseif i > ncol
        col = matpos(1)+(width+s3)*(i-1-ncol);
        p{i} = [col p2bottom width pheight];
        r{i} = [col r2bottom width rheight];
    end
end

% Set positions
set([h.psth.ax; h.r.ax],'Units','normalized')
set(h.psth.ax,{'Position'},p')
set(h.r.ax,{'Position'},r')






