function removeToolbarButtons(hFig,keepInd)
%
% Removes standard toolbar buttons
%
% INPUT
%   hFig: handle to the figure
%   toolInd: Index of tools to be retained.
%   1: Plot tools and dock
%   2: Hide plot tools
%   3: Insert legend
%   4: Insert colorbar
%   5: Link plot
%   6: Brush data
%   7: Data cursor
%   8: Rotate
%   9: Hand
%   10: Zoom out
%   11: Zoom in
%   12: Edit plot
%   13: Print
%   14: Save figure
%   15: Open figure
%   16: New figure


if nargin < 2
    keepInd = [7 10 11 12];
end


% Remove tools
set(0,'Showhidden','on')
ch = get(hFig,'children');
tools = get(ch(9),'children');
deleteInd = 1:16;
deleteInd = setdiff(deleteInd,keepInd);
delete(tools(deleteInd))

% Turn dock controls off
set(hFig,'DockControls','off')

% Remove standard figure menu
m = findall(ch,'Type','uimenu');
delete(m)

set(0,'Showhidden','off')


