function spikes = addSpikeSite(spikes,expt)
%
%
%
%
%

% Created: 6/7/10 - SRO


% Get site from event_channel
tempSite = spikes.info.detect.event_channel;

% Get mapping from event_channel to site number
trodeInd = spikes.info.trodeInd;
trodeSites = expt.info.probe.trode.sites{trodeInd};

% Assign site
for i = 1:length(trodeSites)
    tempSite(tempSite == i) = trodeSites(i);
end

spikes.site = tempSite';