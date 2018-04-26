function [wv outspikes sortvector_idx] = extractSpikeTriggeredLFP( expt, windowLengthSecs, spikes, dosave, data_directory)    
    
    % windowLengthSecs should be about 0.1 (seconds)
    rigdef = RigDefs;
    if(nargin < 5)
        data_directory = rigdef.Dir.Data;
    end
    if(nargin < 4)
        dosave = 1;
    end
            
    fileInd = unique(spikes.fileInd);
    trodeNum = spikes.info.trodeInd;
    unit = unique(spikes.assigns);
    
    Fs = expt.files.Fs(1);
    windowLengthSamples = round(Fs*windowLengthSecs); % window length in samples ON EITHER SIDE OF SPIKE    
    
    chns = expt.sort.trode(trodeNum).channels; 
    %disp(['Extracting LFP segments for ', num2str(length(spikes.spiketimes)), ' spikes.'])   
   
    % find the channel this unit spikes maximally on
    if(length(size(spikes.waveforms)) == 3)
        avgwaveform = squeeze(mean(spikes.waveforms,1));
        waveformpeaks = squeeze(max(avgwaveform,[],1));
        maxchannel = chns( find(waveformpeaks == max(waveformpeaks), 1) );   
    elseif(length(size(spikes.waveforms)) == 2)
        disp('Dimension of waveforms field in spike struct indicates only one channel is present. Using first channel of data.');
        maxchannel = 1;
    else
        error('Dimension of waveforms field on spike struct must be 3 or 2, and only 2 if there is one channel of data.');
    end
    
    % grab the spike-associated LFP waveforms
    
    if(length(unit) == 1)
        unit_tag = ['T',num2str(trodeNum), '_', num2str(unit)];
    else
        unit_tag = 'multipleUnits';
    end
    [wv outspikes sortvector_idx] = spikeTrigLFP(expt, spikes, windowLengthSecs, maxchannel, [0 min(expt.files.duration)], [], data_directory);
    if(dosave)
        save([expt.name,'_', unit_tag, '_f', num2str(fileInd(1)), '-', num2str(fileInd(end)), '-wspik'], 'wv', 'outspikes');
    end
 

end

