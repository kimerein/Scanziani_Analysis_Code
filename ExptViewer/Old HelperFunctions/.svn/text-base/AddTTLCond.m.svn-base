function expt = addTTLCond(expt,TTLname)
% function expt = AddTTLCond(expt,TTLname)
% note TDTexpt only uses TTLname currently

RigDef = RigDefs;

numTrials = sum(expt.files.triggers);
if ~ isTDTexpt(expt); TTLname = 'led'; end              % BA kloogy the DAQ version should  be implemented better
expt.sweeps.(TTLname) = nan(1,numTrials,'single');               % nan makes it easy to check if it was filled in or not

exptname = expt.name;
startInd = 1;
for i = 1:length(expt.files.names)
    
    triggers = expt.files.triggers(i);
    if isTDTexpt(expt)
        TTLcond = loadTDThelper_getTTL(fullfile(RigDef.Dir.Data,expt.files.names{i}),[],TTLname);
    else
        fileInd = GetFileInd(expt.files.names{i});
        LEDfileName = [exptname '_' num2str(fileInd) '_LEDCond'];
        load(LEDfileName);
        TTLcond =  LEDCond(2,:);
    end
    expt.sweeps.led(startInd:startInd+triggers-1) = single(TTLcond);
    startInd = startInd + triggers;
end
