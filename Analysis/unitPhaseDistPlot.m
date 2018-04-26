function [phasedistax refwaveax] = unitPhaseDistPlot(phases, phasedistax, refwaveax, colors)
    % * can be called repeatedly on the same axes to append new data
    % * will figure out how many lines have already been drawn and update
    % colors and markers accordingly
    
    if(nargin < 3)
        phasedistax = axes('Position', [0,0,1,3/4]);
        refwaveax = axes('Position', [0,3/4,1,1/4]);
    end
    if(nargin < 4)
        colors = {'red', 'blue', 'cyan', 'yellow', 'black'};
    elseif(~iscell(colors))
        colors = {colors};
    end
    
    binedges = 0:15:360;
    if(size(phases, 1) == 1)
        phases = phases(:);
    end
    
    % in case this function is called on already populated axes to append
    % new data, we must check other data for maximum y value
    numLines = 0;
    axchildren = get(phasedistax, 'Children');
    allydata = 0;
    for(j = 1:length(axchildren))
        if(~strcmp(get(axchildren(j), 'Type'), 'line'))
            continue;
        end
        tempydata = get(axchildren(j), 'YData');
        allydata = [allydata(:); tempydata(:)];
        
        numLines = numLines+1;
    end
    
    counts = histc(phases, binedges, 1); 
    counts = repmat(counts(1:end-1, :), [2 1]);      
    bincenters = 7.5:15:712.5;
    relcount = nan(size(counts));
    for(i = 1:size(counts, 2))
        numLines = numLines + 1;
        cidx = mod(numLines, length(colors)) + ~mod(numLines, length(colors))*length(colors);
        relcount(:, i) = counts(:,i)./sum(counts(:,i));
        line(bincenters, relcount(:, i), 'Parent', phasedistax, 'Color', colors{cidx}); 
        
        % mark mean phases
        meanPhase = circularMean(phases(:, i), 360, 1); % third arg specifies nanmean
        phaseMarkerStyle = [{'\downarrow'} {''} {'\uparrow'} {'bottom'} {'top'} {'left'} {'right'} {' '} {''} {' '}];
        styleIdx = mod(numLines, 2) + ~mod(numLines, 2)*2;
        % have to do the arrow and text in separate text() calls so that
        % the arrow can be centered on the relevant data
        text(meanPhase, cos(meanPhase*(pi/180)), [phaseMarkerStyle{styleIdx}, phaseMarkerStyle{styleIdx+1}], 'Parent', refwaveax, ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', phaseMarkerStyle{styleIdx+3}, 'Color', colors{cidx});
        text(meanPhase, cos(meanPhase*(pi/180)), [phaseMarkerStyle{styleIdx+7}, num2str(round(meanPhase)), '{\circ}', ...
            phaseMarkerStyle{styleIdx+8}], 'Parent', refwaveax, 'HorizontalAlignment',phaseMarkerStyle{styleIdx+5}, ...
            'VerticalAlignment', phaseMarkerStyle{styleIdx+3},'Color', colors{cidx});                        
    end
    line(bincenters, cos(bincenters*(pi/180)), 'Parent', refwaveax, 'Color', 'black');
    
    ylimit = max([allydata(:); relcount(:)]);
    
    set(phasedistax, 'YLim', [0, ylimit*1.15], 'XLim', [0 720], 'XTick', [0 180 360 540 720]);
    set(refwaveax, 'XLim', [0 720], 'XTick', [], 'YTick', [], 'Layer', 'bottom');    
    
end

