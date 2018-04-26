function contrast_X_LEDintensityFig(expt,spikes,unitTag,fileInd,b,saveTag)
% function contrast_X_LEDintensityFig(expt,unitTag,fileInd,b,saveTag)
%
% INPUT
%   expt: Experiment struct
%   unitTag: Tag of the form 'trode_assign', e.g 'T2_15'
%   fileInd: Vector of file indices to be included in analysis.
%   b: Flag structure with field b.save, b.print, b.pause, b.close

% Created: 10/28/11 - KR
% Modified: 10/28/11 - KR

disp('Making contrast x LED intensity fig');
varTypeOfInterest='Contrast'; % Change to get correct stim.code

if nargin < 4
    b.pause = 0;
    b.save = 0;
    b.print = 0;
    b.close = 0;
    saveTag = '';
end

% Rig defaults
RigDef = RigDefs;

% Get trial duration
getTrialDurationFromUser=0;
duration=0;
if isstruct(spikes.info.detect)
    duration=spikes.info.detect.dur(1);
else
    duration=expt.files.duration(fileInd(1));
end
            
% Check that all daq files give the same stimulus
% Note that I do not explicitly check to see that all daq files give same
% LED intensities
currParams=expt.stimulus(fileInd(1)).params;
if isfield(expt.stimulus(fileInd(1)).params,'contrastValues')
    for i=2:length(fileInd)
        newParams=expt.stimulus(fileInd(i)).params;
        newParams.contrastValues=[0.2 0.6 1];
        if ~isequal(currParams.contrastValues,newParams.contrastValues)
            disp('All selected daq files must present the same stimulus');
            return
        end
    end
elseif isfield(expt.stimulus(fileInd(1)).params,'contrast')
    for i=2:length(fileInd)
        newParams=expt.stimulus(fileInd(i)).params;
        if ~isequal(currParams.contrast,newParams.contrast)
            disp('All selected daq files must present the same stimulus');
            return
        end
    end
else
    disp('Error in making contrast figure. Contrast values have not been defined.');
end

% Set cond struct
if isempty(expt.analysis.other.cond.values)
    % have not yet set expt.analysis.contrast.cond
    disp('Remember to save expt struct after entering analysis params and before analyzing!');
    return
end
cond = expt.analysis.other.cond;

% Set time window struct
if ~isfield(expt.analysis.other,'w')
    expt.analysis.other.w=[];
end
if ~isfield(expt.analysis.other.w,'spont')
    % Prompt user for window information
%     prompt={'Baseline window:','Stimulus window:','Onset response window:','Offset response window:','LED On window:'};
%     dlg_title='Get special time windows';
%     num_lines = 1;
%     def = {'0 1','1 4','1 1.5','4 4.5','1.05 2.05'};
%     answer = inputdlg(prompt,dlg_title,num_lines,def);
%     expt.analysis.other.w.spont=str2num(answer{1});
%     expt.analysis.other.w.stim=str2num(answer{2});
%     expt.analysis.other.w.on=str2num(answer{3});
%     expt.analysis.other.w.off=str2num(answer{4});
%     expt.analysis.other.w.ledOn=str2num(answer{5});
    expt.analysis.other.w.spont=[0 1];
    expt.analysis.other.w.stim=[1 4];
    expt.analysis.other.w.on=[1 1.5];
    expt.analysis.other.w.off=[4 4.5];
    expt.analysis.other.w.ledOn=[1.05 2.05];
    w=expt.analysis.other.w;
else
    w=expt.analysis.other.w;
end

% Temporary color
if ~isfield(cond,'color')
    cond.color=[];
end
if isempty(cond.color)
    cond.color = {[0.1 0.1 0.1],[1 0.25 0.25],[0 0 1],[1 0.5 0],[1 0 1],[0.3 0.3 0.3],[0.7 0.7 0.7]};
end
gray = [0.6 0.6 0.6];
green = [0 1 0];
blue = [0 120/255 200/255];
red = [1 0.25 0.25];

% Figure layout
h.fig = landscapeFigSetup;
set(h.fig,'Visible','off','Position',RigDef.OfflineLandscape.Position)
%set(h.fig,'Visible','on','Position',RigDef.OfflineLandscape.Position);

% Set save name suffix (saveTag)
if isempty(saveTag)
    saveTag = [unitTag '_ContrastXLEDIntensity'];
else
    saveTag = [unitTag '_' saveTag];
end

% Set expt struct as appdata
setappdata(h.fig,'expt',expt);
setappdata(h.fig,'figText',saveTag);

% Add save figure button
addSaveFigTool(h.fig);

% Spikes are passed in
label='';

% Extract spikes for files
spikes = filtspikes(spikes,0,'fileInd',fileInd);

if ~isempty(spikes.spiketimes) % Check that there are spikes
    % Set NaNs = 0
    spikes.led(isnan(spikes.led)) = 0;
    spikes.sweeps.led(isnan(spikes.sweeps.led)) = 0;
    
    % Get stimulus parameters - KR - checks varparam for stim.code
    if strcmp(expt.stimulus(fileInd(1)).varparam.Name,'None')
        stim.type='None';
        stim.values=1;
    else
        if length(expt.stimulus(fileInd(1)).varparam)>1
            if strcmp(expt.stimulus(fileInd(1)).varparam(1).Name,varTypeOfInterest)
                varparam=expt.stimulus(fileInd(1)).varparam(1);
            else
                varparam=expt.stimulus(fileInd(1)).varparam(2);
            end
        else
            varparam = expt.stimulus(fileInd(1)).varparam(1);
        end
        stim.type = varparam.Name;
        stim.values = varparam.Values;
    end
    % Be sure that varparam was populated 
    % Note that if using vStimController rather than PsychStimController 
    % for stimulus presentation,
    % varparam will not automatically be populated when running experiment
    % Instead, use populateVarparam.m to fill in varparam fields
    % after the experiment is made
    if isempty(stim.values)
        disp('stim.values is empty');
        disp('Were you using vStimController to present stimuli?');
        disp('If so, you need to run populateVarparam.m before running this analysis.');
        return
    end
    if length(expt.stimulus(fileInd(1)).varparam)==1
        for i = 1:length(stim.values)
            stim.code{i} = i;
        end
    else
        if strcmp(expt.stimulus(fileInd(1)).varparam(1).Name,varTypeOfInterest)
            for i=1:length(stim.values)
                stim.code{i}=[];
                for j=1:length(expt.stimulus(fileInd(1)).varparam(2).Values)
                    stim.code{i}=[stim.code{i} (i-1)*length(expt.stimulus(fileInd(1)).varparam(2).Values)+j];
                end
            end
        else % All this assumes only 2 variables can be changed at a time in PsychStimController
            for i=1:length(stim.values)
                stim.code{i}=[];
                for j=1:length(expt.stimulus(fileInd(1)).varparam(1).Values)
                    stim.code{i}=[stim.code{i} i+(j-1)*length(expt.stimulus(fileInd(1)).varparam(2).Values)];
                end
            end
        end
    end
    
	% If using all trials
% 	if strcmp(cond.type,'all')
    if strcmp(cond.type,'no')
        spikes.all = ones(size(spikes.spiketimes));
        cond.values = {1};
        cond.type='all';
    else
        cond.type='led';
    end
    
    clear cspikes;
    % Make spikes substruct for each stimulus value and condition value
    for m = 1:length(stim.values)
        for n = 1:length(cond.values)
            if strcmp(cond.type,'led')
                spikes = makeTempField(spikes,'led',cond.values{n});
                cspikes(m,n) = filtspikes(spikes,0,'stimcond',stim.code{m},'led',cond.values{n});
            else
                cspikes(m,n)=filtspikes(spikes,0,'stimcond',stim.code{m});
            end
        end
    end
    
    % Make raster plot for each cspikes substruct
    raster_cspikes=cspikes;
    if sum(spikes.fileInd==fileInd(1))>10000000
        countSpikesInFile=sum(spikes.fileInd==fileInd(1));
        prompt={sprintf('There are >5000 spikes in the first daq file.\nShow all spikes in rasters?\nIf you enter ""no"", program will randomly subsample spikes to show in rasters.')};
        dlg_title='Rasters dlg';
        num_lines=1;
        def={'yes'};
        answer=inputdlg(prompt,dlg_title,num_lines,def);
        if strcmp(answer(1),'yes')
        else
            % Randomly subsample spikes for rasters
            oneInX=round(countSpikesInFile/500);
            for m = 1:size(cspikes,1) 
                for n = 1:size(cspikes,2)       
                    raster_cspikes(m,n)=subsampleSpikes(cspikes(m,n),oneInX);
                end
            end
        end
    end 
%     if length(unique(spikes.trials))/(length(stim.values)*length(cond.values))>30 
%                                         % If there are going to be an insane 
%                                         % number of trials or spikes, just take a
%                                         % subset, asking user for number of
%                                         % trials per condition
% 
%         prompt={'Choose number of trials to show for each condition:'};
%         dlg_title='Choose number of trials for rasters';
%         num_lines=1;
%         def={'30'};
%         answer=inputdlg(prompt,dlg_title,num_lines,def);
%         useNtrials=str2num(answer{1});
%     else
        useNtrials=nan;
%     end
    for m = 1:size(raster_cspikes,1)       % m is number of stimulus values
        h.r.ax(m) = axes;
        defaultAxes(h.r.ax(m));
        for n = 1:size(raster_cspikes,2)   % n is number of conditions
            switch label
                case {'multi-unit','FS multi-unit','axon multi-unit'}
                    if isnan(useNtrials) || useNtrials>length(unique(raster_cspikes(m,n).trials))
                        h.r.l(m,n) = raster(raster_cspikes(m,n),h.r.ax(m),1,0,duration);
                    else
                        allTrials=unique(raster_cspikes(m,n).trials);
                        selectTrials=allTrials(randi(length(allTrials),[1 useNtrials]));
                        h.r.l(m,n) = raster(filtspikes(raster_cspikes(m,n),0,'trials',selectTrials,duration),h.r.ax(m),1,0);
                    end
                otherwise
                    if isnan(useNtrials) || useNtrials>length(unique(raster_cspikes(m,n).trials))
                        % KR - last arg = 1 to plot bursts 
                        h.r.l(m,n) = raster(raster_cspikes(m,n),h.r.ax(m),1,RigDef.OfflineLandscape.PlotBursts,duration);
                    else
                        allTrials=unique(raster_cspikes(m,n).trials);
                        selectTrials=allTrials(randi(length(allTrials),[1 useNtrials]));
                        h.r.l(m,n) = raster(filtspikes(raster_cspikes(m,n),0,'trials',selectTrials),h.r.ax(m),1,RigDef.OfflineLandscape.PlotBursts,duration);
                    end
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
        temp{i} = stim.values(i);
    end
    try
        set(cell2mat(get(h.r.ax,'Title')),{'String'},temp','Position',[1 0 1]);  %'Position',[1.4983 0 1]
    catch msg
        disp('Warning: Could not display condition titles');
    end
    
    % Make PSTH for each cspikes substruct
    for m = 1:size(cspikes,1)
        h.psth.ax(m) = axes;
        for n = 1:size(cspikes,2)
            [h.psth.l(m,n) temp h.psth.n(m,:,n) centers] = psth(cspikes(m,n),50,h.psth.ax(m),1,duration);
        end
    end
    h.psth.ax = h.psth.ax';
    
    % Add handles to appropriate condition field
    for n = 1:size(cspikes,2)
        h.(cond.tags{n}) = [h.(cond.tags{n}); h.psth.l(:,n)];
    end
    
    % Set axes properties
    setRasterPSTHpos(h);
    hTemp = reshape(h.psth.ax,numel(h.psth.ax),1);
    ymax = setSameYmax(hTemp,15);
    for i = 1:length(h.psth.ax)
        addStimulusBar(h.psth.ax(i),[w.stim ymax]);
        addStimulusBar(h.psth.ax(i),[w.ledOn ymax*0.97],'','red');
    end
    removeInd = 1:length(hTemp);
    keepInd = ceil(length(hTemp)/2) + 1;
    removeAxesLabels(hTemp(setdiff(removeInd,keepInd)));
    defaultAxes(hTemp,0.26,0.08);
    
    % Set position of rasters and PSTHs
    setRasterPSTHpos(h);

    % Compute average responses over specified windows as a function of
    % contrast
    [allfr nallfr] = computeResponseVsStimulus(spikes,stim,cond,w);

    % Plot average responses for various stimulus windows
    h=plotAvResponsesForWindows(h,'cr',cspikes,allfr.stim,nallfr.stim,stim,cond,'Stim',varTypeOfInterest);
    h=plotAvResponsesForWindows(h,'crOn',cspikes,allfr.on,nallfr.on,stim,cond,'Stim Onset',varTypeOfInterest);
    h=plotAvResponsesForWindows(h,'crOff',cspikes,allfr.off,nallfr.off,stim,cond,'Stim Offset',varTypeOfInterest);
    h=plotAvResponsesForWindows(h,'crLedOn',cspikes,allfr.ledOn,nallfr.ledOn,stim,cond,'LED On',varTypeOfInterest);
    h=plotAvResponsesForWindows(h,'crSpont',cspikes,allfr.spont,nallfr.spont,stim,cond,'Spont',varTypeOfInterest);
    defaultAxes(h.ncr.ax,0.22,0.5);
    ylabel(h.ncr.ax,'spikes/s','FontSize',7);
    
    % Compute average waveform
    [h.avgwv.l h.avgwv.ax maxch] = plotAvgWaveform(spikes,0);
    defaultAxes(h.avgwv.ax,0.22,0.24);
    setSameYmax(h.avgwv.ax,2,1);  
    xlabel('ms'); 
    ylabel('mV');
    [h.avgwv.l2 h.avgwv.ax2 maxch2] = plotAvgWaveform(spikes,1);
    defaultAxes(h.avgwv.ax2,0.22,0.24);
    setSameYmax(h.avgwv.ax2,2,1);
    xlabel('ms'); ylabel('mV');
    
    % Make autocorrelation plot
    h.autocorr.ax = axes;
    plotAutoCorr(spikes,h.autocorr.ax,50,1);
    defaultAxes(h.autocorr.ax,0.22,0.36);

    % Plot firing rate vs time
    h.frvt.ax = axes;
    h.frvt.l(1) = plotSpikesPerTrial(spikes,h.frvt.ax,0,w.stim);
    h.frvt.l(2) = plotSpikesPerTrial(spikes,h.frvt.ax,0,w.spont);
    defaultAxes(h.frvt.ax,0.22,0.36);
    xlabel('minutes','FontSize',8); ylabel('spikes/s','FontSize',8);
    set(h.frvt.l,'LineStyle','none','Marker','o','MarkerSize',0.75);
    set(h.frvt.l(2),'Color',[0 1 0]);
    set(h.frvt.l(1),'Color',[0 120/255 200/255]);

    % Plot average PSTH across all stimulus conditions
    h.allp.ax = axes;
    [h.allp.l h.allp.ax] = allStimPSTH(h.psth.n,centers,w,h.allp.ax);
    ymax = setSameYmax(h.allp.ax,15);
    addStimulusBar(h.allp.ax,[w.stim ymax]);
    if strcmp(cond.type,'led')
        addStimulusBar(h.allp.ax,[w.ledOn ymax*0.97],'',red,1.5);
    end
    % defaultAxes(h.allp.ax,0.22,0.12);
    defaultAxes(h.allp.ax,0.11,0.19);

    % Add handles to appropriate condition field
    for n = 1:size(cspikes,2)
        h.(cond.tags{n}) = [h.(cond.tags{n}); h.allp.l(:,n)];
    end

    % Compute average firing rate for different windows
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
        [h.avgfr.(temp).l h.avgfr.(temp).ax] = plotCategories(fr.(temp)(:,1),cond.tags,fr.(temp)(:,2),'');
        setTitle(gca,temp,7);
    end
    defaultAxes(h.avgfr.spont.ax,0.1,0.48);
    
    % Define sub-graph locations
    h=defineLocations(h);
    
    % Place axes on axesmatrix
    for i = 1:length(h.mat)
        ind = 1:length(h.mat(i).h);
        setaxesOnaxesmatrix(h.mat(i).h,h.mat(i).nrow,h.mat(i).ncol,ind, ...
            h.mat(i).params,h.fig);
    end
   
    % Set colors
    for i = 1:length(cond.tags)
        set(h.(cond.tags{i}),'Color',cond.color{i})
    end

    exptInfo = unitTag;
    h.textbox = annotation('textbox',[0 0 0.3 0.022],'String',exptInfo,...
        'EdgeColor','none','HorizontalAlignment','left','Interpreter',...
        'none','Color',[0.1 0.1 0.1],'FontSize',8,'FitBoxToText','on');
    set(h.textbox,'Position',[0.01 0.013 0.4 0.022]);

    % Make figure visible
    % set(h.frvt.ax,'Visible','off');
    % set(h.frvt.l,'Visible','off');
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
    
    sname = [RigDef.Dir.Fig expt.name '_' unitTag '_Contrast'];
    if b.save
        disp(['Saving' ' ' sname])
        saveas(h.fig,sname,'pdf')
        saveas(h.fig,sname,'fig')
        saveas(h.fig,sname,'epsc')
        sname = [sname '.epsc'];
        export_fig sname
    end
    
    if b.print
        print('-dwinc',h.fig)
        disp(['Printing' ' ' sname])
    end
    
    if b.close
        close(h.fig)
    end
end
end




% --- Subfunctions --- %

function h=defineLocations(h)
% Define locations in respective axes matrix
% h.mat(1).params.matpos = [0 0.66 0.652 0.38];               % [left top width height]
% h.mat(1).params.matpos = [0 0.67 0.71 0.37];  
% h.mat(1).params.figmargin = [0.00 0 0 0.05];                % [left right top bottom]
% h.mat(1).params.matmargin = [0 0 0 0];                      % [left right top bottom]
% h.mat(1).params.cellmargin = [0.05 0.035 0.05 0.05];        % [left right top bottom]
% h.mat(1).ncol = 7;
% h.mat(1).nrow = 2;
% h.mat(1).h(1) = h.autocorr.ax;
% h.mat(1).h(2) = h.avgwv.ax;
% h.mat(1).h(3) = h.cr.ax;
% h.mat(1).h(4) = h.crOn.ax;
% h.mat(1).h(5) = h.crOff.ax;
% h.mat(1).h(6) = h.crLedOn.ax;
% h.mat(1).h(6) = h.crSpont.ax;
% h.mat(1).h(1) = h.frvt.ax;
% h.mat(1).h(2) = h.avgwv2.ax;
% h.mat(1).h(3) = h.ncr.ax;
% h.mat(1).h(4) = h.ncrOn.ax;
% h.mat(1).h(5) = h.ncrOff.ax;
% h.mat(1).h(6) = h.ncrLedOn.ax;
% h.mat(1).h(6) = h.ncrSpont.ax;

% Block 1
h.mat(1).params.matpos = [0 0.67 0.26 0.37];                % [left top width height]
h.mat(1).params.figmargin = [0.00 0 0 0.05];                % [left right top bottom]
h.mat(1).params.matmargin = [0 0 0 0];                      % [left right top bottom]
h.mat(1).params.cellmargin = [0.05 0.04 0.05 0.05];        % [left right top bottom]
h.mat(1).ncol = 2;
h.mat(1).nrow = 2;
h.mat(1).h(1) = h.autocorr.ax;
h.mat(1).h(2) = h.avgwv.ax;
h.mat(1).h(3) = h.frvt.ax;
h.mat(1).h(4) = h.avgwv.ax2;

% Block 2
h.mat(2).params.matpos = [0.28 0.67 0.37 0.37];               % [left top width height]
h.mat(2).params.figmargin = [0.00 0 0 0.05];                % [left right top bottom]
h.mat(2).params.matmargin = [0 0 0 0];                      % [left right top bottom]
h.mat(2).params.cellmargin = [0.03 0.03 0.05 0.05];        % [left right top bottom]
h.mat(2).ncol = 5;
h.mat(2).nrow = 2;
h.mat(2).h(1) = h.cr.ax;
h.mat(2).h(2) = h.crOn.ax;
h.mat(2).h(3) = h.crOff.ax;
h.mat(2).h(4) = h.crLedOn.ax;
h.mat(2).h(5) = h.crSpont.ax;
h.mat(2).h(6) = h.ncr.ax;
h.mat(2).h(7) = h.ncrOn.ax;
h.mat(2).h(8) = h.ncrOff.ax;
h.mat(2).h(9) = h.ncrLedOn.ax;
h.mat(2).h(10) = h.ncrSpont.ax;

% Block 3
h.mat(3).params.matpos = [0.67 0.67 0.15 0.29];
h.mat(3).params.figmargin = [0 0 0 0];
h.mat(3).params.matmargin = [0 0 0 0];
h.mat(3).params.cellmargin = [0.03 0.03 0.02 0.02];
h.mat(3).ncol = 1;
h.mat(3).nrow = 1;
h.mat(3).h(1) = h.allp.ax;
% h.mat(2).h(2) = [];
% h.mat(2).h(3) = [];
% h.mat(2).h(4) = [];

% Block 4
% h.mat(3).params.matpos = [0.67 0.66 0.15 0.33];
h.mat(4).params.matpos = [0.82 0.67 0.16 0.31];
h.mat(4).params.figmargin = [0 0 0 0];
h.mat(4).params.matmargin = [0 0 0 0];
h.mat(4).params.cellmargin = [0.03 0.03 0.05 0.05];
h.mat(4).ncol = 3;
h.mat(4).nrow = 2;
h.mat(4).h(1) = h.avgfr.spont.ax;
h.mat(4).h(2) = h.avgfr.stim.ax;
h.mat(4).h(3) = h.avgfr.on.ax;
h.mat(4).h(4) = h.avgfr.off.ax;
h.mat(4).h(5) = h.avgfr.ledOn.ax;
% h.mat(3).h(6) = [];
end


function h=plotAvResponsesForWindows(h,fName,cspikes,FRs,norm_FRs,stim,cond,title,varTypeOfInterest)

% Make contrast response functions for window
h.(fName).ax = axes('Parent',h.fig); 
%ylabel('spikes/s','FontSize',8);
nfName=strcat('n',fName);
h.(nfName).ax = axes('Parent',h.fig);
if any(FRs==0)
    FRs(FRs==0)=ones(length(find(FRs==0)),1)*0.00001;
end
if any(norm_FRs==0)
    norm_FRs(norm_FRs==0)=ones(length(find(norm_FRs==0)),1)*0.00001;
end
for i=1:size(FRs,1)
    if FRs(i,1)==FRs(i,2)
        FRs(i,2)=FRs(i,2)+0.00001;
    end
    if isnan(FRs(i,1)) && isnan(FRs(i,2))
        FRs(i,1)=0.00001;
        FRs(i,2)=0.000011;
    elseif isnan(FRs(i,1)) 
        FRs(i,1)=0.00001;
    elseif isnan(FRs(i,2)) 
        FRs(i,2)=0.00001;   
    end
end    
for i=1:size(norm_FRs,1)
    if norm_FRs(i,1)==norm_FRs(i,2)
        norm_FRs(i,2)=norm_FRs(i,2)+0.00001;
    end
    if isnan(norm_FRs(i,1)) && isnan(norm_FRs(i,2))
        norm_FRs(i,1)=0.00001;
        norm_FRs(i,2)=0.000011;
    elseif isnan(norm_FRs(i,1)) 
        norm_FRs(i,1)=0.00001;
    elseif isnan(norm_FRs(i,2)) 
        norm_FRs(i,2)=0.00001;   
    end
end
h.(fName).l = plotContrastResponse(FRs,stim.values,h.(fName).ax);
h.(nfName).l = plotContrastResponse(norm_FRs,stim.values,h.(nfName).ax);
defaultAxes([h.(fName).ax h.(nfName).ax],0.18,0.1);
xlabel(varTypeOfInterest,'FontSize',7)
setTitle(h.(fName).ax,title,7); 
setTitle(h.(nfName).ax,strcat(title,' norm'),7); 

% Add handles to appropriate condition field
for n = 1:size(cspikes,2)
    h.(cond.tags{n}) = [h.(cond.tags{n}); h.(fName).l(:,n); h.(nfName).l(:,n)];
end

end

function setRasterPSTHpos(h)

nstim = length(h.r.ax);
ncol = ceil(nstim/2);
rrelsize = 0.65;                      % Relative size PSTH to raster
prelsize = 1-rrelsize;

% Set matrix position
margins = [0.05 0.02 0.05 0.005];
matpos = [margins(1) 1-margins(2) 0.39 1-margins(4)];  % Normalized [left right bottom top]

% Set space between plots
s1 = 0.003;     % Space between PSTH and raster
s2 = 0.04;     % Space between rows
s3 = 0.05;      % Space between columns

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
end