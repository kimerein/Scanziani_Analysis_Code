function varargout = plotContrastResponse(response,contrast,hAxes,blog)
% plotContrastResponse(response,contrast,hAxes)
%
% INPUT
%   response: A matrix of column vectors, where the response in each row
%   corresponds to contrast in variable "theta"
%   theta: a list of contrasts
%
% OUTPUT
%   varargout{1} = hLine: Handles to lines
%   varargout{2} = hAxes: Handle to axes

% Created: 6/21/10 - SRO
% Modified: 11/1/11 - KR

if nargin < 3
    hAxes = axes;
end

if nargin < 4
    blog = 0;
end


for i = 1:size(response,2)
    hLine(i) = line('Parent',hAxes,'XData',contrast,'YData',response(:,i),...
        'LineWidth',1.5);
end
maxR = max(max(response));
%minR = 0; % Kim changed so can see suppression below spontaneous firing
%            rate
minR = min(min(response));
if minR>0
    minR=0;
end
if isnan(maxR) 
    maxR=1;
    disp('Max value NaN');
end
if isnan(minR)
    minR=0;
    disp('Min value NaN');
end
% if isnan(maxR) || (maxR == 0)
%     maxR = 1;
%     disp('Max value NaN or zero')
% end
% if maxR < 0
%     minR = min(min(response));
%     maxR = 0;
% end
set(hAxes,'XLim',[0 1], 'YLim',[minR maxR],...
    'XTick',[0 0.5 1],'XTickLabel',{'0';'0.5';'1'});

if blog
    set(hAxes,'XScale','log')
end


% Output
varargout{1} = hLine;
varargout{2} = hAxes;

