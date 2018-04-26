function orientationFig(expt,unitTag,fileInd,b,saveTag)
% function orientationFig(expt,unitTag,fileInd,b,saveTag)
%
% INPUT
%   expt: Experiment struct
%   unitTag: Tag of the form 'trode_assign', e.g 'T2_15'
%   fileInd: Vector of file indices to be included in analysis.
%   b: Flag structure with field b.save, b.print, b.pause, b.close

% Created: 5/13/10 - SRO
% Modified: 5/16/10 - SRO


if nargin < 4
    b.pause = 0;
    b.save = 0;
    b.print = 0;
    b.close = 0;
    saveTag = '';
end

% Rig defaults
rigdef = RigDefs;

% Set cond struct
cond = expt.analysis.orientation.cond;

% Set time window struct
w = expt.analysis.orientation.windows;

% Temporary color
if isempty(cond.color)
    cond.color = {[0.1 0.1 0.1],[1 0.25 0.25],[0 0 1],[1 0.5 0],[1 0 1],[0.3 0.3 0.3],[0.7 0.7 0.7]};
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
    saveTag = [unitTag '_Ori'];
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

% Get unit label
label = getUnitLabel(expt,trodeNum,unitInd);

% Get spikes from trode number and unit index
spikes = loadvar(fullfile(rigdef.Dir.Spikes,expt.sort.trode(trodeNum).spikesfile));

% Extract spikes for unit and files
spikes = filtspikes(spikes,0,'assigns',unitInd,'fileInd',fileInd);

if ~isempty(spikes.spiketimes)
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
    
    % % % Kluge for SRO_2010-06-11_M1
    % for i = 1:12
    %     stim.code{i} = [i i+12 i+24];
    % end
    
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
            switch label
                
                case {'multi-unit','FS multi-unit','axon multi-unit'}
                    h.r.l(m,n) = raster(cspikes(m,n),h.r.ax(m),1,0);
                otherwise
                    % Make last arg = 1 to plot bursts
                    h.r.l(m,n) = raster(cspikes(m,n),h.r.ax(m),1,0);
            end
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
    
<<<<<<< .mine
    % --- Make PSTH for each cspikes substruct
    for m = 1:size(cspikes,1)       % m is number of stimulus values
        h.psth.ax(m) = axes;
        for n = 1:size(cspikes,2)   % n is number of conditions
            [n_avg n_sem centers edges junk] = psth2sem(cspikes(m,n),50);
            h.psth.n(m,:,n) = n_avg;
            [h.psth.l(m,n) h.psth.sem(m,n)] = plotPsth2sem(n_avg,n_sem,centers,h.psth.ax(m));
%             [h.psth.l(m,n) temp h.psth.n(m,:,n) centers] = psth(cspikes(m,n),50,h.psth.ax(m),1);
        end
=======
% --- Make PSTH for each cspikes substruct
for m = 1:size(cspikes,1)       % m is number of stimulus values
    h.psth.ax(m) = axes;
    for n = 1:size(cspikes,2)   % n is number of conditions
        [n_avg n_sem centers edges junk] = psth2sem(cspikes(m,n),50);
        h.psth.n(m,:,n) = n_avg;
        [h.psth.l(m,n) h.psth.sem(m,n)] = plotPsth2sem(n_avg,n_sem,centers,h.psth.ax(m));
        %             [h.psth.l(m,n) temp h.psth.n(m,:,n) centers] = psth(cspikes(m,n),50,h.psth.ax(m),1);
>>>>>>> .r1072
    end
end
h.psth.ax = h.psth.ax';
    
<<<<<<< .mine
    % Add handles to appropriate condition field
    for n = 1:size(cspikes,2)
        h.(cond.tags{n}) = [h.(cond.tags{n}); h.psth.l(:,n); h.psth.sem(:,n)];
    end
    
=======
% Add handles to appropriate condition field
for n = 1:size(cspikes,2)
    h.(cond.tags{n}) = [h.(cond.tags{n}); h.psth.l(:,n); h.psth.sem(:,n)];
end
>>>>>>> .r1072
    % Set axes properties
    setRasterPSTHpos(h)
    hTemp = reshape(h.psth.ax,numel(h.psth.ax),1);
    ymax = setSameYmax(hTemp,15);
    for i = 1:length(h.psth.ax)
        addStimulusBar(h.psth.ax(i),[w.stim ymax],'',cond.color{1});
        if strcmp(cond.type,'led')
            addStimulusBar(h.psth.ax(i),[w.ledon ymax*0.97],'',red,1.5);
        end
    end
    removeInd = 1:length(hTemp);
    keepInd = ceil(length(hTemp)/2) + 1;
    removeAxesLabels(hTemp(setdiff(removeInd,keepInd)))
    defaultAxes(hTemp,0.25,0.15)
    
    % --- Compute average response as a function oriention
    [allfr nallfr] = computeResponseVsStimulus(spikes,stim,cond,w);
    
    % --- Make orientation tuning plots
    h.ori.ax = axes('Parent',h.fig); ylabel('spikes/s','FontSize',8)
    h.nori.ax = axes('Parent',h.fig);
    theta = stim.values';
    h.ori.l = plotOrientTuning(allfr.ledon,theta,h.ori.ax);
    h.nori.l = plotOrientTuning(nallfr.ledon,theta,h.nori.ax);
%       h.ori.l = plotOrientTuning(allfr.stim,theta,h.ori.ax);
%     h.nori.l = plotOrientTuning(nallfr.stim,theta,h.nori.ax);
    defaultAxes([h.ori.ax h.nori.ax],0.2,0.14);
    xlabel('orientation','FontSize',8)
    setTitle(h.ori.ax,'stim window',8);
    setTitle(h.nori.ax,'normalized',8);
    
    % Add handles to appropriate condition field
    for n = 1:size(cspikes,2)
        h.(cond.tags{n}) = [h.(cond.tags{n}); h.ori.l(:,n); h.nori.l(:,n)];
    end
    
    % --- Make polar plots
    polplots = {'stim','on'};
    for i = 1:length(polplots)
        win = polplots{i};
        temp = allfr.(win);
        temp(temp<0) = 0;
        [h.pol.(win).l, h.pol.(win).ax] = polarOrientTuning(temp,theta);
        set(get(gca,'Title'),'String',win,'Visible','on');
    end
    temp = nallfr.stim;
    temp(temp<0) = 0;
    [h.npol.l, h.npol.ax] = polarOrientTuning(temp,theta);
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
    computeWV = 0;
    if computeWV
        [avgwv xtime maxch] = computeAvgSpikeWaveform(spikes,expt);
    else
        avgwv = [0 1; 0 1]; xtime = [0 1]; maxch = 1;
    end

    % Make axes
    h.avgwv.ax = axes('Parent',h.fig,'XLim',[0 max(xtime)]);
    % Plot
    h.avgwv.l = line('XData',xtime,'YData',avgwv(:,maxch),'Parent',h.avgwv.ax,...
        'Color',[0.2 0.2 0.2]);
    % Format plot
    defaultAxes(h.avgwv.ax,0.22,0.25);
    setSameYmax(h.avgwv.ax,2,1);
    xlabel('ms'); ylabel('mV');
    
    % --- Make autocorrelation plot
    h.autocorr.ax = axes;
    plotAutoCorr(spikes,h.autocorr.ax,50,1);
    defaultAxes(h.autocorr.ax,0.22,0.2)
    
    % --- Plot firing rate vs time
    h.frvt.ax = axes;
    h.frvt.l(1) = plotSpikesPerTrial(spikes,h.frvt.ax,0,w.stim);
    h.frvt.l(2) = plotSpikesPerTrial(spikes,h.frvt.ax,0,w.spont);
    defaultAxes(h.frvt.ax,0.22,0.14);
    xlabel('minutes','FontSize',8); ylabel('spikes/s','FontSize',8);
    set(h.frvt.l,'LineStyle','none','Marker','o','MarkerSize',0.75);
    set(h.frvt.l(2),'Color',[0 1 0]);
    set(h.frvt.l(1),'Color',[0 120/255 200/255]);
    
    % --- Plot average PSTH across all stimulus conditions
    h.allp.ax = axes;
    [h.allp.l h.allp.ax] = allStimPSTH(h.psth.n,centers,w,h.allp.ax);
    ymax = setSameYmax(h.allp.ax,15);
    addStimulusBar(h.allp.ax,[w.stim ymax]);
    if strcmp(cond.type,'led')
        addStimulusBar(h.allp.ax,[w.ledon ymax*0.97],'',red,1.5);
    end
    defaultAxes(h.allp.ax,0.22,0.14);
    
    % Add handles to appropriate condition field
    for n = 1:size(cspikes,2)
        h.(cond.tags{n}) = [h.(cond.tags{n}); h.allp.l(:,n)];
    end
    
    % --- Compute average firing rate (spontaneous, evoked, on-transient, off)
    for i = 1:length(cond.values)
        if strcmp(cond.type,'led')
            spikes.tempfield = spikes.led;
            spikes.tempfield = compareDouble(spikes.tempfield,cond.values{i});
            spikes.sweeps.tempfield = spikes.sweeps.led;
            spikes.sweeps.tempfield = compareDouble(spikes.sweeps.tempfield,cond.values{i});
            tempspikes = filtspikes(spikes,0,'tempfield',1);
            wnames = fieldnames(w);
        else
            tempspikes = filtspikes(spikes,0,cond.type,cond.values{i});
            wnames = fieldnames(w);
        end
        for n = 1:length(wnames)
            temp = wnames{n};
            [fr.(temp)(i,1) fr.(temp)(i,2)] = computeFR(tempspikes,w.(temp));  % average and SEM
        end
    end
    clear tempspikes
    
    % Make category plot for each time window
    for i = 1:length(wnames)
        temp = wnames{i};
        [h.avgfr.(temp).l junk h.avgfr.(temp).ax] = plotCategories(fr.(temp)(:,1),cond.tags,fr.(temp)(:,2),'',[],0);
        setTitle(gca,temp,7);
    end
    defaultAxes(h.avgfr.spont.ax,0.1,0.48);
    
    
    % Make category plot for blank stimulus
    params = expt.stimulus(fileInd(1)).params;
    if isfield(params,'addBlank')
        addBlank = params.addBlank;
    else
        addBlank = 0;
    end
    
    if addBlank
        bFR = computeBlankResponse(spikes,params,cond,expt);
        [h.blank.l h.blank.ax] = plotCategories(bFR(:,1),cond.tags,bFR(:,2),'',[],0);
        setTitle(gca,'blank',7);
        set(gca,'Position',[.609 .059 .054 .104]);
    end
    
    
    
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
    %     h.mat(2).h(4) = h.pol.off.ax;
    
    h.mat(3).params.matpos = [0.67 0.68 0.25 0.31];
    h.mat(3).params.figmargin = [0 0 0 0];
    h.mat(3).params.matmargin = [0 0 0 0];
    h.mat(3).params.cellmargin = [0.03 0.03 0.05 0.05];
    h.mat(3).ncol = length(wnames)/2;
    h.mat(3).nrow = 2;
    for i = 1:length(wnames)
        h.mat(3).h(i) = h.avgfr.(wnames{i}).ax;
    end
    
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
    
    % --- Make info table
    temp = {expt.sort.trode(trodeNum).unit.assign};
    temp = cell2mat(temp);
%     k = find(temp == unitInd(1));
    k = find(temp == unitInd);
    unitLabel = expt.sort.trode(trodeNum).unit(k).label;
    depth = getUnitDepth(expt,unitTag,maxch,2);
    exptInfo = [unitTag ' ('  num2str(depth) ') ' unitLabel];
    h.textbox = annotation('textbox',[0 0 0.3 0.022],'String',exptInfo,...
        'EdgeColor','none','HorizontalAlignment','left','Interpreter',...
        'none','Color',[0.1 0.1 0.1],'FontSize',8,'FitBoxToText','on');
    set(h.textbox,'Position',[0.01 0.007 0.4 0.022]);
    
    % Add expt name
    h.Ann = addExptNameToFig(h.fig,expt);
    
    % Make figure visible
    set(h.fig,'Visible','on')
    
    if b.pause
        %     reply = input('Do you want to print? y/n [n]: ', 's');
        %     if isempty(reply)
        %         reply = 'n';
        %     end
        %     if strcmp(reply,'y')
        %         b.print = 1;
        %     end
        
        reply = input('Do you want to save? y/n [n]: ', 's');
        if isempty(reply)
            reply = 'n';
        end
        if strcmp(reply,'y')
            b.save = 1;
        end
    end
    
    % Save
    if b.save
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
    
    % Print
    if b.print
        print('-dwinc',h.fig)
        disp(['Printing' ' ' sname])
    end
    
    % Close
    if b.close
        close(h.fig)
    end
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






