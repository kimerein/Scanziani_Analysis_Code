function [maskMat,maskSizePix,maskRefRect] = makeMask(p,d,visSizeStim,white,black)
%
%
%

% Created: SRO - 6/2/10
% Modified: SRO - 6/4/10


% Set size, rows, and columns
maskSizeDeg = p.size;
rows = p.rows;
cols = p.columns;

% Set gray value
gray = round((white + black)/2);

% Convert mask size in degrees to pixels
maskSizePix = ceil(maskSizeDeg/d.degPerPix);

% Set empty (buffer) space on screen
bufferX = (d.ScreenSizePixX - cols*maskSizePix)/2;
bufferY = (d.ScreenSizePixY - rows*maskSizePix)/2;

% Set width of entire matrix
width = visSizeStim*2;
height = width;    

% Gray background
maskMat = ones(height,width,2)*gray;

% Find center of mask
centerLeft = round(width/2 - maskSizePix/2);
centerRight = centerLeft + maskSizePix;

% Set alpha (transparency channel)
maskMat(:,:,2) = white;
maskMat(centerLeft:centerRight,centerLeft:centerRight,2) = black;

% Make reference rectangle
L = centerLeft - (visSizeStim - d.ScreenSizePixX)/2 - bufferX;
T = centerLeft - (visSizeStim - d.ScreenSizePixY)/2 - bufferY;
R = L + visSizeStim;
B = T + visSizeStim;
maskRefRect = [L T R B];  % [left top right bottom]









