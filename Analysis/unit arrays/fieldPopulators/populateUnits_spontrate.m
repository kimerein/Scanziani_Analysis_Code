function unitArray = populateUnits_spontrate(unitArray)

unitArray = unitArray_forEachUnit(unitArray, @populateUnit_spontrate,1);