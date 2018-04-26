function unitArray = populateUnits_spiketimes(unitArray)
    unitArray = unitArray_forEachUnit(unitArray, @populateUnit_spiketimes, 1);                 
end

