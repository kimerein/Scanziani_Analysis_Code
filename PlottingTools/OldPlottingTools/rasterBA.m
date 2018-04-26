function [hAxes ph hlinkAxes] = rasterBA(spikes,hAxesin,bappend, bconcatenate)
% function [hAxes ph hlinkAxes] = rasterBA(spikes,hAxesin,bappend,bconcatenate)

if nargin < 3; bappend = 0; end
if nargin < 4; bconcatenate = 0; end

trialduration = 2;
for i = 1: length(spikes)
    if ~isempty(spikes(i).spiketimes)
        if isfield(spikes(i).sweeps,'trialsInFilter')
            trialduration = max(spikes(i).info.detect.dur(spikes(i).sweeps.trialsInFilter)); % because sweeps is filtered but info.detec.dur is not
        else
            trialduration = max(spikes(i).info.detect.dur(min(length(spikes(i).info.detect.dur),spikes(i).sweeps.trials))); % because sweeps is filtered but info.detec.dur is not
        end
    end
end
[nRowrast nColrast] = size(spikes);
for iVar1 = 1:nRowrast % ROW
    for iVar2 = 1:nColrast % COL
        icond = (iVar1-1)*nColrast+iVar2;
        if exist('hAxesin','var') && ~isempty(hAxesin)% will either overlay new axis with same position as hAxes, or use same plot
            if  ~bappend 
                hAxes(icond) = axes('Position',get(findobj(hAxesin(icond),'Type','axes'),'Position'),...
                    'XAxisLocation','top',...
                    'YAxisLocation','right',...
                    'Color','none',...
                    'XColor','k','YColor','k','Tag','psth');
            else hAxes(icond) = hAxesin(icond); end
        else
            hAxes(icond) = axesmatrix(nRowrast,nColrast,icond);
        end
        plotset(1);hold all;
        set(gcf,'CurrentAxes',hAxes(icond));
        lastplotTrials = get(hAxes(icond),'UserData'); if isempty(lastplotTrials),lastplotTrials = 0; end
        plotparam.fid = gcf;
        if bconcatenate % spikes
            trials = spikes(iVar1,iVar2).trialsInFilter+lastplotTrials;
        else %  (otherwise will overlay spikes)
            trials = spikes(iVar1,iVar2).trialsInFilter;
        end
        ph(icond) = rasterplot(spikes(iVar1,iVar2).spiketimes,trials,plotparam);
        if ~isnan(ph(icond))
            ntrials = length(spikes(iVar1,iVar2).sweeps.trialsInFilter)+lastplotTrials;
        else ntrials= lastplotTrials; end
        % append trials
        set(hAxes(icond),'UserData',ntrials)   ;                                                         % save trials so that later call can append raster
        axis tight;
        
    end
end
plotset(1);set(gca,'box','on');hold all;
if ~isempty(hAxes); %                     format axis % auto increment color
    hAxes = hAxes(hAxes>0); % remove empty plots that didn't get a handle
    
    %     hlinkAxes = linkprop(hAxes,{'box','Color','YLIM','XLIM'}); % this
    %     function is slow
    if iscell(hAxes)||length(hAxes>1),    temp = ([min(cellfun(@min,get(hAxes,'YLIM'))) max(cellfun(@max,get(hAxes,'YLIM')))]);
    else  temp = [min(get(hAxes,'YLIM')) max(get(hAxes,'YLIM'))]; end
    set(hAxes,'XAxisLocation','bottom',...
        'YAxisLocation','left',...
        'Color','none',...
        'XColor','k','YColor','k',...
        'YLIM',temp,'XLIM',[ 0 trialduration*1.02],'box','off',...
        'YTickLabel',[],'YTick',[],'YDir','reverse','FontSize',9,...
        'Tag','raster');
    %     set(hAxes,'xcolor',get(gcf,'color')) % remove X axis
    
    ind = nColrast*(nRowrast-1)+1; % index of bottom left axes (which will have x axis info)
    set(hAxes(hAxes~=hAxes(ind)),'XTickLabel',[]);
    set(get(hAxes(ind),'XLabel'),'String','sec');
    set(get(hAxes(ind),'YLabel'),'String','trial');
    
    % hide  x and y axes (by color)
    set(hAxes,'YColor',get(gcf,'Color'))
    set(hAxes(hAxes~=hAxes(ind)),'XColor',get(gcf,'Color'))
    
    
    %         temp  = get(get(hAxes(ind),'XLabel'),'Position');
    %                     set(get(hAxes(ind),'XLabel'),'Position',temp.*[1 0.75 1]); % bring the xlabel closer to axis
end
