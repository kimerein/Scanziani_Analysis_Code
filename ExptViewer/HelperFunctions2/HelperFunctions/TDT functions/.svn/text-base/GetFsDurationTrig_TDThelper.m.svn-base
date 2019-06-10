function [Fs,duration,triggers] = GetFsDurationTrig_TDThelper(blkPATH)
% function       [Fs,duration,triggers,daqinfo] = GetFsDurationTrig_TDThelper(blkPATH);

% defaults 
EPOCNAME = 'Vcod';
WAVEDATANAME = 'Rawd';
MAXEPOCS = 10000;

duration = loadTDThelper_makeSFile(blkPATH); 
[tank blk] = loadTDThelper_getTankBlk(blkPATH);

TT = actxcontrol('TTank.X');
invoke(TT,'ConnectServer','Local','Me');
if invoke(TT,'OpenTank',tank,'R')~=1; error(sprintf('Opening %s',tank)); end
if invoke(TT,'SelectBlock',blk)~=1;   error(sprintf('Opening Block %s in Tank %s',blk,tank)); end

invoke(TT,'ReadEventsV',100,WAVEDATANAME,0,0,0,0,'ALL')
Fs = invoke(TT,'ParseEvInfoV',0,1,9);                               % Gets the sampling rate for that event % =24414.062500;

temp =loadTDThelper_getEpocVal(blkPATH,EPOCNAME)  ;                       % Returns the Epoc events for Trigger returns a NaN event in this case
triggers = size(temp,2);

TT.CloseTank();
TT.ReleaseServer;
