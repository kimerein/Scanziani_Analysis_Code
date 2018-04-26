function expt = UpdateUnitStruct2(expt,spikes,trodeInd)
% function expt = UpdateUnitStruct2(expt,spikes,trodeInd)
%
%
%
%
%
%

% Created: SRO - 5/6/11

rdef = RigDefs;

unit = expt.sort.trode(trodeInd).unit;

% Determine number of units from spikes file
unitAssigns = unique(spikes.assigns);
numUnits = numel(unitAssigns);

% Update units struct
for i = 1:numUnits
    if isfield(spikes,'labels')
        unit(i).label = spikes.params.display.label_categories{spikes.labels(spikes.labels(:,1)==unitAssigns(i),2)};
    else
        unit(i).label = 'NaN';
    end
    unit(i).assign = unitAssigns(i);
    unit(i).rpv = [];
    unit(i).spikespersec = [];
    unit(i).peakrate = [];
    unit(i).spontaneousrate = [];
    unit(i).numspikes = NaN;
    unit(i).bursting = [];
    unit(i).clustertype = [];
    unit(i).priority = [];
    unit(i).channels = expt.sort.trode(trodeInd).channels;
    unit(i).maxchannel = [];
    unit(i).waveformtype = [];
    unit(i).spikespersec = [];
    unit(i).peakrate = [];
    unit(i).waveform.amplitude = [];             % Need function that pulls out these paramters from raw data
    unit(i).waveform.width = [];
    unit(i).waveform.peak = [];
    unit(i).waveform.trough = [];
    unit(i).waveform.troughpeakratio = [];
    unit(i).waveform.maxchannel = [];
    unit(i).waveform.waveformtype = [];
    unit(i).waveform.avgwave = NaN;
end

expt.sort.trode(trodeInd).unit = unit;

% Save expt struct
save(fullfile(rdef.Dir.Expt,getFilename(expt.info.exptfile)),'expt');


