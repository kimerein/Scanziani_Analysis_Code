function spikes = spikesAddConds(spikes)
%
%
%
%   Created: 3/16/10 - SRO
%   Modified: 4/6/10 - SRO
%   4/13/10 - SRO: Substantial overhaul of this function. Now uses info in
%   spikes.sweeps to add conditions to spikes.


% Get spikes.(field) from spikes.sweeps
fieldList = fieldnames(spikes.sweeps);
reqSize = size(spikes.sweeps.fileInd);  % Fields with size == .fileInd will be added
% Remove trials from fieldList because already have spikes.trials
temp = strcmp(fieldList,'trials');
fieldList(temp) = [];

% Make fields in spikes
for i = 1:length(fieldList)
    if isequal(size(spikes.sweeps.(fieldList{i})),reqSize);
        spikes.(fieldList{i}) = nan(size(spikes.trials),'single');
    end
end

% Use value in spikes.sweeps.(field) to fill in spikes.(field)
uniqTrials = unique(spikes.trials);
for t = uniqTrials  
    ind = spikes.trials == t;
    for i = 1:length(fieldList)
        spikes.(fieldList{i})(ind) = spikes.sweeps.(fieldList{i})(t);
    end 
end

