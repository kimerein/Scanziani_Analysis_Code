function defaultAxes(hAxes,xdta,ydta,fontsize)
%
%
% INPUTS
%   hAxes:
%   xdta:
%   ydata:
%   fontsize:

% Created: 3/15/10 - SRO
% Modified: 5/16/10 - SRO


if nargin < 2
    xdta = 0.10;    % Distance to axis
    ydta = 0.13;
    fontsize = 8;
end

if nargin < 4
    fontsize = 8;
end

% Set color of axes
axesGray(hAxes)

% Set tick out
set(hAxes,'TickDir','out');

% Set font size
set(hAxes,'FontSize',fontsize);

% Remove box
% box off

% Set position of tick label

% Set position and font size of axis label
% for i = 1:length(hAxes)
pta = 0.5;      % Parallel to axis
if length(hAxes) > 1
    set(cell2mat(get(hAxes,'XLabel')),'Units','normalized','Position',[pta -xdta 1]);
    set(cell2mat(get(hAxes,'YLabel')),'Units','normalized','Position',[-ydta pta 1]);
else
    set(get(hAxes,'XLabel'),'Units','normalized','Position',[pta -xdta 1]);
    set(get(hAxes,'YLabel'),'Units','normalized','Position',[-ydta pta 1]);
end

