function [trodeInd unitInd] = readUnitTag(unitTag)
% function [trodeInd unitInd] = readUnitTag(unitTag)
%
% INPUT
%   unitTag: Unique tag of the form: "T4_13", trodeInd = 4, assign = 13
%
% OUTPUT
%   trodeInd: Index to the trode
%   assign: Unit assign from spike sorting

% Created: 7/20/10 - SRO

loc = strfind(unitTag,'_');

trodeInd = str2num(unitTag(2:loc-1));
unitInd = str2num(unitTag(loc+1:end));
