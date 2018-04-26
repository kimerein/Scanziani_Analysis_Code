function handles = MakeThreshVector(handles)
%
%
%   Created: 4/5/10 - SRO
%   Modified:


dvplot = getappdata(handles.hDataViewer,'dvplot');
temp = 1:handles.nActiveChannels;
RasterVector = cell2mat(get(handles.hTglThr,'Value'));
RasterVector = RasterVector(1:handles.nActiveChannels);
dvplot.rvOn = temp(RasterVector==1)';
dvplot.rvOff = temp(RasterVector==0)';
setappdata(handles.hDataViewer,'dvplot',dvplot)