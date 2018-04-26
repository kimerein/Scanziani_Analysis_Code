function hAnn = addExptNameToFig(hFig,expt,position,additionalText)


if nargin < 3
    position = [0.895 0.007 0.1 0.022];  % [x y w h]; 
end

if nargin < 4
    additionalText = '';
end

if isempty(position)
   position = [0.895 0.007 0.1 0.022];  % [x y w h]; 
end

% Get experiment name
exptName = expt.name;


% Add string to bottom right of figure
if isempty(additionalText)
    string = exptName;
else
    string = [exptName ' ' additionalText];
end

figure(hFig);
hAnn = annotation('textbox',position,'String',exptName,...
    'EdgeColor','none','HorizontalAlignment','right','Interpreter',...
    'none','Color',[0.1 0.1 0.1],'FontSize',8,'FitBoxToText','on');

% annotation('rectangle',[0.002 0.002 0.996 0.996]);

