function hSaveFigTool = addSaveFigTool(hFig)
%
%
%
%

% Created: SRO - 10/15/10
% Modified: SRO - 5/24/11


% Get figure specific text
figText = getappdata(hFig,'figText');
expt = getappdata(hFig,'expt');
sdir = getappdata(hFig,'sdir');

% Get toolbar handle
hToolbar = findall(hFig,'Type','uitoolbar');
hSaveFigTool = uipushtool('Parent',hToolbar,'ClickedCallback',{@saveFig,figText,expt,hFig,sdir},...
    'Separator','on','HandleVisibility','off','CData',rand(20,20,3));


% Callback
function saveFig(hObject,eventdata,figText,expt,hFig,sdir)

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
elseif ~isempty(sdir)
    sname = [sdir figText];
else
    sname = [rigdef.Dir.Fig '_' figText];
    prompt = {'Enter save name:'};
    default = {sname};
    sname = inputdlg(prompt,'Save Figure',[1 80],default);
    sname = sname{1};
end

disp(['Saving' ' ' sname])
saveas(hFig,sname,'pdf')
saveas(hFig,sname,'fig')
saveas(hFig,sname,'epsc')
temp = [sname '.epsc'];
export_fig temp


