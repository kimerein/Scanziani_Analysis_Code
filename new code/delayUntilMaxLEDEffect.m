function delay=delayUntilMaxLEDEffect(spikes,ledVal,ledOnWindow)

a=unique(spikes.assigns);
delay=zeros(length(a),1);
for i=1:length(a)
    % Is LED effect suppression or facilitation?
    noLED=filtspikes(spikes,0,'assigns',a(i),'led',0);
    LED=filtspikes(spikes,0,'assigns',a(i),'led',ledVal);
%     noLEDspikes=sum(((noLED.spiketimes>ledOnWindow(1)) + (noLED.spiketimes<ledOnWindow(2)))-1);
%     LEDspikes=sum(((LED.spiketimes>ledOnWindow(1)) + (LED.spiketimes<ledOnWindow(2)))-1);
%     % Have to normalize by number of trials and length of interval
%     noLEDspikes=noLEDspikes/(length(unique(noLED.trials))*(ledOnWindow(2)-ledOnWindow(1)));
%     LEDspikes=LEDspikes/(length(unique(LED.trials))*(ledOnWindow(2)-ledOnWindow(1)));
%     if noLEDspikes-LEDspikes>0
%         effect='suppression';
%     else
%         effect='facilitation';
%     end
    
    % Calculate time until maximal effect of LED
    noLED_FRs=[];
    LED_FRs=[];
    bin=0.05;
    binTimes=[];
    for j=0:bin:ledOnWindow(2)-ledOnWindow(1)
        if ledOnWindow(1)+j+bin>ledOnWindow(2)
            break
        else
            noLED_FRs=[noLED_FRs sum(((noLED.spiketimes>ledOnWindow(1)+j) + (noLED.spiketimes<ledOnWindow(1)+j+bin))-1)/length(unique(noLED.trials))];
            LED_FRs=[LED_FRs sum(((LED.spiketimes>ledOnWindow(1)+j) + (LED.spiketimes<ledOnWindow(1)+j+bin))-1)/length(unique(LED.trials))];
            binTimes=[binTimes j];
        end
    end
    diff=noLED_FRs-LED_FRs;
%     figure();
%     plot(binTimes,noLED_FRs,'Color','black');
%     figure();
%     plot(binTimes,LED_FRs,'Color','red');
%     figure();
%     plot(binTimes,diff,'Color','blue');
    [peak,peakDiffInd]=findpeaks(abs(diff),'SORTSTR','descend','NPEAKS',1);
    if isempty(peakDiffInd)
        timeOfPeak=ledOnWindow(2);
    else
        timeOfPeak=ledOnWindow(1)+peakDiffInd*bin-(bin/2);
    end
%     hold on;
%     plot([timeOfPeak-ledOnWindow(1) timeOfPeak-ledOnWindow(1)],[min(diff) max(diff)]);
    delay(i)=timeOfPeak;
end
delay=delay-ledOnWindow(1);