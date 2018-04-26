function [expt spikes trodeInd] = DetectSpikes(expt,detectFiles,trodeInd)
% function [expt spikes trodeInd] = DetectSpikes(expt,detectFiles,trodeInd)
%
% INPUTS:
%   expt: expt struct
%   detectFiles: A row vector containing indices of files to be sorted together
%   trodeInd (opt): Index trode to be detected.
%
% OUTPUTS:
%   expt: expt struct
%   spikes: spikes struct
%   trodeInd: Index of the trode chosen for detection
%
%   3/16/10 - SRO
%   3/23/10 - BA ADD TDT compatibility
%   4/6/10  - SRO and BA
%   4/12/10 - SRO
%   6/30/10 - SRO
%


if nargin < 3
    chooseTrode = 1; % Flag for opening dialog to choose trode to sort
else
    chooseTrode = 0;
    ok = 1;
    expt.sort.trode(trodeInd).detected = 'no';
end

% Set rig defaults
RigDef = RigDefs;

if chooseTrode
    % Choose which channels to use
    for i = 1:length(expt.sort.trode)
        trodeName = expt.sort.trode(i).name;
        channels = expt.sort.trode(i).channels;
        ListString{i} = [trodeName ':' ' ' '[' num2str(channels) ']'];
    end
    [trodeInd,ok] = listdlg('ListString',ListString,'ListSize',[200 80],...
        'SelectionMode','single','Name','Select channels'); pause(0.05)
end

if ok
    if strcmp('yes',expt.sort.trode(trodeInd).detected)
        % Do you want to replace or append to previous detection?
        bAppend = questdlg(sprintf('Append or replace previous detection on Trode %s?',expt.sort.trode(trodeInd).name),'','Append','Replace','Append');
        pause(0.05)
    else
        % Update detection flag
        expt.sort.trode(trodeInd).detected = 'yes';
        bAppend = 'New';
    end
    
    % Get channels to be used for sorting
    channels = expt.sort.trode(trodeInd).channels;
    fName = getFilename(expt.name);           % BA (TDT has whole path here get only filename)
    trodeName = expt.sort.trode(trodeInd).name;
    chStr = [];
    for i = 1:length(channels)
        temp = num2str(channels(i));
        chStr = [chStr '_' temp];
    end
    fName = [fName '_' trodeName '_Ch' chStr '_S1' '_spikes'];        % TO DO: Note S1 needs to be dependent on expt in order to allow additional spike sorts -- SRO
end

switch bAppend
    case {'Replace','New'}
        % Initialize fileInds
        expt.sort.trode(trodeInd).fileInds = [];
        % Create default spikes struct
        Fs = expt.files.Fs(1);              % Use sampling frequency from first file. This assumes Fs is the same across files.
        
        % Make new default spikes struct
        spikes = ss_default_params_custom(Fs);
        
        % Set default labels
        spikes.params.display.label_categories = RigDef.SS.label_categories ;
        spikes.params.display.label_colors = RigDef.SS.label_colors;
        
        % Get thresholds or set to default threshold ('auto')
        if isempty(expt.sort.manualThresh)                             % sort.manualThresh can be set in DataViewer
            expt.sort.trode(trodeInd).threshtype = 'auto';
            spikes.params.detect_method = 'auto';
        else
            expt.sort.trode(trodeInd).threshtype = 'manual';
            if ~isTDTexpt(expt) % nidaq
                expt.sort.trode(trodeInd).thresh = expt.sort.manualThresh(channels+1);      % Offset by index of 1 because Trigger if Ch1 using nidaq
            else % tdt
                expt.sort.trode(trodeInd).thresh = expt.sort.manualThresh(channels);
            end
            disp('Manually set thresholds will be used for spike detection')
            spikes.params.detect_method = 'manual';
            spikes.params.thresh = expt.sort.trode(trodeInd).thresh';
        end
        
        % Save spikes and expt struct ** Think about why this is here **
        expt.sort.trode(trodeInd).spikesfile = fName;
        spikes.info.spikesfile = expt.sort.trode(trodeInd).spikesfile;
        SaveAssignStructs(expt,spikes,RigDef);
        
    case 'Append'
        % Load spikes file
        spikesDir = RigDef.Dir.Spikes;
        load(fullfile(spikesDir,fName))
        % Remove previously detected files from detectFiles list
        prevDetectFiles = expt.sort.trode(trodeInd).fileInds;
        allDetectFiles = union(prevDetectFiles,detectFiles);
        detectFiles = setdiff(allDetectFiles,prevDetectFiles);
end

% Get list of files (Note: This list includes all files in experiment. The
% file indices are used to identify specific files for spike detection.)
FileList = expt.files.names;

% Loop on detectFiles vector to perform detection (the values in
% detectFiles are indices into the expt.files struct)
for fileInd = detectFiles
    Fs = expt.files.Fs(fileInd);
    Triggers = expt.files.triggers(fileInd);
    duration = expt.files.duration(fileInd);
    
    if isTDTexpt(expt)
        disp('Reading TDT file')
        disp(FileList{fileInd})
        ind = strfind(FileList{fileInd},'\');ind = ind(end);
        if isempty(ind); error('TDT tank and block must both be included'); end
        [STF.tdt.tank STF.tdt.blk] =  loadTDThelper_getTankBlk(FileList{fileInd});
        %             STF.filename = loadTDThelper_makefilename(FileList{fileInd});
        filtparam.dfilter = [NaN,NaN,60 0]; % for other filters (none)
        filtparam.maxlevel =  5;                                        % for wavelet filter
        bNoLoad = 0;                                                    % reload of you can
        
        % Predefine data
        blkpath = [RigDef.Dir.Data  STF.tdt.tank '\' STF.tdt.blk];
        [triggers sweeplength Fs] = loadTDTInfo(blkpath);
        data = nan((sweeplength*Fs+1),triggers,length(channels),'single');
        % Get data
        for i =1 :length(channels) % this is more memory efficient I Think, and if run out of memory in later channels early channesl don't have to recomputed
            data(:,:,i) = preprocessDAQ([],STF,channels(i),filtparam,bNoLoad);
        end
        spikes.preprocess.filter.param = filtparam;
        spikes.preprocess.filter.name = 'wavelet';
        
    else % NIDAQ
        
        % Estimate noise SD using median absolute deviation derived from a
        % random subset of files to sort
        if fileInd == detectFiles(1)
            disp('Computing noise SD...')
            nFiles = min(3,length(detectFiles));
            temp = randperm(length(detectFiles));
            sampFiles = detectFiles(temp(1:nFiles));
            dataTemp = [];
            % KR changed to be consistent with other old, shitty memory
            % machine
%             for j=1:length(channels)
%                 disp(['Reading in ' num2str(j) ' of ' num2str(length(channels)) ' channels']);
%                 dataTemp2=[];
%                 for i=1:length(sampFiles)
%                     disp(['Reading in ' num2str(i) ' of ' num2str(length(sampFiles)) ' files']);
%                     data = daqread([RigDef.Dir.Data FileList{fileInd}],'Channels',channels(j));
%                     dataTemp2=[dataTemp2; data];
%                 end
%                 dataTemp=[dataTemp dataTemp2];
%             end
            for i = 1:length(sampFiles)
                % KR changed to be consistent with my definition of
                % channels in RigDefs.m
                %data = daqread([RigDef.Dir.Data FileList{fileInd}],'Channels',channels+1);
                data = daqread([RigDef.Dir.Data FileList{fileInd}],'Channels',channels);
                dataTemp = [dataTemp; data];
            end
            k = find(isnan(dataTemp(:,1)));
            dataTemp(k,:) = [];
            dataTemp = filtdata(dataTemp,Fs,[],'band',[500 10000],[300 12000]); % Band-pass 0.5-10 kHz
            stds = 1.4785*mad(dataTemp,1)
            clear dataTemp
        end
        
        % Load daq file
        disp('Reading daq file...')
        disp(FileList{fileInd})
        %data = daqread([RigDef.Dir.Data FileList{fileInd}],'Channels',channels+1);    % Recording channels are offset by 1 because trigger is channel 1
        data = daqread([RigDef.Dir.Data FileList{fileInd}],'Channels',channels);    
        
        % Reformat data from daq file organization (All samples x Channnels
        % to Samples x Triggers x Channels)
        data = MakeDataMat(data,Triggers,Fs,duration);
        
        % Band-pass filter data (0.5-10 kHz)
        for i = 1:size(data,3)
            data(:,:,i) = filtdata(data(:,:,i),Fs,[],'band',[500 10000],[300 12000]);
        end
    end
    
    for i = 1:size(data,2)
        if size(data,3) > 1 % If more than 1 channel
            dataTemp{i} = squeeze(permute(data(:,i,:),[2 1 3]));
        else
            dataTemp{i} = data(:,i);
        end
    end
    if ~exist('dataTemp','var')
        continue
    end
    data = dataTemp; clear dataTemp
    
    % Detect. Spikes are appended on each loop
    spikes = ss_detect_custom(data,spikes,stds);                             % Triggers x Samples x Channels
    clear data
    % Add detected file index fileInds
    expt.sort.trode(trodeInd).fileInds(end+1) = fileInd;
    % Set information about detetction
    expt.sort.trode(trodeInd).spikespersec = length(spikes.spiketimes)/sum(spikes.info.detect.dur);
    expt.sort.trode(trodeInd).thresh = spikes.params.thresh;     % Get thresholds actually used
    % Set additional information in spikes struct
    spikes.info.exptfile = expt.info.exptfile;
    spikes.info.trodeInd = trodeInd;
    
    % Save
    SaveAssignStructs(expt,spikes,RigDef);
    
end


% --- Subfunction --- %
function SaveAssignStructs(expt,spikes,RigDef)

% Save spikes and expt
save(fullfile(RigDef.Dir.Spikes,getFilename(spikes.info.spikesfile)),'spikes');
save(fullfile(RigDef.Dir.Expt,getFilename(expt.info.exptfile)),'expt');
% Assign in base
assignin('base','expt',expt);
assignin('base','spikes',spikes);




