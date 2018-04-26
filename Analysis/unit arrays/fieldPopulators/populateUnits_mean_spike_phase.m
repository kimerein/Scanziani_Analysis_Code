function unitArray = populateUnits_mean_spike_phase(unitArray)
    doAsk = '';
    while(~strcmpi(doAsk, 'y') && ~strcmpi(doAsk, 'n') && ~strcmpi(doAsk, 'ask'))
        doAsk = input('Would you like to extract spikephases for units that do not have them cached? (''y'', ''n'', or ''ask'')', 's');
    end
    unitArray = unitArray_forEachUnit(unitArray, @populateUnit_spikephasesORfreqs, 1, [], 'mean_spike_phase', doAsk);
end


