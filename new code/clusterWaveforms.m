function [clus, X]=clusterWaveforms(spikes)

% Get parameters for clustering
% 1. Suppression or activation during LED On
% 2. Delay until maximal LED effect
% 3. F1 - magnitude of response at temporal frequency of stimulus
% 4. Magnitude of visual response
% 5. Spontaneous firing rate
% 6. Average waveform half-width
% 7. Average waveform amplitude
% 8. Channel depth
% 8. Waveform peak-to-trough time
% 9. Magnitude of rebound at LED offset

clusters=[];

ledOnVal=5;
ledOnWindow=[1 2];
Fs=32000;

% 1,9,4,5
[sup,reb,vis,spont]=forWaveClust_getFRforWindows(spikes,ledOnVal);

% 2
effectDelay=delayUntilMaxLEDEffect(spikes,ledOnVal,ledOnWindow);

% 3
F1=calculateF1Response(spikes,2,0.1,[0 5],[1.8 2.2]);

% 6,8,7
[halfwidth peakToTrough amp]=getWaveformFeatures(spikes,Fs);

% 8
% Do later

% Cluster
%  1   2           3  4   5     6         7   8            9
X=[sup effectDelay F1 vis spont halfwidth amp peakToTrough reb];
k=3;
clus=kmeans(X,k);
figure();
scatter(sup,effectDelay,[],clus);
    
    

