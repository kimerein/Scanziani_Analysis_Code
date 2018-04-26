function out = isTDTexpt(expt)
out = 0;
if isfield(expt.info,'equipment')
    if isfield(expt.info.equipment,'amp')
        if ~isempty(regexp(expt.info.equipment.amp,'tdt'))
            out = 1;
        end
    end
end
         