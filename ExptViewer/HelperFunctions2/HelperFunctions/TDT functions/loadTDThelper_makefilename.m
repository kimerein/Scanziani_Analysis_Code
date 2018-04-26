function filename = loadTDThelper_makefilename(blkPATH)
% function filename = loadTDThelper_makefilename(blkPATH)
% 
[tank blk] = loadTDThelper_getTankBlk(blkPATH);

temp = dirc([fullfile(tank,blk) '\*.Tdx']);
filename = temp{2};
