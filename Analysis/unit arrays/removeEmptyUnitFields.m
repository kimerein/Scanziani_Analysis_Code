function unitArray = removeEmptyUnitFields(unitArray, emptyInAny)
% SUMMARY:
% Removes empty fields from a unit array. The second argument specifies
% whether fields should be removed if any or all units lack them. 
% INPUT:
% unitArray  - the unit array
% emptyInAny -  (optional, default = 0) if set to 1, then if any unit lacks a given field, that
% field will be removed. if set to 0, only fields that are empty for all
% units will be removed.
% OUTPUT:
% unitArray  - the unit array with empty fields removed

    if(nargin < 2) % by default we only remove fields that are empty for all units
        emptyInAny = 0;
    end

    fieldlist = fieldnames(unitArray);    

    % time for an orgy of anonymous functions to reduce the coding burden
    is_field_empty = @(unit, field_name)(isempty(unit.(field_name)));
    empty_logical  = @(units, field_name)(arrayfun(@(unit)(is_field_empty(unit, field_name)), units));
    empty_in_any   = @(units, field_name)(any(empty_logical(units, field_name)));
    empty_in_all   = @(units, field_name)(all(empty_logical(units, field_name)));
    
    if(emptyInAny)
        decider_fcn = @(field_name)(empty_in_any(unitArray, field_name));
    else
        decider_fcn = @(field_name)(empty_in_all(unitArray, field_name));
    end
    
    fields_to_delete_logical = cellfun(decider_fcn, fieldlist);
    
    % right on, now we can logically index to get a list of fields to
    % remove!
    unitArray = rmfield(unitArray, fieldlist(fields_to_delete_logical));
    
    % look ma, no loops
end

