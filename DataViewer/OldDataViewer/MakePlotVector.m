function handles = MakePlotVector(handles)
%
%
%   Created: 4/5/10 - SRO
%   Modified: 

dvplot = getappdata(handles.hDataViewer,'dvplot');
temp = 1:handles.nActiveChannels;
PlotVector = cell2mat(get(handles.hTglPlotAll,'Value'));            % Returns a vector of 1s and 0s
PlotVector = PlotVector(1:handles.nActiveChannels);                 % Only take active channels
dvplot.pvOn = temp(PlotVector==1)';
dvplot.pvOff = temp(PlotVector==0)';
setappdata(handles.hDataViewer,'dvplot',dvplot)