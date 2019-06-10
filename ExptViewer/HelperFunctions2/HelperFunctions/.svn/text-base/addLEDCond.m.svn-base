function expt = addLEDCond(expt)
%
%
%   Created: 3/10 - SRO

RigDef = RigDefs;

startInd = 1;
for i = 1:length(expt.files.names)
    triggers = expt.files.triggers(i);
    fileInd = GetFileInd(expt.files.names{i});
    if ~isempty(dir([RigDef.Dir.Data expt.name '_' num2str(fileInd) '_LEDCond.mat']));
        LEDfileName = [expt.name '_' num2str(fileInd) '_LEDCond'];
        load(fullfile(RigDef.Dir.Data,LEDfileName))
        % Remove nans from end of file, if they exist (this occurs when DaqController is
%         % stopped before completing specified triggers)
        LEDCond(:,any(isnan(LEDCond),1)) = [];
        expt.sweeps.led(startInd:startInd+triggers-1) = LEDCond(2,:);
    else
        expt.sweeps.led(startInd:startInd+triggers-1) = nan;
    end
    startInd = startInd + triggers;
end

