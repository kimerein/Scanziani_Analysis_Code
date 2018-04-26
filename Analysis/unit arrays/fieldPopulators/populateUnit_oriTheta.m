function unit = populateUnit_oriTheta(unit, curExpt, curTrodeSpikes)



% Get fileInd for orientation files
fileInd = curExpt.analysis.orientation.fileInd;

% Make stimulus struct for orientation
stim = makeStimStruct(curExpt,fileInd);

unit.oriTheta = stim.values;

