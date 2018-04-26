function makeExptFromList(expt_names)
% function makeExptFromList(expt_names)
%
% INPUT
%   expt_names: Cell array of experiment names
%
%

% Created: SRO - 6/20/11

rdef = RigDefs;
for i = 1:length(expt_names)
    
    disp('Making expt:')
    disp(expt_names{i})
    
    tmp = [rdef.Dir.Data expt_names{i} '_ExptTable'];
    exptTable = loadvar(tmp);
    makeExptSRO(exptTable,1);
    
end