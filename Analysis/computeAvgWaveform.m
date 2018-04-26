function varargout = computeAvgWaveform(waveforms)
%
%
%


avgwv = squeeze(mean(waveforms,1));

temp = any(min(min(avgwv)) == avgwv);
maxch = find(temp);

varargout{1} = avgwv;
varargout{2} = maxch;