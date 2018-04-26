function dr = addTfFcnToDr(dr)
%
%
%
%
%

% Created: SRO - 6/9/11



ua = dr.ua;

% Get response matrix
for u = 1:length(ua)
%     r(:,:,u) = ua(u).fr.ledon;
    r(:,:,u) = ua(u).fr.norm;
end

% for i = 1:size(r,2)
%     r_lgn = r(:,i,1);
%     r_v1 = r(:,i,2);
%     [cfun gof coeff] = fitHrf(r_lgn,r_v1,0);
%     dr.tfcn.cfun{i} = cfun;
%     dr.tfcn.gof(i) = gof;
%     dr.tfcn.coeff(:,i) = coeff;
%     dr.tfcn.coeffnames = {'baseline','v1max','lgn50','exponent'};
% end

i = 1;
r_lgn = r(:,i,1);
r_v1 = r(:,i,2);
[cfun gof coeff] = fitHrf(r_lgn,r_v1,0);
dr.tfcn.cfun{i} = cfun;
dr.tfcn.gof(i) = gof;
dr.tfcn.coeff(:,i) = coeff;
dr.tfcn.coeffnames = {'baseline','v1max','lgn50','exponent'};


dr.r_lgn = r(:,:,1);
dr.r_v1 = r(:,:,2);