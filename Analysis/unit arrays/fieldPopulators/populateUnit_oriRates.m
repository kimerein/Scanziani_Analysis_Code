function unit = populateUnit_oriRates(unit, curExpt, curTrodeSpikes)


expt = curExpt;
spikes = curTrodeSpikes;

% Set stimulus time window
w = expt.analysis.orientation.windows;

% Get fileInd for orientation files
fileInd = expt.analysis.orientation.fileInd;

% Filter spikes on files and assign
spikes = filtspikes(spikes,0,'fileInd',fileInd,'assigns',unit.assign);

% Make stimulus struct for orientation
stim = makeStimStruct(expt,fileInd);

% Make condition struct
cond = expt.analysis.orientation.cond;

% If using all trials
if strcmp(cond.type,'all')
    spikes.all = ones(size(spikes.spiketimes));
    cond.values = {1};
end

% Compute evoked firing rate
fr = computeResponseVsStimulus(spikes,stim,cond,w);

% Assign rate to unit struct
unit.oriRates = fr;


