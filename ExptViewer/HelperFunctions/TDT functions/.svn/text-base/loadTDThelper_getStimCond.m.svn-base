function [filename swcond] = loadTDThelper_getStimCond(blkPATH,EPOCNAME)
% function [filename swcond] = loadTDThelper_getStimCond(blkPATH,EPOCNAME)
%
% INPUT blkPATH
%       EPOCNAME (optional) default to Vcod
if nargin ==1; EPOCNAME = 'Vcod'; end
filename = loadTDThelper_makefilename(blkPATH);

%% create <filename>_SFile.mat with information about where to get
% Vstimulus param file
if isempty(dir(fullfile(blkPATH,[filename '_TrigCond.*'])))
    temp = loadTDThelper_getEpocVal(blkPATH,EPOCNAME);
    if isnan(temp); error('no TDT epocs found'); end                                % get VstimConditions
    swcond = temp([2 1],:);
    data = swcond;
    swcond = swcond(2,:);
    save(fullfile(blkPATH,[filename '_TrigCond']),'data');
elseif nargout;     [junk swcond] = getStimCond({fullfile(blkPATH,filename)},0);  end
