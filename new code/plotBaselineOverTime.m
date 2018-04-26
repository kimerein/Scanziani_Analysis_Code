function plotBaselineOverTime(spikes)

useTheseFileInds=[9:86];
timeWindow=[0 1];

allUnits_withLED=filtspikes(spikes,0,'led',1,'fileInd',useTheseFileInds);
allUnits_noLED=filtspikes(spikes,0,'led',0,'fileInd',useTheseFileInds);

LEDspikesOverTime=zeros(length(useTheseFileInds),1);
noLEDspikesOverTime=zeros(length(useTheseFileInds),1);
for i=useTheseFileInds
    thisDaqSpikes_withLED=filtspikes(allUnits_withLED,0,'fileInd',i);
    thisDaqSpikes_noLED=filtspikes(allUnits_noLED,0,'fileInd',i);
    nLEDTrials=length(unique(thisDaqSpikes_withLED.trigger));
    nNoLEDTrials=length(unique(thisDaqSpikes_noLED.trigger));
    thisDaqSpiketimes_withLED=thisDaqSpikes_withLED.spiketimes;
    thisDaqSpiketimes_noLED=thisDaqSpikes_noLED.spiketimes;
    countSpikesInWindow=0;
    for j=1:length(thisDaqSpiketimes_withLED)
        if thisDaqSpiketimes_withLED(j)>timeWindow(1) && thisDaqSpiketimes_withLED(j)<timeWindow(2)
            countSpikesInWindow=countSpikesInWindow+1;
        end
    end
    LEDspikesInWindow=countSpikesInWindow;
    countSpikesInWindow=0;
    for j=1:length(thisDaqSpiketimes_noLED)
        if thisDaqSpiketimes_noLED(j)>timeWindow(1) && thisDaqSpiketimes_noLED(j)<timeWindow(2)
            countSpikesInWindow=countSpikesInWindow+1;
        end
    end
    noLEDspikesInWindow=countSpikesInWindow;
    disp(nLEDTrials);
    disp(nNoLEDTrials);
    LEDspikesOverTime(i)=LEDspikesInWindow/nLEDTrials;
    noLEDspikesOverTime(i)=noLEDspikesInWindow/nNoLEDTrials;
end

figure();
scatter(1:length(LEDspikesOverTime),LEDspikesOverTime,'r');
hold all;
scatter(1:length(noLEDspikesOverTime),noLEDspikesOverTime,'k');




% figure(1);
% [hPsth1,hAxes1,n1,centers1,edges1,xpoints1,ypoints1]=psth(allUnits_noLED,10);
% figure(2);
% [hPsth2,hAxes2,n2,centers2,edges2,xpoints2,ypoints2]=psth(allUnits_withLED,10);
% 
% figure();
% plot(xpoints1,ypoints1,'Color','black');
% hold on;
% plot(xpoints2,ypoints2,'Color','red');
% hold off;

end