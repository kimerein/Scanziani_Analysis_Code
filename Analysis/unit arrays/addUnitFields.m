function unitArray = addUnitFields( unitArray, fields )
    if(~iscell(fields))
        fields = {fields};
    end
    numFields = length(fields);
    numUnits = length(unitArray);
    
    for( unitIdx = 1:numUnits )
        for( fieldIdx = 1:numFields )            
            % only set the field to empty if it does not already exist!
            if(~isfield(unitArray(unitIdx), fields{fieldIdx}))
                unitArray(unitIdx).(fields{fieldIdx}) = [];
            end
        end
    end
       


end

