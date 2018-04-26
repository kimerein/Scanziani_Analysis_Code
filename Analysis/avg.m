function [data xtime] = avg(expt,channels,bOR,varargin)
% function [data xtime] = avg(expt,channels,bOR,varargin)
%
% INPUT
%   expt: expt struct
%   channels: 
%   bOR: OR = 1, AND = 0;
%   varargin: Property/Value pairs. Value can be a vector.
%
%   Created: 3/24/10 - SRO
%   Modified: 4/8/10 - SRO

RigDef = RigDefs;

if nargin < 4
    error('Not enough arguments supplied')
end

% Set sort field and values from varargin
numSortFields = length(varargin)/2;
for i = 1:numSortFields
    sortfield(i) = {varargin{(i-1)*2+1}};
    sortvalue{i} = varargin{2*i};
end

sweeps = expt.sweeps;

for i = 1:numSortFields
    if strcmp(sortfield{i},'fileInd')
        this_bOR = 1;
    else
        this_bOR = bOR;
    end
    sweeps = filtsweeps(sweeps,this_bOR,sortfield{i},sortvalue{i});  
end
    
fileIndexes = unique(sweeps.fileInd);
data = [];
for i = 1:length(fileIndexes)
    % Get data acquisition paramters
    triggers = expt.files.triggers(fileIndexes(i));
    Fs = expt.files.Fs(fileIndexes(i));
    duration = expt.files.duration(fileIndexes(i));
    
    % Get data
    fileName = [RigDef.Dir.Data expt.files.names{fileIndexes(i)}];
    tempdata = daqread(fileName,'Channels',channels);
    tempdata = MakeDataMat(tempdata,triggers,Fs,duration);
    tempsweeps = filtsweeps(sweeps,0,'fileInd',fileIndexes(i));
    tempdata = tempdata(:,tempsweeps.trigger,:);
    tempdata = sum(tempdata,2);
    data = [data tempdata]; clear tempdata
    size(data);
end
data = sum(data,2)/length(sweeps.fileInd);

data = squeeze(data);
xtime = 0:1/Fs:duration-1/Fs;



