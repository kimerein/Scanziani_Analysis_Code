function spikes = spikes_collapseVarParam(spikes,varparam,nCollapse)
% function spikes = spikes_collapseVarParam(spikes,varparam,nCollapse)

% only deal with stim conditions where VarParams change ( don't include
% blanks which should have stimcond> nVar1 * nVar2

nVar1 = length(varparam(1).Values);
if length(varparam)>1, nVar2 = length(varparam(2).Values); else nVar2 = 1; end
spikes_indVar = find(spikes.stimcond<=nVar1*nVar2); % get index of spikes and sweeps that are not blank
sweeps_indVar = find( spikes.sweeps.stimcond<=nVar1*nVar2); % get index of spikes and sweeps that are not blank

if length(varparam)>1
    if nCollapse==2
        
        % rescale sweep and spike condf
        tempspikestimcond = spikes.stimcond(spikes_indVar);
        tempspikestimcond = (floor((tempspikestimcond-1)/length(varparam(2).Values))+1);
        
        tempswcond = spikes.sweeps.stimcond(sweeps_indVar);
        tempswcond= (floor((tempswcond-1)/length(varparam(2).Values))+1);
        
        spikes.stimcond(spikes_indVar) = tempspikestimcond;
        spikes.sweeps.stimcond(sweeps_indVar) = tempswcond;
        
    elseif nCollapse==1
        % rescale sweep and spike condf
        tempspikestimcond = spikes.stimcond(spikes_indVar);
        tempspikestimcond = rem(tempspikestimcond -1,length(varparam(2).Values))+1;
        
        tempswcond = spikes.sweeps.stimcond(sweeps_indVar);
        tempswcond= rem(tempswcond -1,length(varparam(2).Values))+1;
        
        spikes.stimcond(spikes_indVar) = tempspikestimcond;
        spikes.sweeps.stimcond(sweeps_indVar) = tempswcond;
        
    end
    
end