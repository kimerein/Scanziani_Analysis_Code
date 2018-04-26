function varargout = plotOrientTuning(response,theta,hAxes)
% function varargout = plotOrientTuning(response,theta,hAxes)
%
% INPUT
%   response: A matrix of column vectors, where the response in each row
%   corresponds to the angle in theta
%   theta: A column vector of angles.
%
% OUTPUT
%   varargout{1} = hLine: Handles to lines
%   varargout{2} = hAxes: Handle to axes

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

for i = 1:size(response,2)
    hLine(i) = line('Parent',hAxes,'XData',theta(:,i),'YData',response(:,i),...
        'LineWidth',1.5);
end
maxR = max(max(response));
if isnan(maxR) || (maxR <= 0)
    maxR = 1;
    disp('Max value NaN or zero')
end
set(hAxes,'XLim',[0 360], 'YLim',[0 maxR],...
    'XTick',[0 180 360],'XTickLabel',{'0';'180';'360'});


% Output
varargout{1} = hLine;
varargout{2} = hAxes;


