function sv(s)
% function sv(s)
%
% INPUT
%   s: Struct with field name fname. fname is the file name 

% Created: SRO - 6/9/11



vname = inputname(1);
eval([vname ' = s;']);
save(s.fname,vname);