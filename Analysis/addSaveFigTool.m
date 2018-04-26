function addSaveFigTool(hFig)
%
%
%
%

% 10/15/10 - SRO


% Get figure specific text
figText = getappdata(hFig,'figText');
expt = getappdata(hFig,'expt');

% Get toolbar handle
hToolbar = findall(hFig,'Type','uitoolbar');
hSaveFigTool = uipushtool('Parent',hToolbar,'ClickedCallback',{@saveFig,figText,expt,hFig},...
    'Separator','on','HandleVisibility','off','CData',rand(20,20,3));


% Callback

function saveFig(hObject,eventdata,figText,expt,hFig)

if nargin < 2
    additionalText = '';
end

% Set rig defaults
rigdef = RigDefs;

% Make save name
if ~isempty(expt)
    for i = 1:length(rigdef.Dir.Fig)
        sdir = [rigdef.Dir.Fig expt.name '\'];
        if ~isdir(sdir)
            mkdir(sdir);
        end
        sname = [sdir expt.name '_' figText];
    end
else
    sname = [rigdef.Dir.Fig '_' figText];
    prompt = {'Enter save name:'};
    default = {sname};
    sname = inputdlg(prompt,'Save Figure',[1 80],default);
end

disp(['Saving' ' ' sname])
saveas(hFig,sname,'pdf')
saveas(hFig,sname,'fig')
saveas(hFig,sname,'epsc')
temp = [sname '.epsc'];
export_fig temp


