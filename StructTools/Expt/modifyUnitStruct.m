function modifyUnitStruct(expt_names)



rdef = RigDefs;

for i = 1:length(expt_names)
    % Load expt
    expt = loadvar([rdef.Dir.Expt expt_names{i} '_expt']);
    
    for n = 1:length(expt.mua.trodeInd)
        % Load mua spikes
        spikes = loadvar([rdef.Dir.Spikes expt.sort.trode(expt.mua.trodeInd(n)).spikesfile]);
        
        % Modify expt.unit
        expt = UpdateUnitStruct2(expt,spikes,expt.mua.trodeInd(n));
    end
end

