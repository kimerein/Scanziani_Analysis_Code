function [ categories_index_vectors_cell, categories_cell, numCategories ] = listUnitIndicesByFcn(unitArray, category_fcn, use_for_each)
% [ categories_index_vectors_cell, categories_cell, numCategories ] =
% listUnitIndicesByFcn(unitArray, category_fcn);
% SUMMARY:
% For each unique "category" (string) returned by your "category_fcn" for a unit in the unit array, this function
% returns (1) an index vector specifying the indices of the units belonging to
% that category and (2) the name of that category. The result is (1) a cell array with a cell for each
% category containing the index vector specifying the units from that
% category, and (2) a cell array of category names (only those with units present). These are given in
% the same order.
%
% INPUT:
% unitArray - any unit array
%
% category_fcn - a function taking a unit as input and returning a string
% as output. this string will be interpreted as putting that unit in a
% category.
%
% OUTPUT:
% category_index_vectors_cell - a cell array with length equal to the number of
% unique categories, with each cell
% containing an index vector specifying the units in that category.
%
% categories_cell - the name of each category whose has units in the unit
% array. the order is the same as categories_index_vectors_cell so that the units
% listed in categories_index_vectors_cell{1} are from experiment categories_cell{1}
%
% numCategories - the number of unique categories from which unit array has
% units. also the length of categories_index_vectors_cell. 
%
    if(nargin < 3)
        use_for_each = 0;
    end
    
    if(use_for_each)
        unitCategories = unitArray_forEachUnit(unitArray, category_fcn, 0);
    else
        unitCategories = arrayfun(category_fcn, unitArray, 'UniformOutput', false);
    end
    categories_cell = unique(unitCategories);    
    categories_index_vectors_cell = cellfun(@(cat_name)(find(strcmp(unitCategories, cat_name))), categories_cell, 'UniformOutput', false);            
    numCategories = length(categories_cell);

end

