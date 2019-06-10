function expt = addSort(expt)
%
%
%
%
% Created: 7/15/10 - SRO


rigdef = RigDefs;

% Set sort fields
expt.sort.totalunits = [];
expt.sort.manualThresh = [];

for i = 1:length(rigdef.SS.label_categories)
    temp = rigdef.SS.label_categories{i};
    expt.sort.cluster.type{i} = temp;
end

expt.sort.cluster.number = zeros(size(expt.sort.cluster.type));

% Add .sort.trode(m) struct where m is the number of trodes

for i = 1:expt.probe.numtrodes
    expt = addTrodeSort(expt,i);
end
