function [out Dp] = parentfolder(D,bcreate)
% function [out Dp] = parentfolder(D,bcreate)
%
% function returns the highest directory in the directory structure D that
% exists
% if bcreate is 1 then it creates the entire directory structure.
% if bcreate is -1 then it removes the entire directory structure.
%
if ~exist('bcreate','var'); bcreate = 0; end
        out =0;

if ~isempty(dir(D))
    out = 1;
    Dp = D;
else
    ind = findstr(D,'\');
    if ~isempty(ind)
        i = ind(end); if i==length(D); i = ind(end-1); end
        Dp = D(1:i);
        [out Dpp] = parentfolder(Dp,bcreate);
        if out & bcreate==1
            s = mkdir(D);
            if s
                display(['Directory: '  D ' created'])
            else                    error(['FAILED to create Directory: '  D ]); end
        elseif out & bcreate==-1
            s =  rmdir(D);
            if s
                display(['Directory: '  D ' remove'])
            else                    error(['FAILED to remove Directory: '  D ]); end          
        end
        Dp = Dpp;
    else
        display('entire directory structure does not exist')
        out = 0;
        D = '';
    end
end