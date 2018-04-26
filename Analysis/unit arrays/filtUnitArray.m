function [unitArray logical_vector] = filtUnitArray(unitArray, bOR, varargin)
% [unitArray, logical_vector] = filtUnitArray(unitArray, bOR, varargin);
% SUMMARY:
% Filters based on field/value pairs, OR field/fcn_handle pairs, where the
% fcn_handle points to some (anonymous) function that will return a 1
% (keep) or 0 (discard)
% INPUT:
% unitArray - the unit array to be filtered
% bOR       - boolean: if true, take the union of units passing through
% each filter; if false, take the intersection.
% varargin - should be a list (as separate args or a cell array) of
% field/value OR field/<fcn_handle> pairs
% N.B. value cannot presently be a vector - will fix this as soon as I need
% it (soon).
% e.g. unitArray = filtUnitArray(unitArray, 0, 'label', 'good unit');
% OR equivalently to illustrate passing functions:
% unitArray = filtUnitArray(unitArray, 0, 'label', @(str)(strcmp(str, 'good
% unit')) );
% Notice here that the argument to the anonymous function (here, 'str'),
% will be passed the value of the field for every unit
% OUTPUT:
% unitArray - the filtered unit array
% logical_vector - the logical vector that implemented the filtering
% operation (length of the original unitArray, with true for all units
% present in filtered array, false otherwise)

    % handle if all the filters are passed as one cell array
    if(iscell(varargin{1}) && nargin == 3)
        filterpairs = varargin{1};
    else
        filterpairs = varargin(1:nargin-2);
    end
    
    filtersLength = length(filterpairs);
    assert(mod(filtersLength, 2) == 0, 'filtUnitArray: unbalanced field/value (or field/fcn_handle) pair!');
    leftlist = filterpairs(1:2:filtersLength);
    rightlist = filterpairs(2:2:filtersLength);
    numFilters = filtersLength/2;
    
    
    if(bOR)
        logical_vector = zeros([1 length(unitArray)]); % initial vector should be all zeros for OR ops
        andor = @(a,b)(a|b);        
    else
        logical_vector = ones([1 length(unitArray)]); % initial vector should be all ones for AND
        andor = @(a,b)(a&b);
    end    
    
    for(filtIdx = 1:numFilters)
        logical_vector = andor(logical_vector, process_filter_pair(unitArray, leftlist{filtIdx}, rightlist{filtIdx}));
    end
    unitArray = unitArray(logical_vector);

function lvec = process_filter_pair(units, leftarg, rightarg)
    % eval used below so that one can reference fields with multiple
    % periods
    if(isa(rightarg, 'function_handle'))
        decision_fcn = @(unit)( rightarg(eval(['unit.',leftarg])) ); 
    else
        decision_fcn = @(unit)(isequal(eval(['unit.',leftarg]), rightarg));
    end
    lvec = logical(arrayfun(decision_fcn, units));
end

end

