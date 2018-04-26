function maxch = addMaxChField(spikes)
% function spikes = addMaxChField(spikes)
%
%
%
%

% Created: 10/18/10 - SRO


% Get event_channel vector (channel spike was detected on)
event_channel = spikes.info.detect.event_channel';

% Determine whether there are outliers
b_outlier = isfield(spikes.info,'outliers');

if b_outlier
    % Determine where outliers lie in unwrapped_times
    u_times = spikes.unwrapped_times;
    u_times_outliers = spikes.info.outliers.unwrapped_times;
    % Concatenate times of spikes and outliers
    temp = [u_times u_times_outliers]';
    temp = sort(temp);
    % Find index of outliers
    for i = 1:length(u_times_outliers)
        k(i) = find(temp == u_times_outliers(i));
    end
    % Remove outliers from event_channel
    event_channel(k) = [];
end

if length(event_channel) == length(spikes.spiketimes)
    maxch = event_channel;
else
    error('Mismatch between spikes in event_channel and spiketimes')
end