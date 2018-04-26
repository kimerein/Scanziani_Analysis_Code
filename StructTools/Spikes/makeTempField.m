function spikes = makeTempField(spikes,field,value,type,name)
% function spikes = makeTempField(spikes,field,value,type)
%
% INPUT:
%   spikes:
%   field: Field in spikes on which to perform comparison for generated
%   tempfield (e.g. led)
%   value: Value
%   type: 'equal','greater','less','between'

% Created: 10/18/10 - SRO
% Modified: 4/1/11 - SRO

if nargin < 4
    type = 'equal';
end

if nargin < 5
    name = 'temp';
end

s = spikes;

% Flag for filtering sweeps on value
bSweeps = 1;

% Make temp field
s.temp = s.(field);

% Make temp field in sweeps
if isfield(s.sweeps,field)
    s.sweeps.temp = s.sweeps.(field);
else
    s.sweeps.temp = ones(size(s.sweeps.trials));
    bSweeps = 0;
end

switch type
    case 'equal'
        % Compare to value with low precision
        s.temp = compareDouble(s.temp,value);
        if bSweeps
            s.sweeps.temp = compareDouble(s.sweeps.temp,value);
        end
    case 'greater'
        k = s.temp > value;
        s.temp = zeros(size(s.temp));
        s.temp(k) = 1;
        
        if bSweeps
            k = s.sweeps.temp > value;
            s.sweeps.temp = zeros(size(s.sweeps.temp));
            s.sweeps.temp(k) = 1;
        else
            s.sweeps.temp = ones(size(s.sweeps.trials));
        end
        
    case 'less'
        k = s.temp < value;
        s.temp = zeros(size(s.temp));
        s.temp(k) = 1;
        
        if bSweeps
            k = s.sweeps.temp < value;
            s.sweeps.temp = zeros(size(s.sweeps.temp));
            s.sweeps.temp(k) = 1;
        else
            s.sweeps.temp = ones(size(s.sweeps.trials));
        end
        
    case 'between'
        k = (s.temp > value(1)) & (s.temp < value(2));
        s.temp = zeros(size(s.temp));
        s.temp(k) = 1;
        
        if bSweeps
            k = (s.sweeps.temp > value(1)) & (s.sweeps.temp < value(2));
            s.sweeps.temp = zeros(size(s.sweeps.temp));
            s.sweeps.temp(k) = 1;
        else
            s.sweeps.temp = ones(size(s.sweeps.trials));
        end
end

s.(name) = s.temp;
s.sweeps.(name) = s.sweeps.temp;

spikes = s;


