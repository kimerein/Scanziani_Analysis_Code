function [varparam params paramsfile] = getPsychStimParameters_TDThelper(blkPATH)
RigDef = RigDefs;

loadTDThelper_makeSFile(blkPATH); % make SFile if it doesn't exit
filename = loadTDThelper_makefilename(blkPATH);
 [varparam params paramsfile] = getPsychStimParameters(filename,blkPATH,RigDef.Dir.VStimLog);

