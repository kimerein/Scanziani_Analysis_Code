function psthFcnDepth(spikes,expt,binSize)
% function psthFcnDepth(spikes,expt,binSize)
%
% INPUT
%   spikes
%
% OUTPUT
%   varargout{1} = hfig
%   varargout{2} = hax

% Created: SRO - 6/20/11

if nargin < 3 || isempty(binSize)
    binSize = 50;
end

chn = expt.probe.channelorder

depths = unique(spikes.depth);
depths = sort(depths);

% Make PSTHs
hfig = portraitFigSetup;
set(hfig,'Position',[-1426         323         693         797]);
for i = 1:length(depths)
    s = filtspikesDepth(spikes,depths(i));
    hax(i) = axes; defaultAxes(gca);
    hl(i) = psth(s,binSize,hax(i));
    title([num2str(depths(i)) ' *** ' num2str(chn(i))]);
end

% Format axes
% removeAxesLabels(hax(1:end-1));
params.cellmargin = [0.04 0.04 0.04 0.04];
setaxesOnaxesmatrix(hax,8,2,1:length(hax),params);

