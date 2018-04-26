function [trodeInd unitInd] = readUnitTag(unitTag)
%
%
%
%

% Created: 7/20/10 - SRO

loc = strfind(unitTag,'_');
Tloc=strfind(unitTag,'T');
trodeInd = str2num(unitTag(Tloc+1:loc-1));
unitInd = str2num(unitTag(loc+1:end));
