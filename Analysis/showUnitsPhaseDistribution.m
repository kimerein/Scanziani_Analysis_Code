function showUnitsPhaseDistribution(unitArray, globalax)    
    if(~isfield(unitArray, 'spikephases'))
        unitArray = addUnitFields(unitArray, 'spikephases');
        unitArray = populateUnitFields(unitArray);
    end    
    
    if(nargin < 2)
        globalax = figure;
        set(globalax,'Visible','off','Position',[0 724 528 322]);    
    end

    phasedistax = axes('Parent', globalax,'Position', [ 1/6,   1/6,            2/3,     3/4*(2/3)]);
    refwaveax = axes('Parent', globalax, 'Position', [  1/6,   3/4*(2/3)+1/6,  2/3,     1/4*(2/3)]);

    
    phasePlotterFcn = @(unit)(unitPhaseDistPlot(unit.spikephases, phasedistax, refwaveax));
    arrayfun(phasePlotterFcn, unitArray);        
    
    if(nargin < 2)
        set(globalax, 'Visible', 'on');
    end
end

