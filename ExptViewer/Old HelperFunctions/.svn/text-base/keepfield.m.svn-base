function s = keepfield(s,field)
% function s = keepfield(s,field);
% BA compliment to rmfield
allfields = fieldnames(s);
s = rmfield(s,allfields(~ismember(allfields,field)));