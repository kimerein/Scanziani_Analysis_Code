function cdaq()

hDaqController = evalin('base', 'hDaqController');
hDaqDataViewer = evalin('base', 'hDaqDataViewer');
hDaqPlotChooser = evalin('base', 'hDaqPlotChooser');
hExptTable = evalin('base', 'hExptTable');

figure(hDaqController)
figure(hDaqDataViewer)
figure(hDaqPlotChooser)
figure(hExptTable)