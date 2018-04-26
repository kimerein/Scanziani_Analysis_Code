function spikes = fuseSpikes(mSpikes)
%
% INPUT
%   mSpikes: multi-dimensional spikes
%
% OUTPUT
%   spikes:

% Created: 6/7/10 - SRO

tempSpikes = mSpikes(1);
fields = fieldnames(tempSpikes);

for i = 2:length(mSpikes)
    num_spikes = length(mSpikes(i).(fields{1}));   % All fields should have same length    
    for k = 1:length(fields)
        tempSpikes.(fields{k})(end+1:end+num_spikes) = mSpikes(i).(fields{k});
    end
end

spikes = tempSpikes;
        
