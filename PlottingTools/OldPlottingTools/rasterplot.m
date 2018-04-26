function h = rasterplot(data,trial,plotparam)
% function h = rasterplot(data,trial,plotparam)
% creates rasterplot of spiketime data 
%
% INPUT:
%        data - Vector of spike times ( time in samples)
%        trial  -if vector must be same length as data (i.e. a trial for each spiketime)
%        the ydirection. length of each line is 1/maxTrial
%       % plotparam.
%               fid - figure handle <new figure>
%               scolor - default 'k' character of 1x3 vector with color
% BA 04.09.10

%%
if  nargin < 3 || isempty(plotparam) ,
    plotparam.scolor = [];
    plotparam.fid=[];
else
    if ~isfield(plotparam,'scolor'), plotparam.scolor = []; end
    if ~isfield(plotparam,'fid'), plotparam.fid = []; end 
end

%% plot defaults
if  isempty(plotparam.scolor), scolor = [ 0 0 0]; end
if isempty(plotparam.fid), plotparam.fid=figure(); end
set(0,'CurrentFigure',plotparam.fid);

if ~isempty(data)
    h = linecustommarker(data,trial);
set(h,'linewidth',1,'color',scolor,'Tag','rasterline')
set(gca,'YDir','reverse') % so that first trial is at the top
else h = []; end

if isempty(h), h = NaN; end % this can happen if spiketimes fed in is empty

