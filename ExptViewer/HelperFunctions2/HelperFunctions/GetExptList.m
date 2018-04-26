function ExptList = GetExptList()
%

%   Created: 3/10 - SRO
%   Modified: 6/15/10 - SRO

RigDef = RigDefs;
ExptList = dir(fullfile(RigDef.Dir.Expt,'*expt.mat'));
ExptList = {ExptList.name}';
for i = 1:length(ExptList)
    f = ExptList{i};
    f = f(1:end-9);
    ExptList{i} = f;
end

ExptList = flipdim(ExptList,1);