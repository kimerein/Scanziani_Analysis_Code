function [data dt] = loaddata(filename,channels,varargin)
% function [data dt] = loaddata(filename,chns, varargin)
% purpose: abstracts loading different data types (DAQ and TDT)
% INPUT
%          filename .daq in case of daqfile, or full block path if tdt
%          channels  = list of Channels [ 1 4 2];
%          'Triggers' (optional) = range of trigger e.g. [1 100]; 
%      
% OUTPUT 
%          data in form = samples x triggers x chns
%          dt sampling rate
% BA 032710
triggers = [];
DIR = struct([]);
if nargin>=2
    for i=1:length(varargin)
        if mod(i,2)~=0
            DIR(floor(i/2)+1).param = varargin{i};
        else
            DIR(floor(i/2)).val = varargin{i};
        end
    end
end
for i=1:length(DIR)
    if ~isempty(DIR(i).param)&~isempty(DIR(i).val)
        
        switch DIR(i).param
            case 'Triggers'
                triggers = DIR(i).val;
                %             case 'Time'                                                   % not currently implemented, although loadTDTData supports it
                %                 time = DIR(i).val;
            otherwise
        end
    end
end

dataxmethod = 'daq' ;                                                       % default daq extract
if isempty(regexp(filename,'.daq')); dataxmethod = 'tdt';end                         % could be done based on expt.equipment.amp field
switch(dataxmethod)
    case 'daq'
        [data dt] = loadDAQData(filename,channels,triggers); % TODO make loadDAQData compatible with list of triggers (right now must be 2 element vector specifing range)
    case 'tdt'
        [data dt] = loadTDTData(filename,channels,triggers,[],0);
end

end

