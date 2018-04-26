function srfFig(expt,unitTag,fileInd,b)
% function orientationFig(expt,unitTag,fileInd,b)
%
% INPUT
%   expt: Experiment struct
%   unitTag: Tag of the form 'trode_assign', e.g 'T2_15'
%   fileInd: Vector of file indices to be included in analysis.
%   b: Flag structure with field b.save, b.print, b.pause, b.close

% Created: 10/7/10 - SRO

if nargin < 4
    b.pause = 0;
    b.save = 0;
    b.print = 0;
    b.close = 0;
end

% Rig defaults
rigdef = RigDefs;

% Set cond struct
cond = expt.analysis.srf.cond;

% Set time window struct
w = expt.analysis.srf.windows;

% Temporary color
if isempty(cond.color)
    cond.color = {[0 0 1],[1 0 0],[0 1 0],[1 0 1],[0.3 0.3 0.3],[0.7 0.7 0.7]};
end

% Figure layout
h.fig = landscapeFigSetup;
set(h.fig,'Visible','off','Position',[792 399 1056 724])
colormap('gray')

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
    
    % Set stimulus parameters
    stimParams = expt.stimulus(fileInd(1)).params;
    ncol = stimParams.columns;
    nrow = stimParams.rows;
    numLoc = ncol*nrow;
    oriValues = stimParams.oriValues;
    stim.values = 1:numLoc*numel(oriValues);
    
    for i = 1:length(stim.values)
        stim.code{i} = i;
    end
    
    % If using all trials
    if strcmp(cond.type,'all')
        spikes.all = ones(size(spikes.spiketimes));
        cond.values = {1};
    end
    
    % Make spikes substruct for each stimulus code and condition value
    for m = 1:length(stim.code)
        for n = 1:length(cond.values)
            if strcmp(cond.type,'led')
                spikes.tempfield = spikes.led;
                spikes.tempfield = compareDouble(spikes.tempfield,cond.values{n});
                spikes.sweeps.tempfield = spikes.sweeps.led;
                spikes.sweeps.tempfield = compareDouble(spikes.sweeps.tempfield,cond.values{n});
                cspikes(m,n) = filtspikes(spikes,0,'stimcond',stim.code{m},'tempfield',1);
            else
                cspikes(m,n) = filtspikes(spikes,0,'stimcond',stim.code{m},cond.type,cond.values{n});
            end
        end
    end
    
    % --- Make raster plot for each stimulus location. Different
    % orientations and LED conditions will be plotted on same raster
    numRasters = size(cspikes,1)/length(oriValues);
    for m = 1:size(cspikes,1)       % m is number of stimulus codes (i.e. number of stimuli)
        if m <= numRasters;
            h.r.ax(m) = axes;
            defaultAxes(h.r.ax(m));
        end
        rhInd = mod(m-1,numLoc) + 1;
        for n = 1:size(cspikes,2)   % n is number of conditions
            h.r.l(m,n) = raster(cspikes(m,n),h.r.ax(rhInd),1);
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
            [h.psth.l(m,n) temp h.psth.n(m,:,n) centers] = psth(cspikes(m,n),50,h.psth.ax(m),1);
        end
    end
    h.psth.ax = h.psth.ax';
    
    % Add handles to appropriate condition field
    for n = 1:size(cspikes,2)
        h.(cond.tags{n}) = [h.(cond.tags{n}); h.psth.l(:,n)];
    end
    
    % Set axes properties
    setRasterPSTHpos(h,nrow,ncol)
    hTemp = reshape(h.psth.ax,numel(h.psth.ax),1);
    ymax = setSameYmax(hTemp,15);
    for i = 1:length(h.psth.ax)
        addStimulusBar(h.psth.ax(i),[w.stim ymax]);
        addStimulusBar(h.psth.ax(i),[w.led ymax*0.95],'',[1 0 0]);
    end
    removeInd = 1:length(hTemp);
    keepInd = sub2ind([nrow ncol],nrow,1);
    removeAxesLabels(hTemp(setdiff(removeInd,keepInd)))
    defaultAxes(hTemp,0.25,0.1)
    
    % --- Compute average response as a function of stimulus
    [allfr nallfr] = computeResponseVsStimulus(spikes,stim,cond,w);
    
    % --- Plot average response at spatial locations
    
    w_str = {'stim','led'};
    for m = 1:2
        for n = 1:length(cond.values)
            h.srf.ax(m,n) = axes;
            temp = w_str{m};
            temp_fr = nallfr.(temp)(:,n);
            temp_fr = reshape(temp_fr,nrow,ncol);
            h.srf.cdata(m,n) = imagesc(temp_fr);
%             putvar(h)
        end
    end
    removeAxesLabels(h.srf.ax(:,:));
    
    % --- Compute average waveform
    [h.avgwv.l h.avgwv.ax maxch] = plotAvgWaveform(spikes);
    set(h.avgwv.l,'Visible','off');
    axis off
    

%     % % --- Plot firing rate vs time
%     [h.frvt.l h.frvt.ax] = plotSpikesPerTrial(spikes,[],0);
%     defaultAxes(h.frvt.ax,0.22,0.14);
%     xlabel('trial','FontSize',8); ylabel('spikes/trial','FontSize',8);
%     
%     % --- Plot average PSTH across all stimulus conditions
%     h.allp.ax = axes;
%     [h.allp.l h.allp.ax] = allStimPSTH(h.psth.n,centers,w,h.allp.ax);
%     defaultAxes(h.allp.ax,0.22,0.12);
%     
%     % Add handles to appropriate condition field
%     for n = 1:size(cspikes,2)
%         h.(cond.tags{n}) = [h.(cond.tags{n}); h.allp.l(:,n)];
%     end
%     
%     % --- Compute average firing rate (spontaneous, evoked, on-transient, off)
%     for i = 1:length(cond.values)
%         if strcmp(cond.type,'led')
%             spikes.tempfield = spikes.led;
%             spikes.tempfield = compareDouble(spikes.tempfield,cond.values{i});
%             spikes.sweeps.tempfield = spikes.sweeps.led;
%             spikes.sweeps.tempfield = compareDouble(spikes.sweeps.tempfield,cond.values{i});
%             tempspikes = filtspikes(spikes,0,'tempfield',1);
%             wnames = fieldnames(w);
%         else
%             tempspikes = filtspikes(spikes,0,cond.type,cond.values{i});
%             wnames = fieldnames(w);
%         end
%         for n = 1:length(wnames)
%             temp = wnames{n};
%             fr.(temp)(i) = computeFR(tempspikes,w.(temp));
%         end
%     end
%     clear tempspikes
%     
%     % Make category plot for each time window
%     for i = 1:length(wnames)
%         temp = wnames{i};
%         [h.avgfr.(temp).l h.avgfr.(temp).ax] = plotCategories(fr.(temp),cond.tags,'');
%         setTitle(gca,temp,7);
%     end
%     defaultAxes(h.avgfr.spont.ax,0.1,0.48);
    
    % --- Define locations in respective axes matrix
    dummyAxes = axes('Visible','off');
    
    h.mat(1).params.matpos = [0.6 0 0.25 0.35];                % [left top width height]
    h.mat(1).params.figmargin = [0.00 0 0 0.05];                % [left right top bottom]
    h.mat(1).params.matmargin = [0 0 0 0];                      % [left right top bottom]
    h.mat(1).params.cellmargin = [0.05 0.035 0.05 0.05];        % [left right top bottom]
    h.mat(1).ncol = 2;
    h.mat(1).nrow = 2;
    h.mat(1).h(1) = h.srf.ax(1,1);
    h.mat(1).h(2) = h.srf.ax(1,2);
    h.mat(1).h(3) = h.srf.ax(2,1);
    h.mat(1).h(4) = h.srf.ax(2,2);

    
    h.mat(2).params.matpos = [0.49 0.68 0.18 0.28];
    h.mat(2).params.figmargin = [0 0 0 0];
    h.mat(2).params.matmargin = [0 0 0 0];
    h.mat(2).params.cellmargin = [0.03 0.03 0.02 0.02];
    h.mat(2).ncol = 2;
    h.mat(2).nrow = 2;
    h.mat(2).h(1) = dummyAxes;
    h.mat(2).h(2) = dummyAxes;
    h.mat(2).h(3) = dummyAxes;
    h.mat(2).h(4) = dummyAxes;
    
    h.mat(3).params.matpos = [0.67 0.68 0.15 0.31];
    h.mat(3).params.figmargin = [0 0 0 0];
    h.mat(3).params.matmargin = [0 0 0 0];
    h.mat(3).params.cellmargin = [0.03 0.03 0.05 0.05];
    h.mat(3).ncol = 2;
    h.mat(3).nrow = 2;
    h.mat(3).h(1) = dummyAxes;
    h.mat(3).h(2) = dummyAxes;
    h.mat(3).h(3) = dummyAxes;
    h.mat(3).h(4) = dummyAxes;
    
    % --- Place axes on axesmatrix
    for i = 1:length(h.mat)
        ind = 1:length(h.mat(i).h);
        setaxesOnaxesmatrix(h.mat(i).h,h.mat(i).nrow,h.mat(i).ncol,ind, ...
            h.mat(i).params,h.fig);
    end
    
    % --- Make srf cdata map have square aspect ratio
    set(h.srf.ax,'PlotBoxAspectRatio',[ncol nrow 1])
    
    % --- Set colors
    for i = 1:length(cond.tags)
        set(h.(cond.tags{i}),'Color',cond.color{i})
    end
    
    
    % --- Make info table
    genotype = expt.info.mouse.genotype;
    if isfield(expt.info.transgene,'construct1')
        transgene = expt.info.transgene.construct1;
    elseif isfield(expt.info.transgene,'construct')
        transgene = expt.info.transgene.construct;
    end
    temp = {expt.sort.trode(trodeNum).unit.assign};
    temp = cell2mat(temp);
    k = find(temp == unitInd);
    unitLabel = expt.sort.trode(trodeNum).unit(k).label;
    depth = getUnitDepth(expt,unitTag,maxch);
    exptInfo = strvcat(expt.name, [genotype ',' ' ' transgene], unitLabel,...
        num2str(depth), unitTag);
    h.textbox = annotation('textbox',[0.8 0.1 0.2 0.05],'String',exptInfo,...
        'EdgeColor','none','HorizontalAlignment','right','Interpreter',...
        'none','Color',[0.2 0.2 0.2],'FontSize',9,'FitBoxToText','on');
    
    
    
    % Make figure visible
%     set([h.frvt.ax;h.frvt.l],'Visible','off')
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
    
    
    
    sname = [rigdef.Dir.Fig expt.name '_' unitTag '_Ori'];
    if b.save
        %     if ~strcmp(label,{'in process','garabage'})
        disp(['Saving' ' ' sname])
        saveas(h.fig,sname,'pdf')
        saveas(h.fig,sname,'fig')
        saveas(h.fig,sname,'epsc')
        sname = [sname '.epsc'];
        export_fig sname
        %     end
    end
    
    if b.print
        print('-dwinc',h.fig)
        disp(['Printing' ' ' sname])
    end
    
    if b.close
        close(h.fig)
    end
    
    
end

% --- Subfunctions --- %

function setRasterPSTHpos(h,nrow,ncol)

nstim = length(h.r.ax);
rrelsize = 0.65;                      % Relative size PSTH to raster
prelsize = 1-rrelsize;

% Set matrix position
margins = [0.05 0.4 0.05 0.005];
matpos = [margins(1) 1-margins(2) 0.37 1-margins(4)];  % Normalized [left right bottom top]

% Set space between plots
s1 = 0.003;
s2 = 0.035;
s3 = 0.02;

% Compute heights
rowheight = (matpos(4) - matpos(3))/nrow;
pheight = (rowheight-s1-s2)*prelsize;
rheight = (rowheight-s1-s2)*rrelsize;

% Compute width
width = (matpos(2)-matpos(1)-(ncol-1)*s3)/ncol;

% Row positions
for i = 1:nrow
    pbottom(i) = matpos(3) + rowheight*(nrow-i);
    rbottom(i) = pbottom(i) + pheight + s1;
end

% Compute complete positions
for i = 1:nstim
    [row col] = ind2sub([nrow ncol],i);
    left = matpos(1) + (width+s3)*(col-1);
    p{i} = [left pbottom(row) width pheight];
    r{i} = [left rbottom(row) width rheight];
end

% Set positions
set([h.psth.ax; h.r.ax],'Units','normalized')
set(h.psth.ax,{'Position'},p')
set(h.r.ax,{'Position'},r')






