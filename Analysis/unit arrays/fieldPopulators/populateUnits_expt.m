function unitArray = populateUnits_expt(unitArray)
    unitArray = unitArray_forEachUnit(unitArray, @populateUnit_expt, 1);
end

