function expt = addStimParams(expt)
%
%
%
%   Modified: 4/12/10 - SRO (Added expt.files.varparam1 and
%   expt.files.varparam20


RigDef = RigDefs;
for i = 1:length(expt.files.names)
    if isTDTexpt(expt)  % BA
        [varparam params paramsfile] = getPsychStimParameters_TDThelper(fullfile(RigDef.Dir.Data,expt.files.names{i}));
    else
        fname = expt.files.names{i};
        fname = fname(1:end-4);         % Remove .daq
        [varparam params paramsfile] = getPsychStimParameters(fname,RigDef.Dir.Data, RigDef.Dir.VStimLog);
    end
    expt.stimulus(i).params = params;
    expt.stimulus(i).varparam = varparam;
    expt.stimulus(i).paramsfile = paramsfile;
    
    % Make table 
    for j = 1:2
        if j > length(varparam) % Only 1 variable
            tempcell{2,2+2*(j-1)} = NaN;
            tempcell{1,2+2*(j-1)} = NaN;
        else
            tempcell{2,2+2*(j-1)} = varparam(j).Name;
            tempcell{2,3+2*(j-1)} = varparam(j).Values;
        end
        tempcell{1,2+2*(j-1)} = sprintf('VarParm%d',j);
        tempcell{1,3+2*(j-1)} = sprintf('VarParmVal%d',j);
    end 
    temp = fieldnames(params);
    indlocal = cellfun(@isempty, regexp(temp,'Additional'));% exclude unwanted field
    % Collect struct fieldsnames and values into first and 2nd row of cell
    tempval = struct2cell(params);
    tempcell = [tempcell [temp(indlocal) tempval(indlocal)]'];
    expt.stimulus(i).table = tempcell;
    
    

end