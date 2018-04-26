function expt = analysis_def(expt,analysisType)
% function expt = analysis_def(expt,analysisType)
%   Sets default fields and values for SRO's analysis struct
%
%
%

% Created: 5/23/10 - SRO
% Modified: 10/18/10 - SRO


if nargin < 2
    analysisType = {'overview','orientation','contrast','srf','other'};
end

% --- Set fields for all analysis types
field = {'fileInd','stim','cond','w'};
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

% --- Default windows (in seconds)
for i = 1:length(analysisType)
    expt.analysis.(analysisType{i}).duration = 2.6;
    w.spont = [0 0.25];
    w.stim = [0.25 1.75];
    w.on = [0.25 0.75];
    w.off = [2 2.6];
    expt.analysis.(analysisType{i}).windows = w;
end

