function y = filtdata(y,Fs,cutoff,type,varargin)
% function y = filtdata(y,Fs,cutoff,type,varargin)
%
% INPUT
%   y:
%   Fs:
%   cutoff:
%   type: 'low' or 'high'
%   varargin{1}: Wp, two element pass-band
%   varargin{2}: Ws, two element stop-band
%
% OUTPUT

% Created:  SRO - 6/29/10
% Modified: SRO - 6/30/10

if nargin > 4
    Wp = varargin{1};
    Ws = varargin{2};
end

% Create butterworth filter
switch type
    case 'low'
        [b,a] = butter(2,cutoff*2/Fs,'low');
    case 'high'
        [b,a] = butter(2,cutoff*2/Fs,'high');
    case 'band'
        Wp = Wp*2/Fs;                       % Pass Wp(1) - Wp(2)
        Ws = Ws*2/Fs;                       % Stop 0-Ws(1), Ws(2)-Nyquist
        [n,Wn] = buttord(Wp, Ws, 3, 25);
        [b,a] = butter(n,Wn);
end

% Filter each column vector sequentially
for i = 1:size(y,2)
    y(:,i) = filtfilt(b,a,y(:,i));
end