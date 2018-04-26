function hAnn = addText(hFig,str,position)
%
%
%

% Created: 10/20/10 - SRO


if nargin < 3
    position = [0.895 0.007 0.1 0.022];
end

hAnn = annotation('textbox',position,'String',str,...
    'EdgeColor','none','HorizontalAlignment','right','Interpreter',...
    'none','Color',[0 0 0],'FontSize',8,'FitBoxToText','on');