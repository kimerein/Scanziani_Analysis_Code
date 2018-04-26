function unit = populateUnit_spiketimes(unit, curExpt, curTrodeSpikes)
    tempspikes = filtspikes(curTrodeSpikes, 0, 'assigns', unit.assign);
    unit.spiketimes = tempspikes.spiketimes;                    
end

