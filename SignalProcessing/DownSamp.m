function [data, FsDownSamp] = DownSamp(y,Fs,DownSampFactor)
%
%
%   Created: 2/10 - SRO
%   Modified: 4/5/10 - SRO

if size(y,3) > 1
    type = 'matrix';
else
    type = 'vector';
end

switch type
    case 'vector'
        sizeData = length(y);
        FsDownSamp = Fs/DownSampFactor;                              % Adjusted sampling frequency for filter
        data = y(1:DownSampFactor:sizeData,:);
    case 'matrix'
        sizeData = length(y);
        FsDownSamp = Fs/DownSampFactor;
        data = y(1:DownSampFactor:sizeData,:,:);
end



