function y = compareDouble(x,value)
% function y = compareDouble(x,value)
%
%
%

% Created: 9/10 - SRO

for i = 1:length(value)
    
    
    if ~(value(i) == 0)
        y(:,i) = (x > value(i) - 1E-6*value(i)) & (x < value(i) + 1E-6*value(i));
    else
        y(:,i) = x == 0;
    end
    
end

y = any(y,2)';