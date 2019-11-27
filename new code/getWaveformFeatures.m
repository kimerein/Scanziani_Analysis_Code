function [halfwidth, peakToTrough, amp, avWaveforms]=getWaveformFeatures(spikes,Fs)

a=unique(spikes.assigns);

% Get halfwidths for units
avWaveforms=zeros(length(a),size(spikes.waveforms,2),size(spikes.waveforms,3));
evChsForAssigns={};
for j=1:length(a)
    avWaveforms(j,:,:)=mean(spikes.waveforms(spikes.assigns==a(j),:,:),1);
    evChsForAssigns{j}=spikes.info.detect.event_channel(spikes.assigns==a(j));
end
    
unitAvs=zeros(length(a),1);
peakToTrough=zeros(length(a),1);
amp=zeros(length(a),1);
for j=1:length(a)
    currEventCh=mode(evChsForAssigns{j});
    shift1=double(-avWaveforms(j,:,currEventCh))-min(double(-avWaveforms(j,:,currEventCh)));
    [peak,peakInd]=findpeaks(shift1,'SORTSTR','descend','NPEAKS',1);
    halfAmp=(peak-shift1(1))/2;
    amp(j)=peak-shift1(1);
    shift2=shift1-halfAmp;
    point1=find(shift2(peakInd:-1:1)<0,1,'first');
    if isempty(point1)
        point1=1;
    end
    point1=peakInd-point1+1;
    point2=find(shift2(peakInd:end)<0,1,'first');
    if isempty(point2)
        point2=length(shift2(peakInd:end));
    end
    point2=peakInd+point2-1;
    unitAvs(j)=point2-point1;
    
    [peak,peakInd]=findpeaks(double(-avWaveforms(j,:,currEventCh)),'SORTSTR','descend','NPEAKS',1);
    if length(avWaveforms(j,:,currEventCh))-peakInd<2
        troughInd=length(avWaveforms(j,:,currEventCh));
    else
        [trough,troughInd]=findpeaks(double(avWaveforms(j,peakInd:end,currEventCh)),'SORTSTR','descend','NPEAKS',1);
    end
    if isempty(troughInd)
        troughInd=length(avWaveforms(j,:,currEventCh));
    else
        troughInd(1)=troughInd(1)+peakInd-1;
    end
    peakToTrough(j)=(troughInd(1)-peakInd(1))/Fs;   
end
unitAvs=unitAvs/32000;
halfwidth=unitAvs;