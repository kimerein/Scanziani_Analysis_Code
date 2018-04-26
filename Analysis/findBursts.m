function [bursttimes trials] = findBursts(spiketimes,trials,burstISI)
% function findBursts(spiketimes,trials)
% INPUT
%   spiketimes: Vector of spiketimes
%   trials: Vector of corresponding trial for each spike
%   burstISI: ISI that defines a "burst"
%
% OUTPUT:
%   bursttimes: Time of first spike in each burst
%   trials: Trial in which burst occurred.
%

% Created: 10/25/10 - SRO

if nargin < 3
    burstISI = 0.004;
end

% Compute ISI
temp = diff(spiketimes);

% Find ISI within burst window (value = 1, if following spike occurred <
% burstISI)
burstSpikes = [(temp < burstISI & temp > 0) 0];
nextSpike = [0 burstSpikes(1:end-1)];
burstSpikes = any([burstSpikes ; nextSpike]);

% Find first spike in burst

% Output
bursttimes = spiketimes(burstSpikes);
trials = trials(burstSpikes);
