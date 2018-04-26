function out = loadTDThelper_getEpocVal(blkPATH,EPOCNAME)
% out = loadTDThelper_getEpocVal(blkPATH,EPOCNAME)
%
% TODO if necessary can pass in TT or blk to avoid having to repeatedly
% open actxcontrol

MAXEPOCS = 10000;
if nargin ==1; EPOCNAME = 'Vcod'; end                                           % default
    
[tank blk] = loadTDThelper_getTankBlk(blkPATH);

TT = actxcontrol('TTank.X');
invoke(TT,'ConnectServer','Local','Me');
if invoke(TT,'OpenTank',tank,'R')~=1;                                            
    error(sprintf('Opening %s',tank)); end
if invoke(TT,'SelectBlock',blk)~=1;                                             
    error(sprintf('Opening Block %s in Tank %s',blk,tank)); end

invoke(TT,'ResetFilters');
TT.CreateEpocIndexing;
    
out =invoke(TT,'GetEpocsV',EPOCNAME,0,0,MAXEPOCS);                                     % Returns the Epoc events for Trigger returns a NaN event in this case
if isnan(out); error('GetEpocsV returned nan'); end                             % error checking
if length(out)==MAXEPOCS; disp('\t\tMAXEPOCS Hit!!!!!!!!!'); end                             % error checking

TT.CloseTank();
TT.ReleaseServer;

