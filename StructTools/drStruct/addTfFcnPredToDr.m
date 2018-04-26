function dr = addTfFcnPredToDr(dr)
% function dr = addTfFcnPredToDr(dr)
%
%
% OUTPUT
%   dr.( ):
%       lgn_m: Measured LGN response
%       v1_m: Measured V1 response
%       v1_p: Predicted V1 response based on transfer w/out LED
%       v1_dFRled: Change in FR in V1 produced by LED
%       lgn_comp_s: dFR (in spikes/s) in V1 accounted for by reduction in LGN response
%       v1_comp_s: dFR (in spikes/s) in V1 not due to reduction in LGN,
%       ie., the cortical component
%

% Created: SRO - 6/9/11




% Set transfer function
f = dr.tfcn.cfun{1};

% Set measured LGN responses
% lgn_m = dr.ua(1).fr.ledon;
lgn_m = dr.ua(1).fr.norm;
dr.lgn_m = lgn_m;

% Set measured V1 responses
% v1_m = dr.ua(2).fr.ledon;
v1_m = dr.ua(2).fr.norm;
dr.v1_m = v1_m;

% Predict V1 responses
for i = 1:size(lgn_m,2)
    v1_p(:,i) = feval(f,lgn_m(:,i));
end
dr.v1_p = v1_p;

% Compute V1 dFR
v1_dFRled = repmat(v1_p(:,1),1,size(v1_p,2)) - v1_m;
dr.v1_dFRled = v1_dFRled;

% Compute dFR due to reduction in LGN response
lgn_comp_s = repmat(v1_p(:,1),1,size(v1_p,2)) - v1_p;
dr.lgn_comp_s = lgn_comp_s;

% Compute dFR due to V1
v1_comp_s = v1_dFRled - lgn_comp_s;
dr.v1_comp_s = v1_comp_s;

% Compute fractional component due to V1
v1_comp_f = v1_comp_s./v1_dFRled;
dr.v1_comp_f = v1_comp_f;

% Compute fractional component due to LGN
lgn_comp_f = lgn_comp_s./v1_dFRled;
dr.lgn_comp_f = lgn_comp_f;



