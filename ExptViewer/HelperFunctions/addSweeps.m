function expt = addSweeps(expt)
% function expt = addSweeps(expt) Adds the sweeps struct to the expt
% struct. The sweeps struct can be used for sorting files and triggers
% based on some condition such as the stimulus presented. Each sweep in an
% experiment is represented in the sweeps struct. Fields in expt.sweeps
% struct:
%   .fileInd: An index to the to the files and file properties in the
%   expt.files struct. .trigger: Trigger in the file in which the sweep
%   occurred. .trials: A sequential list of trials. E.g. 4 files of 48
%   triggers would correspond to trials 1:4*48
%
%   Created: 3/15/10 - SRO Modified: BA removed some fields from list cause
%   not used here 4/9/10 Removed 'file' field and replaced with 'fileInd' -
%   SRO and BA

% Initialize the sweeps struct with correct number of elements and fields
CLASS = 'single';

fieldList = {'fileInd','trials','trigger'};
numTrials = sum(expt.files.triggers);
for i = 1:length(fieldList)
    expt.sweeps.(fieldList{i}) = nan(1,numTrials,CLASS);
end

% Assign values to sweeps struct
startInd = 1;
for i = 1:length(expt.files.names) 
    fileInd = i; 
    numTriggers = expt.files.triggers(i);
    expt.sweeps.fileInd(startInd:startInd+numTriggers-1) = single(fileInd);
    expt.sweeps.trigger(startInd:startInd+numTriggers-1) = single(1:expt.files.triggers(i));
    startInd = startInd + expt.files.triggers(i);
end

expt.sweeps.trials =  single(1:numTrials);
expt.sweeps = addTimeToSweeps(expt.sweeps,expt);

