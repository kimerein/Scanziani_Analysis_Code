function varout = unitArray_forEachUnit(unitArray, fcn_handles, theseAreUnitUpdatingFunctions, fcn_unitlist, varargin)
% unitArray = unitArray_forEachUnit(unitArray, updating_fcns, update=1, <restrict_fcn_action_to_unitlist>);
% OR
% returnedvars_foreach_cell = unitArray_forEachUnit(unitArray, fcn_handles);
%
% SUMMARY:
% Have functions you want to map across all units without loading the expt
% or spikes structs more than once? Would you write unit-centric code but
% are worried about overhead?
% This function calls the user specified functions with each unit, and the experiment
% struct and spikes struct for that unit's trode, then returns the
% aggregate output of those functions acting on those units.
% 
% The goal of the code is to only need to load each experiment and each spike struct
% once, by going through units in an orderly fashion.
%
% See populateUnits_spiketimes & populateUnit_spiketimes for an example
% (note the two functions differ by 'Units' vs 'Unit')

    if(nargin < 3)
        theseAreUnitUpdatingFunctions = 0;
    end
    if(nargin < 4)
        fcn_unitlist = [];
    end
    
    if(~iscell(fcn_handles))
        fcn_handles = {fcn_handles};
    end
    
    numTotalUnits = length(unitArray);
    numFcns = length(fcn_handles);
    if(~theseAreUnitUpdatingFunctions)
        varout = cell([numTotalUnits, numFcns]);
    end
    
    rigdef = RigDefs;
    exptdir = rigdef.Dir.Expt;
    
    % go through each unit from the same experiment
    % expt_index_vectors will be a cell array
    % where each cell contains a vector of indices specifying units from a
    % particular experiment (named in exptnames_cell)
    [expt_index_vectors, exptnames_cell, numExpts] = listUnitIndicesByExperiment(unitArray);
    
    for(exptIdx = 1:numExpts)
        curExpt = [];
        index_vector = expt_index_vectors{exptIdx};
        
        full_fname = [exptdir, exptnames_cell{exptIdx}, '_expt.mat'];
        if(exist(full_fname, 'file'))
            curExpt = load(full_fname, 'expt');
            curExpt = curExpt.expt;
        end
        
        if(isempty(curExpt))
            warning(['unitArray_forEachUnit.m: Couldn''t load experiment ''', exptnames_cell{exptIdx}, ''' from path: ''', full_fname, '''']);
            disp(['Skipping ', num2str(length(index_vector)), ' unit(s)']);
            continue;
        end
        
        % go through each unit from the same trode, within that experiment
        trodes = unique([unitArray(index_vector).trode_num]);        
        trode_index_vectors = arrayfun(@(trodenum)(find([unitArray(index_vector).trode_num] == trodenum)), trodes, 'UniformOutput', false);        
        
        numTrodes = length(trodes);
        for(trodeIdx = 1:numTrodes)
            curTrodeSpikes = [];
            index_vector2 = trode_index_vectors{trodeIdx};            
            numUnitsInThisTrode = length(index_vector2);
            
            full_fname_spikes = fullfile(rigdef.Dir.Spikes, curExpt.sort.trode(trodes(trodeIdx)).spikesfile);
            if(exist([full_fname_spikes, '.mat'], 'file'))
                curTrodeSpikes = loadvar(full_fname_spikes);
            end
            if(isempty(curTrodeSpikes))
                warning(['unitArray_forEachUnit: Couldn''t load spikes for trode #', num2str(trodes(trodeIdx)), ' in experiment ''', curExpt.name, '''.']);
                disp('The units from this trode will not be updated.');
                continue;
            end
            for(fcnIdx = 1:numFcns)
                curFcn = fcn_handles{fcnIdx};
                % get an index vector of all units in the trode
                final_index_vector = index_vector(index_vector2); 
                if(~isempty(fcn_unitlist))
                    % and filter to keep only units suitable for this
                    % function (checking fcn_unitlist)
                    fcn_filter = ismember(index_vector(index_vector2), fcn_unitlist{fcnIdx});
                    final_index_vector = index_vector(index_vector2(fcn_filter));
                end
                for(unitIdx = 1:length(final_index_vector))
                        unitPtr = final_index_vector(unitIdx);
                        if(theseAreUnitUpdatingFunctions)
                            unitArray(unitPtr) = curFcn(unitArray(unitPtr), curExpt, curTrodeSpikes, varargin);
                        else
                            varout(unitPtr, fcnIdx) = {curFcn(unitArray(unitPtr), curExpt, curTrodeSpikes, varargin)};
                        end
                end % end loop through units in a given trode within a given experiment
            end 
            
        end % end loop through trodes in a given experiment                
    end % end loop through experiments from which units are present
    
    if(theseAreUnitUpdatingFunctions)
        varout = unitArray;
    end
    
end

