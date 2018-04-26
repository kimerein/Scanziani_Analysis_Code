function unit = populateUnit_spikephasesORfreqs(unit, curExpt, curTrodeSpikes, varargin)
    if(length(varargin{1}) > 1)
        varargin = varargin{1};
    end
    
    field_name = varargin{1};
    
    tempspikes = filtspikes(curTrodeSpikes, 0, 'assigns', unit.assign);        
    % if the spike struct already has spikephases or freqs, life is easy
    if(isfield(tempspikes, field_name))
        if(~all(isnan(tempspikes.(field_name))))
            unit.(field_name) = tempspikes.(field_name);            
            return;
        elseif(strcmp(field_name, 'mean_spike_phase') && ~all(isnan(tempspikes.spikephases)))
            unit.mean_spike_phase = circularMean(tempspikes.spikephases, 360, 1);
        end
    end
    
    % otherwise, let's extract spikephases and save (with permission) the intermediate steps
    % for later
    disp(['populateUnit_spikephasesORfreqs: Unit (expt: ', unit.expt_name, ', trode: ', num2str(unit.trode_num), ', assign: ', num2str(unit.assign), ', label: ', unit.label, ') has no ', field_name, ' in spike struct.']);    
    loadPhases = 'n';
    if(nargin > 3)        
        if(strcmpi(varargin{2}, 'ask'))
            loadPhases = input(['Do you want to extract ', field_name, ' from the raw data? (press ''y'' to load, anything else to skip)'], 's');
        else
            loadPhases = varargin{2};
        end            
    end
    if(~strcmpi(loadPhases, 'y') && ~strcmpi(loadPhases, 'yes') && ~strcmpi(loadPhases, '1'))
        disp('Skipping...');
        unit.spikephases = [];
        return;
    end
    
    disp('Extracting spikephases from raw data... this will take a while.');
    oscillationRange = [20, 80]; % hz
    [spikephases, spikefreqs, spikepows] = extractSpikePhasesAndFreqs(curExpt, unit, curTrodeSpikes, 0, oscillationRange);
    
    if(strcmp(field_name, 'spikephases'))
        unit.spikephases = spikephases;       
    elseif(strcmp(field_name, 'spikefreqs'))
        unit.spikefreqs = spikefreqs;
    elseif(strcmp(field_name, 'mean_spike_phase'))
        unit.mean_spike_phase = circularMean(spikephases, 360, 1);
    elseif(strcmp(field_name, 'spikepows'))
        unit.spikepows = spikepows;
    else
        warning('Unrecognized field name!');
    end
        
    
end


