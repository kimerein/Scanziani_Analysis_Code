function loc = FindPeaks(data,Invert,Threshold,xtime)
%
%
%   Created: 1/10 - SRO
%   Modified: 

data = data*Invert;
crossUp = [diff(data>Threshold) == 1 ; 0];
crossDown = [diff(data>Threshold) == -1 ; 0];
crossUp = xtime(crossUp == 1);
crossDown = xtime(crossDown == 1);
if min(crossDown) < min(crossUp)
    [val,ind] = min(crossDown);
    crossDown(ind) = [];
end
dlength = length(crossDown);
ulength = length(crossUp);
if ulength ~= dlength
    crossDown = crossDown(1:min(ulength,dlength));
    crossUp = crossUp(1:min(ulength,dlength));
end

loc = mean([crossUp' crossDown'],2);
