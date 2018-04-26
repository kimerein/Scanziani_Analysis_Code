function [varargout] = psthBA(spikes,binsize,hAxes,bappend,bplot)
% function [varargout] = psth(spiketimes,binsize,hAxes,bappend,bplot)
%% FINISH COMMENTING
% INPUTS
%   spiketimes:
%   binsize:
%   duration:
%
% OUTPUTS
% if bplot
%   varargout{1} = hAxes:
%   varargout{2} = hPsth:
%   varargout{3} = n:
%   varargout{4} = edges:
% else 
%   varargout{1} = n:
%   varargout{2} = edges:

% 3/30/10 - BA

trialduration = 2;
for i = 1: length(spikes)
    if ~isempty(spikes(i).spiketimes)
        trialduration = max(spikes(i).info.detect.dur(spikes(i).sweeps.trialsInFilter)); % because sweeps is filtered but info.detec.dur is not
    end
end

if nargin < 2 || isempty(binsize)
    binsize = 50; % ms
end
if nargin < 4 % if 1 then new axes will be created with same postion as hAxes
    % else data will be plotted on hAxes
    bappend = 0;
end
if nargin < 5, bplot = 1; end

% Convert binsize from s to ms
binsize = binsize/1000;
edges = 0:binsize:trialduration;

[nRowrast nColrast] = size(spikes);
% predefine
n = nan(nRowrast,nColrast,length(edges));
for iVar1 = 1:nRowrast % ROW
    for iVar2 = 1:nColrast % COL
        
        icond = (iVar1-1)*nColrast+iVar2;
        
         % Make PSTH
        temp = histc(spikes(iVar1,iVar2).spiketimes,edges)';
        if isempty(temp),n(iVar1,iVar2,:) = nan;                            % deal with case where there are no spiketimes
        else
            n(iVar1,iVar2,:) = temp;
            n(iVar1,iVar2,:) = n(iVar1,iVar2,:)/length(spikes(iVar1,iVar2).sweeps.trials)/binsize;
            
        end
        % create or find axes
        if bplot
            if exist('hAxes','var') && ~ isempty(hAxes)% will either overlay new axis with same position as hAxes, or use same plot
                if  ~bappend
                    hPSTHAxes(icond) = axes('Position',get(findobj(hAxes(icond),'Type','axes'),'Position'),...
                        'XAxisLocation','top',...
                        'YAxisLocation','right',...
                        'Color','none',...
                        'XColor','k','YColor','k','Tag','psth');
                else hPSTHAxes(icond) = hAxes(icond); end
            else
                hPSTHAxes(icond) = axesmatrix(nRowrast,nColrast,icond);
            end
            set(gcf,'CurrentAxes',hPSTHAxes(icond));hold on;
            
            hPsth(icond) = line(edges,squeeze(n(iVar1,iVar2,:)),'Parent',hPSTHAxes(icond) ,'LineWidth',1.5);
        end
    end
end
if exist('hPSTHAxes','var') & length(hPSTHAxes)>1    
    temp = ([min(cellfun(@min,get(hPSTHAxes,'YLIM'))) max(cellfun(@max,get(hPSTHAxes,'YLIM')))]);
    set(hPSTHAxes,'YLIM',temp,'box','off','FontSize',9);
    
    ind = nColrast; % index right most axis
    set(hPSTHAxes(hPSTHAxes~=hPSTHAxes(ind)),'YTickLabel',[],'YTick',[]) % hide all but 1 axis
        % hide y axes (by color)
        set(hPSTHAxes(hPSTHAxes~=hPSTHAxes(ind)),'YColor',get(gcf,'Color'))

end

% hide all x axis unless axparam are used
if bplot
    if exist('hAxes','var');
        if ~bappend,
            set(hPSTHAxes,'XTickLabel',[],'XTick',[]);
            set(hPSTHAxes,'XColor',get(gcf,'Color')); % hide x axes (by color)
            
        end
    else
        ind = min(2,length(hPSTHAxes));
        set(hPSTHAxes(hPSTHAxes~=hPSTHAxes(ind)),'XTickLabel',[],'XTick',[]);
        set(hPSTHAxes(hPSTHAxes~=hPSTHAxes(ind)),'XColor',get(gcf,'Color')); % hide x axes (by color)
    end
    
    % Outputs
    varargout{1} = hPSTHAxes;
    varargout{2} = hPsth;
    varargout{3} = n;
    varargout{4} = edges;
else
    varargout{1} = n;
    varargout{2} = edges;
end