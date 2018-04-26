function [filename fpath] = getFilename(filename)
% function [filename fpath] = getFilename(filename)

ind = regexp(filename,'\');

if isempty(ind);
    fpath = '';
else
    fpath = filename(1:ind(end));
    filename = filename(ind(end)+1:end);
end
