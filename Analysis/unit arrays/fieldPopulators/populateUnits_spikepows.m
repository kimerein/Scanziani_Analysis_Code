function unitArray = populateUnits_spikepows(unitArray)
    doAsk = '';
    while(~strcmpi(doAsk, 'y') && ~strcmpi(doAsk, 'n') && ~strcmpi(doAsk, 'ask'))
        doAsk = input('Would you like to extract spikepows for units that do not have them cached? (''y'', ''n'', or ''ask'')', 's');
    end
    unitArray = unitArray_forEachUnit(unitArray, @populateUnit_spikephasesORfreqs, 1, [], 'spikepows',doAsk);
end