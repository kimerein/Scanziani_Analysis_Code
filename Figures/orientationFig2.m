function orientationFig2(expt,unitTag,manipulation,bSave,saveTag)
% function orientationFig2(expt,unitTag,manipulation,bSave,saveTag)
%
% INPUT
%   expt: Experiment struct
%   unitTag: Tag of the form 'trode_assign', e.g 'T2_15'
%   b: Flag structure with field b.save, b.print, b.pause, b.close

% Created: 5/13/10 - SRO
% Modified: 5/16/10 - SRO

if nargin < 4 || isempty(bSave)
    bSave = 0;
end

if nargin < 5 || isempty(saveTag)
    saveTag = '';
end


% Rig defaults
rigdef = RigDefs;

% Set fileInd
fileInd = expt.analysis.orientation.fileInd;

% Set cond struct
cond = expt.analysis.orientation.cond;

% Set time window struct
w = expt.analysis.orientation.windows;

% Temporary color
if isempty(cond.color)
    switch manipulation
        case 'L6_ChR2'
            cond.color = {[0 0 0] [0 0.5 1]};
        case 'L6_Arch'
            cond.color = {[0 0 0] [1 0.5 0]};
        otherwise
            cond.color = {[0 0 0] [1 0 0]};
    end
end
gray = [0.6 0.6 0.6];
green = [0 1 0];
blue = [0 120/255 200/255];
red = [1 0.25 0.25];

% Figure layout
h.fig = landscapeFigSetup;
set(h.fig,'Visible','off','Position',[792 399 1056 724])

% Set save name suffix (saveTag)
if isempty(saveTag)
    saveTag = [unitTag '_Ori2'];
else
    saveTag = [unitTag '_' saveTag];
end

% Set expt struct as appdata
setappdata(h.fig,'expt',expt);
setappdata(h.fig,'figText',saveTag);

% Add save figure button
addSaveFigTool(h.fig);

% Get tetrode number and unit index from unit tag
[trodeNum unitInd] = readUnitTag(unitTag);

% Get spikes from trode number and unit index
spikes = loadvar(fullfile(rigdef.Dir.Spikes,expt.sort.trode(trodeNum).spikesfile));

% Extract spikes for unit and files
% fileInd = 6:10;
spikes = filtspikes(spikes,0,'assigns',unitInd,'fileInd',fileInd);
% 
% Filter on running trials
k = expt.sweeps.runspeed > 0.1;
trials = expt.sweeps.trials(k);
spikes = filtspikes(spikes,0,'trials',trials);


% Set NaNs = 0
spikes.led(isnan(spikes.led)) = 0;
spikes.sweeps.led(isnan(spikes.sweeps.led)) = 0;

% Get stimulus parameters
varparam = expt.stimulus(fileInd(1)).varparam(1);
stim.type = varparam.Name;
if isfield(expt.stimulus(fileInd(1)).params,'oriValues')
    stim.values = expt.stimulus(fileInd(1)).params.oriValues;
else
    stim.values = varparam.Values;
end

for i = 1:length(stim.values)
    stim.code{i} = i;
end

% If using all trials
if strcmp(cond.type,'all')
    spikes.all = ones(size(spikes.spiketimes));
    cond.values = {1};
end

% % temp
% cond.tags = {'a' 'b'};
% cond.values = {[1.9 2] [2.2 2.8]};

% Make spikes substruct for each stimulus value and condition value
for m = 1:length(stim.values)
    for n = 1:length(cond.values)
        if strcmp(cond.type,'led')
            spikes = makeTempField(spikes,'led',cond.values{n});
            cspikes(m,n) = filtspikes(spikes,0,'stimcond',stim.code{m},'temp',1);
        else
            cspikes(m,n) = filtspikes(spikes,0,'stimcond',stim.code{m},cond.type,cond.values{n});
        end
    end
end

% --- Make raster plot for each cspikes substruct
for m = 1:size(cspikes,1)       % m is number of stimulus values
    h.r.ax(m) = axes;
    defaultAxes(h.r.ax(m));
    for n = 1:size(cspikes,2)   % n is number of conditions
        % Make last arg = 1 to plot bursts
        
        % Plot N trials (where N is lowest number of stimulus
        % presentations
        h.r.l(m,n) = raster(cspikes(m,n),h.r.ax(m),1,0);
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
for m = 1:size(cspikes,1)       % m is number of stimulus values
    h.psth.ax(m) = axes;
    for n = 1:size(cspikes,2)   % n is number of conditions
        [n_avg n_sem centers edges junk] = psth2sem(cspikes(m,n),50);
        h.psth.n(m,:,n) = n_avg;
        [h.psth.l(m,n) h.psth.sem(m,n)] = plotPsth2sem(n_avg,n_sem,centers,h.psth.ax(m));
        %             [h.psth.l(m,n) temp h.psth.n(m,:,n) centers] = psth(cspikes(m,n),50,h.psth.ax(m),1);
    end
end
h.psth.ax = h.psth.ax';

% Add handles to appropriate condition field
for n = 1:size(cspikes,2)
    h.(cond.tags{n}) = [h.(cond.tags{n}); h.psth.l(:,n); h.psth.sem(:,n)];
end

% Set axes properties
setRasterPSTHpos(h)
hTemp = reshape(h.psth.ax,numel(h.psth.ax),1);
ymax = setSameYmax(hTemp,15);
for i = 1:length(h.psth.ax)
    addStimulusBar(h.psth.ax(i),[w.stim ymax],'',cond.color{1});
    if strcmp(cond.type,'led')
        addStimulusBar(h.psth.ax(i),[w.ledon ymax*0.96],'',cond.color{2},1.5);
    end
end
removeInd = 1:length(hTemp);
keepInd = ceil(length(hTemp)/2) + 1;
removeAxesLabels(hTemp(setdiff(removeInd,keepInd)))
defaultAxes(hTemp,0.25,0.15)

% --- Compute average response as a function oriention
[allfr nallfr sem] = computeResponseVsStimulus(spikes,stim,cond,w);

switch manipulation
    case 'L6_ChR2'
        fr = allfr.ledon;
        sem = sem.ledon;
    case 'L6_Arch'
        fr = allfr.stim;
        sem = sem.ledon;
end

% Use linear fit to determine scaling factor
f = fittype('m*x');
options = fitoptions(f);
set(options,'StartPoint',0,'Upper',5,'Lower',0.01);
[cfun gof] = fit(fr(:,1),fr(:,2),f,options);
m = coeffvalues(cfun);

% Plot LED on vs off
hax(3) = axes('Parent',h.fig); defaultAxes(gca)
x = [0 max(max(fr))];
y = feval(cfun,x);
htmp = line('Parent',hax(3),'XData',x,'YData',y,'Color',cond.color{2});
x = fr(:,1); y = fr(:,2);
htmp = line('Parent',hax(3),'XData',x,'YData',y,'LineStyle','none',...
    'Marker','o','MarkerFaceColor',cond.color{2},'Color',cond.color{2});
addErrBar(x,y,sem(:,1),'x',hax(3),htmp);
addErrBar(x,y,sem(:,2),'y',hax(3),htmp);
lms = [min(min([0; x; y])) max(max([x; y]))*1.1];
xlim(lms); ylim(lms);
addUnityLine(hax(3));
xlabel('LED off'); ylabel('LED on');
set(hax(3),'Position',[0.5678    0.05    0.1747    0.2394]);


% Duplicate 0 deg response at 360 deg
fr(end+1,:) = fr(1,:);
sem(end+1,:) = sem(1,:);
theta = stim.values;
theta(end+1) = 360;

% Fit average tuning curve
clear cfun
for i = 1:size(fr,2)
    [s pori cfun{i}] = fitOriResponse2Gauss(fr(:,i),theta,0,0);
end

% Plot data and fit
hax(1) = axes('Parent',h.fig); defaultAxes(gca);
for i = 1:size(fr,2)
    x = (0:0.5:360)';
    y = feval(cfun{i},x);
% %     Uncomment to scale control fit
%         y = feval(cfun{1},x);
%         if i == 2
%             y = y*m;
%         end
    h1(i,1) = plotOrientTuning(y,x,hax(1));
    h1(i,2) = plotOrientTuning(fr(:,i),theta',hax(1));
    set(h1(i,2),'Marker','o','Line','none','Color',cond.color{i},'MarkerFaceColor',...
        cond.color{i},'MarkerSize',4);
    addErrBar(theta',fr(:,i),sem(:,i),'y',hax(1),h1(i,2));
end
setSameYmax(hax(1),5);
set(h1(2,:),'Color',cond.color{2});
set(hax(1),'Position',[0.0501    0.05    0.2166    0.2390]);
title('Fit ctrl and LED separately')

% Plot data and fit
hax(2) = axes('Parent',h.fig); defaultAxes(gca);
for i = 1:size(fr,2)
    x = (0:0.5:360)';
    y = feval(cfun{i},x);
    
%     Uncomment to scale control fit
        y = feval(cfun{1},x);
        if i == 2
            y = y*m;
        end
        
    h1(i,1) = plotOrientTuning(y,x,hax(2));
    h1(i,2) = plotOrientTuning(fr(:,i),theta',hax(2));
    set(h1(i,2),'Marker','o','Line','none','Color',cond.color{i},'MarkerFaceColor',...
        cond.color{i},'MarkerSize',4);
    addErrBar(theta',fr(:,i),sem(:,i),'y',hax(2),h1(i,2));
end
setSameYmax(hax(2),5);
set(h1(2,:),'Color',cond.color{2});
set(hax(2),'Position',[0.2878   0.05   0.2166    0.2390]);
title('Scale ctrl fit to get LED curve')

% Add handles to appropriate condition field
for n = 1:size(cspikes,2)
    h.(cond.tags{n}) = [h.(cond.tags{n})];
end

% --- Set colors
for i = 1:length(cond.tags)
    set(h.(cond.tags{i}),'Color',cond.color{i})
end

% Add expt name
h.Ann = addExptNameToFig(h.fig,expt);

% Make figure visible
set(h.fig,'Visible','on')

% Save
if bSave
    sdir = [rigdef.Dir.Fig expt.name '\'];
    if ~isdir(sdir)
        mkdir(sdir);
    end
    sname = [sdir expt.name '_' saveTag];
    disp(['Saving' ' ' sname])
    saveas(h.fig,sname,'pdf')
    saveas(h.fig,sname,'fig')
    saveas(h.fig,sname,'epsc')
    temp = sname;
    export_fig temp
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






