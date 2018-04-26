function [tank blk] = loadTDThelper_getTankBlk(blkPATH)
% function [tank blk] = loadTDThelper_getTankBlk(blkPATH)

ind = strfind(blkPATH,'\');ind = ind(end);
if isempty(ind); error('TDT tank and block must both be included'); end
tank = blkPATH(1:ind-1);
blk = blkPATH(ind+1:end); 