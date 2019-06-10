function handles = GetLineThreshValues(handles)

% KR - modified 7/7/10 to make lines for spike thresholding, rather than
% sliders
Thresholds = zeros(length(handles.hThresh),1);
for i = 1:length(handles.hThresh)
    th = get(handles.hThresh(i),'Ydata');
    Thresholds(i) = th(1);
end
Invert = sign(Thresholds);
Invert(Invert==0) = 1;
handles.Thresholds = [abs(Thresholds) Invert];
setappdata(handles.hDataViewer,'Thresholds',handles.Thresholds);
guidata(handles.hDataViewer,handles)