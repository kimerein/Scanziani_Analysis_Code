function spikes = addDepthToSpikes(spikes,expt)
% function spikes = addDepthToSpikes(spikes,expt)
%
%
%
%

% Created: SRO - 5/4/11

% Get trode index
trodeInd = spikes.info.trodeInd;

% Get waveforms (w is 3D matrix, SPIKES x SAMPLES x CHANNELS)
w = spikes.waveforms;

% Find max sample value for each spike and channel
mVal = max(w,[],2);

% Make SPIKES x CHANNELS matrix
mVal = squeeze(mVal);

% Find max channel
[junk mCh] = max(mVal,[],2);
trodeSites = (expt.sort.trode(trodeInd).channels)';
siteNum = trodeSites(mCh);

% Convert to depth
probe = expt.probe;

if ~isempty(probe.sitedepth)
    for i = 1:length(siteNum)
        depth(i) = round(probe.sitedepth(probe.channelorder == siteNum(i)));
    end
else
    depth = NaN(size(siteNum));
end

% Add depth to spikes
spikes.depth = depth;

