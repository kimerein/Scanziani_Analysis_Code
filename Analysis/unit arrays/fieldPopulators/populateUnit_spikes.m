function unit = populateUnit_spikes(unit, curExpt, curTrodeSpikes)
    unit.spikes = filtspikes(curTrodeSpikes, 0, 'assigns', unit.assign);    
end



