function  [ext] = getfextension(filepath)
% function  [ext] = getfextension(filepath)
tmp = findstr(filepath,'.');
if ~isempty(tmp)
    tmp = max(tmp);
 ext= filepath(tmp+1:end);
end