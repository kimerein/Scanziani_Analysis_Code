function expt = addTrodeSort(expt,trodeInd)
%
%   Add .sort.trode to expt

% Created: 4/9/10 - SRO
% Modified: 5/22/10 - SRO: Changed .fileInds to .fileInd. Removed .label.
% In .unit, removed .priority, .clustertype as these are superseded by
% unit.label.


% Add new trode
if trodeInd > 4
    prompt = {'Enter channels'};
    answer = inputdlg(prompt,'',1); pause(0.05);
    expt.sort.trode(trodeInd).channels =  str2num(answer{1});
    expt.sort.trode(trodeInd).name = ['T' num2str(trodeInd)];
else
    expt.sort.trode(trodeInd).channels = expt.probe.trode.sites{trodeInd};
    expt.sort.trode(trodeInd).name = expt.probe.trode.names{trodeInd};
end
expt.sort.trode(trodeInd).fileInds = [];
expt.sort.trode(trodeInd).threshtype = [];
expt.sort.trode(trodeInd).thresh = [];          % Update at end of Detect
expt.sort.trode(trodeInd).detected = 'no';
expt.sort.trode(trodeInd).clustered = 'no';
expt.sort.trode(trodeInd).sorted = 'no';
expt.sort.trode(trodeInd).numclusters = [];     % = unique(spikes.assigns)
expt.sort.trode(trodeInd).numunits = [];        % User defines a unit
expt.sort.trode(trodeInd).spikespersec = [];
expt.sort.trode(trodeInd).spikesfile = [];
% Set sort.trode(m).units(n) fields
expt.sort.trode(trodeInd).unit.trode = [];
expt.sort.trode(trodeInd).unit.channels = [];
expt.sort.trode(trodeInd).unit.assign = [];
expt.sort.trode(trodeInd).unit.label = [];
expt.sort.trode(trodeInd).unit.rpv = [];
expt.sort.trode(trodeInd).unit.spikespersec = [];
expt.sort.trode(trodeInd).unit.peakrate = [];
expt.sort.trode(trodeInd).unit.spontaneousrate = [];
expt.sort.trode(trodeInd).unit.numspikes = [];
expt.sort.trode(trodeInd).unit.bursting = [];
expt.sort.trode(trodeInd).unit.waveform.amplitude = [];             % Need function that computes these paramters from raw data
expt.sort.trode(trodeInd).unit.waveform.width = [];
expt.sort.trode(trodeInd).unit.waveform.peak = [];
expt.sort.trode(trodeInd).unit.waveform.trough = [];
expt.sort.trode(trodeInd).unit.waveform.troughpeakratio = [];
expt.sort.trode(trodeInd).unit.waveform.maxampchannel = [];
expt.sort.trode(trodeInd).unit.waveform.waveformtype = [];
expt.sort.trode(trodeInd).unit.waveform.avgwave = [];


