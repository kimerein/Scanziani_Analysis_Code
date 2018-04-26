
function file = saveButton_callback(hObject,eventdata)

h = guidata(hObject);

% Set save name
fPath = h.FigDir;
if isfield(h,'ExptName')
    exptName = h.ExptName;
else
    exptName = getappdata(h.hDaqCtlr,'ExptName');
end
fName = [exptName '_' h.FigType '_' datestr(now,30) '.fig'];
file = [fPath fName];

% Make figure invible for save
saveas(gcbf,file)