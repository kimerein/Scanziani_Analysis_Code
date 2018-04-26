function otherFig(expt,unitList,fileInd,b,saveTag,figType)
% INPUT
%   expt: Experiment struct
%   unitList: cell list of tags of the form 'trode_assign', e.g 'T2_15'
%   fileInd: Vector of file indices to be included in analysis.
%   b: Flag structure with field b.save, b.print, b.pause, b.close

% Created: 10/28/2011 - KR
% Modified: 10/28/2011 - KR

RigDef=RigDefs();

% First check if we are combining spikes from all user-selected units
% or if we are analyzing each unit individually
if iscell(unitList)
    combineUnits=1;
else
    combineUnits=0;
end

% KR's analysis figures support MUA
% If user has checked "MUA analysis" box in GUI, then take all
% units from this experiment! 
if b.MUAanalysis
    takeAllUnits=1;
else
    takeAllUnits=0;
end

% Then check which fig user wants to make
% if strcmp(expt.analysis.other.cond.type(1),'contrast x LED intensity')
%if strcmp(expt.analysis.other.cond.type(1),'KR_contrast')
if strcmp(figType,'KR_contrast')
    if takeAllUnits==1
        [spikes unitList]=getAllSpikes_fromExpt(expt,unitList,fileInd);
        names='';
        for i=1:length(unitList)
            strcat('T',num2str(unitList{i}),'_');
        end
        unitList=names;
    else
        if combineUnits==0
            % Get tetrode number and unit index from unit tag
            [trodeNum unitInd]=readUnitTag(unitList);
            % Get spikes from trode number and unit index
            spikes=loadvar(fullfile(RigDef.Dir.Spikes,expt.sort.trode(trodeNum).spikesfile));
            spikes.event_channel=spikes.info.detect.event_channel;
            spikes.event_channel=spikes.event_channel';
            spikes=filtspikes(spikes,0,'assigns',unitInd,'fileInd',fileInd);
        else
            [spikes unitList]=concatSpikes_fromSameFiles(expt,unitList,fileInd,[]);
        end
    end
    contrast_X_LEDintensityFig(expt,spikes,unitList,fileInd,b,saveTag);
end

if strcmp(figType,'SRO_orientation')
%     [trodeNum unitInd] = readUnitTag(unitList);
%     label = getUnitLabel(expt,trodeNum,unitInd);
    if combineUnits==1 || takeAllUnits==1
        disp('SRO figures do not support the combination of multiple units.');
        disp('Please choose to analyze units separately.');
        return;
    else
        orientationFig(expt,unitList,fileInd,b,saveTag); 
    end
end
        
if strcmp(figType,'KR_acrossChannelsFR')
    if takeAllUnits==1
        [spikes unitList]=getAllSpikes_fromExpt(expt,unitList,fileInd);
        names='';
        for i=1:length(unitList)
            strcat('T',num2str(unitList{i}),'_');
        end
        unitList=names;
    else
        if combineUnits==0
            % Get tetrode number and unit index from unit tag
            [trodeNum unitInd]=readUnitTag(unitList);
            % Get spikes from trode number and unit index
            spikes=loadvar(fullfile(RigDef.Dir.Spikes,expt.sort.trode(trodeNum).spikesfile));
            spikes.event_channel=spikes.info.detect.event_channel;
            spikes.event_channel=spikes.event_channel';
            spikes=filtspikes(spikes,0,'assigns',unitInd,'fileInd',fileInd);
        else
            [spikes unitList]=concatSpikes_fromSameFiles(expt,unitList,fileInd,[]);
        end
    end
    FR_across_channelsFig(expt,spikes,unitList,fileInd,b,saveTag);
end

if strcmp(figType,'KR_acrossChannelsFR_withoutWindowsAnalysis')
    if takeAllUnits==1
        [spikes unitList]=getAllSpikes_fromExpt(expt,unitList,fileInd);
        names='';
        for i=1:length(unitList)
            strcat('T',num2str(unitList{i}),'_');
        end
        unitList=names;
    else
        if combineUnits==0
            % Get tetrode number and unit index from unit tag
            [trodeNum unitInd]=readUnitTag(unitList);
            % Get spikes from trode number and unit index
            spikes=loadvar(fullfile(RigDef.Dir.Spikes,expt.sort.trode(trodeNum).spikesfile));
            spikes.event_channel=spikes.info.detect.event_channel;
            spikes.event_channel=spikes.event_channel';
            spikes=filtspikes(spikes,0,'assigns',unitInd,'fileInd',fileInd);
        else
            [spikes unitList]=concatSpikes_fromSameFiles(expt,unitList,fileInd,[]);
        end
    end
    FR_acrossChs_woutWindowsAnalysis(expt,spikes,unitList,fileInd,b,saveTag);
end
   
if strcmp(figType,'KR_acrossChannels_multiCountSpikes')
    if takeAllUnits==1
        [spikes unitList]=getAllSpikes_fromExpt(expt,unitList,fileInd);
        names='';
        for i=1:length(unitList)
            strcat('T',num2str(unitList{i}),'_');
        end
        unitList=names;
    else
        if combineUnits==0
            % Get tetrode number and unit index from unit tag
            [trodeNum unitInd]=readUnitTag(unitList);
            % Get spikes from trode number and unit index
            spikes=loadvar(fullfile(RigDef.Dir.Spikes,expt.sort.trode(trodeNum).spikesfile));
            spikes.event_channel=spikes.info.detect.event_channel;
            spikes.event_channel=spikes.event_channel';
            spikes=filtspikes(spikes,0,'assigns',unitInd,'fileInd',fileInd);
        else
            [spikes unitList]=concatSpikes_fromSameFiles(expt,unitList,fileInd,[]);
        end
    end
    spikes=getMultiCountSpikes(spikes);
    FR_acrossChs_multiCountSpikes(expt,spikes,unitList,fileInd,b,saveTag);
end

if strcmp(figType,'KR_basicFiringRateOverTime')
    if takeAllUnits==1
        [spikes unitList]=getAllSpikes_fromExpt(expt,unitList,fileInd);
        names='';
        for i=1:length(unitList)
            strcat('T',num2str(unitList{i}),'_');
        end
        unitList=names;
    else
        if combineUnits==0
            % Get tetrode number and unit index from unit tag
            [trodeNum unitInd]=readUnitTag(unitList);
            % Get spikes from trode number and unit index
            spikes=loadvar(fullfile(RigDef.Dir.Spikes,expt.sort.trode(trodeNum).spikesfile));
            spikes.event_channel=spikes.info.detect.event_channel;
            spikes.event_channel=spikes.event_channel';
            spikes=filtspikes(spikes,0,'assigns',unitInd,'fileInd',fileInd);
        else
            [spikes unitList]=concatSpikes_fromSameFiles(expt,unitList,fileInd,[]);
        end
    end
    basicFiringRate(expt,spikes,unitList,fileInd,b,saveTag);
end
    
if strcmp(figType,'KR_orientation')
%     if takeAllUnits==1
%         [spikes unitList]=getAllSpikes_fromExpt(expt,unitList,fileInd);
%         names='';
%         for i=1:length(unitList)
%             strcat('T',num2str(unitList{i}),'_');
%         end
%         unitList=names;
%     else
        if combineUnits==0
            % Get tetrode number and unit index from unit tag
            [trodeNum unitInd]=readUnitTag(unitList);
            % Get spikes from trode number and unit index
            spikes=loadvar(fullfile(RigDef.Dir.Spikes,expt.sort.trode(trodeNum).spikesfile));
            spikes.event_channel=spikes.info.detect.event_channel;
            spikes.event_channel=spikes.event_channel';
            %spikes=filtspikes(spikes,0,'assigns',unitInd,'fileInd',fileInd);
            spikes=[];
        else
            [spikes unitList]=concatSpikes_fromSameFiles(expt,unitList,fileInd,[]);
        end
%     end
    KR_orientation(expt,unitList,fileInd,b,saveTag,spikes);
end

if strcmp(figType,'KR_basicFR_6layout')
    if takeAllUnits==1
        [spikes unitList]=getAllSpikes_fromExpt(expt,unitList,fileInd);
        names='';
        for i=1:length(unitList)
            strcat('T',num2str(unitList{i}),'_');
        end
        unitList=names;
    else
        if combineUnits==0
            % Get tetrode number and unit index from unit tag
            [trodeNum unitInd]=readUnitTag(unitList);
            % Get spikes from trode number and unit index
            spikes=loadvar(fullfile(RigDef.Dir.Spikes,expt.sort.trode(trodeNum).spikesfile));
            spikes.event_channel=spikes.info.detect.event_channel;
            spikes.event_channel=spikes.event_channel';
            spikes=filtspikes(spikes,0,'assigns',unitInd,'fileInd',fileInd);
        else
            [spikes unitList]=concatSpikes_fromSameFiles(expt,unitList,fileInd,[]);
        end
    end
    basicFR_6layout(expt,spikes,unitList,fileInd,[],b,saveTag);
end

if strcmp(figType,'KR_separateByAllStimuli')
    if takeAllUnits==1
        [spikes unitList]=getAllSpikes_fromExpt(expt,unitList,fileInd);
        names='';
        for i=1:length(unitList)
            strcat('T',num2str(unitList{i}),'_');
        end
        unitList=names;
    else
        if combineUnits==0
            % Get tetrode number and unit index from unit tag
            [trodeNum unitInd]=readUnitTag(unitList);
            % Get spikes from trode number and unit index
            spikes=loadvar(fullfile(RigDef.Dir.Spikes,expt.sort.trode(trodeNum).spikesfile));
            spikes.event_channel=spikes.info.detect.event_channel;
            spikes.event_channel=spikes.event_channel';
            spikes=filtspikes(spikes,0,'assigns',unitInd,'fileInd',fileInd);
        else
            [spikes unitList]=concatSpikes_fromSameFiles(expt,unitList,fileInd,[]);
        end
    end
    separateByAllStimuliFig(expt,spikes,unitList,fileInd,b,saveTag);
end
