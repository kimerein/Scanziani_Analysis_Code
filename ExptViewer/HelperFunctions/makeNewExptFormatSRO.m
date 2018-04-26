function expt = makeNewExptFormatSRO(expt)
%
%
%
%

% Created: 7/16/10 - SRO

if ~isfield(expt.info,'structversion')
    oldversion = 0;
else
    oldversion = expt.info.structversion;
    if ~isnumeric(oldversion)
        oldversion = str2double(oldversion);
    end
end

if oldversion < 2.0
    
    disp('Updating expt struct to version 2.0')
    
    % Pull .probe out of .info to make expt.probe
    if isfield(expt.info,'probe')
        probe = expt.info.probe;
        expt.probe = probe;
        expt.info = rmfield(expt.info,'probe');
    end
    
    % Remove .sort field from .trode
    if isfield(expt.sort.trode,'sort')
        expt.sort.trode = rmfield(expt.sort.trode,'sort');
    end
    
    % Add .waveform struct to .unit
    expt = addWaveformStruct(expt);
    
    expt.info.structversion = '2.0';
end



% --- Subfunctions --- %

function expt = addWaveformStruct(expt)

ntrodes = length(expt.sort.trode);

addfields = {'amplitude','width','peak','trough','troughpeakratio',...
    'maxampchannel','waveformtype','avgwave'};

rmfields = {'spikewaveform','avgwaveform','waveformtype'};

for i = 1:length(addfields)
    temp = addfields{i};
    w.(temp) = [];
end

for i = 1:ntrodes
    for j = 1:size(expt.sort.trode(i).unit,2)
        expt.sort.trode(i).unit(j).waveform = w;
    end
    expt.sort.trode(i).unit = rmfield(expt.sort.trode(i).unit,rmfields);
end



