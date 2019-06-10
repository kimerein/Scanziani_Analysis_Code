function expt = addAnalysisSRO(expt)
%
%
%
%
% Created: 5/23/10  - SRO
% Modified: 7/15/10 - SRO

% Define analysis types
analysisType = {'orientation','contrast','srf'};

% --- Set fields for all analysis types
field = {'fileInd','stim','cond','windows'};
for i = 1:length(analysisType)
    for k = 1:length(field)
        expt.analysis.(analysisType{i}).(field{k}) = [];
    end
end

% --- Set stim fields
field = {'values','code'};
for i = 1:length(analysisType)
    for k = 1:length(field)
        expt.analysis.(analysisType{i}).stim.(field{k}) = [];
    end
end

% --- Set cond fields
field = {'type','values','tags','color'};
for i = 1:length(analysisType)
    for k = 1:length(field)
        expt.analysis.(analysisType{i}).cond.(field{k}) = [];
    end
end

% Define time windows in seconds
stimType = {'Drifting gratings','Reversing gratings','Localized gratings'};
for i = 1:length(analysisType)
    
    % Determine whether stimulus was given
    if ~isfield(expt.files,'stimType')
        expt.files.stimType=[];
    end
    fileInd = strcmp(stimType{i},expt.files.stimType);
    fileInd = min(find(fileInd));
    
    if fileInd
        sweepDuration = expt.files.duration(fileInd);
        if isfield(expt.stimulus(fileInd).params,'delay')
            stimOn = expt.stimulus(fileInd).params.delay;
        else
            stimOn = 0.15; % Default from early experiments
        end
        if isfield(expt.stimulus(fileInd).params,'StimDuration') % PSC
            stimOff = stimOn + expt.stimulus(fileInd).params.StimDuration;
        elseif isfield(expt.stimulus(fileInd).params,'duration') % VSC
            stimOff = stimOn + expt.stimulus(fileInd).params.duration;
        end
        w.spont = [0 stimOn];
        w.stim = [stimOn stimOff];
        w.on = [stimOn stimOn+0.5];
        w.off = [stimOff+0.1 sweepDuration];
    else
        w.spont = [];
        w.stim = [];
        w.on = [];
        w.off = [];
        sweepDuration = [];
    end
    
    expt.analysis.(analysisType{i}).duration = sweepDuration;
    expt.analysis.(analysisType{i}).windows = w;
end



