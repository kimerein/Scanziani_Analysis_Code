function [hAxOri fid]= plotclusterTuning(expt,spikes,fileInd,bLed)
% function [hAxOri fid]= plotclusterTuning(expt,spikes,fileInd)
% TO DO catch case of varparam in different files are different
varparamTemplate = expt.stimulus(fileInd(1)).varparam;
nVar = length(varparamTemplate);
for i = 2:length(fileInd)
    if ~isequal(expt.stimulus(fileInd(i)).varparam,varparamTemplate)
        error('varparam in selectedfiles do not match')
    end
end

% user specific would be here
indOrientation = find(ismember({varparamTemplate.Name},'Orientation'));
if  isempty(indOrientation)
    error('None of the files selected for analysis vary Orientation')
end

if indOrientation==1 && nVar>1
    % collapse var2
    spikes = spikes_collapseVarParam(spikes,varparamTemplate,2);
    nCond = length(unique(varparamTemplate(1).Values));
elseif indOrientation==2 && nVar>1 % collapse var1
    spikes =  spikes_collapseVarParam(spikes,varparamTemplate,1);
    nCond = length(unique(varparamTemplate(2).Values));
end

sName = '';
if exist('bLed','var') % use bLed as a sort criteria and note it in the figure name
    sName = sprintf('LED %',bLed);
end

fid = figure;
fid(2) = figure;
fid(3) = figure;
set(fid,'Visible','off')
set(fid(1),'Name',sprintf('Polar: Cluster Tuning %s',sName));
set(fid(2),'Name',sprintf('Raster: Cluster Tuning %s',sName));
set(fid(3),'Name',sprintf('PSTH: Cluster Tuning %s',sName));
set(fid,'Tag','Cluster Tuning');
selectassigns = unique(spikes.assigns);
nclus = length(selectassigns);

ncol = spikes.params.display.max_cols;
nrow = ceil(nclus/ncol);
binsizePSTH = 50; %ms
theta = deg2rad(varparamTemplate(indOrientation).Values);

hAxes = [];
hAxesPsth = [];

sparam =  expt.stimulus(fileInd(1)).params;
for i = 1:nclus
    clear cspikes;
    for iVar = 1:nCond
        icond = iVar ;
        if exist('bLed','var') % use bLed as a sort criteria
            cspikes(iVar,1) = filtspikes(spikes,0,'assigns',selectassigns(i),'stimcond',icond,'led',bLed);
        else
            cspikes(iVar,1) = filtspikes(spikes,0,'assigns',selectassigns(i),'stimcond',icond);
        end
    end
    
        set(0,'CurrentFigure',fid(3));
    [hAxesPsth hPsth  junk junk] = psthBA(cspikes,[],hAxesPsth,1,1);
    set(hPsth(~isnan(hPsth)),'Color',spikes.info.kmeans.colors(selectassigns(i),:))

    set(0,'CurrentFigure',fid(2));
    [hAxes ph] = rasterBA(cspikes,hAxes,1,0);
    set(ph(~isnan(ph)),'Color',spikes.info.kmeans.colors(selectassigns(i),:))

    set(0,'CurrentFigure',fid(1));
    [nPSTH edgesPSTH] = psthBA(cspikes,binsizePSTH,[],[],0);
    
    analyzewindow = [ 0 min(sparam.StimDuration, size(nPSTH,3)*binsizePSTH*1e-3)];
    analyzewindowbins = [max(1,analyzewindow(1)/(binsizePSTH*1e-3)) analyzewindow(2)/(binsizePSTH*1e-3)];
    ratePSTH = mean(nPSTH(:, :,analyzewindowbins(1):analyzewindowbins(2)),3);
    hAxOri(i) = axes();
    [hpolar  hAxOri(i)] = plotOriTuning(theta,ratePSTH);
    setaxesOnaxesmatrix(hAxOri(i),nrow,ncol,i,[],fid(1));
    if 1 % polar plot needs special formating ttreatement
        set(0,'Showhiddenhandles','on')
        htitle = get(hAxOri(i),'Title');
        extrastuff = setdiff(get(hAxOri(i),'children'),[hpolar htitle]);
        set(extrastuff,'Visible','off');
        %                set(hpAxes,'Position',get(hpAxes,'Position').*[-3*(i==1)-1 -1.5 1.5 1.5]) % make ploar axes bigger and shift over
    end
    set(hpolar,'color',spikes.info.kmeans.colors(selectassigns(i),:),'linewidth',2);
    title(sprintf(' # %d',selectassigns(i)));
    
end
    set([hAxesPsth hAxes],'Color',[0 0 0])
    set(fid([2 3]),'Color',[0 0 0])
set(hAxes,'XColor',[1 1 1])
set(hAxes,'YColor',[1 1 1])

set(fid,'Visible','on')

%     TO DO add raster (only of max respond condition)