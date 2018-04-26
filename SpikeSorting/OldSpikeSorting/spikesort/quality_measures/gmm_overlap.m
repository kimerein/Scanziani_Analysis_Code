function confusion = gmm_overlap(spikes,  use1, use2 )
% UltraMegaSort2000 by Hill DN, Mehta SB, & Kleinfeld D  - 07/12/2010
%
% gmm_overlap - estimate cluster overlap from a 2-mean Gaussian mixture model
%
% Usage:
%     confusion = gmm_overlap(spikes,  use1, use2 )
%
% Description:  
%   Estimates the overlap between 2 spike clusters by fitting a mean
% and covariance matrix to each one.  Then, under the assumption of the
% multivariate Gaussian distribution, the percent of false positive and
% false negative errors is estimated for each class and stored as a 
% confusion matrix.  The estimation is performed by simulating 1000
% data points from each cluster and seeing what percent of generated spikes
% are more likely under the wrong cluster model.  
%
% Note the results should be interpreted as an estimate of the performance
% of an ideal observer, and not necessarily an estimate of the error in the
% actual clusters.  Secondly, this analysis is biased towards low error
% estimates since the user will typically label non-overlapping set of spikes
% as different clusters, and so the two means will be skewed farther apart from
% their true values.
%
% If a particular data set is degenerate (not enough data points to 
% calculate a covariance matrix) , the confusion matrix is [-1 -1; -1 -1]
%
% Input: 
%   spikes      - a spikes object
%   use1        - array describing first data cluster
%   use2        - array describing second data cluster
%               - see get_spike_indices.m
%
% Output:
%   confusion   - a confusion matrix
%               - element (i,j) is the estimated probability that a spike
%                 from group i will be classified as being in group j
%

   % number of iterations used to estimate overlap
   iters = 1000;
   
   % get data
   group1 = get_spike_indices( spikes, use1);    
   group2 = get_spike_indices( spikes, use2);    
   data1 = spikes.waveforms(group1,:);
   data2 = spikes.waveforms(group2,:);
   N1 = size(data1,1);
   N2 = size(data2,1);
   ndims = size(data1(:,:),2);
   
   % project data onto 95% of its eigen spectrum
   covar = cov( [data1;data2]); % joint covarianc?
   r = round( rank( covar ) );
   [v,d] = eig(covar);
   for j = 1:size(d,1), k(j) = d(j,j); end
   k = k/sum(k);
   r = length( find( cumsum(k) > .05 ) ); 
   last = [1:r] + ndims  - r;
   for j = 1:ndims, v(:,j) = v(:,j); end        
    v = v(:,last);
    data1 = (data1*v);
    data2 = (data2*v);
    ndims = r;
   
   
    % estimate 2-mean gaussian mixture model parameters
    mu1 = mean(data1(:,:));
    mu2 = mean(data2(:,:));
    c1  = cov( data1(:,:));
    c2 = cov( data2(:,:) );
    
  if rank(c1) == size(c1,1) & rank(c2) == size(c2,1)

    % sample models
    fake1 = repmat(mu1,[iters 1]) + randn( [iters ndims ]) * chol(c1);
    fake2 = repmat(mu2,[iters 1]) + randn( [iters ndims ]) * chol(c2);

    % get probability of each under the models
    resids11 = ( fake1 - repmat( mu1, [iters 1]) );
    resids12 = ( fake1 - repmat( mu2, [iters 1]) );
    resids21 = ( fake2 - repmat( mu1, [iters 1]) );
    resids22 = ( fake2 - repmat( mu2, [iters 1]) );


    % calculate likelihoods
    ic1 = inv(c1);
    ic2 = inv(c2);
    f1 = log( N1 / (N1 + N2) );
    f2 = log( N2 / (N1 + N2) );
    d1 = -.5*log(det(c1));
    d2 = -.5*log(det(c2));
    for j = 1:iters
       d11(j) = f1 + d1 - 0.5 * resids11(j,:) * ic1 * resids11(j,:)' ;
       d12(j) = f2 + d2 - 0.5 * resids12(j,:) * ic2 * resids12(j,:)' ;
       d21(j) = f1 + d1 - 0.5 * resids21(j,:) * ic1 * resids21(j,:)' ;
       d22(j) = f2 + d2 - 0.5 * resids22(j,:) * ic2 * resids22(j,:)' ;
    end    
    
    % build confusion matrix
    x1 =  sum( d11 < d12 ) / iters;
    x2 =  sum( d22 < d21 ) / iters;
    confusion(1,1) =   (1-x1)*N1/ ((1-x1)*N1 + x2*N2);
    confusion(1,2) =    x1*N1/ (x1*N1 + (1-x2)*N2);
    confusion(2,2) =   (1-x2)*N2/ ((1-x2)*N2 + x1*N1);
    confusion(2,1) =    x2*N2/ (x2*N2 + (1-x1)*N1);
 
  else
     confusion = [-1 -1; -1 -1]; 
  end
end


