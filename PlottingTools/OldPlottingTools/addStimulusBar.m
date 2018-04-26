function varargout = addStimulusBar(hAxes,position,str,color,linewidth)
% function varargout = addStimulusBar(hAxes,position,str,color,linewidth)
% 
% INPUTS
%   hAxes: handles to axis 
%   position: [left right ylevel] in axes coordinates
%   str: String to be displayed above bar
%   color: 3-element RGB vector
%   linewidth: Thickness of line
%
% OUTPUTS
%   hLine: Handle to line object.

%   Created: 3/16/10 - SRO

if nargin < 3
    str = '';
    color = [0.3 0.3 0.3];
    linewidth = 2;
end

if nargin < 4
    color = [0.3 0.3 0.3];
    linewidth = 2;
end

if nargin < 5
    linewidth = 2;
end

l = position(1);
r = position(2);
y = position(3)-position(3)*0.03;
hLine = line([l r],[y y],'Parent',hAxes,'LineWidth',linewidth,'color',color);
hAxes;
hText = text(mean([l r]),y+0.08*y,str,'FontSize',8,'Color',color,...
    'HorizontalAlignment','center','Parent',hAxes);


% Outputs
varargout{1} = hLine;
varargout{2} = hText;

