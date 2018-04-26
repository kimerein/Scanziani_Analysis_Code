function spikes = getSpikesStruct(expt,unitTag)
% function spikes = getSpikes(expt,unitTag)
%
% BA
RigDef = RigDefs;

[trodeInd unitInd] = getUnitInfo(unitTag);
spikesfile = expt.sort.trode(trodeInd).spikesfile;
if ~isempty(spikesfile)
    load(fullfile(RigDef.Dir.Spikes,getFilename(spikesfile)),'spikes');
else
    fprintf('spikesfile does not exist')
end
