function [thresh_val,m,stdev,missing] = plot_detection_criterion(spikes,clus,display)
% UltraMegaSort2000 by Hill DN, Mehta SB, & Kleinfeld D  - 07/12/2010
%
% plot_detection_criterion - histogram of minimum waveform value
%
% Usage:
%     [thresh_val,m,stdev,missing] = plot_detection_criterion(spikes,show,display)
%
% Description:  
%    Plots a histogram of the minimum value of each waveform from the selected
% set of spikes with the purpose of seeing whether we may have missed a few
% spikes during detection because the detection threshold is too negative. The 
% minimum value is normalized by the threshhold for the channel the data was
% recorded on so that spike detected on different channels can be pooled together.
%
% To estimate how many spikes may have been undetected, the distribution is 
% fit with a Gaussian (red line) and compared to the threshhold, normalized
% to -1 (vertical black dotted line).  The percentage of the Gaussian 
% distribution that would be undetected is shown in the axes title.
%
% Input:
%   spikes - a spike structure
%
% Optional input:
%   show          - array describing which events to show in plot
%                 - see get_spike_indices.m, (default = 'all')
%   plot_it       - flag for whether plot should be made (default = 1)
%
% Output:
%  thresh_val   - the minimum value of each waveform when the waveform is normalized by the threshhold
%  m            - mode estimated for distribution of minimum values
%  stdev        - standard deviation estimated for distribution of minimum values
%  missing      - estimate of how many spikes were missed because they didn't reach threshhold
%

    % constant
    bins = 75;

    % check arguments
    if ~isfield(spikes,'waveforms'), error('No waveforms found in spikes object.'); end 
    if nargin < 3, display = 1; end
    if nargin < 2, show = 'all'; end 
  
    % grab data
    a = get_spike_indices(spikes, clus );
    waves = spikes.waveforms(a,:,:);
    num_channels = size(waves,3);
    num_samples  = size( waves,2);

    % get minimum on each channel normalized by threshold
    if  size(waves,1) == 1
        mins = -squeeze(min(waves,[],2))' ./ repmat( spikes.info.detect.thresh, length(a), 1 );
    else
        mins = -squeeze(min(waves,[],2)) ./ repmat( spikes.info.detect.thresh, length(a), 1 );
    end

    % determine global minimum if there are other detection criterion plots on the current figure
    my_min = min(mins(:));
    ax = findobj( gcf, 'Tag', 'detection_criterion' );
    if ~isempty(ax)
        xlims = get(ax(1),'XLim');
        if xlims(1) < my_min
            global_min = xlims(1);
        else
            global_min = my_min;
            set(ax, 'XLim', [my_min 0])
        end
    else
        global_min = my_min;
    end

    % save the minimum vals from each waveform
    if num_channels > 1
        thresh_val = min(mins');
    else
        thresh_val = mins;
    end

    % create the histogram values
    mylims = linspace( global_min, -1, bins+1);
    x = mylims +  (mylims(2) - mylims(1))/2;
    n = histc( thresh_val,mylims );

    % fit the histogram with a cutoff gaussian
    m = mode_guesser(thresh_val, .05);    % use mode binsteadf of mean, since tail might be cut off
    [stdev,m] = stdev_guesser(thresh_val, n, x, m); % fit the standard deviation as well

    % Now make an estimate of how many spikes are missing, given the Gaussian and the cutoff
    N = max( 2 * sum(thresh_val <= m), length(thresh_val));
    a = linspace(global_min,0,200);
    b = normpdf(a,m,stdev);
    b = (b/sum(b))*N*(x(2)-x(1))/(a(2)-a(1));
    missing = 1-normcdf( -1,m,stdev);

    % plot everything
    if display
      
        cla
 
        % histogram
        hh = bar(x,n,1.0);
        set(hh,'EdgeColor',[0 0 0 ])
        set( gca,'XLim',[ global_min 0]);

        % gaussian fit
        l =line(a,b);
        set(l,'Color',[1 0 0],'LineWidth',1.5)

        % threshold line
        l = line([-1 -1], get(gca,'YLim' ) );
        set(l,'LineStyle','--','Color',[0 0 0],'LineWidth',2)

        % prettify axes
        axis tight
        set( gca,'XLim',[ global_min 0]);
        set(gca,'Tag','detection_criterion')
        title( ['Estimated missing spikes: ' num2str(missing*100,'%2.1f') '%']);
        xlabel('Detection metric')
        ylabel('No. of spikes')
    end       

end

% fit the standard deviation to the histogram by looking for an accurate
% match over a range of possible values
function [stdev,m] = stdev_guesser( thresh_val, n, x, m)

    % initial guess is juts the RMS of just the values below the mean
    init = sqrt( mean( (m-thresh_val(thresh_val<=m)).^2  ) );

    % try 20 values, within a factor of 2 of the initial guess
    num = 20;
    st_guesses = linspace( init/2, init*2, num );
    m_guesses  = linspace( m-init,min(m+init,-1),num);
    for j = 1:length(m_guesses)
        for k = 1:length(st_guesses)
              b = normpdf(x,m_guesses(j),st_guesses(k));
              b = b *sum(n) / sum(b);
              error(j,k) = sum(abs(b(:)-n(:)));
        end        
    end
    
    % which one has the least error?
    [val,pos] = min(error(:));
    jpos = mod( pos, num ); if jpos == 0, jpos = num; end
    kpos = ceil(pos/num);
    stdev = st_guesses(kpos);
    
    % refine mode estimate
    m     = m_guesses(jpos);

end







