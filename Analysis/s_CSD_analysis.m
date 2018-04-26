function CSD_analysis()
% Script for CSD analysis on 16 channel linear probe

%% Set rig defaults
RigDefaultsScript;

%% Define variables
FileList = PlotObj.FileList;
FilesInBlock = 2;
NumChns = 4; 


%% Define DataBlocks to be filtered, averaged, and analyzed
% Need block name, file numbers, ordered list of channel indices

for i = 1:length(FileList);
    StartFile = i;
    EndFile = StartFile + FilesInBlock - 1;
    DataBlock(i).BlockName = ['f' num2str(StartFile) 'f' num2str(EndFile)];
    if i ~= length(FileList)
        DataBlock(i).FileNames = {FileList{StartFile:EndFile}}';
        DataBlock(i).TriggersInFile = PlotObj.TriggersInFile(StartFile:EndFile)';
    end
end

%% Get data
cd(RigDefaults.DirData);

for i = 1
    FileNames = DataBlock(i).FileNames;
    [Fs duration] = SweepFsDuration(FileNames{1});
    Triggers = sum(DataBlock(i).TriggersInFile);
    data = zeros(Fs*duration*Triggers + Triggers - 1,NumChns);
    DataCounter = 1;
    for f = 1:length(FileNames)
        tic
        tempData = daqread(FileNames{f},'Channels',2:5);
        data(DataCounter:length(tempData),:) = tempData;
        DataCounter = DataCounter + length(tempData)
        data(DataCounter) = nan;
        DataCounter = DataCounter + 1;
        clear tempData;
        disp('load time = '); disp(toc);
    end
    % save mat file?
end

%% Filter between 1 and 300 Hz


% Average across triggers


% Compute second spatial derivative


% Normalize


% Interpolate


