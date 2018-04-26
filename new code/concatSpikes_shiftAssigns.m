function allTogether=concatSpikes_shiftAssigns(spikes1,spikes2)

allTogether.led=[spikes1.led spikes2.led];
allTogether.stimcond=[spikes1.stimcond spikes2.stimcond];
try
    allTogether.waveforms=[spikes1.waveforms; spikes2.waveforms];
catch
    disp('hey');
end
allTogether.spiketimes=[spikes1.spiketimes spikes2.spiketimes];
allTogether.info.detect.event_channel=[spikes1.info.detect.event_channel; spikes2.info.detect.event_channel];
allTogether.trials=[spikes1.trials spikes2.trials];
allTogether.unwrapped_times=[spikes1.unwrapped_times spikes2.unwrapped_times];
allTogether.fileInd=[spikes1.fileInd spikes2.fileInd];
allTogether.trigger=[spikes1.trigger spikes2.trigger];
allTogether.time=[spikes1.time spikes2.time];
allTogether.time=[spikes1.time spikes2.time];

allTogether.sweeps.fileInd=[spikes1.sweeps.fileInd spikes2.sweeps.fileInd];
allTogether.sweeps.trials=[spikes1.sweeps.trials spikes2.sweeps.trials];
allTogether.sweeps.trigger=[spikes1.sweeps.trigger spikes2.sweeps.trigger];
allTogether.sweeps.stimcond=[spikes1.sweeps.stimcond spikes2.sweeps.stimcond];
allTogether.sweeps.led=[spikes1.sweeps.led spikes2.sweeps.led];

a=unique(spikes1.assigns);
assignsOffset=max(a);
spikes2.assigns=spikes2.assigns+assignsOffset;
allTogether.assigns=[spikes1.assigns spikes2.assigns];