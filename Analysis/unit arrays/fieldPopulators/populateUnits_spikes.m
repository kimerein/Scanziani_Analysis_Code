function unitArray = populateUnits_spikes(unitArray)
    unitArray = unitArray_forEachUnit(unitArray, @populateUnit_spikes, 1);                 
end

