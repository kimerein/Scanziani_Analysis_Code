function varargout = computeResponseVsStimulus(spikes,stim,cond,w)
% function varargout = computeResponseVsStimulus(spikes,stim,cond,w)
%
% INPUT
%   spikes: spikes struct
%   stim: stimulus struct with fields: .type, .values, .code (cell array for
%   holding multiple code values)
%   cond: condition struct with fields: .type, .values
%   w: window struct with windows for analysis.  If not supplied entire
%   sweep will be used as window.
%
% OUTPUT
%   varargout{1} = fr: firing rate
%   varargout{2} = nfr: normalized firing rate

% Created: 5/16/10 - SRO
% Modified: 11/1/11 - KR 
% KR added reasonable normalization procedure for 
% SUPPRESSION below spontaneous firing rate


% Make make spikes substruct for each stimulus value and condition value
for m = 1:length(stim.values)
    for n = 1:length(cond.values)
        if strcmp(cond.type,'led')
            spikes.tempfield = spikes.led;
            spikes.tempfield = compareDouble(spikes.tempfield,cond.values{n});
            spikes.sweeps.tempfield = spikes.sweeps.led;
            spikes.sweeps.tempfield = compareDouble(spikes.sweeps.tempfield,cond.values{n});
            cspikes(m,n) = filtspikes(spikes,0,'stimcond',stim.code{m},'tempfield',1);
        else
            cspikes(m,n) = filtspikes(spikes,0,'stimcond',stim.code{m},cond.type,cond.values{n});
        end
    end
end

% Compute average firing rate for each stim, cond, and window
wnames = fieldnames(w);
for m = 1:size(cspikes,1)
    for n = 1:size(cspikes,2)
        for i = 1:length(wnames)
            temp = wnames{i};
            fr.(temp)(m,n) = computeFR(cspikes(m,n),w.(temp));
        end
    end
end

% Substract spontaneous rate from each window except spont window
wnames = fieldnames(fr);
for i = 1:length(wnames)
    temp = wnames{i};
    if ~strcmp(temp,'spont')
        fr.(temp) = fr.(temp) - fr.spont;
    end
end

% Compute normalized firing rate
% SRO normalized to maximal rate
% but this does not make sense for suppression below 
% baseline firing rate
% Instead, normalize to the area under the absolute
% value of the curve
% wnames = fieldnames(fr);
% for i = 1:length(wnames)
%     temp = wnames{i};
%     for n = 1:size(fr.(temp),2)
%         nfr.(temp)(:,n) = fr.(temp)(:,n)/max(fr.(temp)(:,n));
%     end
% end
wnames=fieldnames(fr);
for i=1:length(wnames)
    temp=wnames{i};
    % Calculate area under the absolute value of the curve
    for n=1:size(fr.(temp),2)
        s=sum(abs(fr.(temp)(:,n)));
        fac=1/s;
        nfr.(temp)(:,n)=fac*fr.(temp)(:,n);
    end
end

% Outputs
varargout{1} = fr;
varargout{2} = nfr;
% varargout{3} = ci;
% varargout{4} = stimval;
% varargout{5} = condval;