function [expected, lb, ub, RPV ] = poisson_contamination( spikes, use )
% UltraMegaSort2000 by Hill DN, Mehta SB, & Kleinfeld D  - 07/12/2010
%
% poisson_contamination - estimate contamination of a spike train
%
% Usage:
%      [expected, lb, ub, RPV ] = poisson_contamination( spikes, use )
%
% Description:  
%    Wrapper function to call get_rpv_range which estimates contamination
%  of a spike train by observing refractory period violations (RPVs) and 
%  assuming that contaminating spikes are independent and Poisson.
%
% Input: 
%   spikes   - a spike structure
%   show     - array describing which events to show in plot
%            - see get_spike_indices.m
%
% Output:
%   expected   - expected value of % contamination,
%   lb   - lower bound on % contamination, using alpha confidence interval
%   ub   - upper bound on % contamination, using alpha confidence interval
%   RPV  - number of RPVs found
%

    % get spike times
    members = get_spike_indices( spikes, use);     
    spiketimes =  sort( spikes.unwrapped_times(members) );

    % get important parameters
    N = length( members );
    T = sum( spikes.info.detect.dur );
    RP = (spikes.params.refractory_period - spikes.params.shadow) * .001; 
    RPV  = sum( diff(spiketimes)  <= (spikes.params.refractory_period * .001) );

    % calculate contamination
    [lb,ub,expected] = get_rpv_range(N, T, RP, RPV );
    
    
    
