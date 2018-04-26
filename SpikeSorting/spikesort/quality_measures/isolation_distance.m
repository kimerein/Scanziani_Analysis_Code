function stat = isolation_distance(spikes,use)
% UltraMegaSort2000 by Hill DN, Mehta SB, & Kleinfeld D  - 07/12/2010
%
% isolation_distance - calculates isolation distance statistic for a given cluster
%                    - See Schmitzer-Torbert N et al., 2005
%
% Usage:
%      stat = isolation_distance( spikes, use )
%
% Description:  
%   Calculates isolation_distance statistic for how well non-member spikes are
% separated from the cluster.
%
% Input: 
%   spikes   - a spike structure
%   use      - array describing which events to show in plot
%            - see get_spike_indices.m
%
% Output:
%   stat - the isolation distance statistic
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

     if num_members > length(nonmembers)
        warning( 'Isolation distance is not defined if cluster is greater than half the data set.');
        stat = [];
     else
         % get isolation distance statistic
         mahaldists = sort( mahal( waves, waves ) );
         stat = mahaldists( min( num_members, length(nonmembers ) ) );
     end
     

     
     
     