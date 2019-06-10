function dvUnitDisplay(dv,expt,PlotObj,hDataViewer)

dv.hUnitRaster = getappdata(hDataViewer,'handlesUnit');
r = RigDefs();
% TO DO add
% FOR itrode = 1:each trode
itrode = 2;

% SET colors to match mergtool colors
my_colors = {[1 0 0],[0 1 0],[0 0 1],[0 1 1],[1 0 1],[1 1 0]};
% get spikes file
% WATCH out this could get slow??
try
    load(fullfile(r.Dir.Spikes,expt.sort.trode(itrode).spikesfile))

% get assigns to plot
assigns = unique(spikes.assigns);
ind_nongarbage = cellfun(@(x) ~isequal(x,'garbage'),spikes.params.display.label_categories(spikes.labels(:,2)));
assignsToPlot = assigns(ind_nongarbage);
catch
    spikes = [];
    assignsToPlot = [];
end
% get the channel to plot it on (us the first channel in the probe)
trodeChns = cell2mat(expt.probe.trode(itrode).sites);
plotChn = trodeChns(1)+1;
ylim = get(dv.hAllAxes(plotChn),'YLim');

for iassigns = 1:length(assignsToPlot)
    thisAssign =  assignsToPlot(iassigns);
    thisSp = filtspikes(spikes,0,'assigns',thisAssign,'fileInd',PlotObj.FileIndex,'trigger',PlotObj.Trigger);
    if ~isempty( thisSp.spiketimes)
        loc = thisSp.spiketimes;
        pks = loc;
        pks(:) = ylim(2)*0.9;       % y-location of raster is set to 0.95*y-axis max
        
    else pks = NaN; loc = NaN;
    end
    
    bCreatehUnitRaster = 1;
    if isfield(dv,'hUnitRaster')
        if length(dv.hUnitRaster)>=iassigns
            try
                set(dv.hUnitRaster(iassigns),'XData',loc,'YData',pks);
                bCreatehUnitRaster = 0;
            catch ME, getReport(ME); bCreatehUnitRaster = 1; end
        end
    end
    if bCreatehUnitRaster
        dv.hUnitRaster(iassigns) = line('XData',loc,'YData',pks,'Parent',dv.hAllAxes(plotChn),...
            'color',my_colors{iassigns},'Marker','.','LineStyle','none');
        setappdata(hDataViewer,'handlesUnit',dv.hUnitRaster)
    end
    
end



