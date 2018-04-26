function [spikephases, spikefreqs, spikepows] = extractSpikePhasesAndFreqs(expt, unit, spikes, resetAnyway, oscillationRange)
    if(nargin < 4)
        resetAnyway = 0;
    end
        
    rigdef = RigDefs;
    [unitspikes unitspikes_logvec] = filtspikes(spikes, 0, 'assigns', unit.assign);
    Fs = expt.files.Fs(unitspikes.fileInd(1));
        
    numspikes = length(unitspikes.spiketimes);
    seg_size = 1000; % number of spikes per segment
    numSegs = ceil(numspikes/seg_size);
    disp(['Extracting phases and frequencies for ', num2str(numspikes), ' spikes.']);
    disp(['The spikes will be processed in ', num2str(numSegs), ' segments of ', num2str(seg_size), ' spikes.']);    
    unitspikes.spikeidx = 1:numspikes;
    
    spikephases = nan(size(unitspikes.spiketimes));
    spikefreqs = nan(size(unitspikes.spiketimes));
    spikepows = nan(size(unitspikes.spiketimes));
    for(segIdx = 1:numSegs)
        spike_1 = (segIdx-1)*seg_size + 1;
        spike_end = min(segIdx*seg_size, numspikes);
        disp(['Processing spikes ', num2str(spike_1), '-', num2str(spike_end), ' ...']);
        % pick out a segment of the struct        
        
        spike_in_seg_fcn = @(spikeidx)((spikeidx >= spike_1) && (spikeidx <= spike_end));
        segspikes = filtspikes(unitspikes, 0, 'spikeidx', spike_in_seg_fcn);
        
        [wv outspikes st_lfp_idxvec] = extractSpikeTriggeredLFP(expt, 0.1, segspikes, 0);
        st_lfp_idxvec = st_lfp_idxvec+spike_1-1;
        
        %oscillationRange = [20, 80]; % hz
        wv = filtdata(wv,Fs,oscillationRange(2),'low');
        wv = filtdata(wv,Fs,oscillationRange(1),'high');
        
        [spikephasest, spikefreqst, spikepowst] = findSpikePhaseFromLFPWin(wv, [], 1);
        clear('wv');
        
        spikephases(st_lfp_idxvec) = spikephasest;
        spikefreqs(st_lfp_idxvec ) = squeeze(median(spikefreqst, 1));        
        spikepows(st_lfp_idxvec  ) = spikepowst;
        
    end

    if(resetAnyway)
        if(isfield(spikes, 'spikephases'))
            spikes = rmfield(spikes, 'spikephases');
        end
        if(isfield(spikes, 'spikefreqs'))
            spikes = rmfield(spikes, 'spikefreqs');
        end        
        if(isfield(spikes, 'spikepows'))
            spikes = rmfield(spikes, 'spikepows');
        end
    end
    
    if(~isfield(spikes, 'spikephases') || resetAnyway)    
        spikes.spikephases = nan(size(spikes.spiketimes));
    end
    if(~isfield(spikes, 'spikefreqs') || resetAnyway)
        spikes.spikefreqs = nan(size(spikes.spiketimes));
    end
    if(~isfield(spikes, 'spikepows') || resetAnyway)
        spikes.spikepows = nan(size(spikes.spiketimes));
    end
    
    idx_vector = find(unitspikes_logvec);
    spikes.spikephases(idx_vector) = spikephases;
    spikes.spikefreqs(idx_vector) = spikefreqs;
    spikes.spikepows(idx_vector) = spikepows;
    if(all(isnan(spikephases)))
        disp('NOTE: This unit''s phases are all NaN. Something went wrong.');
    end
    disp('Saving spikephases/spikefreqs to spikes struct...');
    full_fname_spikes = fullfile(rigdef.Dir.Spikes, spikes.info.spikesfile);
    if(~exist([full_fname_spikes, '.mat'], 'file'))
        disp(['Spikes file for trode#', num2str(unit.trode_num), ' not found at: ''', full_fname_spikes, ', saving without overwriting.']);
    end
    save(full_fname_spikes, 'spikes');
    
    
end

