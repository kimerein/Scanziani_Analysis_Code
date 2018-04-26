function out = MakeDataMat(data,Triggers,Fs,Duration)
% function out = MakeDataMat(data,Triggers,Fs,Duration)
%
% This function takes a data vector obtained from daqread and generates
% a data matrix in which each column corresponds to a sweep. The number of
% columns is equal to Triggers. If data contains multiple channels in
% different columns, then a 3D matrix is made where channels run along
% dim3.
%
% INPUT
%   data: Data vector returned from daqread
%   Triggers: Number of triggers
%   Fs: Sampling frequency
%   Duration: Duration of sweep

% SRO - 3/4/10

if size(data,2) > 1
    type = 'matrix';
else
    type = 'vector';
end

switch type
    case 'vector'
        datamat = zeros(Fs*Duration,Triggers);
        for i = 1:Triggers
            FirstPoint = (i-1)*Fs*Duration+i;
            LastPoint = FirstPoint+Fs*Duration-1;
            datamat(:,i) = data(FirstPoint:LastPoint);
        end
        out = datamat;
        
    case 'matrix'
        datamat = zeros(Fs*Duration,size(data,2),Triggers,'double');
        for i = 1:Triggers
            FirstPoint = (i-1)*Fs*Duration+i;
            LastPoint = FirstPoint+Fs*Duration-1;
            datamat(:,:,i) = data(FirstPoint:LastPoint,:);
        end
        clear data
        datamat = permute(datamat,[1 3 2]);
        out = datamat;
end
        