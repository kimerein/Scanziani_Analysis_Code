function [grating, visSizeGrating] = makeGrating(sf,gratingsize,contrast,white,black,square)
%
%
% INPUT
%   sf: spatial frequency in cycles per second
%   gratingsize: Size of grating in pixels

% Created: SRO - 5/31/10 (inspired by DriftDemo2 in Psychtoolbox)
% Modified: SRO - 6/2/10


% Set gray value
gray = round((white + black)/2);

% Set contrast 'inc'rement range
inc = (white - gray)*contrast;

% Define Half-Size of the grating image on the screen
texsize = gratingsize/2;

% Set visible size of grating (add one point)
visSizeGrating = 2*texsize + 1;

% Calculate parameters of grating:

% Compute pixels per cycle
p = ceil(1/sf);

% Get frequency in radians
sfr = sf*2*pi;

% Create 1D wave in pixels 'p'. Length is equal to visible size of
% grating extended by length of 1 period.
x = -texsize:(texsize + p);

% Compute actual cosine grating
grating = gray + inc*cos(sfr*x);

% If square grating 
if square
    grating(grating < gray) = gray - inc;
    grating(grating >= gray) = gray + inc;
end

