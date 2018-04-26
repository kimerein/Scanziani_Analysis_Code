function unitArray = populateUnits_oriTheta(unitArray)

 unitArray = unitArray_forEachUnit(unitArray, @populateUnit_oriTheta, 1);