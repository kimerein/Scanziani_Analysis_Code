function hAnn = addText(hFig,position,str)
%
%
%

% Created: 10/20/10 - SRO


hAnn = annotation('textbox',[position 0 0],'String',str,...
    'EdgeColor','none','HorizontalAlignment','right','Interpreter',...
    'none','Color',[0 0 0],'FontSize',8,'FitBoxToText','on');