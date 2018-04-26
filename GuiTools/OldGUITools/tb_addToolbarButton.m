function hButton = tb_addToolbarButton(hFig, iconFilename, toggleOrPush, clickedCallback)
%
% Creates a toolbar button with the specified icon and clicked callback
%
% INPUT
%   hFig: handle to figure


% Get toolbar handle
ht = findall(hFig,'Type','uitoolbar');
ht = ht(1);  % Use first toolbar found

% Make button
rd = RigDefs;
iconFile = [rd.Dir.Icons, iconFilename];

if strcmp(toggleOrPush, 'push')
    hButton = uipushtool(ht,'CData',iconRead(iconFile),'ClickedCallback',clickedCallback);
elseif strcmp(toggleOrPush, 'toggle')
    hButton = uitoggletool(ht,'CData',iconRead(iconFile),'ClickedCallback',clickedCallback);
else
    error('tb_addToolbarButton was called with argument "toggleOrPush" set to an invalid option (valid options are "toggle" and "push")');
end
    
