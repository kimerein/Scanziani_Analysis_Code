function unitStructArray = constructUnitArray(expt_names, unit_tags, expt_dirs)
% unitArray = constructUnitArray(expt_names, <unit_tags>, <{expt_dirs}>);
% SUMMARY:
% Constructs a basic unit array, in which all units from all experiments
% specified in the first argument are each given a struct. The initial unit
% struct is very skeletal, consisting of only basic fundamental fields: the
% experiment name, unit tag, unit label, and a few others. 
%
% INPUT:
% expt_names      - a cell array of experiment names
% unit_tags       - (optional) a cell array (length == length(expt_names))
% with one cell for each experiment, each cell containing a list of unit
% tags to be included from that experiment.
% expt_dirs       - (optional) a cell array of directories to search (will
% be searched in order) for experiment files
%
% OUTPUT:
% unitStructArray - A struct array with one entry for every unit across all
% experiments specified in expt_names. It is a skeleton; only some very basic/fundamental
% fields will be populated by default: the experiment name, unit tag, and unit
% label.
%
% EXAMPLES:
% The resulting array can have fields added with "unitArray =
% addUnitFields(unitArray, field_names);".
%
% The resulting fields can then be populated with data using "unitArray =
% populateUnitFields(unitArray);".
%
% Units with populated fields can be merged with newly constructed units:
% "unitArray = mergeUnitArrays(0, existingUnitArray, newUnits); 
% unitArray = populateUnitFields(unitArray);"
% This will add and populate the missing fields on the new units.
%
% Unit arrays can be filtered based on the value of a field or a user
% specified function:
% filteredUnits = filtUnitArray(unitArray, bOR, 'fieldname', value, 'fieldname', @is_field_good_fcn);
%
% And after filtering/merging, one can get back a list of the units by experiment using:
% [expt_index_vectors_cell, exptnames_cell, numExpts] =
% listUnitIndicesByExperiment(unitArray);
%

    if(~iscell(expt_names))
        expt_names = {expt_names};
    end
    
    rigdef = RigDefs;
    if(nargin < 3)
        expt_dirs = {rigdef.Dir.Expt};
    end    
    if(nargin < 2)
        unit_tags = [];
    end
    
    unitStructArray = [];
    
    numExpts    = length(expt_names);
    numExptDirs = length(expt_dirs);
    for exptIdx = 1:numExpts
        clear('expt');
        curExptName = expt_names{exptIdx};
        fname = [curExptName, '_expt.mat'];
        full_fname = [];
        for exptDirIdx = 1:numExptDirs
            full_fname = [expt_dirs{exptDirIdx}, fname];
            if(~exist(full_fname, 'file'))
                continue;
            end
            load(full_fname, 'expt');
            if(~exist('expt', 'var'))
                warning(['Expt file ''', full_fname, ''' exists but does not contain expected variable ''expt'' ! Trying next directory!']);
                continue;
            end
            
            % if this line is reached we have successfully loaded the
            % experiment and should terminate our search
            disp(['Successfully loaded experiment ''', curExptName, ''' from path ''', full_fname, '''.']);
            break; % terminate for exptDirIdx = 1:numExptDirs             
        end
        if(~exist('expt', 'var'))
            warning(['The experiment file for experiment ''', curExptName, ''' could not be found. Skipping.']);
            continue;
        end
        if(~isfield(expt.sort, 'trode'))
            warning(['The experiment ''', curExptName, ''' does not have a ''trode'' field. Skipping...']);
            continue;
        end
        
        for(trodeIdx = 1:length(expt.sort.trode))            
            for(unitIdx = 1:length(expt.sort.trode(trodeIdx).unit))
                expt.sort.trode(trodeIdx).unit(unitIdx).expt_name = curExptName;
                expt.sort.trode(trodeIdx).unit(unitIdx).expt_last_fname = full_fname;
                expt.sort.trode(trodeIdx).unit(unitIdx).trode_num = trodeIdx;
                expt.sort.trode(trodeIdx).unit(unitIdx).trode_name = expt.sort.trode(trodeIdx).name;
                if(isfield(expt.sort.trode(trodeIdx).unit(unitIdx), 'assign'))
                    assign = expt.sort.trode(trodeIdx).unit(unitIdx).assign;
                    expt.sort.trode(trodeIdx).unit(unitIdx).unit_tag = [expt.sort.trode(trodeIdx).name, '_', num2str(assign)];
                end
            end            
        end
        
        %thisExptUnits = [expt.sort.trode(:).unit];
        % In some experiments the unit structs from different trodes
        % have different fieldnames, necessitating the following
        thisExptUnits = mergeUnitArrays(0, {expt.sort.trode(:).unit});
        if(~isempty(unit_tags))
            if(~isempty(unit_tags{exptIdx}))
                a_desired_unit = @(unit_tag)(ismember(unit_tag, unit_tags{exptIdx}));
                thisExptUnits = filtUnitArray(thisExptUnits, 1, 'unit_tag', a_desired_unit);
            end
        end
        
        if(isempty(unitStructArray))
            unitStructArray = thisExptUnits;
        else
            unitStructArray = mergeUnitArrays(0, unitStructArray, thisExptUnits);
        end                
        
        % yipee, on to the next experiment!
    end
    
    if(~isempty(unitStructArray))
        unitStructArray = removeEmptyUnitFields(unitStructArray, 0);
    end


end

