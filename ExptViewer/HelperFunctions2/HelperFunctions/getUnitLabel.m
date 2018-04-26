function label = getUnitLabel(expt,trodeInd,unitInd)
%
%
%
%
%

% Created: 7/20/10 - SRO


assigns = {expt.sort.trode(trodeInd).unit.assign};
assigns = cell2mat(assigns);
label = expt.sort.trode(trodeInd).unit(assigns==unitInd).label;