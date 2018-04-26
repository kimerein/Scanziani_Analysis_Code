function CSDanalysis()
% Script for CSD analysis on 16 channel linear probe

% Set rig defaults
rigdef = RigDefs;

% temporary
load('C:\Documents and Settings\Shawn\My Documents\MATLAB\Temp variable storage\PlotObj.mat')

% Define variables
FileList = PlotObj.FileList(2:5)
FilesInBlock = length(FileList);
NumChns = 4;


% Define DataBlocks to be filtered, averaged, and analyzed
% Need block name, file numbers, ordered list of channel indices

for i = 1:(length(FileList)-FilesInBlock+1);
    StartFile = i;
    EndFile = StartFile + FilesInBlock - 1;
    DataBlock(i).BlockName = ['f' num2str(StartFile) 'f' num2str(EndFile)];
    DataBlock(i).FileNames = {FileList{StartFile:EndFile}}';
    DataBlock(i).TriggersInFile = PlotObj.TriggersInFile(StartFile:EndFile)';    
end


cd(rigdef.Dir.Data);

for blockInd = 1:length(DataBlock)
    SaveIndex = 1;
    for ChnInd = 2:NumChns:17
        % Get data
        FileNames = DataBlock(blockInd).FileNames;
        [Fs duration] = SweepFsDuration(FileNames{1});
        Triggers = sum(DataBlock(blockInd).TriggersInFile);
        data = zeros(Fs*duration*Triggers + Triggers - 1,NumChns);
        DataCounter = 1;
        for f = 1:length(FileNames)
            tic
            tempData = daqread(FileNames{f},'Channels',ChnInd:ChnInd+NumChns-1);
            data(DataCounter:DataCounter+length(tempData)-1,:) = tempData;
            DataCounter = DataCounter + length(tempData);
            if DataCounter < length(data)
                data(DataCounter) = nan;
                DataCounter = DataCounter + 1;
            end
            clear tempData;
            disp('load time = '); disp(toc);
        end
        
        % Avoid memory error by converting to single
        data = single(data);
        
        % Reformat data and downsample
        data = MakeDataMat(data,Triggers,Fs,duration);
        [data Fs] = DownSamp(data,Fs,8);
        
        % Filter between 1 and 300 Hz
        for i = 1:size(data,3)
            data(:,:,i) = FilterBlock(data(:,:,i),Fs,1,300);
        end
        
        % Average across triggers
        data = mean(data,2);
        data = squeeze(data);   % m = SamplesPerTrigger, n = number of channels
        
        % Temporarily save averaged traces to free up memory
        SaveName = ['TempDataChnInd' num2str(ChnInd)];
        SaveName = fullfile(rigdef.Dir.DataFilt,SaveName);
        SavedFiles{SaveIndex,1} = SaveName
        save(SaveName,'data')
        SaveIndex = SaveIndex + 1;
        clear data
    end
    
    % Assemble N x 16 matrix with average waveform
    DataCounter = 1;
    for i = 1:length(SavedFiles)
        temp = load(SavedFiles{i});
        temp = temp.data;
        Chns = size(temp,2);
        data(:,DataCounter:DataCounter+Chns-1) = temp;
        DataCounter = DataCounter + Chns;
    end
    
    % Reorganize data matrix so top-most channel is first column and bottom-most
    % is last column
    SiteMap = [12 10 14 6 8 16 4 2 1 3 15 7 5 13 9 11];
    data = data';
    data = [data SiteMap'];
    data = sortrows(data,size(data,2));
    data = data(:,1:end-1);
    data = data';
    
    % Site 10 (index3) was defective in this experiment so use average of adjacent sites as approximation
    data(:,3) = mean(data(:,[2 4]),2);
    
    % Bass's function
%     data = single(data);
%     data = data';
%     computeCSD(data(:,1:1500),Fs);
    
    % Compute second spatial derivative (use 2 site spacing as Cris Niell did)
    dataSmooth = zeros(size(data));
    dataSmooth(:,1) = (2*data(:,1) + data(:,2))/3;
    dataSmooth(:,16) = (2*data(:,16) + data(:,15))/3;
    for i = 2:15
        dataSmooth(:,i) = (data(:,i-1) + 2*data(:,i) + data(:,i+1))/4;
    end
    data = dataSmooth;
    clear dataSmooth
    for i = 1:16
        data(:,i) = smooth(data(:,i),17);
    end
    data1 = data(:,1:2:16);
    data2 = data(:,2:2:16);
    data1 = diff(data1,2,2);
    data2 = diff(data2,2,2);
    data = zeros(length(data1),2*size(data1,2));
    DataCounter = 1;
    for i = 1:size(data1,2)
        data(:,DataCounter) = data1(:,i);
        DataCounter = DataCounter + 1;
        data(:,DataCounter) = data2(:,i);
        DataCounter = DataCounter + 1;
    end
    data = -data';  % so sinks are negative
    
    
    % 2D linear interpolation
    [y x] = size(data);
    y = 1:y;
    x = 1:x;
    [xi yi] = meshgrid(1:1:max(x),1:0.05:max(y));
    dataInt = interp2(x,y,data,xi,yi);
    
    % Save
    SaveName = ['CSDblockInd' num2str(blockInd)];
    SaveName = fullfile(rigdef.Dir.DataFilt,SaveName);
    save(SaveName,'dataInt')
    
    
    %     Plot
    figure(1);
    %     subplot(length(DataBlock),1,blockInd);
    imagesc(dataInt);
    drawnow
    clear dataInt
%     pause
end



