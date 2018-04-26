function avgdata = circularMean( data, period , use_nan_mean)
    % WB 8/2010
    % Given a data matrix of data distributed on [0 period], takes the
    % circular average of each column and returns a vector of such column
    % averages.
    % E.g. data in radians should be passed as "avg = circularMean(
    % data,2*pi);"
    if(nargin < 3)
        use_nan_mean = 0;
    end
    
    assert(~any(~isreal(data(:))), 'circularMean: only takes real input.');
    
    phases = data * (2*pi)/period;
    cdata = exp(1i * phases);
    if(~use_nan_mean)
        cdata = mean(cdata, 1);
    else
        cdata = nanmean(cdata, 1);
    end
    
    cdata(abs(cdata) <= eps) = 0;
    phases = angle(cdata);
    %phases(phases < 0) = phases(phases < 0) + 2*pi; % shift from [-pi , pi] to [0 2*pi]
    
    avgdata = phases / (2*pi) * period; % change to original period

end

