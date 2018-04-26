function exptTableFig(expt,bsave)
%
%
%
%

% 10/15/10 - SRO

if nargin < 2
    bsave = 0;
end

% Set rig defaults
rigdef = RigDefs;

% Make figure
hFig = portraitFigSetup;

% Set expt struct as appdata
setappdata(hFig,'expt',expt);
setappdata(hFig,'figText','ExptTable');

% Add save figure button 
addSaveFigTool(hFig);

% Get expt table
table = expt.info.table;

% Add expt name
hAnn = addExptNameToFig(hFig,expt);

% Remove undesired fields

% Remove empty fields
for i = length(table):-1:1
    if isempty(table{i,1}) && isempty(table{i,2})
        table(i,:) = [];
    end
end

% Make textboxes
color = [0.1 0.1 0.1];
edgecolor = [0.7 0.7 0.7];
lineStyle = 'none';
c1 = annotation('textbox','String',table(:,1),'Interpreter','none','FontSize',7,...
    'Color',color,'EdgeColor',edgecolor,'LineStyle','none');
c2 = annotation('textbox','String',table(:,2),'Interpreter','none','FontSize',7,...
    'Color',color,'EdgeColor',edgecolor,'LineStyle','none');

% Position textboxes
set(c1,'Position',[0.125 0.2 0.13 0.8])
set(c2,'Position',[0.255 0.2 0.4 0.8])

% Place image of mouse brain

% Save
sdir = [rigdef.Dir.Fig expt.name '\'];
if ~isdir(sdir)
    mkdir(sdir);
end
sname = [sdir expt.name '_ExptTable'];
if bsave
    disp(['Saving' ' ' sname])
    saveas(hFig,sname,'pdf')
    saveas(hFig,sname,'fig')
    saveas(hFig,sname,'epsc')
    sname = [sname '.epsc'];
    export_fig sname
end

% Print