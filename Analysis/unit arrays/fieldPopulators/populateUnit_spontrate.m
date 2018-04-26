function unit = populateUnit_spontrate(unit, curExpt, curTrodeSpikes)

expt = curExpt;
spikes = curTrodeSpikes;

% Set spontaneous time window
w = expt.analysis.orientation.windows.spont;

% Compute spontaneous rate for orientation stimuli files
fileInd = expt.analysis.orientation.fileInd;

% Filter spikes
spikes = filtspikes(spikes,0,'fileInd',fileInd,'assigns',unit.assign);

% Compute spontaneous firing rate
[fr fr_sem] = computeFR(spikes,w);

% Assign rate to unit struct
unit.spontrate = [fr; fr_sem];