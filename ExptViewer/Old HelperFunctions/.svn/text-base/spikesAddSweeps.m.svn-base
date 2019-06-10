function spikes = spikesAddSweeps(spikes,expt,trodeInd)
%
% Make sweeps struct and add to spikes. Note: The trials and trigger fields
% are distinct in that trials is indexed from 1:total number of sweeps that
% were detected/sorted, whereas trigger indexes each sweep according to the
% file in which the sweep occured. (e.g. For 2 files with 48 sweeps, trigger
% will run from 1:48 then will start at 1 for the next file, whereas trials
% will increment from 1:96).
%
%
%   Modidified: 4/13/10 - SRO: Pulled this out of DetectSpikes and
%   simplified code using filtsweeps


fileInds = expt.sort.trode(trodeInd).fileInds;
numTrials = sum(expt.files.triggers(fileInds));

% Get .sweeps field list from expt struct.
fieldList = fieldnames(expt.sweeps);
reqSize = size(expt.sweeps.fileInd);  % Fields with size == .fileInd will be added
for i = 1:length(fieldList)
    if isequal(size(expt.sweeps.(fieldList{i})),reqSize);
        sweeps.(fieldList{i}) = nan(1,numTrials);
    end
end

fieldList = fieldnames(sweeps);
startInd = 1;
for  i = fileInds
    numTriggers = expt.files.triggers(i);
    for j = 1:length(fieldList)  % Simplified by using filtsweeps - SRO
        tempSweeps = filtsweeps(expt.sweeps,0,'fileInd',i);
        sweeps.(fieldList{j})(startInd:startInd+numTriggers-1) = tempSweeps.(fieldList{j});
    end
    startInd = startInd + numTriggers;
end

sweeps.trials = 1:numTrials;
spikes.sweeps = sweeps;
