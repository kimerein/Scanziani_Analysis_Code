function newSpikes=addLEDtoSpikes(spikes, expt)

newSpikes=spikes;
for i=1:length(spikes.led)
    currFileInd=spikes.fileInd(i);
    currTrigger=spikes.trigger(i);
    % Find LED condition for this daq file for this trigger
    firstIndForThisDaqFile=find(expt.sweeps.fileInd==currFileInd,1,'first');
    corrIndIntoLED=firstIndForThisDaqFile+(currTrigger-1);
    newSpikes.led(i)=expt.sweeps.led(corrIndIntoLED);
end

% Now fix spikes.sweeps.led
for i=1:length(newSpikes.sweeps.led)
    currFileInd=newSpikes.sweeps.fileInd(i);
    currTrigger=newSpikes.sweeps.trigger(i);
    firstInd=find(expt.sweeps.fileInd==currFileInd,1,'first');
    corrIndIntoLED=firstInd+(currTrigger-1);
    newSpikes.sweeps.led(i)=expt.sweeps.led(corrIndIntoLED);
end
    

