function handles = MakeLPVector(handles)
%
%
%   Created: 4/5/10 - SRO
%   Modified:

dvplot = getappdata(handles.hDataViewer,'dvplot');
temp = 1:handles.nActiveChannels;
LPVector = cell2mat(get(handles.hTglLP,'Value'));
LPVector = LPVector(1:handles.nActiveChannels);
dvplot.lpvOn = temp(LPVector==1)';
setappdata(handles.hDataViewer,'dvplot',dvplot)