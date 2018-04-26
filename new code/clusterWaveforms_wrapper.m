% Put together all spikes

newExpt_s=concatSpikes_shiftAssigns(newExpt_T7,newExpt_T8);

% s=concatSpikes_shiftAssigns(T5_spikes,T6_spikes);
% s=concatSpikes_shiftAssigns(s,T7_spikes);
% 
% s=concatSpikes_shiftAssigns(s,T5B_spikes);
% s=concatSpikes_shiftAssigns(s,T6B_spikes);
% T8B_spikes.waveforms(:,:,4)=zeros(size(T8B_spikes.waveforms,1),size(T8B_spikes.waveforms,2));
% s=concatSpikes_shiftAssigns(s,T8B_spikes);

[newExpt_clus, newExpt_X]=clusterWaveforms(newExpt_s);
