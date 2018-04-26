function spikes = UpdateTrials(spikes,sweeps)
% function spikes = UpdateTrials(spikes,sweeps)
%
% This function is used to update the number trials corresponding to the
% field the spikes struct has been filtered on. 
%
% INPUTS
%   spikes: The spikes struct
%   sweeps: The sweeps struct
%
% OUTPUTS
%   spikes: Updated spikes struct
%
%   Created: 3/15/10 - SRO
%   Modified: 4/7/10 - BA 

if nargin < 2
    sweeps = spikes.sweeps;
end

if isempty(spikes.spiketimes)
    spikes.trialsInFilter = [];
else
    spikes.sweeps.trialsInFilter = [1:length(sweeps.trials)];
    spikes.trialsInFilter = nan(size(spikes.trials));
    for i = 1:length(sweeps.trials)
        spikes.trialsInFilter(spikes.trials == sweeps.trials(i)) = i;
    end
end

if any(isnan(spikes.trialsInFilter) )% error checking
    error('not every spikes.trialsInFilter got a value something is wrong')
end



