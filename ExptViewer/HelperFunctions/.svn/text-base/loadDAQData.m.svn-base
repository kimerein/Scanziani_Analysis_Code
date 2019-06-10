function [data dt time] = loadDAQData(LOADFILE,Chns,TrigRange)
% function [data dt time] = loadDAQData(LOADFILE,Chns,TrigRange)
% Load DAQ data using daqread and reshape into
% data = WAVEFORM x SWEEPS x SITES
% dt = sample interval
% time = time of each sample
%
% BA 091109

% may be taking too much memory... remove dataread and just use data

% NOTE: not considered adding sampRange suport, but data reshaping must be
% fixed to be compatible with this so it is commented out

bspecTrigger = 0;
% bspecSamp = 0;

if nargin>2 ;   if ~isempty(TrigRange ); bspecTrigger = 1; end; end
if nargin<1; error('Channels must be specified'); end

if ~regexp(LOADFILE,'.daq')
LOADFILE = [LOADFILE '.daq'];
end

% if bspecTrigger && bspecSamp
% error ('The ''Samples'' and ''Triggers'' properties are mutually exclusive.')
% else
if      bspecTrigger
    [data time]  = daqread(LOADFILE, 'Channels', Chns,'Triggers',TrigRange, 'Dataformat','native');
    % elseif      bspecSamp
    %     [data time]  = daqread([LOADFILE '.daq'], 'Channels', Chns,'Samples', SampRange, 'Dataformat','native');
else
    [data time]  = daqread(LOADFILE, 'Channels', Chns, 'Dataformat','native');
end
try
dt = time(2) - time(1);
if nargout<3; clear time; end
data = single(data);
catch
    if isempty(time)
    error(['daq time variable is empty. daq file:' LOADFILE  'maybe corrup']);
    end
end
indnan = isnan(data);
sweeplength = find(indnan,1,'first')-1;                                     % length of each sweep
if isempty(sweeplength);
    sweeplength  = size(data,1); end
nsw = (size(data,1)+1)/(sweeplength+1);                                     % number of sweeps/triggers
nchns = size(data,2);

% reshape to be WAVEFORM x SWEEPS x SITES

if (nsw - floor(nsw))>1/sweeplength                                         % case where acquisition ended before the end of sweep (can't just test if it is an integer cause it is actually a float)
    nsw = floor(nsw);
    indEND = nsw*(sweeplength+1);
    data = data(1:indEND,:);
    indnan = isnan(data);
end

if nsw>1 & nchns>1
    data = reshape(data(~indnan),sweeplength,nsw,nchns);                     % remove NaNs that seperate sweeps
elseif nsw>1 & nchns ==1
    data = reshape(data(~indnan),sweeplength,nsw);    
elseif nsw==1
    data = reshape(data(~indnan),sweeplength,nchns);    
end