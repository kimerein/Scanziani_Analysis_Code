function spikes = makeNewSpikesFormat(spikes,bremoveOld)
% function spikes = makeNewSpikesFormat(spikes,bremoveOld)
% BA 0419

% RigDefaultsScript

if nargin <2, bremoveOld = 0; end

if isfield(spikes,'sweeps')
    if isfield(spikes.sweeps,'trial')
        spikes.sweeps.trials = spikes.sweeps.trial;
    end
    
    if isfield(spikes.sweeps,'file')
        spikes.sweeps.fileInd = spikes.sweeps.file;
    end
    
    
    if ~isfield(spikes,'fileInd')
        spikes.fileInd = spikes.sweeps.fileInd(spikes.trials);
    end
end

if isfield(spikes,'file')
    spikes.fileInd = spikes.file;
end

if bremoveOld
    if isfield(spikes,'sweeps')
        spikes.sweeps = rmfield(spikes.sweeps,'trial');
        spikes.sweeps = rmfield(spikes.sweeps,'file');
    end
end


if ~isfield(spikes,'unwrapped_times')
    spikes.unwrapped_times = single( unwrap_time( spikes.spiketimes, spikes.trials, spikes.info.detect.dur, spikes.params.display.trial_spacing ) );
end

if ~isfield(spikes.params,'initial_split_figure_panels')
    spikes.params.initial_split_figure_panels = 15;
end
% save(fullfile(RigDefaults.DirAnalyzed,'SortedSpikes',getFilename(spikes.info.spikesfile)),'spikes')
if ~isfield(spikes.params.display,'show_gmm_overlap')
    spikes.params.display.show_gmm_overlap = 0;
end
