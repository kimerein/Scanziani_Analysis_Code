function varargout = polarOrientTuning(response,theta,hAxes)
% function varargout = polarOrientTuning(response,theta,hAxes)
%
% INPUT
%   response: A matrix of column vectors, where the response in each row
%   corresponds to the angle in theta
%   theta: A column vector of angles.
%
% OUTPUT
%   varargout{1} = hPol: Handles to the lines in the polar plot
%   varargout{2} = hAxes: Handle to the polar axes 
%   varargout{3} = maxval: Max value on plot

% Created: 5/16/10 - SRO

if nargin < 3
    hAxes = axes;
end

% Replicate theta to get same number of columns as response matrix
ncol = size(response,2);
theta = repmat(theta,1,ncol);

% Make sure theta is defined at both 0 and 360 degrees
if ~ismember(360,theta)
    nrow = size(response,1);
    response(nrow+1,:) = response(theta==0);
    theta(nrow+1,:) = 360;
end

% Convert to radians
theta = theta*pi/180;

% Scale response so max response reaches edge of outer circle in plot
maxval = max(max(response));
response = response/maxval*0.99;

% Make polar plot
hPol = polar(hAxes,theta,response);
polarDefault(hAxes);
set(hPol,'LineWidth',1.5);

% Output
varargout{1} = hPol;
varargout{2} = hAxes;
varargout{3} = maxval;
