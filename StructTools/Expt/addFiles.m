function expt = addFiles(expt)
%
%
%
%

% Created: SRO - 7/15/10


% Set rig defaults
rigdef = RigDefs;

% Define files fields
expt.files.names = [];
expt.files.triggers = [];
expt.files.duration = [];
expt.files.Fs = [];

% Get file names
if ~isempty(expt.name)
    FileList = GetFileNames(expt,rigdef.Dir.Data);
    expt.files.names = FileList;
else
    expt.files.names = [];
end

% Get acquisition parameters
if ~isempty(expt.files.names)
    for i = 1:length(expt.files.names)
        disp('Processing ...')
        disp(expt.files.names{i})
        [Fs,duration,triggers,daqinfo] = GetFsDurationTrig_NIDAQhelper([rigdef.Dir.Data expt.files.names{i}]);
        expt.files.triggers(i) = triggers;
        expt.files.duration(i) = duration;
        expt.files.Fs(i) = Fs;
        expt.files.daqinfo(i) = daqinfo;
    end
    
else
    expt.files.triggers = [];
    expt.files.duration = [];
    expt.files.Fs = [];
    expt.files.daqinfo = [];
end


% --- Subfunctions --- %
function FileList = GetFileNames(expt,DataDir)

% Get list of daq files for experiment in raw data directory
files = dir([DataDir expt.name '_' '*.daq']);
FileList = {files.name}';
if isempty(FileList)
    disp('No daq files found for this experiment name')
else
    % Need to reorder FileList (what's the best way to do this?)
    FilesFound = 0;
    i = 1;
    while(FilesFound < length(FileList))
        file = dir([DataDir expt.name '_' num2str(i) '.daq']);
        if ~isempty(file)
            FilesFound = FilesFound + 1;
            FileList(FilesFound) = {file.name}';
        end
        i = i+1;
        if i == 200
            disp('No daq files found for this experiment name');
        end
    end
    disp('The following daq files were found:')
    disp(FileList)
end
