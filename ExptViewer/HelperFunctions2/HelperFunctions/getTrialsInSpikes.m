function trials  = getTrialsInSpikes(spikes,fileInd)
% function trials  = getTrialsInSpikes(spikes,fileInd)
% BA
fileIndsInSpikes = unique(spikes.sweeps.file) ;
for i = 1: length(fileIndsInSpikes) % get ntriggers for each file
    ntriggers(i) = sum(spikes.sweeps.file==fileIndsInSpikes(i));
end

clear startTrial endTrial;
trials = [];
for i =1:length(fileInd)
    temp = find(fileIndsInSpikes==(fileInd(i)));
    if isempty(temp)
        error(sprintf('fileInd %d does not exist in the spikes struct',fileInd(i)));
    end
    
%     trial(1,1) is the Starttrial for fileInd(i)
%     trial(1,2) is the Endtrial for fileInd(i)
    if temp==1
        startTrial(i)= 1;
    else
        startTrial(i) = sum(ntriggers(1:temp-1))+1;
    end
  
    endTrial(i) = sum(ntriggers(1:temp));
    
    trials = [trials startTrial(i):endTrial(i)];
end

