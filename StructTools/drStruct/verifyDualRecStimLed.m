function match = verifyDualRecStimLed(expt_names)
% function match = verifyDualRecStimLed(expt_names)
%
%
%

% Created: SRO - 6/8/11

rdef = RigDefs;

% Load experiments and get sweeps struct
for i = 1:length(expt_names)
   expt(i) = loadvar([rdef.Dir.Expt expt_names{i} '_expt']);
   sweeps(i) = expt(i).sweeps;
end

flds = fieldnames(sweeps);
for i = 1:length(flds)
    tmp = [];
    % Remove NaNs
    if strcmp(flds{i},'led')
        for s = 1:length(sweeps)
            sweeps(s).(flds{i})(isnan(sweeps(s).(flds{i}))) = 0;
        end
    end
    % Compare values
    for n = 1:length(sweeps(1).(flds{i}))
        tmp(end+1) = compareDouble(sweeps(1).(flds{i})(n),sweeps(1).(flds{i})(n));
    end
    match.(flds{i}) = all(tmp);
end

match