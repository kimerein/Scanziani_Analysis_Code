function dv = dvCallbackHelper(hDataViewer)
%
%
%
%   Created: 4/3/10 - SRO
%   Modified:

% Get handles for DataViewer plot objects
temp = getappdata(hDataViewer,'handlesPlot');
dv.hAllAxes = temp(1,:);
dv.hPlotLines = temp(2,:);
dv.hRasters = temp(3,:);

% Get data for plots, rasters, and filtering
dvplot = getappdata(hDataViewer,'dvplot');
dv.PlotVectorOn = dvplot.pvOn;
dv.LPVectorOn = dvplot.lpvOn;
dv.HPVectorOn = dvplot.hpvOn;
dv.RasterVectorOn = dvplot.rvOn;
dv.LPCutoff = getappdata(hDataViewer,'LPCutoff');
dv.HPCutoff = getappdata(hDataViewer,'HPCutoff');
dv.Thresholds = getappdata(hDataViewer,'Thresholds');
dv.Invert = dv.Thresholds(:,2);
dv.Thresholds = dv.Thresholds(:,1);
dv.nPlotOn = length(dv.PlotVectorOn);