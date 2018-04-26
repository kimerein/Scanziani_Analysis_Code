function sweeps = filtsweeps(sweeps,bOR,varargin)
% sweeps = filtsweeps(sweeps,bOR,varargin {property,value})
%
% Filter the spikes.sweeps struct according to one or more property/value pairs.
% INPUTS
%   sweeps: Struct with parameters for each sweep
%   varargin: A property value pair that is used to filter the spikes
%   struct according to the value of the given property for each spike.
%   Multiple property/value pairs can be used to output the spikes
%   corresponding to the intersection of multiple conditions.
% OUTPUTS
%   sweeps: The filtered sweeps struct
%
%   Created:    3/14/10 - SRO
%   Modified:   3/30/10 - BA added bOR
%               6/28/10 - SRO

% 
fromStruct = 0;
if length(varargin) == 1
    sw = varargin{1};
    fromStruct = isstruct(sw);
    if fromStruct
        sortfield = sw.fieldnames;
        sortvalue = sw.sortvalue;
        numSortFields = length(sortfield);
    else
        error('Not enough input arguments')
    end
end

if ~fromStruct
    % Set sort field and values from varargin
    numSortFields = length(varargin)/2;
    for i = 1:numSortFields
        sortfield(i) = {varargin{(i-1)*2+1}};
        sortvalue{i} = varargin{2*i};
    end
end

if ~isempty(sweeps)
    % Make logical vector to sort sweeps
    for i = 1:numSortFields
        tempvector = ismember(sweeps.(sortfield{i}),sortvalue{i});     % Take trials = value
        % Combine multiple conditions
        if (numSortFields > 1) && (i > 1)
            if bOR % OR
                sortvector = sortvector | tempvector;
            else % AND
                sortvector = sortvector & tempvector;
            end
        else
            sortvector = tempvector;
        end
    end
    
    % Use logical vector to extract fileInd, trigger, trials, etc.
    reqSize = size(sweeps.trials);  % Find fields that have same length as trials
    fieldList = fieldnames(sweeps);
    for i = 1:length(fieldList)
        if isequal(size(sweeps.(fieldList{i})),reqSize);
            sweeps.(fieldList{i}) = sweeps.(fieldList{i})(sortvector);      % Using dynamic field names
        end
    end 
end
