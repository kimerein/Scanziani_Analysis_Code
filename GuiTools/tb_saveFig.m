function hSaveButton = tb_saveFig(hFig)
%
% Creates a toolbar button for saving the current figure as a .fig file 
%
% INPUT
%   hFig: handle to figure


% Get toolbar handle
ht = findall(hFig,'Type','uitoolbar');
ht = ht(1);  % Use first toolbar found

% Make button
rd = RigDefs;
iconFile = [rd.Dir.Icons, 'file_save.png'];
hSaveButton = uipushtool(ht,'CData',iconRead(iconFile),'ClickedCallback',@saveButton_callback);

