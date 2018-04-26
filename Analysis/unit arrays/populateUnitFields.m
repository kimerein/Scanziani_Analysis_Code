function [unitArray, updatedUnits, unrecognizedFields] = populateUnitFields(unitArray, forceUpdate)
% [unitArray, updatedUnits, unrecognizedFields] =
% populateUnitFields(unitArray, <forceUpdate>);
% SUMMARY:
% The workhorse function of the unit mgr utilities. Populates all empty
% fields with appropriate unit data, drawing from spikes struct, expt
% struct, and .daq files as appropriate (handled by the individual
% populateUnits_<fieldname> function for each field)
% INPUT:
% unitArray   - this unit array will have all empty fields populated by that
% field's handler (if it exists)
% forceUpdate - (optional) this flag specifies whether to update units who have
% non-empty fields (useful if the data is suspected to be stale)
% OUTPUT:
% unitArray          - the populated unitArray
% updatedUnits       - the indices of updated units
% unrecognizedFields - a list of the field names which were not populated
% because there was no wrapper

% next modification for efficiency's sake will be to use 
% a single call to unitArray_forEach with all the field updating functions,
% passing all the applicable units for each using fcn_unitlist
    if(nargin < 2)
        forceUpdate = 0;
    end
    
    fieldlist = fieldnames(unitArray);
    numUnits = length(unitArray);
    numFields = length(fieldlist);
    
    unrecognizedFields = [];
    updatedUnits = [];
    
    % For each field, find all units for which the field is empty
    % pass all of them at once to the wrapper, who can best decide how to
    % update them efficiently
    for(fieldIdx = 1:numFields)
        fldname = fieldlist{fieldIdx};
        if(~forceUpdate)
            % determine first whether this field is empty for any units
            fldemptylogical = arrayfun(@(unit)(isempty(unit.(fldname))), unitArray);
            if(~any(fldemptylogical)) % if nobody is missing this field, continue
                continue;
            end
        end
        
        % N.B. USING A SEPARATE FUNCTION FOR EACH FIELD IS TEMPORARY
        % certain fields should be bundled together for simplicity and
        % speed
        % need a map OF fields TO populating functions
        wrapper_fcn_name = ['populateUnits_', fldname];
        if(~exist([wrapper_fcn_name, '.m'], 'file'))
            if(isempty(unrecognizedFields))
                unrecognizedFields = {fldname};
            else
                unrecognizedFields = [unrecognizedFields, fldname];
            end            
            continue;
        end
        wrapper_fcn = str2func(wrapper_fcn_name);
        
        if(~forceUpdate)
            tempUnitArray = unitArray(fldemptylogical);
            tempUnitArray = wrapper_fcn(tempUnitArray);

            numUnitsToUpdate = length(tempUnitArray);
            updatedUnitIndices = find(fldemptylogical);
            for(unitIdx = 1:numUnitsToUpdate)
                unitArray(updatedUnitIndices(unitIdx)) = tempUnitArray(unitIdx);
            end
            if(isempty(updatedUnits))
               updatedUnits = sort(updatedUnitIndices, 'ascend');
            else
                updatedUnits = unique([updatedUnits, updatedUnitIndices]);
            end
        else
            unitArray = wrapper_fcn(unitArray);
        end
        
        clear('tempUnitArray');                        

        
    end
    if(forceUpdate)
        updatedUnits = 1:length(unitArray);
    end
    if(~isempty(updatedUnits))
        disp(['Populating functions called on ', num2str(length(updatedUnits)), ' unit(s).']);
    end
    if(~isempty(unrecognizedFields))
        disp([num2str(length(unrecognizedFields)), ' fields could not be updated - couldn''t find the populating function. (see output ''unrecognizedFields'' for a list)']);
    elseif(isempty(updatedUnits)) 
        disp('No updates needed.');
    end
        

end

