function expt = addRunData(expt)
%
%
%
%
%

% Created: SRO - 4/1/11
% Modified:

% Set rig defaults and channel containing photointerrupter signal
rigdef = RigDefs;
runChn = 18;            
tickDistance = 0.01;      % units, meters 

% Files to process
FileList = expt.files.names;

speed = [];
for fileInd = 1:length(FileList)
    % Set sweep properties
    Fs = expt.files.Fs(fileInd);
    Triggers = expt.files.triggers(fileInd);
    duration = expt.files.duration(fileInd);
    
    % Load data
    data = daqread([rigdef.Dir.Data FileList{fileInd}],'Channels',runChn);
    
    % Reformat data from daq file organization (All samples x Channnels
    % to Samples x Triggers x Channels)
    data = MakeDataMat(data,Triggers,Fs,duration);
    
    % Bandpass filter
    data = filtdata(data,Fs,200,'low');
    data = filtdata(data,Fs,2,'high');
    
    % Detect events
    for n = 1:size(data,2)
        temp = data(:,n);
        thresh = (max(temp) - min(temp))/2;
        peakLoc = peakfinder(temp,thresh,-1);
        
        % Convert peak locations to event times
        t = sampleToTime(peakLoc,Fs);
        run.eventtimes{fileInd,n} = t;
        
        % Compute average running speed within trial
        nTicks = length(peakLoc);
        distance = (nTicks-1)*tickDistance;
        tempSpeed = distance/duration;  
        speed = [speed; tempSpeed];
        
    end
    
end

expt.run.eventtimes = run.eventtimes;
expt.run.speed = speed;

% Add average speed per sweep to sweeps struct
expt.sweeps.runspeed = speed';

% % Save expt
% save(fullfile(RigDef.Dir.Expt,getFilename(expt.info.exptfile)),'expt')
% disp(['Expt saved to' ' ' fullfile(RigDef.Dir.Expt,getFilename(expt.info.exptfile))])
% assignin('base','expt',expt)




