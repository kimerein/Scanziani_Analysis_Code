function newExpt=addLEDtoExpt(ledCondDirectory, expt)

newExpt=expt;

FileList=GetFileNames(expt, ledCondDirectory);

% Make sure there are LEDCond files for all daq files in expt
if length(FileList)~=length(expt.files.names)
    disp('There must be LEDCond.mat files for every daq file in expt.');
    return
end

% Order FileList to match order of daq files in expt.files.names
% First get mapping of daq file list to FileList
indsIntoFileList=zeros(length(FileList),1);
for i=1:length(expt.files.names)
    currE=expt.files.names{i};
    for j=1:length(FileList)
        currLEDCondFile=FileList{j};
        % KR - hack, specific to my name format for experiments
        if strcmp(currE(15:end-4),currLEDCondFile(15:end-12))
            indsIntoFileList(i)=j;
            continue
        end
    end
end
% Then reorder FileList
for i=1:length(indsIntoFileList)
    newFileList{i}=FileList{indsIntoFileList(i)};
end
FileList=newFileList;
    
for i=1:length(FileList)
    s=load([ledCondDirectory '/' FileList{i}]);
    ledConds=s.LEDCond(2,:);
    indsIntoSweeps=find(expt.sweeps.fileInd==i);
    if length(ledConds)>length(indsIntoSweeps)
        expt.sweeps.led(indsIntoSweeps)=ledConds(1:length(indsIntoSweeps));
    elseif length(ledConds)<length(indsIntoSweeps)
        expt.sweeps.led(indsIntoSweeps(1:length(ledConds)))=ledConds;
    else
        expt.sweeps.led(indsIntoSweeps)=ledConds;
    end
end

newExpt=expt;
end
    

function FileList=GetFileNames(expt, ledCondDirectory)
% Get list of LEDConds.mat files with LED conditions
% e.g., KR_2011-08-05_80_LEDCond
files=dir([ledCondDirectory '\' expt.name '_*_LEDCond.mat']);
FileList={files.name}';
end