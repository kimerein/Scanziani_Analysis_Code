function unitArray = populateUnits_osi(unitArray)

unitArray = unitArray_forEachUnit(unitArray, @populateUnit_osi,1);