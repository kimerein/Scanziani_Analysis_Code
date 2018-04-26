
thresh=3*10^-4;

T5_spikes=filtspikes(T5_spikes,0,'stimcond',[3 6 9 12 15 18]);
T6_spikes=filtspikes(T6_spikes,0,'stimcond',[3 6 9 12 15 18]);
T7_spikes=filtspikes(T7_spikes,0,'stimcond',[3 6 9 12 15 18]);

% T5
a=unique(T5_spikes.assigns);
thinUnitsAssigns=[];
regUnitsAssigns=[];
for j=1:length(a)
    if T5_unitAvs(j)<=thresh
        thinUnitsAssigns=[thinUnitsAssigns; a(j)];
    else
        regUnitsAssigns=[regUnitsAssigns; a(j)];
    end
end
allThinNames={};
allRegNames={};
for i=1:length(thinUnitsAssigns)
    allThinNames={allThinNames{1:end},strcat('T5_',num2str(thinUnitsAssigns(i)))};
end
for i=1:length(regUnitsAssigns)
    allRegNames={allRegNames{1:end},strcat('T5_',num2str(regUnitsAssigns(i)))};
end
% allThinNames={'T5_1','T5_6'};
% allRegNames={'T5_2','T5_3','T5_4','T5_5','T5_8','T5_9','T5_13','T5_15'};
thinSpikes5=filtspikes(T5_spikes,0,'assigns',thinUnitsAssigns');
regSpikes5=filtspikes(T5_spikes,0,'assigns',regUnitsAssigns');

% thinSuppression=[];
% regSuppression=[];
% for i=1:length(thinUnitsAssigns)
%     currNoLED=filtspikes(T5_spikes,0,'assigns',thinUnitsAssigns(i),'led',0);
%     currLED=filtspikes(T5_spikes,0,'assigns',thinUnitsAssigns(i),'led',5);
%     noLEDspikes=sum(((currNoLED.spiketimes>1) + (currNoLED.spiketimes<2))-1);
%     LEDspikes=sum(((currLED.spiketimes>1) + (currLED.spiketimes<2))-1);
%     % Have to normalize by number of trials and length of interval
%     noLEDspikes=noLEDspikes/length(unique(currNoLED.trials));
%     LEDspikes=LEDspikes/length(unique(currLED.trials));
%     thinSuppression=[thinSuppression; noLEDspikes-LEDspikes];
% end
% for i=1:length(regUnitsAssigns)
%     currNoLED=filtspikes(T5_spikes,0,'assigns',regUnitsAssigns(i),'led',0);
%     currLED=filtspikes(T5_spikes,0,'assigns',regUnitsAssigns(i),'led',5);
%     noLEDspikes=sum(((currNoLED.spiketimes>1) + (currNoLED.spiketimes<2))-1);
%     LEDspikes=sum(((currLED.spiketimes>1) + (currLED.spiketimes<2))-1);
%     noLEDspikes=noLEDspikes/length(unique(currNoLED.trials));
%     LEDspikes=LEDspikes/length(unique(currLED.trials));
%     regSuppression=[regSuppression; noLEDspikes-LEDspikes];
% end

% T6
a=unique(T6_spikes.assigns);
thinUnitsAssigns=[];
regUnitsAssigns=[];
for j=1:length(a)
    if T6_unitAvs(j)<=thresh
        thinUnitsAssigns=[thinUnitsAssigns; a(j)];
    else
        regUnitsAssigns=[regUnitsAssigns; a(j)];
    end
end
for i=1:length(thinUnitsAssigns)
    allThinNames={allThinNames{1:end},strcat('T6_',num2str(thinUnitsAssigns(i)))};
end
for i=1:length(regUnitsAssigns)
    allRegNames={allRegNames{1:end},strcat('T6_',num2str(regUnitsAssigns(i)))};
end
% allThinNames={allThinNames{1:end},'T6_1','T6_3','T6_10','T6_18','T6_32'};
% allRegNames={allRegNames{1:end},'T6_6','T6_8','T6_12','T6_13','T6_16','T6_17','T6_19','T6_22','T6_26','T6_28','T6_34','T6_35','T6_43','T6_44','T6_56','T6_62'};
thinSpikes6=filtspikes(T6_spikes,0,'assigns',thinUnitsAssigns');
regSpikes6=filtspikes(T6_spikes,0,'assigns',regUnitsAssigns');

% thinSuppression=[];
% regSuppression=[];
% for i=1:length(thinUnitsAssigns)
%     currNoLED=filtspikes(T6_spikes,0,'assigns',thinUnitsAssigns(i),'led',0);
%     currLED=filtspikes(T6_spikes,0,'assigns',thinUnitsAssigns(i),'led',5);
%     noLEDspikes=sum(((currNoLED.spiketimes>1) + (currNoLED.spiketimes<2))-1);
%     LEDspikes=sum(((currLED.spiketimes>1) + (currLED.spiketimes<2))-1);
%     % Have to normalize by number of trials and length of interval
%     noLEDspikes=noLEDspikes/length(unique(currNoLED.trials));
%     LEDspikes=LEDspikes/length(unique(currLED.trials));
%     thinSuppression=[thinSuppression; noLEDspikes-LEDspikes];
% end
% for i=1:length(regUnitsAssigns)
%     currNoLED=filtspikes(T6_spikes,0,'assigns',regUnitsAssigns(i),'led',0);
%     currLED=filtspikes(T6_spikes,0,'assigns',regUnitsAssigns(i),'led',5);
%     noLEDspikes=sum(((currNoLED.spiketimes>1) + (currNoLED.spiketimes<2))-1);
%     LEDspikes=sum(((currLED.spiketimes>1) + (currLED.spiketimes<2))-1);
%     noLEDspikes=noLEDspikes/length(unique(currNoLED.trials));
%     LEDspikes=LEDspikes/length(unique(currLED.trials));
%     regSuppression=[regSuppression; noLEDspikes-LEDspikes];
% end

% T7
a=unique(T7_spikes.assigns);
thinUnitsAssigns=[];
regUnitsAssigns=[];
for j=1:length(a)
    if T7_unitAvs(j)<=thresh
        thinUnitsAssigns=[thinUnitsAssigns; a(j)];
    else
        regUnitsAssigns=[regUnitsAssigns; a(j)];
    end
end
for i=1:length(thinUnitsAssigns)
    allThinNames={allThinNames{1:end},strcat('T7_',num2str(thinUnitsAssigns(i)))};
end
for i=1:length(regUnitsAssigns)
    allRegNames={allRegNames{1:end},strcat('T7_',num2str(regUnitsAssigns(i)))};
end
% allThinNames={allThinNames{1:end},'T7_1','T7_14'};
% allRegNames={allRegNames{1:end},'T7_9','T7_10','T7_11','T7_12','T7_13','T7_15','T7_16'};
thinSpikes7=filtspikes(T7_spikes,0,'assigns',thinUnitsAssigns');
regSpikes7=filtspikes(T7_spikes,0,'assigns',regUnitsAssigns');

% thinSuppression=[];
% regSuppression=[];
% for i=1:length(thinUnitsAssigns)
%     currNoLED=filtspikes(T7_spikes,0,'assigns',thinUnitsAssigns(i),'led',0);
%     currLED=filtspikes(T7_spikes,0,'assigns',thinUnitsAssigns(i),'led',5);
%     noLEDspikes=sum(((currNoLED.spiketimes>1) + (currNoLED.spiketimes<2))-1);
%     LEDspikes=sum(((currLED.spiketimes>1) + (currLED.spiketimes<2))-1);
%     % Have to normalize by number of trials and length of interval
%     noLEDspikes=noLEDspikes/length(unique(currNoLED.trials));
%     LEDspikes=LEDspikes/length(unique(currLED.trials));
%     thinSuppression=[thinSuppression; noLEDspikes-LEDspikes];
% end
% for i=1:length(regUnitsAssigns)
%     currNoLED=filtspikes(T7_spikes,0,'assigns',regUnitsAssigns(i),'led',0);
%     currLED=filtspikes(T7_spikes,0,'assigns',regUnitsAssigns(i),'led',5);
%     noLEDspikes=sum(((currNoLED.spiketimes>1) + (currNoLED.spiketimes<2))-1);
%     LEDspikes=sum(((currLED.spiketimes>1) + (currLED.spiketimes<2))-1);
%     noLEDspikes=noLEDspikes/length(unique(currNoLED.trials));
%     LEDspikes=LEDspikes/length(unique(currLED.trials));
%     regSuppression=[regSuppression; noLEDspikes-LEDspikes];
% end

allThin=concatSpikes_fromSameFiles(expt,allThinNames,[],[]);
allReg=concatSpikes_fromSameFiles(expt,allRegNames,[],[]);

scriptForComparingMUA(allThin);
scriptForComparingMUA(allReg);

figure();
hist(thinSuppression);
figure();
hist(regSuppression);

