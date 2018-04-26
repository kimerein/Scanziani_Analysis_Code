function h = makeFigure(expt)
% function h = makeFigure(expt)
%
%
%

% Created: 5/18/10 - SRO

% Set expt struct
h.expt = expt;
exptname = expt.name;

% Make figure
h.fig = figure('MenuBar','none','Toolbar','none','NumberTitle','off',...
    'Name','Make figure','Visible','off','Position',[6 58 471 308],...
    'Color',[0.925 0.914 0.847],'HandleVisibility','callback');

% Add panel
h.panel = uipanel('Parent',h.fig,'Units','normalized','Position',...
    [0.01 0.01 0.98 0.98]);

% Add experiment name
h.exptname = uicontrol('Parent',h.panel,'Style','text','Units','normalized',...
    'Position',[0.05 0.92 0.9 0.05],'String',exptname,'HorizontalAlignment','left');

% Add make figure button
h.makefigure = uicontrol('Parent',h.panel,'Units','normalized','Position',...
    [0.1 0.2 0.25 0.1],'String','Make figure','Tag','makefigure');

% Add check buttons
h.chkTags = {'save','pause','print','update','close'};
for i = 1:length(h.chkTags)
    ypos = 0.7 - 0.085*(i-1);
    pos = [0.1 ypos 0.2 0.09];
    h = makeCheck(h,h.chkTags{i},pos);
end
h = getCheckVal(h);
set([h.save],'Value',1);

% Make edit boxes
editbxs = {'files','type','values','tags'};
for i = 1:length(editbxs)
    ypos = 0.7 - 0.085*(i-1);
    height = 0.065;
    pos = [0.5 ypos 0.4 height];
    % Edit box
    h.(editbxs{i}) = uicontrol('Parent',h.panel,'Style','edit','Units',...
        'normalized','Position',pos,'String','','BackgroundColor',[1 1 1],...
        'HorizontalAlignment','left');
    % String
    str = [editbxs{i} 'str'];
    pos = [0.35 ypos-0.01 0.1 height];
    editStr = editbxs{i};
    editStr = [upper(editStr(1)) editStr(2:end)];
    h.(str) = uicontrol('Parent',h.panel,'Style','text','Units','normalized',...
        'String',editStr,'Position',pos,'HorizontalAlignment','right');
    % Button for file list
    if i == 1
        pos = [0.93 ypos 0.04 height];
        h.filebutton = uicontrol('Parent',h.panel,'Units','normalized',...
            'Position',pos,'String','');
    end
end

% Add callbacks
set(h.makefigure,'Callback',@makefigure_callback)
set(h.filebutton,'Callback',@filebutton_callback)

% Make figure visible
set(h.fig,'Visible','on')

% Save guidata
guidata(h.fig,h);

% --- Subfunctions --- %

function h = makeCheck(h,tag,pos)
tagStr = [upper(tag(1)) tag(2:end)];
h.(tag) = uicontrol('Parent',h.panel,'Style','checkbox','Units','normalized',...
    'Position',pos,'String',tagStr);

function h = getCheckVal(h)

for i = 1:length(h.chkTags)
    tag = h.chkTags{i};
    h.chkVal.(tag) = get(h.(tag),'Value');
end

guidata(h.fig,h)

% --- Callbacks --- %

function makefigure_callback(hObject,eventdata)
h = guidata(hObject);
expt = h.expt;

% ***Temp***
cond.type = 'led';
cond.val = [0 2];
cond.tag = {'ctrl','led'};
cond.color = {[0 0 1],[1 0 0]};

% Get check flags (e.g. save, print, etc.)
h = getCheckVal(h);


% Get files list
files = get(h.files,'String');
if isempty(files)
    [fileInd ok] = listdlg('ListString',{expt.files.names{:}},'ListSize',[225 300],...
        'Name','Choose files for analysis');
else
    fileInd = str2num(files);
    ok = 1;
end

if ok
    % Get list of units to analyze
    unitList = expt.sort.unittags;
    [unitInd, ok] = listdlg('ListString',unitList,'ListSize',[175 300],...
        'Name','Choose units for analysis');
    unitList = unitList(unitInd);
    
    % Loop through units
    for i = 1:length(unitList)
        unitTuningFigNew(expt,unitList{i},fileInd,cond,h.chkVal)
    end  
end

function filebutton_callback(hObject,eventdata)
h = guidata(hObject);
expt = h.expt;
[fileInd ok] = listdlg('ListString',{expt.files.names{:}},'ListSize',[225 300],...
    'Name','Choose files for analysis');
if ok
    set(h.files,'String',mat2str(fileInd))
end


