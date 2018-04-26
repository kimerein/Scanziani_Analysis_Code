function unit = populateUnit_osi(unit, curExpt, curTrodeSpikes)


% Get theta
theta = unit.oriTheta';

% Get response for stimulus window
r = unit(1).oriRates.stim;

% LED may have been used. If response + LED is similar, use average,
% otherwise use response - LED.
if size(r,2) > 1
    mr = mean(r);
    percentDiff = abs((mr(1)-mr(2))/mr(1));
    if percentDiff > 1
        r = r(:,1);
    else
        r = mean([r(:,1) r(:,2)],2);
    end
end


% osi(1) = 1-circular variance, osi(2) = frac{R_p- R_o}{R_p+ R_o}
[unit.osi(1) unit.osi(2)] = orientTuningMetric(r,theta);