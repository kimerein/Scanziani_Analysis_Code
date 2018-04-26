function spikes = makeTempField(spikes,field,value)
% function spikes = makeTempField(spikes,field,value)
%
% INPUT:
%   spikes:
%   field: Field in spikes on which to perform comparison for generated
%   tempfield (e.g. led)
%   value: Value
%   *** To add *** Flag for >, >, =>, <= operations

% Created: 10/18/10 - SRO


s = spikes;

% Make temp field
s.temp = s.(field);

% Compare to value with low precision
s.temp = compareDouble(s.temp,value);

% Make temp field in sweeps
if isfield(s.sweeps,(field))
    s.sweeps.temp = s.sweeps.(field);
    s.sweeps.temp = compareDouble(s.sweeps.temp,value);
end

spikes = s;


