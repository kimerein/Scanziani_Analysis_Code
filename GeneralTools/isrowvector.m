function out =isrowvector(x)
% function isrowvector(x)
%
% check if x is a row vector returns 1 else 0

if size(x,1) ==1
    out =1;
else
    out = 0;
end