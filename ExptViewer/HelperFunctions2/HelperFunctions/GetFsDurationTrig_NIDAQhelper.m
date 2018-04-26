function [Fs,duration,triggers,daqinfo] = GetFsDurationTrig_NIDAQhelper(FileName)
% Returns sampling frequency and duration of sweeps collected in the daq
% file name FileName

daqinfo = daqread(FileName,'info');
Fs = daqinfo.ObjInfo.SampleRate;
duration = daqinfo.ObjInfo.SamplesPerTrigger;
duration = duration/Fs;
triggers = daqinfo.ObjInfo.TriggersExecuted;
