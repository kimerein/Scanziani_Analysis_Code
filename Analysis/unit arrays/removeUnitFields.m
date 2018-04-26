function unitArray = removeUnitFields( unitArray, fields )
    % unitArray = removeUnitFields( unitArray, {field1, field2, ...} );
    % SUMMARY:
    % Utility function that removes fields (right now just a wrapper for
    % rmfield, but in case the implementation changes let's encourage
    % reliance on this interface - also won't throw errors if extra fields
    % are present).
    % INPUT: 
    % unitArray - the unitArray
    % fields - a single field name OR a cell array of fieldnames to remove
    
    if(~iscell(fields))
        fields = {fields};
    end
    numFields = length(fields);
    fields_overlap_logical = ismember(fields, fieldnames(unitArray));
    if(any(~fields_overlap_logical))
        disp('removeUnitFields: asked to remove non-existent field(s)');
    end
    
    % avoid errors and only try to rmfield the fields that are actually
    % present
    fields = fields(fields_overlap_logical);    
    unitArray = rmfield(unitArray, fields);        

end

