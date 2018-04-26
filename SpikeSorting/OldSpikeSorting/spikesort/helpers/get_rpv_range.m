function [lb,ub,ev] = get_rpv_range(N, T, RP, RPV )
% UltraMegaSort2000 by Hill DN, Mehta SB, & Kleinfeld D  - 07/09/2010
%
% get_rpv_range - get refractory period violation range
%
% Usage:
%   [lb,ub,ev] = get_rpv_range(N, T, RP, RPV )
%
% Description:
%   Estimates contamination of a cluster based on refractory period
% violations (RPVs).  Estimate of contamination assumes that the 
% contaminating spikes are statistically independent from the other spikes
% in the cluster.  Estimate of the confidence interval assumes Poisson
% statistics.
%
% Input: 
%   N    - Number of spike events in cluster
%   T    - Duration of recording (s)
%   RP   - Duration of refractory period (ms)
%   RPV  - Number of observed refractory period violations in cluster
%
% Output:
%   lb   - lower bound on % contamination, using alpha confidence interval
%   ub   - upper bound on % contamination, using alpha confidence interval
%   ev   - expected value of % contamination,
%

   conf_int = 95; % percent confidence interval
   lambda = N/T;  % mean firing rate for cluster 

   % get Poisson confidence interval on number of expected RPVs
   [dummy, interval] = poissfit(RPV, (100-conf_int)/100 ); 
   
   % convert contamination from number of RPVs to a percentage of spikes
   lb = convert_to_percentage( interval(1), RP, N, T, lambda ); 
   ub = convert_to_percentage( interval(2), RP, N, T, lambda ); 
   ev = convert_to_percentage( RPV        , RP, N, T, lambda );
  
end

function p = convert_to_percentage( RPV, RP, N, T, lambda )
    % converts contamination from number of RPVs to a percentage of spikes

    RPVT = 2 * RP * N; % total amount of time in which an RPV could occur
    RPV_lambda = RPV / RPVT; % rate of RPV occurence
    p =  RPV_lambda / lambda; % estimate of % contamination of cluster
    
    % force p to be a real number in [0 1]
    if isnan(p), p = 0; end  
    if p>1, p= 1; end     
        
end
