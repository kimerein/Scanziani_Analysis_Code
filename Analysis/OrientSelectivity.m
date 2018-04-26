function [OSI varargout] = OrientSelectivity(orientations,responses,prefDir)

% prefDir is not supplied, then find it
if nargin < 3
    % Get orientation of maximum response
    maxR = max(responses);
    maxD = orientations(responses == maxR);
    if numel(maxD) > 1
        maxD = maxD(floor(numel(maxD)/2));
    end
else
    maxD = prefDir;
end

% Get direction 180 degrees away
maxD180 = mod((maxD+180),360);

% Get perpendicular directions
nullD = mod((maxD+90),360);
nullD180 = mod((nullD+180),360);

% Get response values
pDirR = responses((orientations == maxD) | (orientations == maxD180));
nDirR = responses((orientations == nullD) | (orientations == nullD180));

% Compute orientation selectivity index
OSI = (mean(pDirR) - mean(nDirR))/(mean(pDirR) + mean(nDirR));

% Compute direction selectivity index
DSI = (pDirR(1) - pDirR(2))/(pDirR(1) + pDirR(2));

% Variable outputs
varargout{1} = maxD;
varargout{2} = DSI;