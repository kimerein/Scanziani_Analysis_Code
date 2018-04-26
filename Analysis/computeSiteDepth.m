function expt = computeSiteDepth(expt)
% function expt = computeSiteDepth(expt)
%
%
%
%

% Created: 5/21/10 - SRO
% Modified: 7/15/10 - SRO


% Set parameters (xdist is distance read off manipulator keypad)
config = expt.probe.configuration;
angle = expt.probe.angle;
xdist = expt.probe.xdistance;


if ~isempty(config) && ~isempty(angle) && ~isempty(xdist)
    
    % Find tip depth along z-dimension
    angle = angle*pi/180;   % radians
    tipdepth = cos(angle)*xdist;
    
    % Set distances between tip and electrode site
    nchn = expt.probe.numchannels;
    switch config
        case {'1x16','1 x 16'}
            d = (nchn:-1:1)*50; % d is distance from tip of probe
            
        case {'2x2','2 x 2'}
            d = [248 230 230 212 248 230 230 212 116 98 98 80 116 98 98 80];
            
        case {'4x1','4 x 1'}
            d = [116 98 98 80 116 98 98 80 116 98 98 80 116 98 98 80];
            
        case {'1x1','1 x 1'}
            d = tipdepth;      
    end
    
    % Find sitedepth for each site
    sitedepth = tipdepth - d*cos(angle);
    
else
    tipdepth = [];
    sitedepth = [];
    disp('The fields .tipdepth and .sitedepth are empty')
end

% Set fields
expt.probe.tipdepth = round(tipdepth);
expt.probe.sitedepth = round(sitedepth);      % Order from superficial to deep
disp('Check this code NOW!')
pause


