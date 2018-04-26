function closedaq()

hDaqController = evalin('base', 'hDaqController');
hDaqDataViewer = evalin('base', 'hDaqDataViewer');
hDaqPlotChooser = evalin('base', 'hDaqPlotChooser');
hExptTable = evalin('base', 'hExptTable');

% If analysis plots are open then delete them
try % need a try here in case the DataViewer is already closed, in which case guidata(hDaqDataViewer) will throw an error
    h = guidata(hDaqDataViewer);
    % and nested tries are necessary so that if one of these fails the rest
    % are still attempted
    try delete(h.fr.frFig); end
    try delete(h.psth.psthFig); end
    try delete(h.lfp.lfpFig); end
end

try delete(hDaqController); end
try delete(hDaqDataViewer); end
try delete(hDaqPlotChooser); end
try delete(hExptTable); end

evalin('base','clear hDaqController')
evalin('base','clear hDaqDataViewer')
evalin('base','clear hDaqPlotChooser')
evalin('base','clear hExptTable')