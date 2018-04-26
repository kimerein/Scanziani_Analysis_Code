function unitArray = populateUnits_oriRates(unitArray)

 unitArray = unitArray_forEachUnit(unitArray, @populateUnit_oriRates, 1);