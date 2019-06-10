function handles = MakeHPVector(handles)
%
%
%   Created: 4/5/10 - SRO
%   Modified:

dvplot = getappdata(handles.hDataViewer,'dvplot');
temp = 1:handles.nActiveChannels;
HPVector = cell2mat(get(handles.hTglHP,'Value'));
HPVector = HPVector(1:handles.nActiveChannels);
dvplot.hpvOn = temp(HPVector==1)';
setappdata(handles.hDataViewer,'dvplot',dvplot)