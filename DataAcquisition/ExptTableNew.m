function h = ExptTableNew(varargin)
% GUI with table for entering experimental information during an
% experiment. Data in the table can be used to set fields in the expt
% struct by using the getFromExptTable function when making an expt.

%   Created: SRO - 5/10/10
%   Modified: SRO - 5/20/10

% Inputs
h.hDaqCtlr = varargin{1};

rigdef = RigDefs;

% Make figure
hFig = figure('Visible','off','menubar','none','NumberTitle','off', ...
    'Name','ExptTable','Color',[0.925 0.914 0.847],'HandleVisibility',...
    'callback');
h.ExptTableFig = hFig;
set(hFig,'Units','pixels','Position',[rigdef.ExptTable.Position 439 420],'Resize', ...
    'off');

% Add panel
h.backPanel = uipanel('Parent',h.ExptTableFig,'Units','normalized', ...
    'Position',[0.01 0.01 0.98 0.98]);

% Add save button
h.save = uicontrol('Parent',h.backPanel,'String', ...
    'Save','Units','pixels','Position',[15 5 80 26]);

% Add clear button
h.clear = uicontrol('Parent',h.backPanel,'String', ...
    'Clear','Units','pixels','Position',[100 5 60 26]);

% Add save template button
h.saveTemplate = uicontrol('Parent',h.backPanel,'String', ...
    'Save template','Units','pixels','Position',[208 5 100 26]);

% Add open template button
h.openTemplate = uicontrol('Parent',h.backPanel,'String', ...
    'Open template','Units','pixels','Position',[313 5 100 26]);

% Add table
h.table = uitable('Parent',h.backPanel,'Units','normalized', ...
    'Position',[0.033 0.191 0.94 0.8],'ColumnEditable',logical([1 1]));
set(h.table,'ColumnWidth',{136 247},'ColumnName',[],'RowName',[]);

if rigdef.ExptTable.MarkPanel
    % Add mark buttons
    h.markPanel = uipanel('Parent',h.backPanel,'Units','pixels',...
        'Position',[15 36 402 37]);    
    
    buttonnames = {'time','event'};
    for i = 1:length(buttonnames)
        name = buttonnames{i};
        namestr = [upper(name(1)) name(2:end)];
        xpos = 10 + 90*(i-1);
        h.(name) = uicontrol('Parent',h.markPanel,'Units','pixels',...
            'String',namestr,'Position',[xpos 6 80 24]);
    end
    set(h.time,'Callback',@time_callback)
    set(h.event,'Callback',@event_callback)
else
    set(h.table,'Position',[0.033 0.105 0.94 0.87]);
end

% Set callback functions
set(h.save,'Callback',@save_callback)
set(h.clear,'Callback',@clear_callback)
set(h.saveTemplate,'Callback',@saveTemplate_callback)
set(h.openTemplate,'Callback',@openTemplate_callback)
set(h.table,'CellEditCallback',@tableEdit_callback)

% Save guidata
guidata(hFig,h)

% ExptTable handle as appdata
setappdata(hFig,'hExptTable',hFig);

% Assign ExptTable handle in base workspace
assignin('base','hExptTable',hFig);

% Get handles for DaqController
ExptTable = rigdef.ExptTable.Parameters;

set(h.table,'Data',ExptTable);

% Enable the save button
set(h.save,'Enable','on','FontWeight','bold','ForegroundColor',[1 0 0]);

% Set directories
h.saveDir = rigdef.Dir.Data;
h.exptTableDir = [rigdef.Dir.Settings 'ExptTable\'];

% Save guidata
guidata(hFig,h)

% Make figure visible
set(hFig,'Visible','on')


% --- Subfunctions --- %

function row = emptyRow(data)

temp = strcmp('',data);
k = find(temp(:,1) == 1);

for i = 1:length(k)
    if temp(k(i),2) == 1
        row = k(i);
        break
    end
end

function enableSave(hObject)
set(hObject,'Enable','on','FontWeight','bold','ForegroundColor',[1 0 0]);

% --- Callbacks --- %

function save_callback(hObject,eventdata)
h = guidata(hObject);
Data = get(h.table,'Data');
temp = Data(3,2);
SaveName = strcat(temp{1},'_ExptTable');
SaveName = fullfile(h.saveDir,SaveName);
save(SaveName,'Data');



% Save as template called 'current'
ExptTablePath = h.exptTableDir;
ExptTable = Data;
save([ExptTablePath 'Current'],'ExptTable')

% Return button to default state
set(h.save,'Enable','off','FontWeight','normal','ForegroundColor',[0 0 0]);

function clear_callback(hObject,eventdata)
h = guidata(hObject);
% Get updated ExptTable
ExptTable = get(h.table,'Data');
% Clear entries from 2nd column
for i = 1:length(ExptTable)
    ExptTable{i,2} = '';
end
% Update table
set(h.table,'Data',ExptTable);

% % Set info in table as app data in the ExptTableButton on the DaqController
% ExptTable = get(handles.hTable,'Data');
% setappdata(handles.ExptTableButton,'ExptTable',ExptTable);

enableSave(h.save);

function saveTemplate_callback(hObject,eventdata)
h = guidata(hObject);
% Get updated ExptTable
ExptTable = get(h.table,'Data');
% Set save path
ExptTablePath = h.exptTableDir;
cd(ExptTablePath)
% User input
uisave('ExptTable');

function openTemplate_callback(hObject,eventdata)
h = guidata(hObject);
% Path to ExptTable templates
ExptTablePath = h.exptTableDir;
cd(ExptTablePath);
% User choose file
ExptTableFile = uigetfile('*.mat');
if ~ExptTableFile == 0
    load(ExptTableFile);
    % The variable stored in file is called ExptTable
    set(h.table,'Data',ExptTable);
    
    % % Set info in table as app data in the ExptTableButton on the DaqController
    % ExptTable = get(h.table,'Data');
    % setappdata(handles.ExptTableButton,'ExptTable',ExptTable);
    
    % Enable the save button
    enableSave(h.save);
end

function tableEdit_callback(hObject,eventdata)
h = guidata(hObject);
% Enable the save button
enableSave(h.save);

function time_callback(hObject,eventdata)
h = guidata(hObject);
ExptTable = get(h.table,'Data');
rigdef = RigDefs;
list = rigdef.ExptTable.TimeStrings;
[selection ok] = listdlg('ListString',list,'ListSize',[160 150],...
    'SelectionMode','single');
selection = list{selection};
if ok
    % Determine row
    iRow = strcmp(ExptTable(:,1),selection);
    if any(iRow)
        ExptTable{iRow,2} = datestr(now,14);
        set(h.table,'Data',ExptTable)
    end
end
enableSave(h.save);

function event_callback(hObject,eventdata)
h = guidata(hObject);
ExptTable = get(h.table,'Data');
irow = emptyRow(ExptTable);
ExptTable{irow,1} = datestr(now,14);
ExptTable{irow,2} = 'event';
set(h.table,'Data',ExptTable)
enableSave(h.save);





