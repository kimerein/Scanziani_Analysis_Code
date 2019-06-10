function varargout = ExptViewer(varargin)
% GUI for viewing experiments, sorting spikes, and performing analysis

% Created: 3/16/10 - SRO
% Modified: 4/5/10 - SRO and BA
% Modified: 5/17/10 - SRO

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @ExptViewer_OpeningFcn, ...
    'gui_OutputFcn',  @ExptViewer_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


function ExptViewer_OpeningFcn(hObject, eventdata, handles, varargin)

handles = initializeExptViewer(handles);

% Update handles structure
guidata(hObject, handles);

function varargout = ExptViewer_OutputFcn(hObject, eventdata, handles)

RigDef = RigDefs;
set(hObject,'Position',RigDef.ExptViewer.Position); pause(0.2)
set(hObject,'Visible','on'); pause(0.2)

function varargout = SortTable_OpeningFcn(hObject, eventdata, handles)

% Get default command line output from handles structure
% varargout{1} = handles.expt;

handles.UnitTableSelectedCells = [];

function OpenExptButton_Callback(hObject, eventdata, handles)

%BA find list of experiments again
temp = handles.CurrentExpt; % hold on to current expt to look up later
handles.ExptList = GetExptList();
handles.CurrentExpt = find(ismember(handles.ExptList,temp)); % set the CurrentExpt index to be right (there may have beenchanges in the Expt List)

% Open list dialog with all experiments and load chosen experiment
ExptList = handles.ExptList;
[Selection ok] = listdlg('ListString',ExptList,'ListSize',[200 250],'SelectionMode','single', ...
    'Name','Select experiment');
if ok == 1
    handles.ExptInd = Selection;
    Selection = ExptList{Selection};
    handles.CurrentExpt = Selection;
    handles = LoadExpt(handles);
    set(handles.SortFilePopUp,'Value',1)
    handles = UpdateSortTable(handles);
    handles = UpdateUnitTable(handles);
    spikes = LoadSpikesFile(handles);
    guidata(hObject, handles);
end

function DownExpt_Callback(hObject, eventdata, handles)

numExpt = length(handles.ExptList);
handles.ExptInd = handles.ExptInd + 1;
if handles.ExptInd > numExpt
    handles.ExptInd = 1;
end
handles.CurrentExpt = handles.ExptList{handles.ExptInd};
handles = LoadExpt(handles);
handles = UpdateSortTable(handles);
handles = UpdateUnitTable(handles);
spikes = LoadSpikesFile(handles);
guidata(hObject,handles);

function UpExpt_Callback(hObject, eventdata, handles)

numExpt = length(handles.ExptList);
handles.ExptInd = handles.ExptInd - 1;
if handles.ExptInd < 1
    handles.ExptInd = numExpt;
end
handles.CurrentExpt = handles.ExptList{handles.ExptInd};
handles = LoadExpt(handles);
handles = UpdateSortTable(handles);
handles = UpdateUnitTable(handles);
spikes = LoadSpikesFile(handles);
guidata(hObject,handles);

function SaveExpt_Callback(hObject, eventdata, handles)
RigDef = RigDefs();
expt = evalin('base','expt');
save(fullfile(RigDef.Dir.Expt,getFilename(expt.info.exptfile)),'expt')
disp(['Expt saved to' ' ' fullfile(RigDef.Dir.Expt,getFilename(expt.info.exptfile))])
handles = UpdateExpt(handles);
guidata(hObject,handles);

function DataViewerButton_Callback(hObject, eventdata, handles)

ExptDataViewer('Visible','off',handles.expt);

function AnalysisViewer_Callback(hObject, eventdata, handles)

function DetectSpikes_Callback(hObject, eventdata, handles)
tic
% Update expt struct
handles = UpdateExpt(handles);

% Set rig defaults
RigDef = RigDefs;

% Determine status of detect and cluster checkbox
detectChk = get(handles.detectChk,'Value');
clusterChk = get(handles.clusterChk,'Value');

% If detectChk, set all trodes for detection
if detectChk
    detectTrode = 1:handles.expt.probe.numtrodes;
else
    detectTrode = NaN;
end

% Get list of files in this experiment
FileList = handles.expt.files.names;
disp('This experiment contains the files ...');
disp(FileList);

% Choose which files to use for spike sorting
if isTDTexpt(handles.expt)
    prompt = {'Select files to sort together'};
    tempList  = cellfun(@getFilename, FileList,'UniformOutput',0);% get only files
    answer = listdlg('ListString',tempList,'PromptString',prompt); pause(0.05)
    detectFiles = answer;
elseif 1
    detectFiles = chooseFilesForSort(FileList);
end

if ~isempty(detectFiles)
    
    % Loop over trodes set for detection
    for i = 1:length(detectTrode)
        
        % Get updated handles
        handles = guidata(handles.hExptViewer);
        
        % Detect spikes
        if detectChk
            [handles.expt spikes trodeInd] = DetectSpikes(handles.expt,detectFiles,i);
        else
            [handles.expt spikes trodeInd] = DetectSpikes(handles.expt,detectFiles);
        end
        
        % Add .sweeps struct to spikes
        spikes = spikesAddSweeps(spikes,handles.expt,trodeInd);
        
        % Add .stimcond to spikes
        spikes = spikesAddConds(spikes);
        
        % Save spikes and output to base
        save(fullfile(RigDef.Dir.Spikes,getFilename(spikes.info.spikesfile)),'spikes')
        assignin('base','spikes',spikes);
        
        % Save and output updated expt struct to workspace
        assignin('base','expt',handles.expt);
        expt = handles.expt;
        save(fullfile(RigDef.Dir.Expt,getFilename(expt.info.exptfile)),'expt');
        
        % Update GUI
        handles = UpdateSortTable(handles);
        set(handles.SortFilePopUp,'Value',trodeInd)
        guidata(hObject,handles);
        
        % Cluster detected spikes
        if clusterChk 
            handles.expt.sort.trode(trodeInd).clustered = 'no';  % Forces new clustering
            hCluster_Callback(handles.hCluster, [], handles);
        end
        
    end
    
end

toc

function hCluster_Callback(hObject, eventdata, handles)

RigDef = RigDefs;

% Get active spikes
spikes = LoadSpikesFile(handles);
trodeInd = spikes.info.trodeInd;

scluster = 'ReCluster';
if strcmp('yes',handles.expt.sort.trode(trodeInd).clustered)
    % Do you want to replace or append to previous detection?
    scluster = questdlg('This trode HAS been clustered. ReCluster?','','ReCluster','Cancel','Cancel');
    pause(0.05)
end

if isequal(scluster,'ReCluster')
    
    % Heuristic for picking size of clusters
    spikes.params.kmeans_clustersize = round(max(500,length(spikes.spiketimes)/100));
    
    % Cluster spikes
    sprintf('Aligning and Clustering %d spikes\t trode %d, chns: %s',...
        length(spikes.spiketimes),spikes.info.trodeInd,...
        num2str(handles.expt.sort.trode(spikes.info.trodeInd).channels));
    spikes = ss_align(spikes);
    spikes = ss_kmeans(spikes);
    spikes = ss_energy(spikes);
    spikes = ss_aggregate(spikes);
    
    handles.expt.sort.trode(trodeInd).clustered = 'yes';
    handles.expt.sort.trode(trodeInd).sorted = 'yes'; % this could theoretically used to note a later step but is not used now
    
    % Save spikes and output to base
    save(fullfile(RigDef.Dir.Spikes,getFilename(spikes.info.spikesfile)),'spikes')
    assignin('base','spikes',spikes);
    % Save expt and output to base
    expt = handles.expt;
    save(fullfile(RigDef.Dir.Expt,getFilename(handles.expt.info.exptfile)),'expt')
    assignin('base','expt',handles.expt);
    
    % Update GUI
    handles = UpdateSortTable(handles);
    guidata(handles.hCluster,handles);
end

function MergeTool_Callback(hObject, eventdata, handles)

spikes = LoadSpikesFile(handles);
splitmerge_tool(spikes);

% handles = UpdateSortTable(handles);
set(handles.SaveSpikes,'Enable','on');

function DeleteSpikes_Callback(hObject, eventdata, handles)

% Verify user wants to delete spikes
answer = questdlg('Delete active spikes?');

if strcmp('Yes',answer)
    
    rigdef = RigDefs;
    
    % Delete spikes file shown in SorFileFileUp
    spikes = LoadSpikesFile(handles);
    
    if ~isempty(spikes)
        fName = spikes.info.spikesfile;
        delete([rigdef.Dir.Spikes fName '.mat']);
        currentTrode = GetCurrentTrode(handles);
        set(handles.SortFilePopUp,'Value',1);
        
        % Modfiy expt fields pertaining to deleted spikes
        expt = handles.expt;
        expt.sort.trode(currentTrode).channels = [];
        expt.sort.trode(currentTrode).fileInds = [];
        expt.sort.trode(currentTrode).threshtype = [];
        expt.sort.trode(currentTrode).thresh = [];
        expt.sort.trode(currentTrode).detected = 'no';
        expt.sort.trode(currentTrode).sorted = 'no';
        expt.sort.trode(currentTrode).clustered = 'no';
        expt.sort.trode(currentTrode).numclusters = [];
        expt.sort.trode(currentTrode).spikespersec = [];
        expt.sort.trode(currentTrode).spikesfile = [];
        
        % Save modified expt struct
        save(fullfile(rigdef.Dir.Expt,getFilename(expt.info.exptfile)),'expt')
        
        % Update expt struct
        handles = UpdateExpt(handles);
        guidata(hObject,handles)
    end
end

function SaveSpikes_Callback(hObject, eventdata, handles)
RigDef = RigDefs;
% Get active trode
currentTrode = GetCurrentTrode(handles);

% Get expt from handles
expt = handles.expt;

% Get the spikes struct from the base workspace
spikes = evalin('base','spikes');

if ~isempty(spikes)
    
    % Update the fields added to spikes struct (outliers may have removed
    % spikes)
    
    spikes = spikesAddSweeps(spikes,expt,spikes.info.trodeInd);
    spikes = spikesAddConds(spikes);
    assignin('base','spikes',spikes);
    
    display(sprintf('Saving spikes struct: %s',fullfile(RigDef.Dir.Spikes,getFilename(spikes.info.spikesfile))));
    
    % Save spikes file
    save(fullfile(RigDef.Dir.Spikes,getFilename(spikes.info.spikesfile)),'spikes')
    
    bUpdate = 'yes';
    bComplete = 'no';
    
    if strcmp(bUpdate,'yes')
        % Clear units from current trode
        expt.sort.trode(currentTrode).unit = [];
        expt = UpdateUnitStruct(expt,spikes,currentTrode);
    end
    
    % Change .numunits to access user-defined units, rather than all clusters
    expt.sort.trode(currentTrode).numunits = size(expt.sort.trode(currentTrode).unit,2);
    
    if 0   %strcmp(bComplete,'yes')
        expt.sort.trode(currentTrode).sort = 'complete';
    else
        expt.sort.trode(currentTrode).sort = 'incomplete';
    end
    
    % Update expt in handles
    handles.expt = expt;
    
    %
    handles = UpdateSortTable(handles);
    handles = UpdateUnitTable(handles);
    
    % Update unit tags list
    handles.expt.sort.unittags = GetUnitList(handles);
    
    % Update handles and assign in base
    guidata(handles.hExptViewer,handles)
    save(fullfile(RigDef.Dir.Expt,getFilename(expt.info.exptfile)),'expt')
    assignin('base','expt',handles.expt);
    
else
    disp('spikes struct is empty')
end

function SortFilePopUp_Callback(hObject, eventdata, handles)
evalin('base','clear spikes')
pause(0.05)
spikes = LoadSpikesFile(handles);

function UnitPopUp_Callback(hObject, eventdata, handles)

function SeeUnitButton_Callback(hObject, eventdata, handles)
handles.UnitTableSelectedCells
[rows] = handles.UnitTableSelectedCells(:,1);
%get the data from the UITABLE
tableData = get(handles.UnitTable,'data');
% get unitIndex
clus_list  = cell2mat(cellfun(@str2num, tableData(rows,2),'UniformOutput',0));
spikes = LoadSpikesFile(handles);
% if length(clus_list)>1
% compare_clusters(spikes, [clus_list]);
% else
show_clusters(spikes, [clus_list]);

function SortFilePopUp_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function UnitTable_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to UnitTable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
handles.UnitTableSelectedCells = eventdata.Indices;

%update the gui data
guidata(hObject, handles);

function clusterChk_Callback(hObject, eventdata, handles)

function detectChk_Callback(hObject, eventdata, handles)

function filterButton_Callback(hObject, eventdata, handles)

function analysisButton_Callback(hObject, eventdata, handles)

handles.expt.sort.unittags = GetUnitList(handles);
%[exptModified handles.analysisGUI] = analysisGUInew(handles.expt,{@SaveExpt_Callback,handles.SaveExpt});
[exptModified handles.analysisGUI] = KR_analysisGUI(handles.expt,{@SaveExpt_Callback,handles.SaveExpt});

% Save expt if modified
if exptModified
    SaveExpt_Callback(handles.SaveExpt,[],handles);
end

setappdata(handles.analysisGUI,'expt',handles.expt);

guidata(hObject, handles);


% --- Subfunctions --- %

function handles = initializeExptViewer(handles)
% Get rig defaults
handles.RigDef = RigDefs;

% Determine list of experiments (either search for ExptTable files, or
% use information stored in a master table file). For now, search for
% ExptTable files

ExptList = GetExptList();
handles.ExptList = ExptList;
handles.ExptInd = 1;
if ~isempty(handles.ExptList)
    handles.CurrentExpt = handles.ExptList{handles.ExptInd};

    % Load information from most recent experiment
    handles = LoadExpt(handles);

    % Set trode names in sort pop-up menu
    trode = handles.expt.sort.trode;
    trodeNames = {trode.name};
    set(handles.SortFilePopUp,'String',trodeNames);
    
    % Initialize sort and unit tables
    handles = UpdateSortTable(handles);
    handles = UpdateUnitTable(handles);
    
    % Open spikes
    spikes = LoadSpikesFile(handles);
end

% Update handles structure
guidata(handles.hExptViewer, handles);

function handles = LoadExpt(handles)

% Get experiment name
CurrentExpt = handles.CurrentExpt;

% Load expt
RigDef = RigDefs;
FileName = [RigDef.Dir.Expt CurrentExpt '_expt.mat'];
expt = loadvar(FileName);

% Update expt if old version
expt = makeNewExptFormatSRO(expt);

% Store expt in handles
handles.expt = expt;

% Set experiment name
set(handles.ExptName,'String',CurrentExpt);

% Get and set experiment info
set(handles.DetailsTable,'Data',expt.info.table);

% Output expt struct to workspace
assignin('base','expt',expt);

% Update handles
guidata(handles.hExptViewer,handles)

function handles = UpdateSortTable(handles)

if  ~isfield(handles.expt.info,'structversion') % backward compatiblity
    handles.expt = makeNewExptFormat( handles.expt);
    display('Updating Expt Struct')
end

RigDef = RigDefs;
trode = handles.expt.sort.trode;

% Set trode names in sort pop-up menu
trode = handles.expt.sort.trode;
trodeNames = {trode.name};
set(handles.SortFilePopUp,'String',trodeNames);

% Update sort table
for i = 1:length(trode)
    sortTable{i,1} = trode(i).name;
    sortTable{i,2} = num2str(trode(i).fileInds);
    sortTable{i,3} = num2str(trode(i).spikespersec,3);
    sortTable{i,4} = num2str(trode(i).sorted);
    sortTable{i,6} = num2str(trode(i).channels);
end

[SpikesFiles trodeNames] = GetSpikesFiles(handles);
if ~isempty(SpikesFiles)
    try
        currentTrode = GetCurrentTrode(handles);
    catch
        currentTrode = 1;
    end
    if currentTrode == 0
        currentTrode = 1;
    end
    set(handles.SortFilePopUp,'Value',currentTrode);
else
    set(handles.SortFilePopUp,'Value',1);
end
set(handles.SortTable,'Data',sortTable);
% Update trode struct (Make sure calling fcn always updates handles
% and also the expt struct).
handles.expt.sort.trode = trode;
guidata(handles.hExptViewer,handles)

function varargout = GetSpikesFiles(handles)

trode = handles.expt.sort.trode;
SpikesFiles = {};
trodeNames = {};
for i = 1:length(trode)
    if ~isempty(trode(i).spikesfile);
        spikesfile = trode(i).spikesfile;
        [temp spikesfile] = fileparts(spikesfile);
        SpikesFiles{end+1} = spikesfile;
        trodeNames{end+1} = trode(i).name;
    end
end

varargout{1} = SpikesFiles;
varargout{2} = trodeNames;

function currentTrode = GetCurrentTrode(handles)
trodeList = get(handles.SortFilePopUp,'String');
Selection = get(handles.SortFilePopUp,'Value');
if Selection > length(trodeList)
    Selection = length(trodeList);
end
trodeName = trodeList{Selection};
trode = handles.expt.sort.trode;
currentTrode = 0;
for i = 1:length(trode)
    FileMatch = strcmp(trode(i).name,trodeName);
    if FileMatch
        currentTrode = i;
        break
    end
end

function expt = UpdateUnitStruct(expt,spikes,cTrode)

unit = expt.sort.trode(cTrode).unit;

% Determine number of units from spikes file
unitAssigns = unique(spikes.assigns);
numUnits = numel(unitAssigns);

% Update units struct
for i = 1:numUnits
    unit(i).label = spikes.params.display.label_categories{spikes.labels(spikes.labels(:,1)==unitAssigns(i),2)};
    unit(i).assign = unitAssigns(i);
    unit(i).rpv = [];
    unit(i).spikespersec = [];
    unit(i).peakrate = [];
    unit(i).spontaneousrate = [];
    unit(i).numspikes = ComputeNumSpikes(spikes,unitAssigns(i));
    unit(i).bursting = [];
    unit(i).clustertype = [];
    unit(i).priority = [];
    unit(i).channels = expt.sort.trode(cTrode).channels;
    unit(i).maxchannel = [];
    unit(i).waveformtype = [];
    unit(i).spikespersec = [];
    unit(i).peakrate = [];
    unit(i).waveform.amplitude = [];             % Need function that pulls out these paramters from raw data
    unit(i).waveform.width = [];
    unit(i).waveform.peak = [];
    unit(i).waveform.trough = [];
    unit(i).waveform.troughpeakratio = [];
    unit(i).waveform.maxchannel = [];
    unit(i).waveform.waveformtype = [];
    unit(i).waveform.avgwave = ComputeAvgWaveform(spikes,unitAssigns(i));
end

expt.sort.trode(cTrode).unit = unit;

function handles = UpdateUnitTable(handles)
trode = handles.expt.sort.trode;
unitNum = 1;

bSorted = {trode.sorted};
bSorted = strcmp(bSorted,'no');
bSorted = any(~bSorted);
UnitTable = {};
set(handles.numUnitsText,'String','');

if bSorted
    for i = 1:length(trode)  % Loop on trodes
        for j = 1:size(trode(i).unit,2)  % Loop on units
            if ~isempty(trode(i).spikesfile)
                UnitTable{unitNum,2} = num2str(trode(i).unit(j).assign);
                UnitTable{unitNum,2+1} = trode(i).unit(j).label;
                UnitTable{unitNum,3+1} = num2str(trode(i).unit(j).numspikes);
                UnitTable{unitNum,4+1} = num2str(trode(i).unit(j).rpv);      % Refractory period violations
                UnitTable{unitNum,5+1} = num2str(trode(i).unit(j).spikespersec);
                UnitTable{unitNum,6+1} = num2str(trode(i).unit(j).peakrate);
                UnitTable{unitNum,7+1} = trode(i).unit(j).waveform.waveformtype;
                UnitTable{unitNum,8+1} = num2str(trode(i).unit(j).waveform.amplitude);
                UnitTable{unitNum,1} = trode(i).name;
                UnitTable{unitNum,9+1} = num2str(trode(i).unit(j).channels);
                unitNum = unitNum + 1;
            end
        end
    end
    set(handles.numUnitsText,'String',num2str(unitNum));
end
set(handles.UnitTable,'Data',UnitTable);

function AvgWaveform = ComputeAvgWaveform(spikes,UnitIndex)

index = spikes.assigns == UnitIndex;
AvgWaveform = spikes.waveforms(index,:,:);
AvgWaveform = squeeze(mean(AvgWaveform,1));

function numSpikes = ComputeNumSpikes(spikes,UnitIndex)

index = spikes.assigns == UnitIndex;
numSpikes = sum(index);

function spikes = LoadSpikesFile(handles)

% Open spikes file shown in SortFileFileUp
trodeList = get(handles.SortFilePopUp,'String');
Selection = get(handles.SortFilePopUp,'Value');
if Selection > length(trodeList)
    Selection = length(trodeList);
end

trodeNum = trodeList{Selection};
[SpikesFiles trodeNames] = GetSpikesFiles(handles);
if ~isempty(trodeNames)
    for i = 1:length(trodeNames)
        found = strfind(trodeNames{i},trodeNum);
        if found
            load(fullfile(handles.RigDef.Dir.Spikes,SpikesFiles{i}));
            break
        else
            spikes = [];
        end
    end
else
    spikes = [];
end

if ~isempty(spikes)
    spikes = makeNewSpikesFormat(spikes); % backward compatiblity
end

% Output spikes struct to workspace
assignin('base','spikes',spikes);

function unitList = GetUnitList(handles)

unitTable = get(handles.UnitTable,'Data');
trodeStr = {unitTable{:,1}};
asgn = {unitTable{:,2}};
if ~isempty(trodeStr)
    for i = 1:length(trodeStr)
        unitList(i) = {[trodeStr{i} '_' asgn{i}]};
    end
else
    unitList = [];
end

function detectFiles = chooseFilesForSort(FileList)
prompt = {'Enter starting file:','Enter ending file:','Omit files:'};
num_lines = 1;
endfile = num2str(length(FileList));
def = {'1',endfile,''};
answer = inputdlg(prompt,'',num_lines,def); pause(0.05)
% Make file index vector
if ~isempty(answer)
    StartFile = answer{1};
    EndFile = answer{2};
    omitFiles = answer{3};
    StartFile = str2num(StartFile);
    EndFile = str2num(EndFile);
    omitFiles = str2num(omitFiles);
    detectFiles = StartFile:EndFile;
    for i = 1:length(omitFiles)
        k = find(detectFiles == omitFiles(i));
        detectFiles(k) = [];
    end
else
    detectFiles = [];
end




% --- End of subfunctions --- %


% --- Executes when selected cell(s) is changed in SortTable.
function SortTable_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to SortTable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)

a = 1;


% --- Executes on button press in saveTable.
function saveTable_Callback(hObject, eventdata, handles)
RigDef = RigDefs();
expt = evalin('base','expt');
updatedTable = get(handles.DetailsTable,'Data');
expt.info.table = updatedTable;
assignin('base','expt',expt);
SaveExpt_Callback(handles.SaveExpt, [], handles)


function makeExpt_Callback(hObject, eventdata, handles)

makeExptSRO;
handles = initializeExptViewer(handles);


function addTrodeButton_Callback(hObject, eventdata, handles)

expt = handles.expt;
sort = expt.sort;
newTrodeInd = length(sort.trode) + 1;
expt = addTrodeSort(expt,newTrodeInd);
assignin('base','expt',expt)
SaveExpt_Callback(handles.SaveExpt, [], handles);

function handles = UpdateExpt(handles)

handles = LoadExpt(handles);
handles = UpdateSortTable(handles);
handles = UpdateUnitTable(handles);
guidata(handles.hExptViewer,handles);
