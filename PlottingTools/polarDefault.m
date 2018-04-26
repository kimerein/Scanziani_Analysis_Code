function polarDefault(hAxes)
%
% INPUT
%   hAxes:

% Created: 3/15/10 - SRO

% Find line object and change color from black to gray
temp = findall(hAxes,'type','line');
temp = findobj(temp,'Color',[0 0 0]);
set(temp,'Color',[0.9 0.9 0.9]);

% Find text objects and change color and size
temp = findall(hAxes,'type','text');
set(temp,'Color',[0.3 0.3 0.3],'FontSize',8,'Visible','off');
