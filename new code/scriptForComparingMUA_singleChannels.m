function scriptForComparingMUA_singleChannels(spikes)

useThisChannelOfTrode=4;
useTheseFileInds=[28:30];
ledValue=5;

spikes.event_channel=spikes.info.detect.event_channel;
spikes=filtspikes(spikes,0,'event_channel',useThisChannelOfTrode);

allUnits_withLED=filtspikes(spikes,0,'led',ledValue,'fileInd',useTheseFileInds);
allUnits_noLED=filtspikes(spikes,0,'led',0,'fileInd',useTheseFileInds);

allSpiketimes_withLED=[];
allSpiketimes_noLED=[];

figure();
[hPsth1,hAxes1,n1,centers1,edges1,xpoints1,ypoints1]=psth(allUnits_noLED,40);
figure();
[hPsth2,hAxes2,n2,centers2,edges2,xpoints2,ypoints2]=psth(allUnits_withLED,40);

figure();
plot(xpoints1,ypoints1,'Color','black');
%axis([0 5 0 180]);
hold on;
plot(xpoints2,ypoints2,'Color','red');
%axis([0 5 0 180]);
hold off;

end