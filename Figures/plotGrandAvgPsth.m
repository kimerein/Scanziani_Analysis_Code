function plotGrandAvgPsth(ua,avgGroup,binSize,uaFiltArray,sdir)
% function plotGrandAvgPsth(ua,avgGroup,binSize,uaFiltArray,sdir)
%
% INPUT
%   ua: Unit array
%   avgGroup: 'all','best','top2','top4','low2','ex','inh'
%   binSize:
%   uaFiltArray: Nx2 cell array of fields and values to filter unit array.

% Created: SRO - 5/25/11

if nargin < 4 || isempty(uaFiltArray)
    uaFiltArray = [];
end

if nargin < 5 || isempty(sdir)
    sdir = 'S:\SRO DATA\Figures\DataFigures\Temp\';
end

% Set number of psth
if ~isempty(uaFiltArray)
    num_psth = size(uaFiltArray,1);
else
    num_psth = 1;
end

% Figure setup
hfig = portraitFigSetup;
setappdata(hfig,'sdir',sdir);
setappdata(hfig,'figText',['grand psth_' avgGroup ' ' 'stimuli']);
hSaveFigTool = addSaveFigTool(gcf);
addText(hfig,[avgGroup ' ' 'stimuli']);

% Set master ua
uaM = ua;

for i = 1:num_psth
    
    % Filter unit array
    if ~isempty(uaFiltArray)
        ua = filtUnitArray(uaM,0,uaFiltArray{i});
    else
        ua = uaM;
    end
    
    % Get information from expt for ua(1)
    expt = loadvar(ua(1).expt_last_fname);
    w = expt.analysis.orientation.windows;      % Assumes same windows for all units
    
    all_p = [];
    
    length(ua)
    for u = 1:length(ua)
        % Get stimulus index of responses to average
        k = getResponseInd(ua(u),avgGroup);
        
        % Set psthInd
        psthInd = determinePsthInd(ua(u),binSize);
        
        % Set centers and psth
        centers = ua(u).psth(psthInd).centers;
        p = ua(u).psth(psthInd).data;
        
        % Compute average psth
        pavg = mean(p(:,k,:),2);
        pavg = squeeze(pavg);
        
%         % Only include units tested with 6 LED levels
%         if size(pavg,2) == 6
%             % Accumulate psths
%             all_p = cat(3,all_p,pavg);
%         end
        
          % Accumulate psths
            all_p = cat(3,all_p,pavg);
    end
    
    % Normalize to peak within 200 ms of stimulus onset
%     nall_p = normalizePsth(all_p,centers,[w.stim(1) w.stim(1)+0.2],'max');
        nall_p = normalizePsth(all_p,centers,[w.stim],'mean');
    
    % Make struct with psth values
    clear p
    p.raw = all_p;
    p.norm = nall_p;
    flds = fieldnames(p);
    
    for m = 1:length(flds)
        % Make axes
        hax(i,m) = axes('Parent',hfig);
        % Compute average
        [avg sem] = avgSem(p.(flds{m}),3);
        % Plot psth
        for n = 1:size(avg,2)
            hl(i,m,n) = plotPsth2(avg(:,n),centers,hax(i,m),colors(n));
            herr(i,m,n) = addErrBar(centers,avg(:,n),sem(:,n),'y',hax(i,m),hl(i,m,n));
        end
        ymax = setSameYmax(hax(i,m),15);
        addStimulusBar(hax(i,m),[w.stim ymax],'',[0 0 0]);
        addStimulusBar(hax(i,m),[w.ledon ymax*0.97],'',[1 0 0],1.5);   
    end    
end

% Format axes
h = NaN(numel(hax),1);
h(1:2:end) = hax(:,1);
h(2:2:end) = hax(:,2);
params.cellmargin = [0.1 0.1 0.05 0.05];
setaxesOnaxesmatrix(h,6,2,1:length(h),params);

% Subfunctions
function psthInd = determinePsthInd(ua,binSize)

if isfield(ua,'psth')
    bFound = 0;
    for i = 1:length(ua.psth)
        if binSize == ua.psth(i).binSize
            psthInd = i;
            bFound = 1;
            break
        end
    end
    if bFound == 0
        psthInd = 1;
    end
else
    psthInd = 1;
end
