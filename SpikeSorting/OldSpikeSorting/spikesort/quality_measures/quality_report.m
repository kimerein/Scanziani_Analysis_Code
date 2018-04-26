function report = quality_report( spikes, cluster)
% UltraMegaSort2000 by Hill DN, Mehta SB, & Kleinfeld D  - 07/12/2010
%
% quality_report - collect statistics from the various quality metric functions
%
% Usage:
%      report = quality_report( spikes, cluster)
%
% Description:  
%      Generates a set of quality metrics for a specified cluster.  It contains
% statistics related to (1) whether waveforms are near the threshold for
% detection, (2) whether refractory period violations (RPVs) are too high,
% (3) whether a lot of collisions (i.e., overlapping waveforms) are to be
% expected, and (4) whether the waveforms of various clusters tend to overlap.
%
% Input: 
%   spikes      - a spikes structure
%   cluster     - cluster ID to report quality of
%
% Output:
%    report     - contains fields for the varioud quality measures
%               (1)  below_thresh -> estimate % of events that went undetected, from plot_detection_criterion
%               
%               (2)  RPV -> contains fields lb, ub, num, expected.  See poisson_contamination.m
%                        -> estimate of contamination derived from refractory period violations
%
%               (3)  expected_colisions -> estimate of % of contamination with rest of data set assuming all 
%                                          detected events not in this cluster can bemodeled as an independent Poisson process
%                                        -> [1 x 3] vector, [lower_bound expected value upper_bound] using 95% confidence interval
%
%               (4)   confusion      ->  expected cross-contamination with other clusters assuming a 2-distribution Gaussian mixture model
%                                    ->  this output comes from gmm_overlap called for each cluster
%                                    ->  fields: matrix - cell aray of output from gmm_overlap for different clusters
%                                    ->          cluster - array of corresponding cluster IDs
%                                      
   
    % check arguments
    if ~isfield(spikes,'assigns'), error( 'Spikes structure must have assignments' );end
    if length(cluster) ~= 1, error('Must specify a single cluster ID'); end

    
    % how many spikes aremissing due to threshold 
    [blah,bluh,bleh,report.below_thresh] = plot_detection_criterion(spikes,cluster,0);
   
    % refractory period violation range
    [expected, lb, ub, RPV ] = poisson_contamination( spikes, cluster );
    report.RPV.lb = lb;
    report.RPV.ub = ub;
    report.RPV.num = RPV;
    report.RPV.expected = expected;
    
    % collisions with entire data set  
    N1 = sum( spikes.assigns == cluster );
    TOTAL = length(spikes.assigns);
    if isfield( spikes.info,'outliers')
        if isfield( spikes.info.outliers, 'waveforms')
        TOTAL = length(spikes.info.outliers.waveforms ) + TOTAL;
    end
    report.expected_collisions = poissinv([.025 .975],  2*(spikes.params.window_size/1000)*N1*TOTAL/sum(spikes.info.detect.dur)) / N1;
   
    % multivariate gaussian overlap
    other_clusters = setdiff( unique(spikes.assigns), cluster );
    w1 = spikes.waveforms( spikes.assigns == cluster ,: );
    for j = 1:length( other_clusters )
       report.confusion.matrix{j} = gmm_overlap( spikes, cluster, other_clusters(j) );
       report.confusion.cluster(j) = other_clusters(j);
    end

end
