function scriptForComparingMUA(spikes,useTheseFileInds)

%useTheseFileInds=[1:48];
%useTheseFileInds=[14:19];
ledValue=[0 5];

%spikes=filtspikes(spikes,0,'stimcond',1:3:24); 

% allUnits_withLED=spikes;
% allUnits_noLED=spikes;

if ~isempty(useTheseFileInds)
    allUnits_withLED=filtspikes(spikes,0,'led',ledValue,'fileInd',useTheseFileInds);
    allUnits_noLED=filtspikes(spikes,0,'led',0,'fileInd',useTheseFileInds);
else
    allUnits_withLED=filtspikes(spikes,0,'led',ledValue);
    allUnits_noLED=filtspikes(spikes,0,'led',0);
end

allSpiketimes_withLED=[];
allSpiketimes_noLED=[];

figure();
[hPsth1,hAxes1,n1,centers1,edges1,xpoints1,ypoints1]=psth_5sDuration(allUnits_noLED,60);
figure();
[hPsth2,hAxes2,n2,centers2,edges2,xpoints2,ypoints2]=psth_5sDuration(allUnits_withLED,60);

figure();
plot(xpoints1,ypoints1,'Color','black');
hold on;
plot(xpoints2,ypoints2,'Color','red');
hold off;

end