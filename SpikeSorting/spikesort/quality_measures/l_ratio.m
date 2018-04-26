function stat = l_ratio( spikes, use )
% UltraMegaSort2000 by Hill DN, Mehta SB, & Kleinfeld D  - 07/12/2010
%
% l_ratio - calculates l_ratio statistic for a given cluster
%         - See Schmitzer-Torbert N et al., 2005
%
% Usage:
%      stat = l_ratio( spikes, use )
%
% Description:  
%   Calculates L-ratio statistic for how well non-member spikes are
% separated from the cluster.
%
% Input: 
%   spikes   - a spike structure
%   show     - array describing which events to show in plot
%            - see get_spike_indices.m
%
% Output:
%   stat - the l-ratio statistic
%

    % get indices for members versus nonmembers
    members = get_spike_indices( spikes, use);    
    nonmembers = setdiff( 1:length(spikes.assigns), members );
    
    % whiten all waveforms by projectin onto the PC components that 
    % account for 95% of the variance
    d = diag(spikes.info.pca.s);
    r = find( cumsum(d)/sum(d) >.95,1);
    waves = spikes.waveforms(:,:) * spikes.info.pca.v(:,1:r);
    num_members = length(members);
        
    % calculate the L-ratio
    mahaldists = sort( mahal(waves, waves) );
    stat = ( length(nonmembers) - sum( chi2cdf( mahaldists, r ) ) ) / length(members);
    