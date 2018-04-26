function [ expt_index_vectors_cell, exptnames_cell, numExpts] = listUnitIndicesByExperiment(unitArray)
% [expt_index_vectors_cell, exptnames_cell, numExpts] =
% listUnitIndicesByExperiment(unitArray);
% SUMMARY:
% For each unique experiment represented in the unit array, this function
% returns (1) an index vector specifying the indices of the units belonging to
% that experiment and (2) the name of that experiment. The result is (1) a cell array with a cell for each
% experiment containing the index vector specifying the units from that
% experiment, and (2) a cell array of experiment names. These are given in
% the same order.
% You can implement your own function of this type using
% "listUnitIndicesByFcn" (type "help listUnitIndicesByFcn")
%
% INPUT:
% unitArray - any unit array
% 
% OUTPUT:
% expt_index_vectors_cell - a cell array with length equal to the number of
% unique experiments (=length(unique({unitArray.expt_name})), with each cell
% containing an index vector specifying the units in that experiment.
%
% exptnames_cell - the name of each experiment whose has units in the unit
% array. the order is the same as expt_index_vectors_cell so that the units
% listed in expt_index_vectors_cell{1} are from experiment exptnames_cell{1}
%
% numExpts - the number of unique experiments from which unit array has
% units. also the length of expt_index_vectors_cell. 
%

    % could easily implement this through listUnitIndicesByFcn but will
    % save memory to do it from scratch. this gets called by
    % populateUnitFields so better to save memory.
    
    % Easy way (wastes a little memory):
    %[expt_index_vectors_cell, exptnames_cell, numExpts] = listUnitIndicesByFcn(unitArray, @(unit)(unit.expt_name));
    
    % Slightly less easy way (wastes less memory):
    exptnames_cell = unique({unitArray.expt_name});    
    expt_index_vectors_cell = cellfun(@(exptname)(find(strcmp({unitArray.expt_name},exptname))), exptnames_cell, 'UniformOutput', false);            
    numExpts = length(exptnames_cell);

    
end

