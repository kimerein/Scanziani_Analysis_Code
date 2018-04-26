function [phase freq pows] = findSpikePhaseFromLFPWin(lfp, windowTimeInSamples, useHilbert)
% Takes a matrix of LFP traces where each column is a LFP trace centered on
% a spike, and a ~1/3 target period windowTimeInSamples, and computes the
% phase associated w/ that spike.
% If useHilbert = 0 or not specified, phase is found by (spiketime -
% peak0)/(peak1 - peak0) * 360 degrees, otherwise by hilbert transform
Fs = 32000;
if(nargin < 2)
    windowTimeInSamples = round(0.018*Fs); % 18ms in samples
elseif(nargin < 3)
    useHilbert = false;
end
pows = [];

num_sweeps = size(lfp, 2);
spikesample = round(size(lfp, 1)/2);

if(~useHilbert)
    lfp = lfp((spikesample-windowTimeInSamples):(spikesample+windowTimeInSamples), :);
    len_lfp = size(lfp, 1); % need to get new size
    spikesample = round(size(lfp, 1)/2); % recompute center
    
    lastpeak = squeeze(max(lfp(1:spikesample,   :), [], 1));
    nextpeak = squeeze(max(lfp(spikesample:end, :), [], 1));
    for( i = 1:num_sweeps )    
        t0(i) = find(lfp(:, i) == lastpeak(i) );
        t1(i) = find(lfp(:, i) == nextpeak(i) );
        nextmin = squeeze(  min(   lfp(t0(i):t1(i), i),  [],1)  );
        %pi_t(i) = find(lfp(:, i) == nextmin);
    end
    phase = (spikesample - t0) ./ (t1 - t0) * 360;
    freq = 1 ./ (t1 - t0) * Fs; 
    
else
    % compare w/ hilbert estimate
    hlfp = hilbert(lfp);
    %for(i = 1:size(lfp, 2)) % do this in a loop instead of processing matrix to save memory
    %    hlfp(:, i) = hilbert(lfp(:, i));
    %end
    tempphase = angle(hlfp);
    tempphase(tempphase < 0) = tempphase(tempphase < 0) + 2*pi;
    phase = squeeze(tempphase(spikesample, :))*(180/pi);
    phase = phase(:);
    freq = diff(unwrap(angle(hlfp), [], 1), 1, 1) * Fs/(2*pi);
    pows = sum(abs(hlfp).^2, 1);
end

end

