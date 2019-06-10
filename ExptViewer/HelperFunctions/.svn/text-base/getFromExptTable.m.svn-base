function value = getFromExptTable(ExptTable,field)
% function value = getFromExptTable(ExptTable,field)
%
% INPUT
%   ExptTable: N x 2 cell array containing information about experiment.
%   field: Field to be queried. Must be a string.
%   
% OUTPUT
%   value: Entry in table corresponding to field.


%   Created: 4/6/10 - SRO


iRow = strcmp(ExptTable(:,1),field);

if any(iRow)
    value = ExptTable(iRow,2);
    if iscell(value)
        value = value{1};
    end
else
    disp(['The field,' ' ' field ', was not found in ExptTable'])
    value = '';
end
    

