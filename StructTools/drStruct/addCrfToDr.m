function dr = addCrfToDr(dr)
% function dr = addCrfToDr(dr)
%
% INPUT
%   dr: Dual recording struct
%

% Created: SRO - 6/9/11


ua = dr.ua;

for u = 1:length(ua)
    % Get contrast values
    c = ua(u).stim.values;
    c = [0; c'];
    
    for i = 1:size(ua(u).fr.ledon,2)    % Number of LED conditions
        %         r = ua(u).fr.ledon(:,i);
        r = ua(u).fr.norm(:,i);
        
        % Compute average spontaneous activity (use as 0 contrast response)
%         rspont = mean(mean(ua(u).fr.spont));
%         r = [rspont; r];
%         
        rspont = 0;
        r = [rspont; r];
        [cfun gof coeff] = fitHrf(c,r,0);
        ua(u).crf.cfun{i} = cfun;
        ua(u).crf.gof(i) = gof;
        ua(u).crf.coeff(:,i) = coeff;
        ua(u).crf.coeffnames = {'baseline','rmax','c50','exponent'};
    end
    
end

dr.ua = ua;

