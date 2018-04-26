function [hpolar hAxes]  = plotOriTuning(theta,values)


theta(end+1) = theta(1);
if min(size(values))>1 % if not collapsed on 1 vstim variable
        theta = repmat(theta,size(values,1),1)';
        rho = [values values(:,1)]';
else
    rho = values;
    rho(end+1) = values(1);
    if ~isrowvector(rho), rho = rho'; end
end

hpolar = polar(theta,rho);         hAxes = gca;hold on;
