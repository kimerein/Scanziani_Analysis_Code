function unitArray = populateUnits_trodeSpikes(unitArray)
    unitArray = unitArray_forEachUnit(unitArray, @populateUnit_trodespikes, 1);
end


