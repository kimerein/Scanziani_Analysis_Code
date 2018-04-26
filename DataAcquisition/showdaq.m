function showdaq()
%
%
%
%
%

% Created: 4/10 - SRO
% Modified: 6/4/10 - SRO

hDaqController = evalin('base', 'hDaqController');
hDaqDataViewer = evalin('base', 'hDaqDataViewer');
hDaqPlotChooser = evalin('base', 'hDaqPlotChooser');
hExptTable = evalin('base', 'hExptTable');

figure(hDaqController)
figure(hDaqDataViewer)
figure(hDaqPlotChooser)
figure(hExptTable)

% If analysis plots are open then show them
h = guidata(hDaqDataViewer);
if getappdata(hDaqDataViewer,'frON')
    figure(h.fr.frFig)
end
if getappdata(hDaqDataViewer,'psthON')
    figure(h.psth.psthFig)
end
if getappdata(hDaqDataViewer,'lfpON')
    figure(h.lfp.lfpFig)
end
if getappdata(hDaqDataViewer,'srfON')
    figure(h.srf.srfFig)
end