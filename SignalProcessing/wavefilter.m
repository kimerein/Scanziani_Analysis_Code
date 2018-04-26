% Matlab code for wavelet filtering.
% This function requires the Wavelet Toolbox.

function data = wavefilter(data, maxlevel)
% fdata = wavefilter(data, maxlevel)
% data	- an N x M array of continuously-recorded raw data
%		where N is the number of channels, each containing M samples
% maxlevel - the level of decomposition to perform on the data. This integer
%		implicitly defines the cutoff frequency of the filter.
% 		Specifically, cutoff frequency = samplingrate/(2^(maxlevel+1))
%
% Based on XX code
% modified for 3D matrix by BA

% bChopUpData = 1;% because arrays get too big and wavefilter chokes

numwires =1;
if ndims(data)==3
    [numpoints, numsweeps, numwires] = size(data);
else
    [numpoints, numsweeps] = size(data);
end

% bChopped = 0; % flag set to 1 if data gets chopped
% if bChopUpData
%     if numpoints >  10*32e3% arb limit
%         if ndims
%         bChopped = 1
%         realnumpoints = numpoints;
%         

% fdata = zeros(numpoints,numsweeps,numwires,class(data));

% We will be using the Daubechies(4) wavelet.
% Other available wavelets can be found by typing 'wavenames'
% into the Matlab console.
wname = 'db4'; 


for j=1:numwires % For each wire
    for i=1:numsweeps % For each wire
        
        
        % Decompose the data
        [c,l] = wavedec(data(:,i,j), maxlevel, wname);
        % Zero out the approximation coefficients
        c = wthcoef('a', c, l);
        % then reconstruct the signal, which now lacks low-frequency components
        data(:,i,j) = waverec(c, l, wname);
    end
end
data = squeeze(data);