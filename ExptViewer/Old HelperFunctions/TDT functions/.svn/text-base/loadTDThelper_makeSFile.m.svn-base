function sweeplength = loadTDThelper_makeSFile(blkPATH)
% function sweeplength = loadTDThelper_makeSFile(filename)
RigDef = RigDefs;

filename = loadTDThelper_makefilename(blkPATH);

%% create <filename>_SFile.mat with information about where to get
% Vstimulus param file
if isempty(dir(fullfile(blkPATH,[filename '_SFile.*'])))
    sfilename = sprintf('%s.Tdx',filename);
    [VarParam StaParam params.sfilename] = getPsychStimParameters(sfilename,blkPATH,RigDef.Dir.VStimLog);
    params.condName  = StaParam.StimulusName;
    % get sweeplength form Vstim Info
    sweeplength = StaParam.StimDuration;
    if StaParam.blankbkgrnd; sweeplength = sweeplength + StaParam.Baseline ; end
    params.sweeplength = sweeplength;
    save(fullfile(blkPATH,[filename '_SFile']),'params');
    
else     load(fullfile(blkPATH,[filename '_SFile']),'params');  sweeplength = params.sweeplength ; end
