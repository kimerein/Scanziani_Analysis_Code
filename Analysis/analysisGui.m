function h = analysisGui(expt)
% function h = makeFigure(expt)
%
%
%

% Created: 5/18/10 - SRO
% Modified: 5/23/10 - SRO


% Add analyis fields, if missing
if ~isfield(expt.analysis,'orientation')
    expt = analysis_def(expt);
end

% Set expt struct
h.expt = expt;
exptname = expt.name;

% Make figure
figName = ['Analysis' ' ' '-' ' ' exptname];
h.fig = figure('MenuBar','none','Toolbar','none','NumberTitle','off',...
    'Name',figName,'Visible','off','Position',[6 58 471 308],...
    'Color',[0.925 0.914 0.847],'HandleVisibility','callback');

% Add main panel
h.panel = uipanel('Parent',h.fig,'Units','normalized','Position',...
    [0.01 0.01 0.98 0.98]);

% Add check box panel
h.panelchk = uipanel('Parent',h.panel,'Units','normalized','Position',...
    [0.72 0.02 0.27 0.75]);

% Add condition panel
h.panelcond = uipanel('Parent',h.panel,'Units','normalized','Position',...
    [0.01 0.02 0.69 0.75]);

% Add analyis type pop-up menu
analysisTypes = {'orientation','contrast','srf'};
h.text1 = uicontrol('Parent',h.panel,'Style','text','Units','normalized',...
    'Position',[0.018 0.85 0.2 0.05],'String','Analysis type:',...
    'HorizontalAlignment','right');
h.analysisType = uicontrol('Parent',h.panel,'Style','popupmenu','Units',...
    'normalized','Position',[0.245 0.855 0.36 0.05],'String',analysisTypes,...
    'HorizontalAlignment','left','callback',@analysisType_callback,...
    'BackgroundColor',[1 1 1]);

% Add make figure button
bottom = 0.075;
width = 0.23;
height = 0.13;
h.makefigure = uicontrol('Parent',h.panel,'Units','normalized','Position',...
    [0.74 bottom width height],'String','Make figure','Tag','makefigure');

% Add save expt button
h.saveexpt = uicontrol('Parent',h.panel,'Units','normalized','Position',...
    [0.07 bottom width height],'String','Save expt','Tag','saveexpt');

% Add check buttons
h.chkTags = {'save','pause','print','update','close'};
for i = 1:length(h.chkTags)
    ypos = 0.62 - 0.085*(i-1);
    pos = [0.74 ypos 0.2 0.09];
    h = makeCheck(h,h.chkTags{i},pos);
end
h = getCheckVal(h);
% set([h.save],'Value',1);

% Make edit boxes
editbxs = {'files','type','tags','values'};
for i = 1:length(editbxs)
    ypos = 0.62 - 0.1*(i-1);
    height = 0.07;
    pos = [0.19 ypos 0.4 height];
    % Edit box
    h.(editbxs{i}) = uicontrol('Parent',h.panel,'Style','edit','Units',...
        'normalized','Position',pos,'String','','BackgroundColor',[1 1 1],...
        'HorizontalAlignment','left');
    % String
    str = [editbxs{i} 'str'];
    pos = [0.04 ypos-0.01 0.1 height];
    editStr = editbxs{i};
    editStr = [upper(editStr(1)) editStr(2:end)];
    h.(str) = uicontrol('Parent',h.panel,'Style','text','Units','normalized',...
        'String',editStr,'Position',pos,'HorizontalAlignment','right');
    % Add button
    buttonName = [editbxs{i} 'button'];
    pos = [0.6 ypos 0.045 height];
    h.(buttonName) = uicontrol('Parent',h.panel,'Units','normalized',...
        'Position',pos,'String','');
end

% Add callbacks
set(h.makefigure,'Callback',@makefigure_callback)
set(h.saveexpt,'Callback',@saveexpt_callback)
set(h.filesbutton,'Callback',@filebutton_callback)
set(h.typebutton,'Callback',@typebutton_callback)
set(h.tagsbutton,'Callback',@tagsbutton_callback)
set(h.valuesbutton,'Callback',@valuesbutton_callback)

% Set values in edit boxes if present in expt
h = setEditFromExpt(h);

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

function analysisType = getAnalysisType(h)

temp = get(h.analysisType,{'String','Value'});
strings = temp{1};
ind = temp{2};
analysisType = strings{ind};

function h = getEditVal(h)

analysisType = getAnalysisType(h);

% Get file indices
fileInd = get(h.files,'String');
h.expt.analysis.(analysisType).fileInd = str2num(fileInd);

% Set cond struct
fields = {'type','tags','values'};
for i = 1:length(fields)
    temp = get(h.(fields{i}),'String');
    temp = parseString(temp);
    if strcmp(fields{i},'values')
        if iscell(temp)
            for k = 1:length(temp)
                temp{k} = str2num(temp{k});
            end
        else
            temp2{1} = str2num(temp);
            temp = temp2;
        end
    elseif strcmp(fields{i},'tags')
        if ~iscell(temp)
            temp2{1} = temp;
            temp = temp2;
        end
    end
    h.expt.analysis.(analysisType).cond.(fields{i}) = temp;
end

function h = setEditFromExpt(h)

analysisType = getAnalysisType(h);
analysisType = h.expt.analysis.(analysisType);

if isfield(analysisType,'fileInd')
    set(h.files,'String',num2str(analysisType.fileInd))
end

fields = {'type','values','tags'};
for i = 1:length(fields)
    if isfield(analysisType.cond,fields{i})
        str = parseArray(analysisType.cond.(fields{i}));
        set(h.(fields{i}),'String',str)
    end
end

function str = parseArray(array)

str = [];
if iscell(array)
    for i = 1:length(array)
        temp = array{i};
        if isnumeric(temp)
            temp = num2str(temp);
        end
        if i < length(array)
            str = [str temp ';' ' '];
        elseif i == length(array)
            str = [str temp];
        end
    end
else
    str = array;
end

function array = parseString(str)

k = strfind(str,';');

if ~isempty(k)
    array{1} = str(1:k-1);
    for i = 1:length(k)
        if i < length(k)
            temp = str((k(i)+1):(k(i+1)-1));
            array{i+1} = strtrim(temp);
        elseif i == length(k)
            temp = str((k(i)+1):end);
            array{i+1} = strtrim(temp);
        end
    end
    
else
    array = str;
end



% --- Callbacks --- %

function makefigure_callback(hObject,eventdata)
h = guidata(hObject);
h = getEditVal(h);
expt = h.expt;

% Get analysis type
analysisType = get(h.analysisType,'Value');

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
        switch analysisType
            case 1
                orientationFig(expt,unitList{i},fileInd,h.chkVal)
                %                 fr{i} = allPolarPlots(expt,unitList{i},fileInd,h.chkVal);
            case 2
                contrastFig(expt,unitList{i},fileInd,h.chkVal)
            case 3
                srfFig(expt,unitList{i},fileInd,h.chkVal)
        end
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

function typebutton_callback(hObject,eventdata)
h = guidata(hObject);
typestr = {'fileInd','led','hm4d','iso','dye','all'};
[selection, ok] = listdlg('ListString',typestr,'SelectionMode','single',...
    'ListSize',[160 150]);
if ok
    set(h.type,'String',typestr{selection})
end

function valuesbutton_callback(hObject,eventdata)
h = guidata(hObject);
typestr = {'{[ ],[ ]}','off_on'};
[selection, ok] = listdlg('ListString',typestr,'SelectionMode','single',...
    'ListSize',[160 150]);
if ok
    set(h.values,'String',typestr{selection})
end

function tagsbutton_callback(hObject,eventdata)
h = guidata(hObject);
typestr = {'ctrl_led','ctrl_cno','ctrl_dye','iso1_iso2'};
[selection, ok] = listdlg('ListString',typestr,'SelectionMode','single',...
    'ListSize',[160 150]);
if ok
    set(h.tags,'String',typestr{selection})
end

function saveexpt_callback(hObject,eventdata)
h = guidata(hObject);
h = getEditVal(h);


assignin('base','expt',h.expt);
guidata(hObject,h)

function analysisType_callback(hObject,eventdata)
h = guidata(hObject);
h = setEditFromExpt(h);






