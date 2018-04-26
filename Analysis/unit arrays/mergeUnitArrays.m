function unitArray = mergeUnitArrays(intersectionNotUnion, varargin)   
% unitArray = mergeUnitArrays(intersectionNotUnion, varargin);
% SUMMARY:
% Used for merging N unit arrays, possibly possessing very different
% sets of fields. One can specify whether the smallest common set of fields
% should be kept or whether fields should be added to units lacking them.
% 
% INPUT:
% intersectionNotUnion - boolean specifying whether to take the
% intersection of the FIELDS (only keep fields present on all arrays
% merged) or the union (add fields present on any of the arrays to the
% rest, initializing them to be empty).
%
% varargin - each subsequent argument should be a unit array (the unit
% arrays you want merged)

% OUTPUT:
% unitArray - a single unit array containing all the units from the unit
% arrays in the input.

    if(iscell(varargin{1}))
        if(length(varargin) > 1)
            error('mergeUnitArrays.m: If a cell array is passed, all unit arrays to be merged should be contained in that cell array (no other args should be present).');
        end
        varargin = varargin{1};
    end
    
    numUnitArrays = length(varargin);
    fldnames = fieldnames(varargin{1});
    totalNumUnits = 0;
    for(unitArrayIdx = 2:numUnitArrays)
        curUnitArray = varargin{unitArrayIdx};
        curFldnames = fieldnames(curUnitArray(1));
        if(intersectionNotUnion)
            overlap = ismember(fldnames, curFldnames);
            fldnames = fldnames(overlap);
        else % if union
            fldnames = unique([fldnames; curFldnames]);
        end
    end
    
    unitArray = [];
    
    for(unitArrayIdx = 1:numUnitArrays)
        curUnitArray = varargin{unitArrayIdx};
        curFldnames = fieldnames(curUnitArray(1));
        missing = ~ismember(fldnames, curFldnames); 
        excess = ~ismember(curFldnames, fldnames); % there won't be any in union case
        
        if(any(excess))
            curUnitArray = removeUnitFields(curUnitArray, curFldnames(excess));
        end
        if(any(missing))
            curUnitArray = addUnitFields(curUnitArray, fldnames(missing));
        end
        
        if(isempty(unitArray))
            unitArray = curUnitArray;
        else
            unitArray = [unitArray, curUnitArray];
        end
    end


end

