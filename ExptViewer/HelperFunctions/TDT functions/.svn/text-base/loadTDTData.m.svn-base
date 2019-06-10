function [data dt] = loadTDTData(blkPATH,chns,epocrange,timewindow,bprint)
% [data dt] = loadTDTData(blkPATH,chns,epocrange,timewindow)
% INPUT - blkPATH  string with entire directory path of block directory
%         for backward compatibility blkPATH can also be a struct
%         STF.tdt.tank ( directory in (but not including)
%         RigDefaults.DirData)
%                .blk
%                .filename
%                .epocrange (optional)
%                .timewindow (optional)
%        - vector of chns
% TO DO add ablility to use remote tank (using Rigspecific.something)
RigDef = RigDefs;
% defaults
EPOCNAME = 'Vcod';
WAVEDATANAME = 'Rawd';
MAXEPOCS = 10000;

if exist('timewindow','var') && exist('epocrange','var')
    if ~isempty(timewindow) && ~isempty(epocrange); error('epocrange and timewindow are mutually exclusive pick one'); end
end

if ~exist('timewindow','var'); timewindow = []; end
if ~exist('epocrange','var'); epocrange = []; end
if nargin < 5; bprint = 1; end;

if isstruct(blkPATH)                                                            % deal with case where STF struct is passed in
    tank = blkPATH.tdt.tank; %
    tank = fullfile(RigDef.Dir.Data,tank); % add fullpath
    blk = blkPATH.tdt.blk;
    %     struct fields override other inputs
    if isfield(blkPATH.tdt,'epocrange');         epocrange = blkPATH.tdt.epocrange; end
    if isfield(blkPATH.tdt,'timewindow');         timewindow = blkPATH.tdt.timewindow; end
    blkPATH = [tank '\' blk];
else
    [tank blk] = loadTDThelper_getTankBlk(blkPATH);
end

sweeplength = loadTDThelper_makeSFile(blkPATH);
% save a file with the conditions of each sweep to be compatible with DAQ
% version of acquisition
loadTDThelper_getStimCond(blkPATH ,'Vcod');

if isempty(regexp(blk,'~'));  blk = ['~' blk]; end                              % remember it should start with a tilda else TDT won't index based on each epoc star


TT = actxcontrol('TTank.X');
invoke(TT,'ConnectServer','Local','Me');
if invoke(TT,'OpenTank',tank,'R')~=1; error(sprintf('Opening %s',tank)); end
if invoke(TT,'SelectBlock',blk)~=1;   error(sprintf('Opening Block %s in Tank %s',blk,tank)); end

invoke(TT,'ReadEventsV',100,WAVEDATANAME,0,0,0,0,'ALL');
actualSampFreq = invoke(TT,'ParseEvInfoV',0,1,9);                               % Gets the sampling rate for that event % =24414.062500;
dt = 1/actualSampFreq;

invoke(TT,'ResetFilters');
TT.CreateEpocIndexing;
TT.SetGlobalV('RespectOffsetEpoc',0);                                           % else will not include events that occured with "sweeplength of onset" but after offset

allEpocs = loadTDThelper_getEpocVal(blkPATH,EPOCNAME)   ;                           % Returns the Epoc events for Trigger returns a NaN event in this case
                                                                                % get VstimConditions
% check that sweeplength is not longer than Epocs (this code is not
% necessary to extract data from TT, just for error checking
if 1 %
%     figure(1); hist(diff(allEpocs(2,:)),20);title('hist of time between sweeps') ; xlabel('time (s)');
    temp = min(diff(allEpocs(2,:)));
    if sweeplength > temp;
        error(sprintf('************************** sweeplength cannot exceed time to next Epoc: %1.3f ****************',temp))
        %         sweeplength = allEpocs; % QUICK DIRTY FIX
    end
end
% ADD CHECK if timewindow is out or range
if ~isempty(timewindow)
    TT.SetGlobalV('T1',timewindow(1));                                          % can load a subset of data by restricting the
    TT.SetGlobalV('T2',timewindow(2));
elseif ~isempty(epocrange)                                                      % extract only a continous subset of epocs
%     allEpocs = invoke (TT, 'GetValidTimeRangesV');                              % Gets the start and end of the Time ranges.
    TT.SetGlobalV('T1',allEpocs(2,epocrange(1)));
    if length(epocrange)==1;                                                    %  getting just 1 sweep
        TT.SetGlobalV('T2',allEpocs(2,epocrange(1)+1)-dt*2);
    else
        TT.SetGlobalV('T2',allEpocs(2,epocrange(2)),1);
    end
end


% read
Filt = invoke(TT,'SetepocTimeFilterV', EPOCNAME,0,sweeplength);                 % Sets the Time filter so that the Epoc event occurs in the
if ~Filt;        error('Error creating tdt time filter'); end
tranges = invoke (TT, 'GetValidTimeRangesV');                                   % Gets the start and end of the Time ranges.
time = [1:sweeplength/dt+1]*dt;

if bprint
    fprintf('Number of Epocs to be extracted: %d\n', length(tranges));
    fprintf('%d MB required per chn\n',2^nextpow2((size(time,2))*size(tranges,2)*4)/1024/1024)
end
TT.SetGlobalV('WavesMemLimit',2^nextpow2((size(time,2))*size(tranges,2)*4));    % TDT has a default maximum memory of 32MB to read more than that it must be set larger else one gets a NaN back
% the memory required is 4 (for bytes per sample) times the number of
% samples x number of sweeps (assuming 1 chn is extracted at a time)

% load all chns
% predefine
data = zeros(size(time,2),size(tranges,2),length(chns),'single');

if bprint ;                                                                          % debugging
    memory
end
% tic
j = 1;
for i = chns
    
    if bprint
        fprintf('Loading TDT dat chn %d\n',i)
    end
    data(:,:,j)= invoke (TT, 'ReadWavesOnTimeRangeV', WAVEDATANAME, i);         % reads back epoc stream data.
    if any(isnan(data(:,:,j)))
        display('data read from TDT contains NaNs, could all be nans.....................')
        keyboard;
    end
    j = j+1;
    
end
% toc
TT.CloseTank();
TT.ReleaseServer;


% rescale to be in uV
data = data/10;

if 0
    %% plot sweeps
    clf
    for sw = 1: size(W,2)
        j = 1 ;for i = chns
            subplot(length(chns),1,j)
            plot(time,W(:,sw,j));
            title(['chn ' num2str(i)]);
            j
            j = j+1;
            plotset(1);
            axis tight
        end
        pause;
    end
end



